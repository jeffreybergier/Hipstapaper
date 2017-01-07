//
//  HipstapaperWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

class HipstapaperWindowController: NSWindowController, RealmControllable {
    
    @IBOutlet private weak var shareToolbarButton: NSButton? {
        didSet {
            // configure the share button to send its action on mousedown
            self.shareToolbarButton?.sendAction(on: .leftMouseDown)
        }
    }
    
    // MARK: References to child view controllers
    
    /*@IBOutlet*/ fileprivate weak var sidebarViewController: TagListViewController?
    /*@IBOutlet*/ fileprivate weak var mainViewController: URLListViewController?
    
    // MARK: Realm Controller Owner
    
    var realmController = RealmController() {
        didSet {
            self.sidebarViewController?.realmController = self.realmController
            self.mainViewController?.realmController = self.realmController
        }
    }
    
    // MARK: Configure the window
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Get that OSX Yosemite 'look'
        self.window?.titleVisibility = .hidden
        
        // Populate the child VC's
        // This should be done in IB, but storyboards don't seem to allow it
        for childVC in self.window?.contentViewController?.childViewControllers ?? [] {
            if let sidebarVC = childVC as? TagListViewController {
                self.sidebarViewController = sidebarVC
            } else if let mainVC = childVC as? URLListViewController {
                self.mainViewController = mainVC
            }
        }
        
        // Become the selection delegate for the sidebar
        // This lets us update the content view controller when the selection changes in the sidebar
        self.sidebarViewController?.selectionDelegate = self
        
        // Become the selection delegate for the contentVC
        // This lets us update the sourceListVC when the user changes selection settings in the contentVC
        self.mainViewController?.selectionDelegate = self
        
        // check to see if the realm controller loaded
        // if it didn't load, then we're not logged in
        if let realmController = self.realmController {
            self.sidebarViewController?.realmController = realmController
            self.mainViewController?.realmController = realmController
        }
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        // check to see if the realm controller loaded
        // if it didn't load, then we're not logged in
        // if we're not logged in, show an alert
        if self.realmController == nil {
            let loginAlert = NSAlert()
            loginAlert.messageText = "You need to login. 😱"
            loginAlert.informativeText = "Hipstapaper uses a Realm Mobile Platform server to synchronize your Reading list between all of your devices."
            loginAlert.addButton(withTitle: "Open Preferences")
            loginAlert.addButton(withTitle: "Dismiss")
            loginAlert.beginSheetModal(for: self.window!) { finished in
                if finished == 1000 { self.showPreferencesWindow(loginAlert) }
            }
        }
    }
    
    // MARK: Ownership of the preferences window
    
    private lazy var preferencesWindowController: PreferencesWindowController = {
        let wc = PreferencesWindowController()
        wc.delegate = self
        return wc
    }()
    
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

extension HipstapaperWindowController: URLItemsToLoadChangeDelegate {
    var itemsToLoad: URLItem.ItemsToLoad {
        return self.mainViewController?.itemsToLoad ?? .all
    }
    var filter: URLItem.ArchiveFilter {
        return self.mainViewController?.filter ?? .unarchived
    }
    var sortOrder: URLItem.SortOrderA {
        return self.mainViewController?.sortOrder ?? .recentlyAddedOnTop
    }
    
    func didChange(itemsToLoad: URLItem.ItemsToLoad?, sortOrder: URLItem.SortOrderA?, filter: URLItem.ArchiveFilter?, sender: ViewControllerSender) {

        switch sender {
        case .tertiaryVC:
            fatalError()
        case .sourceListVC:
            // if the new selection is different than the last one, forward it on
            // since the items can be nil, I only want to compare them if they are not nill
            // to accomplish that, if they're nil I set them to the same value that they're being compared with
            guard
                (itemsToLoad ?? self.itemsToLoad) != self.itemsToLoad ||
                (filter ?? self.filter) != self.filter ||
                (sortOrder ?? self.sortOrder) != self.sortOrder
            else { return }
            self.mainViewController?.didChange(itemsToLoad: itemsToLoad, sortOrder: sortOrder, filter: filter, sender: sender)
        case .contentVC:
            self.sidebarViewController?.didChange(itemsToLoad: itemsToLoad, sortOrder: sortOrder, filter: filter, sender: sender)
        }
    }
}
