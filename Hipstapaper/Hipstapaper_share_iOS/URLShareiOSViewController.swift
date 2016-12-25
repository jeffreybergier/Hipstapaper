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
                UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
                    switch self.uiState {
                    case .start:
                        self.modalView?.alpha = 0.0
                        self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height
                        self.messageLabel?.text = "Logging In"
                    case .loggingIn:
                        self.modalView?.alpha = 0.3
                        self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height / 2.5
                        self.messageLabel?.text = "Logging In"
                    case .saving:
                        self.modalView?.alpha = 0.3
                        self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height / 2.5
                        self.messageLabel?.text = "Saving"
                    case .error:
                        self.modalView?.alpha = 0.0
                        self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height / 2.5
                        self.messageLabel?.text = "Error"
                    case .saved:
                        self.modalView?.alpha = 0.0
                        self.containerViewVerticalSpaceConstraint?.constant = -50
                        self.messageLabel?.text = "Saved"
                    }
                    self.view.layoutIfNeeded()
                }, completion: .none)
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
}

