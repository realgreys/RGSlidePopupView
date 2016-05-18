//
//  PopupViewController.swift
//  RGSlidePopupView
//
//  Created by realgreys on 2016. 5. 10..
//  Copyright © 2016 realgreys. All rights reserved.
//

import UIKit
import RGSlidePopupView

class PopupViewController: UIViewController {

    @IBAction func onClose(sender: AnyObject) {
        if let slideViewController = parentViewController as? RGSlideViewController {
            slideViewController.togglePopup()
        }
    }
}
