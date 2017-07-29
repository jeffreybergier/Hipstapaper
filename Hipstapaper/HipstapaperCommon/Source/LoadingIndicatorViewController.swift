//
//  LoadingIndicatorViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/31/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
#if os(OSX)
    import AppKit
#else
    import UIKit
#endif

open class LoadingIndicatorViewController: XPViewController, RealmControllable {
    
    // MARK: Custom Type
    
    private enum State {
        case synchronizing, notSynchronizing
    }
    
    // MARK: Animation Constants
    
    private let duration = TimeInterval(0.2)
    private let damping = CGFloat(0.5)
    private let velocity = CGFloat(3.0)
    
    // MARK: Realm Controller
    
    public weak var realmController: RealmController? {
        didSet {
            self.state = .notSynchronizing
            
            self.downloadToken?.stop()
            self.uploadToken?.stop()
            
            self.downloadToken = nil
            self.uploadToken = nil
            
            guard self.allowedToAnimate else { return }
            
            self.uploadToken = self.realmController?.session?.addProgressNotification(for: .upload, mode: .reportIndefinitely)
            { [weak self] progress in
                DispatchQueue.main.async(execute: { self?.synchronizationActivityChanged(progress) })
            }
            self.downloadToken = self.realmController?.session?.addProgressNotification(for: .download, mode: .reportIndefinitely)
            { [weak self] progress in
                DispatchQueue.main.async(execute: { self?.synchronizationActivityChanged(progress) })
            }
        }
    }
    
    // MARK: Internal State
    
    // this property stops views from animating before we have appeared on the screen
    // it also stops the realm controller from getting updates when we're not allowed to animate.
    private var allowedToAnimate = false {
        didSet {
            guard self.allowedToAnimate != oldValue else { return }
            // when this is updated, trigger the didSet on realmController
            let realmController = self.realmController
            self.realmController = realmController
        }
    }
    
    // MARK: Outlets
    
    @IBOutlet private weak var topConstraint: NSLayoutConstraint?
    @IBOutlet private weak var spinner: XPActivityIndicatorView?
    @IBOutlet private weak var loadingView: XPView?
    
    // MARK: Synchronization State
    
    private var timer: Timer?
    
    private var state = State.synchronizing {
        didSet {
            guard self.state != oldValue else { return }
            switch self.state {
            case .notSynchronizing:
                self.animateOut()
            case .synchronizing:
                self.animateIn()
            }
        }
    }
    
    // MARK: View Controller Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.configureShadow() // configures the shadow on iOS
        self.setBackgroundColor(Color.iconColor)
        self.state = .notSynchronizing
    }
    
    #if os(OSX)
    open override func viewDidAppear() {
        super.viewDidAppear()
        self.loadingView?.layer?.opacity = 0 // set the alpha of the loading view to 0 until it starts animating, then the animation takes over alpha
        self.allowedToAnimate = true
    }
    override open func viewDidLayout() {
        super.viewDidLayout()
        
        // OSX is really finicky with this shadow. I can't find a good hook in point that only happens once
        // I tried viewDidLoad, viewDidAppear, viewDidMoveToWindow. None of them reliably created a shadow all the time
        self.configureShadow()
        
        // update the rounded rect of the pill shape
        self.updatePillShapeOnLoadingView()
    }
    #else
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.allowedToAnimate = true
    }
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        // update the rounded rect of the pill shape
        self.updatePillShapeOnLoadingView()
    }
    #endif
    
    private func updatePillShapeOnLoadingView() {
        self.loadingView?.xpLayer?.cornerRadius = floor((self.loadingView?.bounds.height ?? 0) / 2)
    }
    
    // MARK: Appearance
    
    private func configureShadow() {
        let upsidedownMultiplier = (self.loadingView?.isFlipped ?? true) ? 1 : -1
        self.loadingView?.xpLayer?.masksToBounds = false
        self.loadingView?.xpLayer?.shadowOffset = CGSize(width: 0, height: 1 * upsidedownMultiplier)
        self.loadingView?.xpLayer?.shadowRadius = 1
        self.loadingView?.xpLayer?.shadowOpacity = 0.2
    }
    
    #if os(OSX)
    open func setBackgroundColor(_ newValue: NSColor) {
        self.loadingView?.xpLayer?.backgroundColor = newValue.cgColor
    }
    #else
    open func setBackgroundColor(_ newValue: UIColor) {
        self.loadingView?.xpLayer?.backgroundColor = newValue.cgColor
    }
    #endif
    
    // MARK: Handle Changes from Realm
    
    private func synchronizationActivityChanged(_ progress: SyncSession.Progress) {
        self.timer?.invalidate()
        self.timer = nil
        self.state = .synchronizing
        self.timer = Timer.scheduledTimer(timeInterval: self.duration * 3, target: self, selector: #selector(self.timerFired(_:)), userInfo: nil, repeats: false)
    }
    
    @objc private func timerFired(_ timer: Timer?) {
        timer?.invalidate()
        self.timer?.invalidate()
        self.timer = nil
        self.state = .notSynchronizing
    }
    
    // MARK: Animation
    
    #if os(OSX)
    private func animateIn() {
        // 1) Start the spinner animation immediately
        // 2) Animate the Opacity in
            // Quickly with a linear curve (so its fully opaque before it comes out of the nav/toolbar
        // 3) (Simultaneously) Animate in the loading view
            // Would like a spring curve, but now its easeIn
        
        self.spinner?.startAnimation(self)
        let opacityFinalState: (NSAnimationContext?) -> Void = { context in
            context?.duration = self.duration / 3
            context?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            context?.allowsImplicitAnimation = true
            self.loadingView?.xpLayer?.opacity = 1
        }
        let locationFinalState: (NSAnimationContext?) -> Void = { context in
            context?.duration = self.duration
            context?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            context?.allowsImplicitAnimation = true
            self.topConstraint?.constant = 12
            self.view.layoutSubtreeIfNeeded()
        }
        
        if self.allowedToAnimate {
            NSAnimationContext.runAnimationGroup(opacityFinalState, completionHandler: nil)
            NSAnimationContext.runAnimationGroup(locationFinalState, completionHandler: nil)

        } else {
            // if not allowed to animate (view has not appeared once)
            // then just move everything without animating
            opacityFinalState(nil)
            locationFinalState(nil)
        }
    }
    private func animateOut() {
        // 1) Animate the Opacity out
            // Very slowly with a linear curve (so it doesn't disappear until its under the nav/toolbar)
        // 2) (Simultaneously) Animate out the loading view
            // With a curveEaseOut because we can't see it finish the animation
        // 3) After thats done, stop the spinner
        
        let opacityFinalState: (NSAnimationContext?) -> Void = { context in
            context?.duration = self.duration * 3
            context?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            context?.allowsImplicitAnimation = true
            self.loadingView?.xpLayer?.opacity = 0
        }
        let locationFinalState: (NSAnimationContext?) -> Void = { context in
            context?.duration = self.duration
            context?.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            context?.allowsImplicitAnimation = true
            self.topConstraint?.constant = -50
            self.view.layoutSubtreeIfNeeded()
        }
        let completionState: () -> Void = {
            self.spinner?.stopAnimation(self)
        }
        
        if self.allowedToAnimate {
            NSAnimationContext.runAnimationGroup(opacityFinalState, completionHandler: nil)
            NSAnimationContext.runAnimationGroup(locationFinalState, completionHandler: completionState)
        } else {
            opacityFinalState(nil)
            locationFinalState(nil)
            completionState()
        }
    }
    #else
    private func animateIn() {
        // 1) Start the spinner animation immediately
        // 2) Animate the Opacity in
            // Quickly with a linear curve (so its fully opaque before it comes out of the nav/toolbar
        // 3) (Simultaneously) Animate in the loading view
            // Would like a spring curve, but now its easeInOut
        
        self.spinner?.startAnimating()
        let opacityFinalState: () -> Void = {
            self.loadingView?.alpha = 1
        }
        let locationFinalState: () -> Void = {
            self.topConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
        
        if self.allowedToAnimate {
            UIView.animate(withDuration: self.duration / 3,
                           delay: 0.0,
                           options: [.curveLinear],
                           animations: opacityFinalState,
                           completion: nil)
            UIView.animate(withDuration: self.duration * 2,
                           delay: 0.0,
                           usingSpringWithDamping: self.damping,
                           initialSpringVelocity: self.velocity,
                           options: [],
                           animations: locationFinalState,
                           completion: nil)
        } else {
            // if not allowed to animate (view has not appeared once)
            // then just move everything without animating
            opacityFinalState()
            locationFinalState()
        }
    }
    private func animateOut() {
        // 1) Animate the Opacity out
            // Very slowly with a linear curve (so it doesn't disappear until its under the nav/toolbar)
        // 2) (Simultaneously) Animate out the loading view
            // With a curveEaseOut because we can't see it finish the animation
        // 3) After thats done, stop the spinner
        
        let opacityFinalState: () -> Void = {
            self.loadingView?.alpha = 0
        }
        let locationFinalState: () -> Void = {
            self.topConstraint?.constant = -70
            self.view.layoutIfNeeded()
        }
        let completionState: (Bool) -> Void = { _ in
            self.spinner?.stopAnimating()
        }
        
        if self.allowedToAnimate {
            UIView.animate(withDuration: self.duration * 3,
                           delay: 0.0,
                           options: [.curveLinear],
                           animations: opacityFinalState,
                           completion: nil)
            UIView.animate(withDuration: self.duration,
                           delay: 0.0,
                           options: [.curveEaseIn],
                           animations: locationFinalState,
                           completion: completionState)
        } else {
            // if not allowed to animate (view has not appeared once)
            // then just move everything without animating
            opacityFinalState()
            locationFinalState()
            completionState(false)
        }
    }
    #endif
    
    // MARK: Handle Going Away
    
    private var downloadToken: SyncSession.ProgressNotificationToken?
    private var uploadToken: SyncSession.ProgressNotificationToken?
    
    deinit {
        self.downloadToken?.stop()
        self.uploadToken?.stop()
    }
}
