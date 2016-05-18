//
//  RGSlideViewController.swift
//
//  Created by realgreys on 2016. 5. 10..
//  Copyright © 2016 realgreys. All rights reserved.
//

import UIKit

public class RGSlideViewController: UIViewController {
    
    private enum SlideAction {
        case Open
        case Close
    }
    
    private struct PanInfo {
        var action: SlideAction
        var shouldBounce: Bool
        var velocity: CGFloat
    }
    
    private struct PanState {
        static var frameAtStartOfPan: CGRect = .zero
        static var startPointOfPan: CGPoint = .zero
        static var wasOpenAtStartOfPan: Bool = false
        static var wasHiddenAtStartOfPan: Bool = false
    }
    
    private var options: RGSlideOptions!
    private var popupViewController: UIViewController!
    
    private var opacityView: UIView = {
        let view = UIView(frame: .zero)
//        view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.opacity = 0.0
        return view
    }()
    
    private var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.clearColor()
        view.autoresizingMask = UIViewAutoresizing.FlexibleHeight
        return view
    }()
    
    
    // MARK: - lifecycle
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public init(popupViewController: UIViewController, options: RGSlideOptions) {
        super.init(nibName: nil, bundle: nil)
        
        self.options = options
        self.popupViewController = popupViewController
        
        configure()
    }
    
    public convenience init(popupViewController: UIViewController) {
        self.init(popupViewController: popupViewController, options: RGSlideOptions())
    }
    
    override public func viewWillLayoutSubviews() {
        addChildViewController(popupViewController)
        popupViewController.view.frame = containerView.bounds
        containerView.addSubview(popupViewController.view)
        popupViewController.didMoveToParentViewController(self)
    }
    
    // MARK: - layout

    private func configure() {
        
        setupOpacityView()
        layoutOpacityView()
        setupContainerView()
        layoutContainerView()
        
        addGestureHandlers()
    }
    
    private func setupOpacityView() {
        opacityView.backgroundColor = options.opacityViewBackgroundColor
        view.addSubview(opacityView)
    }
    
    private func layoutOpacityView() {
        let viewsDictionary = ["opacityView": opacityView]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[opacityView]|",
                                                                                   options: [],
                                                                                   metrics: nil,
                                                                                   views: viewsDictionary)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[opacityView]|",
                                                                                 options: [],
                                                                                 metrics: nil,
                                                                                 views: viewsDictionary)
        
        NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints)
    }
    
    private func setupContainerView() {
        view.addSubview(containerView)
    }
    
    private func layoutContainerView() {
        var frame = view.bounds
        frame.size.height = options.slideViewHeight
        frame.origin.y = view.bounds.maxY
        containerView.frame = frame
    }
    
    func isPopupOpen() -> Bool {
        return containerView.frame.origin.y == view.bounds.height - options.slideViewHeight
    }
    
    func isPopupHidden() -> Bool {
        return containerView.frame.origin.y >= view.bounds.maxY
    }
    
    func openPopup() {
        setOpenWindowLevel()
        
        popupViewController.beginAppearanceTransition(isPopupHidden(), animated: true)
        openWithVelocity(0.0)
    }
    
    func closePopup() {
        popupViewController.beginAppearanceTransition(isPopupHidden(), animated: true)
        closeWithVelocity(0.0)
        
        setCloseWindowLevel()
    }
    
    private func setOpenWindowLevel() {
        if options.hideStatusBar {
            dispatch_async(dispatch_get_main_queue(), {
                if let window = UIApplication.sharedApplication().keyWindow {
                    window.windowLevel = UIWindowLevelStatusBar + 1
                }
            })
        }
    }
    
    private func setCloseWindowLevel() {
        if options.hideStatusBar {
            dispatch_async(dispatch_get_main_queue(), {
                if let window = UIApplication.sharedApplication().keyWindow {
                    window.windowLevel = UIWindowLevelNormal
                }
            })
        }
    }

    
    private func openWithVelocity(velocity: CGFloat) {
        let yOrigin: CGFloat = containerView.frame.origin.y
        let finalYOrigin: CGFloat = view.bounds.height - options.slideViewHeight
        
        var frame = containerView.frame;
        frame.origin.y = finalYOrigin;
        
        var duration = options.animationDuration
        if velocity != 0.0 {
            duration = Double(fabs(yOrigin - finalYOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        UIView.animateWithDuration(duration,
                                   delay: 0.0,
                                   options: .CurveEaseInOut,
                                   animations: { [unowned self] () -> Void in
                                    self.containerView.frame = frame
                                    self.opacityView.layer.opacity = self.options.contentViewOpacity
        }) { [weak self] (Bool) -> Void in
            if let strongSelf = self {
//                strongSelf.disableContentInteraction()
                strongSelf.popupViewController?.endAppearanceTransition()
            }
        }
    }
    
    private func closeWithVelocity(velocity: CGFloat) {
        let yOrigin: CGFloat = containerView.frame.origin.y
        let finalYOrigin: CGFloat = view.bounds.height
        
        var frame: CGRect = containerView.frame;
        frame.origin.y = finalYOrigin
        
        var duration = options.animationDuration
        if velocity != 0.0 {
            duration = Double(fabs(yOrigin - finalYOrigin) / velocity)
            duration = Double(fmax(0.1, fmin(1.0, duration)))
        }
        
        UIView.animateWithDuration(duration,
                                   delay: 0.0,
                                   options: .CurveEaseInOut,
                                   animations: { [unowned self] () -> Void in
                                    self.containerView.frame = frame
                                    self.opacityView.layer.opacity = 0.0
        }) { [weak self] (Bool) -> Void in
            if let strongSelf = self {
//                strongSelf.enableContentInteraction()
                strongSelf.popupViewController?.endAppearanceTransition()
                strongSelf.dismissViewControllerAnimated(false, completion: nil)
            }
        }
    }
    
    // MARK: - gesture handlers
    
    private func addGestureHandlers() {
        addPanGestureHandlers()
        addTapGestureHandlers()
    }
    
    private func addPanGestureHandlers() {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func addTapGestureHandlers() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(togglePopup))
        opacityView.addGestureRecognizer(gestureRecognizer)
    }
    
//    private func removeGestures() {
//        if panGesture != nil {
//            view.removeGestureRecognizer(panGesture!)
//            panGesture = nil
//        }
//        
//        if tapGesture != nil {
//            view.removeGestureRecognizer(tapGesture!)
//            tapGesture = nil
//        }
//    }
    
    func handlePanGesture(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case UIGestureRecognizerState.Began:
            PanState.frameAtStartOfPan = containerView.frame
            PanState.startPointOfPan = panGesture.locationInView(view)
            PanState.wasOpenAtStartOfPan = isPopupOpen()
            PanState.wasHiddenAtStartOfPan = isPopupHidden()
            
            popupViewController.beginAppearanceTransition(PanState.wasHiddenAtStartOfPan, animated: true)
            setOpenWindowLevel()
            
        case UIGestureRecognizerState.Changed:
            let translation: CGPoint = panGesture.translationInView(panGesture.view!)
            containerView.frame = applyTranslation(translation, toFrame: PanState.frameAtStartOfPan)
            applyOpacity()
            
        case UIGestureRecognizerState.Ended:
            let velocity = panGesture.velocityInView(panGesture.view)
            let panInfo: PanInfo = panResultInfoForVelocity(velocity)
            
            if panInfo.action == .Open {
                if !PanState.wasHiddenAtStartOfPan {
                    popupViewController.beginAppearanceTransition(true, animated: true)
                }
                openWithVelocity(panInfo.velocity)
            } else {
                if PanState.wasHiddenAtStartOfPan {
                    popupViewController.beginAppearanceTransition(false, animated: true)
                }
                closeWithVelocity(panInfo.velocity)
                setCloseWindowLevel()
            }
        default:
            break
        }
        
    }
    
    private func applyTranslation(translation: CGPoint, toFrame: CGRect) -> CGRect {
        var newOrigin: CGFloat = toFrame.origin.y
        newOrigin += translation.y
        
        let minOrigin: CGFloat = view.bounds.height - options.slideViewHeight
        let maxOrigin: CGFloat = view.bounds.height
        var newFrame: CGRect = toFrame
        
        if newOrigin < minOrigin {
            newOrigin = minOrigin
        } else if newOrigin > maxOrigin {
            newOrigin = maxOrigin
        }
        
        newFrame.origin.y = newOrigin
        return newFrame
    }
    
    private func getOpenedRatio() -> CGFloat {
        let height = containerView.frame.size.height
        let currentPosition = containerView.frame.origin.y
        return (CGRectGetHeight(view.bounds) - currentPosition) / height
    }
    
    private func applyOpacity() {
        let openedRatio = Float(getOpenedRatio())
        let opacity = options.contentViewOpacity * openedRatio
        opacityView.layer.opacity = opacity
    }
    
    private func panResultInfoForVelocity(velocity: CGPoint) -> PanInfo {
        
        let thresholdVelocity: CGFloat = -1000.0
        let pointOfNoReturn: CGFloat = CGFloat(floor(CGRectGetHeight(view.bounds)) - options.pointOfNoReturnHeight)
        let topOrigin: CGFloat = containerView.frame.origin.y
        
        var panInfo: PanInfo = PanInfo(action: .Close, shouldBounce: false, velocity: 0.0)
        
        // check noReturn region
        panInfo.action = topOrigin >= pointOfNoReturn ? .Close : .Open;
        
        // check gesture velocity
        if velocity.y <= thresholdVelocity {
            panInfo.action = .Open
            panInfo.velocity = velocity.y
        } else if velocity.y >= (-1.0 * thresholdVelocity) {
            panInfo.action = .Close
            panInfo.velocity = velocity.y
        }
        
        return panInfo
    }
    

    
    // MARK: - public
    
    public func togglePopup() {
        isPopupOpen() ? closePopup() : openPopup()
    }
}
