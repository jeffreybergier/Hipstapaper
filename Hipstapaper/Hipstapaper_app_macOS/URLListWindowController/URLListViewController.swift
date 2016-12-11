//
//  URLListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/10/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import AppKit

class URLListViewController: NSViewController {
    
    @IBOutlet private weak var bindingManager: URLListBindingManager? {
        didSet {
            self.bindingManager?.dataSource = self.dataSource
        }
    }
    @IBOutlet private weak var tableView: NSTableView?
    
    // MARK: Data Source
    
    weak var dataSource: URLItemCRUDDoublePersistanceType?
    
    // MARK: Manage Child Windows of this Window
    fileprivate var openItemWindows: [URLItem.Value : URLItemWebViewWindowController] = [:]
    var isPresentingChildWindows: Bool {
        return !self.openItemWindows.isEmpty
    }
    
    // MARK: Lifecycle
    
    // MARK: Handle Table View Actions
    
    @IBAction func tableViewDoubleClicked(_ sender: NSObject?) {
        guard let selectedItems = self.bindingManager?.selectedItems else { return }
        self.openItemWindows(for: selectedItems)
    }
    
    func windowSyncFinished(result: Result<Void>, sender: NSObject?) {
        self.tableView?.deselectAll(self)
        self.bindingManager?.reloadData()
    }
    
    // MARK: Handle Menu Bar Items
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard menuItem.title == "Open Selected" else { fatalError() }
        if let selectedItems = self.bindingManager?.selectedItems, selectedItems.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    
    @objc private func open(_ sender: NSObject?) {
        guard let selectedItems = self.bindingManager?.selectedItems else { return }
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
    
    // MARK: Tag Selection Responder
    
    @objc func didChangeTag(selection: TagSelectionContainer?) {
        print("View Controller Received Selection: \(selection!.selection)")
    }
}

extension URLListViewController /*NSWindowDelegate*/ {
    
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
