//
//  ShareViewController.swift
//  Hipstapaper_share_macOS
//
//  Created by Jeffrey Bergier on 12/1/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence_macOS
import Cocoa

class ShareViewController: NSViewController {

    override var nibName: String? {
        return "ShareViewController"
    }

    override func loadView() {
        super.loadView()
        
        let cloudKit: SingleSourcePersistenceType = CloudKitURLItemSyncingController()
        cloudKit.reloadData() { result in
            print(result)
            print(cloudKit.ids)
        }
        let realm: SingleSourcePersistenceType = RealmURLItemSyncingController()
        realm.reloadData() { result in
            print(result)
            print(realm.ids)
        }
    
        // Insert code here to customize the view
        let item = self.extensionContext!.inputItems[0] as! NSExtensionItem
        if let attachments = item.attachments {
            NSLog("Attachments = %@", attachments as NSArray)
        } else {
            NSLog("No Attachments")
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
