//
//  ViewController.swift
//  InjectableSlideUpPanel
//
//  Created by ali ziwa on 17/12/2018.
//  Copyright © 2018 ali ziwa. All rights reserved.
//

import Slidable

class ViewController: SlidableController {

    override func viewDidLoad() {
        super.viewDidLoad()
        isSlideInteractable = true
        addSlidable(ImplementorController(), forState: .collapsed)
    }
}

