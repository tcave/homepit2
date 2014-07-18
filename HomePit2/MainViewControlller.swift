//
//  MainViewControlller.swift
//  HomePit2
//
//  Created by John Grosen on 6/29/14.
//  Copyright (c) 2014 John Grosen. All rights reserved.
//

import UIKit

class MainViewController: UISplitViewController {
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            return Int(UIInterfaceOrientationMask.Landscape.toRaw())
        } else {
            return Int(UIInterfaceOrientationMask.Portrait.toRaw())
        }
    }
}
