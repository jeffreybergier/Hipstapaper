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
            
            self.downloadToken = .none
            self.uploadToken = .none
            
            self.uploadToken = self.realmController?.session.addProgressNotification(
                for: .upload,
                mode: .reportIndefinitely,
                block: { [weak self] in self?.synchronizationActivityChanged($0) })
            self.downloadToken = self.realmController?.session.addProgressNotification(
                for: .download,
                mode: .reportIndefinitely,
                block: { [weak self] in self?.synchronizationActivityChanged($0) })
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
        self.setBackgroundColor(Color.iconColor)
        self.configureShadow()
        self.state = .notSynchronizing
    }
    
    #if os(OSX)
    override open func viewDidLayout() {
        super.viewDidLayout()
        self.updatePillShapeOnLoadingView()
    }
    #else
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updatePillShapeOnLoadingView()
    }
    #endif
    
    private func updatePillShapeOnLoadingView() {
        self.loadingView?.xpLayer?.cornerRadius = floor((self.loadingView?.bounds.height ?? 0) / 2)
    }
    
    // MARK: Appearance
    
    #if os(OSX)
    open func setBackgroundColor(_ newValue: NSColor) {
        self.loadingView?.xpLayer?.backgroundColor = newValue.cgColor
    }
    
    private func configureShadow() {
        let shadow = NSShadow()
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        shadow.shadowBlurRadius = 1.0
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.4)
        self.loadingView?.shadow = shadow
    }
    #else
    open func setBackgroundColor(_ newValue: UIColor) {
        self.loadingView?.xpLayer?.backgroundColor = newValue.cgColor
    }
    
    private func configureShadow() {
        self.loadingView?.xpLayer?.masksToBounds = false
        self.loadingView?.xpLayer?.shadowOffset = CGSize(width: 0, height: 1)
        self.loadingView?.xpLayer?.shadowRadius = 1
        self.loadingView?.xpLayer?.shadowOpacity = 0.2
    }
    #endif
    
    // MARK: Handle Changes from Realm
    
    private func synchronizationActivityChanged(_ progress: SyncSession.Progress) {
        self.timer?.invalidate()
        self.timer = .none
        self.state = .synchronizing
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerFired(_:)), userInfo: .none, repeats: false)
    }
    
    @objc private func timerFired(_ timer: Timer?) {
        timer?.invalidate()
        self.timer?.invalidate()
        self.timer = .none
        self.state = .notSynchronizing
    }
    
    // MARK: Animation
    
    #if os(OSX)
    private func animateIn() {
        self.spinner?.startAnimation(self)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = self.duration / 2
            context.allowsImplicitAnimation = true
            self.loadingView?.xpLayer?.opacity = 1
        }, completionHandler: .none)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = self.duration
            context.allowsImplicitAnimation = true
            self.topConstraint?.constant = 12
            self.view.layoutSubtreeIfNeeded()
        }, completionHandler: {
        })
    }
    private func animateOut() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = self.duration * 2
            context.allowsImplicitAnimation = true
            self.loadingView?.xpLayer?.opacity = 0
        }, completionHandler: .none)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = self.duration
            context.allowsImplicitAnimation = true
            self.topConstraint?.constant = -50
            self.view.layoutSubtreeIfNeeded()
        }, completionHandler: {
            self.spinner?.stopAnimation(self)
        })
    }
    #else
    private func animateIn() {
        self.spinner?.startAnimating()
        UIView.animate(withDuration: self.duration * 2, delay: 0.0, usingSpringWithDamping: self.damping, initialSpringVelocity: self.velocity, options: [], animations: {
            self.topConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }, completion: .none)
        UIView.animate(withDuration: self.duration / 2) {
            self.loadingView?.alpha = 1
        }
    }
    
    private func animateOut() {
        UIView.animate(withDuration: self.duration, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.topConstraint?.constant = -70
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.spinner?.stopAnimating()
        })
        UIView.animate(withDuration: duration * 2) {
            self.loadingView?.alpha = 0
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
