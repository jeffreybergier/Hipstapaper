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
    
    @IBOutlet fileprivate weak var arrayController: NSArrayController?
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
        case .share:
            let items = selectedItems.map({ URL(string: $0.urlString) }).flatMap({ $0 })
            guard items.isEmpty == false else { return false }
            menuItem.submenu = NSMenu(shareMenuWithItems: items)
            return true
        case .shareSubmenu:
            return true
        case .javascript:
            return false
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
    
    // MARK: Handle Key Events
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 36, 76: // enter keys
            break
        case 53: // escape key
            break
        default:
            super.keyDown(with: event)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 36, 76: // enter keys
            self.open(event)
        case 53: // escape key
            self.view.window?.firstResponder.try(toPerform: #selector(NSTableView.deselectAll(_:)), with: event)
            self.view.window?.toolbar?.validateVisibleItems() // it was taking almost a full second to re-validate toolbar items without forcing it manually
        default:
            super.keyUp(with: event)
        }
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
        self.presentViewController(tagVC, asPopoverRelativeTo: .zero, of: item, preferredEdge: .maxY, behavior: .semitransient)
    }
    
    @objc private func share(_ sender: NSObject?) {
        guard
            let button = sender as? NSButton,
            let urls = self.arrayController?.selectedURLItems?.map({ URL(string: $0.urlString) }).flatMap({ $0 }),
            urls.isEmpty == false
        else { return }
        NSSharingServicePicker(items: urls).show(relativeTo: .zero, of: button, preferredEdge: .minY)
    }
    
    @objc func shareMenu(_ sender: NSObject?) {
        guard let urls = self.arrayController?.selectedURLItems?.map({ URL(string: $0.urlString) }).flatMap({ $0 }), urls.isEmpty == false else { return }
        ((sender as? NSMenuItem)?.representedObject as? NSSharingService)?.perform(withItems: urls)
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

extension URLListViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableRowActionEdge) -> [NSTableViewRowAction] {
        guard
            edge == .trailing,
            let rowView = tableView.rowView(atRow: row, makeIfNecessary: false),
            let item = (self.arrayController?.content as? NSArray)?[row] as? URLItem,
            let realmController = self.realmController
        else { return [] }
        
        let archiveActionTitle = item.archived ? "📤Unarchive" : "📥Archive"
        let archiveToggleAction = NSTableViewRowAction(style: .regular, title: archiveActionTitle) { _ in
            let newArchiveValue = !item.archived
            realmController.updateArchived(to: newArchiveValue, on: [item])
        }
        let tagAction = NSTableViewRowAction(style: .regular, title: "🏷Tag") { action, index in
            let actionButtonView = tableView.tableViewActionButtons?.first ?? rowView
            let tagVC = URLTaggingViewController(items: [item], controller: realmController)
            self.presentViewController(tagVC, asPopoverRelativeTo: .zero, of: actionButtonView, preferredEdge: .minY, behavior: .transient)
        }
        tagAction.backgroundColor = NSColor.lightGray
        return [tagAction, archiveToggleAction]
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

fileprivate extension NSView {
    
    fileprivate var tableViewActionButtons: [NSView]? {
        guard let type = NSClassFromString("NSTableViewActionButton") else { return .none }
        let matches = self.subviews(matchingType: type)
        if matches.isEmpty { return .none } else { return matches }
    }
    
    private func subviews(matchingType type: AnyClass) -> [NSView] {
        var matches = [NSView]()
        if self.classForCoder == type {
            matches.append(self)
        }
        for subview in self.subviews {
            matches += subview.subviews(matchingType: type)
        }
        return matches
    }
}

// MARK: Helper methods for getting selected Item

fileprivate extension NSArrayController {
    fileprivate var selectedURLItems: [URLItem]? {
        let selectedItems = self.selectedObjects.map({ $0 as? URLItem }).flatMap({ $0 })
        if selectedItems.isEmpty { return .none } else { return selectedItems }
    }
}

// MARK: Handle Showing URL if there is no Title

private extension URLItem {
    @objc private var bindingTitle: String {
        return self.extras?.pageTitle ?? self.urlString
    }
}
