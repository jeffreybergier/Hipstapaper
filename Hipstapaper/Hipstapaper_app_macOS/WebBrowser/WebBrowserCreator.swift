//
//  URLItemWebViewWindowControllerLazyLoader.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/22/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Common
import AppKit

class WebBrowserCreator: NSObject {
    
    // MARK: Internal State
    
    // internal state to strongly reference windows
    private var openWindowsControllers: [URLItem.UIIdentifier : WebBrowserWindowController] = [:]
    
    // MARK: Public API
    
    // Reference to the URLListViewController that owns this window loader
    weak var windowControllerDelegate: RealmControllable?
    
    // lazy loading interface
    subscript(identifier: URLItem.UIIdentifier) -> WebBrowserWindowController! {
        get {
            let wc: WebBrowserWindowController
            if let foundWC = self.openWindowsControllers[identifier] {
                // look for an existing window
                wc = foundWC
            } else {
                // create a window if one doesn't exist
                let newWC = type(of: self).windowController(for: identifier)
                wc = newWC
                self.openWindowsControllers[identifier] = newWC
            }
            // be told when the window closes so we can release it
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.itemWindowWillClose(_:)),
                                                   name: .NSWindowWillClose,
                                                   object: wc.window!)
            // configure the window delegate
            // this can't be done when the window is created because its a static function
            wc.delegate = self.windowControllerDelegate
            return wc
        }
        set {
            // configure the window delegate
            // this can't be done when the window is created because its a static function
            newValue?.delegate = self.windowControllerDelegate
            self.openWindowsControllers[identifier] = newValue
        }
    }

}

extension WebBrowserCreator /*NSWindowDelegate*/ {
    
    // MARK: Handle Child Window Closing to Remove from OpenItemWindows Property and from Memory
    
    @objc fileprivate func itemWindowWillClose(_ notification: NSNotification) {
        guard
            let window = notification.object as? NSWindow,
            let itemWindowController = window.windowController as? WebBrowserWindowController,
            let item = itemWindowController.itemID
        else { return }
        
        NotificationCenter.default.removeObserver(self, name: .NSWindowWillClose, object: window)
        self[item] = nil
    }
}

extension WebBrowserCreator: NSWindowRestoration {
    
    // MARK: State Restoration
    
    static func restoreWindow(withIdentifier identifier: String, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Swift.Void) {
        // restore the needed state
        guard
            let appDelegate = NSApp.delegate as? AppDelegate,
            let itemUUID = state.decodeObject(forKey: WebBrowserWindowController.StateRestorationConstants.kURLItemUUID) as? String,
            let itemURLString = state.decodeObject(forKey: WebBrowserWindowController.StateRestorationConstants.kURLItemURLString) as? String,
            let itemArchived = state.decodeObject(forKey: WebBrowserWindowController.StateRestorationConstants.kURLItemArchived) as? NSNumber
        else { completionHandler(nil, nil); return; }
        
        // create the window controller
        let itemID = URLItem.UIIdentifier(uuid: itemUUID, urlString: itemURLString, archived: itemArchived.boolValue)
        let wc = self.windowController(for: itemID) // the state should be restored on its own
        
        // save the windowcontroller in the instance of myself
        appDelegate.rootWindowController.contentListViewController.windowLoader[itemID] = wc
        
        // call the completion handler
        completionHandler(wc.window, nil)
    }
    
    // MARK: Generic New Window Static Function
    
    // used for state restoration and normal operation
    
    fileprivate static func windowController(for itemID: URLItem.UIIdentifier) -> WebBrowserWindowController {
        let newWC = WebBrowserWindowController(itemID: itemID)
        newWC.window?.isRestorable = true
        newWC.window?.restorationClass = self
        newWC.window?.identifier = "URLItemWebViewWindow"
        newWC.windowFrameAutosaveName = itemID.uuid
        return newWC
    }
}
