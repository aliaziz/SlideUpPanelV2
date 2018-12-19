//
//  SlidableController.swift
//  InjectableSlideUpPanel
//
//  Created by ali ziwa on 18/12/2018.
//  Copyright © 2018 ali ziwa. All rights reserved.
//

import UIKit

public enum SlidableState: Int {
    typealias divisor = CGFloat
    
    case collapsed
    case expanded
    
    func getY(view: UIView) -> divisor {
        switch self {
        case .collapsed:
            return view.frame.height / 2
        case .expanded:
            return view.frame.minY + 40
        }
    }
}

open class SlidableController: UIViewController {
    private(set) var slidingController: UIViewController!
    private var animator: UIViewPropertyAnimator!
    private var slideState: SlidableState!
    open var isSlideInteractable: Bool = false
    
    open func addSlidable(_ childController: UIViewController, forState: SlidableState) {
        initialiseAnimation()
        slidingController = childController
        addChild(childController)
        childController.view.frame = view.frame.offsetBy(dx: 0.0, dy: forState.getY(view: view))
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
        
        //add PanGesture
        childController.view.addGestureRecognizer(slidePanGesture())
    }
    
    private func initialiseAnimation() {
        animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut)
        animator.startAnimation()
    }
    
    private func slidePanGesture() -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer(target: self, action: #selector(handleSlideGesture(recogniser:)))
    }
    
    @objc private func handleSlideGesture(recogniser: UIPanGestureRecognizer) {
        slidableTransitionHandler(recogniser: recogniser)
    }
    
    private func slidableTransitionHandler(recogniser: UIPanGestureRecognizer) {
        let slidableView = self.view
        let yTranslation = recogniser.translation(in: slidableView).y
        let originalY = slidingController.view.frame.origin.y
        let newTransition = originalY + yTranslation
        
        if isSlideInteractable {
            interactableSlide(state: recogniser.state, newTransition: newTransition)
        } else {
            if yTranslation > 0 {
                slideState = .collapsed
            } else if yTranslation < 0 {
                slideState = .expanded
            }
            nonInteractableSlide(recogniserState: recogniser.state, slideState: slideState)
        }
        recogniser.setTranslation(.zero, in: slidableView)
    }
    
    /// Used when slide panel interactions are enabled. One can drag and interact with the panel
    ///
    /// - Parameters:
    ///   - state: recogniser state
    ///   - newTransition: new y position
    private func interactableSlide(state: UIPanGestureRecognizer.State, newTransition: CGFloat) {
        switch state {
        case .changed:
            animator.addAnimations {[unowned self] in
                self.setSlidableYPosition(newTransition)
            }
        case .ended:
            animator.addAnimations {[unowned self] in
                self.moveToState(with: newTransition)
            }
        default: break
        }
        animator.startAnimation()
    }
    
    /// Used when slide panel interaction is disabled, to only listen to the final transition of the panel
    ///
    /// - Parameters:
    ///   - recogniserState: state of pan gesture interaction
    ///   - slideState: state to be at on interaction
    private func nonInteractableSlide(recogniserState: UIPanGestureRecognizer.State, slideState: SlidableState) {
        switch recogniserState {
        case .began:
            animator.addAnimations {[unowned self] in
                self.updateSlidable(slideState)
            }
            animator.pauseAnimation()
        case .ended:
            animator.continueAnimation(withTimingParameters: UICubicTimingParameters(animationCurve: .easeInOut), durationFactor: 0)
        default: break
        }
    }
    
    /// Moves the slide panel to a new state, depending on the given translation. This is used only when `isSlideInteractables`
    /// is enabled.
    ///
    /// - Parameter translation: the new translation of the slide panel.
    private func moveToState(with translation: CGFloat) {
        let yCollapsed = self.view.frame.midY
        let yExpanded: CGFloat = 40.0
        
        if (translation - yExpanded) < (yCollapsed - translation) {
            updateSlidable(.expanded)
        } else {
            updateSlidable(.collapsed)
        }
    }
    
    /// Uses slidable state to determine where the slidePanel should be when interaction ends
    ///
    /// - Parameter state:
    private func updateSlidable(_ state: SlidableState) {
        setSlidableYPosition(state.getY(view: self.view))
    }
    
    /// Updates y position of slidable View
    ///
    /// - Parameter value: new Y value.
    private func setSlidableYPosition(_ value: CGFloat) {
        slidingController.view.frame.origin.y = value
    }
}
