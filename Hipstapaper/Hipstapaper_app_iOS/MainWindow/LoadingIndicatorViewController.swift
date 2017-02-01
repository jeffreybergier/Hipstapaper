//
//  LoadingIndicatorViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/31/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Common
import RealmSwift
import UIKit

class LoadingIndicatorViewController: UIViewController, RealmControllable {
    
    private enum State {
        case synchronizing, notSynchronizing
    }
    
    private var downloadToken: SyncSession.ProgressNotificationToken?
    private var uploadToken: SyncSession.ProgressNotificationToken?
    
    weak var realmController: RealmController? {
        didSet {
            self.downloadToken?.stop()
            self.uploadToken?.stop()
            
            self.downloadToken = .none
            self.uploadToken = .none
            
            self.uploadToken = self.realmController?.session.addProgressNotification(for: .upload, mode: .reportIndefinitely, block: self.activityClosure)
            self.downloadToken = self.realmController?.session.addProgressNotification(for: .download, mode: .reportIndefinitely, block: self.activityClosure)
        }
    }
    
    @IBOutlet private weak var topConstraint: NSLayoutConstraint?
    @IBOutlet private weak var spinner: UIActivityIndicatorView?
    @IBOutlet private weak var loadingView: UIView? {
        didSet {
            self.loadingView?.layer.masksToBounds = false
            self.loadingView?.layer.shadowOffset = CGSize(width: 0, height: 1)
            self.loadingView?.layer.shadowRadius = 1
            self.loadingView?.layer.shadowOpacity = 0.2
        }
    }
    
    private var timer: Timer?
    
    private var state = State.notSynchronizing {
        didSet {
            guard self.state != oldValue else { return }
            let duration = TimeInterval(0.5)
            let damping = CGFloat(0.5)
            let velocity = CGFloat(3.0)
            switch self.state {
            case .notSynchronizing:
                UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [], animations: {
                    let value = (self.loadingView?.bounds.height ?? 36.5) * -2
                    self.topConstraint?.constant = value
                    self.view.layoutIfNeeded()
                }, completion: { success in
                    self.spinner?.stopAnimating()
                })
                UIView.animate(withDuration: duration * 2) {
                    self.loadingView?.alpha = 0
                }
            case .synchronizing:
                self.spinner?.startAnimating()
                UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: [], animations: {
                    self.topConstraint?.constant = 0
                    self.view.layoutIfNeeded()
                }, completion: .none)
                UIView.animate(withDuration: duration / 3) {
                    self.loadingView?.alpha = 1
                }
            }
        }
    }
    
    private lazy var activityClosure: (SyncSession.Progress) -> Void = { [weak self] progress in
        guard let mySelf = self else { return }
        mySelf.timer?.invalidate()
        mySelf.timer = .none
        mySelf.state = .synchronizing
        mySelf.timer = Timer.scheduledTimer(timeInterval: 0.5, target: mySelf, selector: #selector(mySelf.timerFired(_:)), userInfo: .none, repeats: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.state = .notSynchronizing
    }
    
    @objc private func timerFired(_ timer: Timer?) {
        timer?.invalidate()
        self.timer?.invalidate()
        self.timer = .none
        self.state = .notSynchronizing
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loadingView?.layer.cornerRadius = floor((self.loadingView?.bounds.height ?? 0) / 2)
    }
    
    deinit {
        self.downloadToken?.stop()
        self.uploadToken?.stop()
    }
}
