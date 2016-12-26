//
//  HipstapaperWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

class HipstapaperWindowController: NSWindowController {
    
    private let preferencesWindowController = PreferencesWindowController()
    
    /*@IBOutlet*/ private weak var sidebarViewController: TagListViewController?
    /*@IBOutlet*/ fileprivate weak var mainViewController: URLListViewController?
    
    private var realmController = RealmController() {
        didSet {
            self.sidebarViewController!.realmController = self.realmController!
            self.mainViewController!.realmController = self.realmController!
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.titleVisibility = .hidden
        
        for childVC in self.window?.contentViewController?.childViewControllers ?? [] {
            if let sidebarVC = childVC as? TagListViewController {
                self.sidebarViewController = sidebarVC
            } else if let mainVC = childVC as? URLListViewController {
                self.mainViewController = mainVC
            }
        }
        
        self.sidebarViewController!.selectionDelegate = self
        
        if let realmController = self.realmController {
            self.sidebarViewController!.realmController = realmController
            self.mainViewController!.realmController = realmController
        } else {
            NSLog("No User Present: Attempting Login.")
//            let credentials = SyncCredentials.usernamePassword(username: realmUsername, password: realmPassword, register: false)
//            SyncUser.logIn(with: credentials, server: realmAuthServer) { user, error in
//                if let user = user {
//                    DispatchQueue.main.async {
//                        NSLog("Login Successful")
//                        let realmController = RealmController(user: user)
//                        self.realmController = realmController
//                    }
//                } else {
//                    NSLog("Failed to login: \(error)")
//                }
//            }
        }
    }
    
    @IBAction private func showPreferencesWindow(_ sender: NSObject?) {
        self.preferencesWindowController.showWindow(sender)
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.tag == 333 {
            return true
        } else {
            return false
        }
    }
    
}

extension HipstapaperWindowController: URLItemSelectionReceivable {
    func didSelect(_ selection: URLItem.Selection, from outlineView: NSOutlineView?) {
        self.mainViewController!.didSelect(selection, from: outlineView)
    }
}
