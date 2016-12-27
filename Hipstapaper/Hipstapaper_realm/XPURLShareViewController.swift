//
//  XPlatformURLSharingViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/24/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

enum UIState {
    case start, saving, saved, error
}

#if os(OSX)
    import AppKit
    typealias XPViewController = NSViewController
#else
    import UIKit
    typealias XPViewController = UIViewController
#endif

class XPURLShareViewController: XPViewController {
    
    var uiState = UIState.start
    
    #if os(OSX)
    override func viewDidAppear() {
        super.viewDidAppear()
        self.start()
    }
    #else
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.start()
    }
    #endif
    
    func start() {
        self.uiState = .saving
        
        guard let extensionItem = self.extensionContext?.inputItems.first as? NSExtensionItem else {
            self.uiState = .error
            self.extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0, userInfo: nil))
            return
        }
        
        SerializableURLItem.item(from: extensionItem) { item in
            if let item = item {
                let itemsToSave: [SerializableURLItem]
                if let itemsOnDisk = NSKeyedUnarchiver.unarchiveObject(withFile: SerializableURLItem.archiveURL.path) as? [SerializableURLItem] {
                    itemsToSave = itemsOnDisk + [item]
                } else {
                    // delete the file if it exists and has incorrect data, or else this could fail forever and never get fixed
                    try? FileManager.default.removeItem(at: SerializableURLItem.archiveURL)
                    itemsToSave = [item]
                }
                NSKeyedArchiver.archiveRootObject(itemsToSave, toFile: SerializableURLItem.archiveURL.path)
                self.uiState = .saved
                self.extensionContext?.completeRequest(returningItems: .none, completionHandler: { _ in })
            } else {
                self.uiState = .error
                self.extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0, userInfo: nil))
            }
        }
    }
}
