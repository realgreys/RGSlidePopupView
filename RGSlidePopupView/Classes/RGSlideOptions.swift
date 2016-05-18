//
//  RGSlideOptions.swift
//
//  Created by realgreys on 2016. 5. 10..
//  Copyright © 2016 realgreys. All rights reserved.
//

import UIKit

public struct RGSlideOptions {
    public var slideViewHeight: CGFloat = 250
    public var contentViewOpacity: Float = 0.5
    public var animationDuration: NSTimeInterval = 0.3
    public var opacityViewBackgroundColor: UIColor = UIColor.blackColor()
    public var pointOfNoReturnHeight: CGFloat = 44.0
    
    internal var hideStatusBar: Bool = false
    
    public init() {}
}