//
//  URLListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import Social
import AppKit

class URLListViewController: NSViewController, RealmControllable {
    
    weak var realmController: RealmController? {
        didSet {
            self.hardReloadData()
        }
    }
    
    @IBOutlet private weak var arrayController: NSArrayController?
    fileprivate var openWindowsControllers: [URLItem.UIIdentifier : NSWindowController] = [:]
    var selection = URLItem.Selection.unarchived {
        didSet {
            self.hardReloadData()
        }
    }
    
    // MARK: Reload Data
    
    fileprivate func hardReloadData() {
        // clear out all previous update tokens and tableview
        self.notificationToken?.stop()
        self.notificationToken = .none
        self.arrayController?.content = []
        
        // now ask realm for new data and give it our closure to get updates
        switch self.selection {
        case .unarchived:
            self.title = "Hipstapaper"
        case .all:
            self.title = "All Items"
        case .tag(let tagID):
            self.title = "🏷 \(tagID.displayName)"
        }
        
        let items = self.realmController?.urlItems(for: selection, sortOrder: URLItem.SortOrder.creationDate(newestFirst: true))
        self.notificationToken = items?.addNotificationBlock(self.realmResultsChangeClosure)
    }
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<URLItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial(let results):
            self?.arrayController?.content = Array(results)
        case .update(let results, _, _, _):
            self?.arrayController?.content = Array(results)
        case .error(let error):
            guard let window = self?.view.window else { break }
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: window, completionHandler: .none)
        }
    }
    
    // MARK: Handle Double click on TableView
    
    @IBAction func tableViewDoubleClicked(_ sender: NSObject?) {
        guard let selectedItems = self.arrayController?.selectedURLItems else { return }
        self.openOrBringFrontWindowControllers(for: selectedItems)
    }
    
    // MARK: Handle Menu Bar Items
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard
            let realmController = self.realmController,
            let kind = NSMenuItem.Kind(rawValue: menuItem.tag),
            let selectedItems = self.arrayController?.selectedURLItems
        else { return false }
        
        switch kind {
        case .unarchive:
            return realmController.atLeastOneItem(in: selectedItems, canBeArchived: false)
        case .archive:
            return realmController.atLeastOneItem(in: selectedItems, canBeArchived: true)
        case .copy:
            return selectedItems.count == 1
        case .delete:
            return true
        case .open:
            return true
        }
    }
    
    @objc private func open(_ sender: NSObject?) {
        guard let selectedItems = self.arrayController?.selectedURLItems else { return }
        self.openOrBringFrontWindowControllers(for: selectedItems)
    }
    
    @objc private func delete(_ sender: NSObject?) {
        guard let selectedItems = self.arrayController?.selectedURLItems else { return }
        self.realmController?.delete(items: selectedItems)
    }
    
    @objc private func copy(_ sender: NSObject?) {
        guard let selectedItems = self.arrayController?.selectedURLItems, let item = selectedItems.first else { NSBeep(); return; }
        NSPasteboard.general().declareTypes([NSStringPboardType], owner: self)
        NSPasteboard.general().setString(item.urlString, forType: NSStringPboardType)
    }
    
    // MARK: Handle Toolbar Items
    
    @objc private func archive(_ sender: NSObject?) {
        guard let selectedItems = self.arrayController?.selectedURLItems else { return }
        self.realmController?.updateArchived(to: true, on: selectedItems)
    }
    
    @objc private func unarchive(_ sender: NSObject?) {
        guard let selectedItems = self.arrayController?.selectedURLItems else { return }
        self.realmController?.updateArchived(to: false, on: selectedItems)
    }
    
    @objc private func tag(_ sender: NSObject?) {
        guard
            let item = sender as? NSButton,
            let realmController = self.realmController,
            let selectedItems = self.arrayController?.selectedURLItems
        else { return }
        let tagVC = URLTaggingViewController(items: selectedItems, controller: realmController)
        self.presentViewController(tagVC, asPopoverRelativeTo: .zero, of: item, preferredEdge: .minY, behavior: .semitransient)
    }
    
    @objc private func share(_ sender: NSObject?) {
        print("share")
    }
    
    override func validateToolbarItem(_ item: NSObject?) -> Bool {
        guard
            let item = item as? NSToolbarItem,
            let kind = NSToolbarItem.Kind(rawValue: item.tag),
            let realmController = self.realmController,
            let selectedItems = self.arrayController?.selectedURLItems
        else { return false }
        switch kind {
        case .unarchive:
            return realmController.atLeastOneItem(in: selectedItems, canBeArchived: false)
        case .archive:
            return realmController.atLeastOneItem(in: selectedItems, canBeArchived: true)
        case .tag:
            return !selectedItems.isEmpty
        case .share:
            return !selectedItems.isEmpty
        }
    }
    
    // MARK: Handle Opening / Bringing to Front Windows
    
    private func openOrBringFrontWindowControllers(for items: [URLItem]) {
        items.forEach() { item in
            let itemID = URLItem.UIIdentifier(uuid: item.uuid, urlString: item.urlString, archived: item.archived)
            if let existingWC = self.openWindowsControllers[itemID] {
                existingWC.showWindow(self)
            } else {
                let newWC = URLItemWebViewWindowController(itemID: itemID, delegate: self)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.itemWindowWillClose(_:)),
                                                       name: .NSWindowWillClose,
                                                       object: newWC.window!)
                self.openWindowsControllers[itemID] = newWC
                newWC.showWindow(self)
            }
        }
    }
    
    // MARK: Handle Going Away
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

fileprivate extension UInt16 {
    fileprivate var isReturnKeyCode: Bool {
        return self == 36 || self == 76
    }
}

extension URLListViewController /*NSWindowDelegate*/ {
    
    // MARK: Handle Child Window Closing to Remove from OpenItemWindows Property and from Memory
    
    @objc fileprivate func itemWindowWillClose(_ notification: NSNotification) {
        guard
            let window = notification.object as? NSWindow,
            let itemWindowController = window.windowController as? URLItemWebViewWindowController,
            let item = itemWindowController.itemID
        else { return }
        
        NotificationCenter.default.removeObserver(self, name: .NSWindowWillClose, object: window)
        self.openWindowsControllers[item] = .none
    }
}

// MARK: Helper methods for getting selected Item

fileprivate extension NSArrayController {
    fileprivate var selectedURLItems: [URLItem]? {
        let selectedItems = self.selectedObjects.map({ $0 as? URLItem }).flatMap({ $0 })
        if selectedItems.isEmpty { return .none } else { return selectedItems }
    }
}

// MARK: Custom enum so I know which toolbar item was clicked

extension NSToolbarItem {
    enum Kind: Int {
        case unarchive = 544, archive = 555, tag = 222, share = 233
    }
}

fileprivate extension NSMenuItem {
    fileprivate enum Kind: Int {
        case open = 999
        case copy = 444
        case archive = 555
        case unarchive = 544
        case delete = 666
    }
}

// MARK: Handle Showing URL if there is no Title

private extension URLItem {
    @objc private var bindingTitle: String {
        return self.extras?.pageTitle ?? self.urlString
    }
}
