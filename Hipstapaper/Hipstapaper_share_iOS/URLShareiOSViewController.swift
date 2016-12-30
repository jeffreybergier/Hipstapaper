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
            DispatchQueue.main.async {
                switch self.uiState {
                case .start:
                    self.messageLabel?.text = "Saving  📱"
                case .saving:
                    self.messageLabel?.text = "Saving  📱"
                case .error:
                    self.messageLabel?.text = "Error  😭"
                case .saved:
                    self.messageLabel?.text = "Saved  ☺️"
                }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height
        self.view.layoutIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.modalView?.alpha = 0.3
            self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height / 2.5
            self.view.layoutIfNeeded()
        }, completion: { success in
            Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.waitingTimerFired(_:)), userInfo: .none, repeats: true)
        })
    }
    
    @objc private func waitingTimerFired(_ timer: Timer?) {
        let uiState = self.uiState
        guard uiState == .saved || uiState == .error else { return }
        
        timer?.invalidate()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
            
            self.modalView?.alpha = 0.0
            self.containerViewVerticalSpaceConstraint?.constant = -50
            self.view.layoutIfNeeded()
            
        }, completion: { sucess in
            
            if case .saved = uiState {
                self.extensionContext?.completeRequest(returningItems: .none, completionHandler: { _ in })
            } else if case .error = uiState {
                self.extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0, userInfo: nil))
            }
            
        })
    }
}

