//
//  URLItemSavingShareViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/21/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

class URLShareMacViewController: XPURLShareViewController {
    
    override var uiState: UIState {
        didSet {
            DispatchQueue.main.async {
                switch self.uiState {
                case .start:
                    self.spinner?.startAnimation(self)
                    self.messageLabel?.stringValue = "Saving"
                case .saving:
                    self.spinner?.startAnimation(self)
                    self.messageLabel?.stringValue = "Saving"
                case .error:
                    self.spinner?.stopAnimation(self)
                    self.messageLabel?.stringValue = "Error"
                case .saved:
                    self.spinner?.stopAnimation(self)
                    self.messageLabel?.stringValue = "Saved"
                }
            }
        }
    }
    
    @IBOutlet private var messageLabel: NSTextField?
    @IBOutlet private var spinner: NSProgressIndicator?
    
}
