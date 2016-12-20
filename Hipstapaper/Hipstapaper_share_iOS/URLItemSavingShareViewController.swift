//
//  URLItemSavingShareViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import UIKit

@objc(URLItemSavingShareViewController)
class URLItemSavingShareViewController: UIViewController {
    
    private enum UIState {
        case start, loggingIn, saving, saved, error
    }
    
    private var uiState = UIState.start {
        didSet {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
                    switch self.uiState {
                    case .start:
                        self.modalView?.alpha = 0.0
                        self.containerViewVerticalSpaceConstraint?.constant = UIScreen.main.bounds.height
                        self.messageLabel?.text = "Logging In"
                    case .loggingIn:
                        self.modalView?.alpha = 0.5
                        self.containerViewVerticalSpaceConstraint?.constant = 250
                        self.messageLabel?.text = "Logging In"
                    case .saving:
                        self.modalView?.alpha = 0.5
                        self.containerViewVerticalSpaceConstraint?.constant = 250
                        self.messageLabel?.text = "Saving"
                    case .error:
                        self.modalView?.alpha = 0.0
                        self.containerViewVerticalSpaceConstraint?.constant = 250
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.uiState = .loggingIn
        
        RealmConfig.configure() {
            self.uiState = .saving
            
            guard let extensionItem = self.extensionContext?.inputItems.first as? NSExtensionItem else {
                self.uiState = .error
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.extensionContext?.cancelRequest(withError: NSError())
                }
                return
            }
            
            InterimURLObject.interimURL(from: extensionItem) { interimURL in
                guard let interimURL = interimURL else {
                    self.uiState = .error
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.extensionContext?.cancelRequest(withError: NSError())
                    }
                    return
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let realm = try! Realm()
                    realm.beginWrite()
                    let newURLItem = URLItem()
                    newURLItem.urlString = interimURL.urlString ?? newURLItem.urlString
                    newURLItem.title = (interimURL.title ?? interimURL.urlString) ?? newURLItem.title
                    newURLItem.image = interimURL.image
                    realm.add(newURLItem)
                    try! realm.commitWrite()
                    self.uiState = .saved
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7) {
                        self.extensionContext?.completeRequest(returningItems: .none, completionHandler: { _ in })
                    }
                    
                }
            }
        }
    }
    
    @IBAction private func cancel(_ sender: NSObject?) {
        
    }
}

extension URLItemSavingShareViewController {
    
  
}

