//
//  ShareViewController.swift
//  Hipstapaper_share_macOS
//
//  Created by Jeffrey Bergier on 12/1/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence_macOS
import AppKit

class URLItemSavingShareViewController: NSViewController {

    @IBOutlet private weak var messageLabel: NSTextField?
    @IBOutlet private weak var dismissButton: NSButton?
    
    override var nibName: String? {
        return "URLItemSavingShareViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.extensionContext?.jsb_inputItems.mapURLs() { results in
            DispatchQueue.main.async {
                switch results {
                case .success(let urls):
                    if let url = urls.first {
                        self.found(url: url)
                    } else {
                        self.foundNoItems()
                    }
                case .error(let errors):
                    NSLog("Error Getting URLs: \(errors)")
                    self.foundNoItems()
                }
            }
        }
    }
    
    private func foundNoItems() {
        self.messageLabel?.stringValue = "No Web Site Found to Save"
    }
    
    private func found(url: URL) {
        self.dismissButton?.isHidden = true
        self.messageLabel?.stringValue = "Saving web site..."
        let persistence: DoubleSourcePersistenceType = CombinedURLItemSyncingController()
        persistence.createItem(withID: .none, quickResult: .none) { createResult in
            switch createResult {
            case .success(var newItem):
                newItem.urlString  = url.absoluteString
                persistence.update(item: newItem, quickResult: .none) { updateResult in
                    DispatchQueue.main.async {
                        switch updateResult {
                        case .success:
                            self.extensionContext!.completeRequest(returningItems: [])
                        case .error(let error):
                            self.dismissButton?.isHidden = false
                            self.messageLabel?.stringValue = "Error Saving URL :("
                            NSLog("Error Updating URL: \(error)")
                        }
                    }
                }
            case .error(let error):
                DispatchQueue.main.async {
                    self.dismissButton?.isHidden = false
                    self.messageLabel?.stringValue = "Error Saving URL :("
                    NSLog("Error Creating URL: \(error)")
                }
            }
        }
        
    }

    @IBAction func send(_ sender: AnyObject?) {
        let outputItem = NSExtensionItem()
        // Complete implementation by setting the appropriate value on the output item
    
        let outputItems = [outputItem]
        self.extensionContext!.completeRequest(returningItems: outputItems, completionHandler: nil)
}

    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        self.extensionContext!.cancelRequest(withError: cancelError)
    }

}
