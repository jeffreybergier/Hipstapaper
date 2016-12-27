//
//  URLItemSavingShareViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

class URLShareiOSViewController: XPURLShareViewController {
    
    override var uiState: UIState {
        didSet {
            if self.waitingTimer == nil {
                self.waitingTimerFired(.none)
                self.waitingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.waitingTimerFired(_:)), userInfo: .none, repeats: false)
            }
        }
    }
    
    @IBOutlet private var containerViewVerticalSpaceConstraint: NSLayoutConstraint?
    @IBOutlet private var messageLabel: UILabel?
    @IBOutlet private var modalView: UIView?
    @IBOutlet private var containerView: UIView? {
        didSet {
            self.containerView?.layer.shadowColor = UIColor.black.cgColor
            self.containerView?.layer.shadowOffset = CGSize(width: 2, height: 3)
            self.containerView?.layer.shadowOpacity = 0.4
            self.containerView?.layer.cornerRadius = 5
        }
    }
    
    private var waitingTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height
        self.view.layoutIfNeeded()
    }
    
    @objc private func waitingTimerFired(_ timer: Timer?) {
        timer?.invalidate()
        self.waitingTimer?.invalidate()
        self.waitingTimer = .none
        let uiState = self.uiState
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
                switch uiState {
                case .start:
                    self.modalView?.alpha = 0.0
                    self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height
                    self.messageLabel?.text = "Saving  📱"
                case .saving:
                    self.modalView?.alpha = 0.3
                    self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height / 2.5
                    self.messageLabel?.text = "Saving  📱"
                case .error:
                    self.modalView?.alpha = 0.0
                    self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height / 2.5
                    self.messageLabel?.text = "Error  😭"
                case .saved:
                    self.modalView?.alpha = 0.0
                    self.containerViewVerticalSpaceConstraint?.constant = -50
                    self.messageLabel?.text = "Saved  ☺️"
                }
                self.view.layoutIfNeeded()
            }, completion: { success in
                switch uiState {
                case .saved:
                    self.extensionContext?.completeRequest(returningItems: .none, completionHandler: { _ in })
                case .error:
                    self.extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0, userInfo: nil))
                default:
                    break
                }
            })
        }
    }
}

