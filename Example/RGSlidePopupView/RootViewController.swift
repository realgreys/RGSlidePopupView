//
//  RootViewController.swift
//  RGSlidePopupView
//
//  Created by realgreys on 2016. 5. 10..
//  Copyright © 2016 realgreys. All rights reserved.
//

import UIKit
import RGSlidePopupView

class RootViewController: UITableViewController {
    
    var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = NSDateFormatter()
        data = dateFormatter.monthSymbols
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let popupViewController = storyboard?.instantiateViewControllerWithIdentifier("PopupViewController") {
        var slideViewOptions = RGSlideOptions()
        slideViewOptions.slideViewHeight = 300.0
        
        let slideViewController = RGSlideViewController(popupViewController: popupViewController, options: slideViewOptions)
        slideViewController.modalPresentationStyle = .OverCurrentContext
        presentViewController(slideViewController, animated: false, completion: { slideViewController.togglePopup() })
        }
        
    }

}
