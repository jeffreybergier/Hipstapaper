//
//  URLListWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import CloudKit
import AppKit

class URLListWindowController: NSWindowController {
    
    // MARK: Data Source
    
    fileprivate let cloudKitComms = CloudKitComms(recordType: "URLItem")
    @IBOutlet private weak var uiBindingObserver: URLListBindingObserver?
    @IBOutlet private weak var tableView: NSTableView?
    
    // MARK: Manage Child Windows of this Window
    fileprivate var openItemWindows = [URLBindingItem : URLItemWebViewWindowController]()
    var isPresentingChildWindows: Bool {
        return !self.openItemWindows.isEmpty
    }
    
    //MARK: Initialization
    
    convenience init() {
        self.init(windowNibName: "URLListWindowController")
        self.window?.isExcludedFromWindowsMenu = true
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titleVisibility = .hidden
        self.uiBindingObserver?.delegate = self
    }
    
    // MARK: Handle Toolbar Buttons
    
    @IBAction private func refreshButonClicked(_ sender: NSObject?) { // IB can send anything and swift won't check unless I do.
        self.tableView?.deselectAll(self)
        self.reloadData()
    }
    
    // MARK: Handle Table View Actions
    
    @IBAction func tableViewDoubleClicked(_ sender: NSObject?) {
        guard let selectedItems = self.uiBindingObserver?.selectedItems else { return }
        self.openItemWindows(for: selectedItems)
    }
    
    // MARK: Handle Menu Bar Items
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard menuItem.title == "Open Selected" else { fatalError() }
        if let selectedItems = self.uiBindingObserver?.selectedItems, selectedItems.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    
    @objc private func open(_ sender: NSObject?) {
        guard let selectedItems = self.uiBindingObserver?.selectedItems else { return }
        self.openItemWindows(for: selectedItems)
    }
    
    // MARK: Open Windows based on User Input
    
    private func openItemWindows(for selectedItems: [URLBindingItem]) {
        for item in selectedItems {
            self.existingOrNewItemWindowController(for: item).showWindow(self)
        }
    }
    
    private func existingOrNewItemWindowController(for item: URLBindingItem) -> NSWindowController {
        if let oldWC = self.openItemWindows[item] {
            return oldWC
        } else {
            let newWC = URLItemWebViewWindowController(urlItem: item)
            self.openItemWindows[item] = newWC
            NotificationCenter.default.addObserver(self, selector: #selector(self.itemWindowWillClose(_:)), name: .NSWindowWillClose, object: newWC.window!)
            return newWC
        }
    }
    
    // MARK: Reload Data and Update UI
    
    private func reloadData() {
        self.cloudKitComms.reloadData() { result in
            switch result {
            case .success(let records):
                let items = records.map({ URLBindingItem(record: $0) })
                self.uiBindingObserver?.replaceList(list: items)
            case .error(let error):
                NSLog("\(error)")
            }
        }
    }
}

extension URLListWindowController: RecordChangeDelegate {
    
    // MARK: Observe Changes in Data from UI and forward it to CloudKit Sync
    
    func bindingsObserver(_: URLListBindingObserver, didAdd records: [URLBindingItem]) {
        records.forEach({ self.cloudKitComms.writeToCloudKit(item: $0.record, completionHandler: {_ in}) })
    }
    func bindingsObserver(_: URLListBindingObserver, didChange records: [URLBindingItem]) {
        records.forEach({ self.cloudKitComms.writeToCloudKit(item: $0.record, completionHandler: {_ in}) })
    }
    func bindingsObserver(_: URLListBindingObserver, didDelete records: [URLBindingItem]) {
        records.forEach({ self.cloudKitComms.deleteFromCloudKit(item: $0.record, completionHandler: {_ in}) })
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
