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
                    self.messageLabel?.stringValue = "Saving 💻"
                case .saving:
                    self.spinner?.startAnimation(self)
                    self.messageLabel?.stringValue = "Saving 💻"
                case .error:
                    self.spinner?.startAnimation(self)
                    self.messageLabel?.stringValue = "Error  😭"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0, userInfo: nil))
                    }
                case .saved:
                    self.spinner?.startAnimation(self)
                    self.messageLabel?.stringValue = "Saved  ☺️"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.extensionContext?.completeRequest(returningItems: .none, completionHandler: { _ in })
                    }
                }
            }
        }
    }
    
    
    @IBOutlet private var messageLabel: NSTextField?
    @IBOutlet private var spinner: NSProgressIndicator?

    
}
