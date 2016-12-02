//
//  URLListWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence_macOS
import CloudKit
import AppKit

class URLListWindowController: NSWindowController {
    
    enum SyncController {
        case realmOnly, cloudKitOnly, combined
        
        var windowTitle: String {
            switch self {
            case .realmOnly:
                return "Realm"
            case .cloudKitOnly:
                return "CloudKit"
            case .combined:
                return "Hipstapaper"
            }
        }
    }
    
    // MARK: Data Source
    
    private var syncController: SyncController = .combined
    private(set) lazy var dataSource: DoubleSourcePersistenceType = {
        switch self.syncController {
        case .combined:
            return CombinedURLItemSyncingController()
        case .realmOnly:
            return RealmURLItemSyncingController()
        case .cloudKitOnly:
            return CloudKitURLItemSyncingController()
        }
    }()
    
    // MARK: Outlets
    
    @IBOutlet private weak var uiBindingManager: UIBindingManager?
    @IBOutlet private weak var tableView: NSTableView?
    @IBOutlet private weak var debugWindowToolbarImageView: NSImageView?
    
    
    // MARK: Manage Child Windows of this Window
    fileprivate var openItemWindows: [URLItem.Value : URLItemWebViewWindowController] = [:]
    var isPresentingChildWindows: Bool {
        return !self.openItemWindows.isEmpty
    }
    
    //MARK: Initialization
    
    convenience init(syncController: SyncController = .combined) {
        self.init(windowNibName: "URLListWindowController")
        self.syncController = syncController
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        self.uiBindingManager?.dataSource = self.dataSource
        self.window?.title = self.syncController.windowTitle
        self.window?.titleVisibility = .hidden
        switch self.syncController {
        case .cloudKitOnly, .realmOnly:
            self.window?.isExcludedFromWindowsMenu = false
            self.debugWindowToolbarImageView?.isHidden = false
        case .combined:
            self.window?.isExcludedFromWindowsMenu = true
            self.debugWindowToolbarImageView?.isHidden = true
        }
    }
    
    // MARK: Handle Toolbar Buttons
    
    @IBAction private func refreshButonClicked(_ sender: NSObject?) { // IB can send anything and swift won't check unless I do.
        self.tableView?.deselectAll(self)
        self.uiBindingManager?.reloadData()
    }
    
    // MARK: Handle Table View Actions
    
    @IBAction func tableViewDoubleClicked(_ sender: NSObject?) {
        guard let selectedItems = self.uiBindingManager?.selectedItems else { return }
        self.openItemWindows(for: selectedItems)
    }
    
    // MARK: Handle Menu Bar Items
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard menuItem.title == "Open Selected" else { fatalError() }
        if let selectedItems = self.uiBindingManager?.selectedItems, selectedItems.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    
    @objc private func open(_ sender: NSObject?) {
        guard let selectedItems = self.uiBindingManager?.selectedItems else { return }
        self.openItemWindows(for: selectedItems)
    }
    
    // MARK: Open Windows based on User Input
    
    private func openItemWindows(for selectedItems: [URLItemType]) {
        for item in selectedItems {
            let item = item as! URLItem.Value
            self.existingOrNewItemWindowController(for: item).showWindow(self)
        }
    }
    
    private func existingOrNewItemWindowController(for item: URLItem.Value) -> NSWindowController {
        if let oldWC = self.openItemWindows[item] {
            return oldWC
        } else {
            let newWC = URLItemWebViewWindowController(urlItem: item)
            self.openItemWindows[item] = newWC
            NotificationCenter.default.addObserver(self, selector: #selector(self.itemWindowWillClose(_:)), name: .NSWindowWillClose, object: newWC.window!)
            return newWC
        }
    }
}

extension URLListWindowController /*NSWindowDelegate*/ {
    
    // MARK: Handle Child Window Closing to Remove from OpenItemWindows Property and from Memory
    
    @objc fileprivate func itemWindowWillClose(_ notification: NSNotification) {
        guard
            let window = notification.object as? NSWindow,
            let itemWindowController = window.windowController as? URLItemWebViewWindowController,
            let item = itemWindowController.item
        else { return }
        
        NotificationCenter.default.removeObserver(self, name: .NSWindowWillClose, object: window)
        self.openItemWindows[item] = .none
    }
}
