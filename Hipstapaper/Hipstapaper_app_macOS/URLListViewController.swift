//
//  URLListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

extension NSArrayController {
    var selectedURLItems: [URLItem]? {
        let selectedItems = self.selectedObjects.map({ $0 as? URLItem }).flatMap({ $0 })
        if selectedItems.isEmpty { return .none } else { return selectedItems }
    }
}

class URLListViewController: NSViewController {
    
    @IBOutlet weak var arrayController: NSArrayController?
    
    fileprivate var openWindowsControllers = [URLItem : NSWindowController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("URLListViewController Loaded")
    }
    
    // MARK: Handle Double click on TableView
    
    @IBAction func tableViewDoubleClicked(_ sender: NSObject?) {
        guard let selectedItems = self.arrayController?.selectedURLItems else { return }
        self.openOrBringFrontWindowControllers(for: selectedItems)
    }
    
    // MARK: Handle Menu Bar Items
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard menuItem.title == "Open Selected" else { fatalError() }
        if let selectedItems = self.arrayController?.selectedURLItems, selectedItems.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    
    @objc private func open(_ sender: NSObject?) {
        guard let selectedItems = self.arrayController?.selectedURLItems else { return }
        self.openOrBringFrontWindowControllers(for: selectedItems)
    }
    
    // MARK: Handle Key Input
    
    override func keyDown(with event: NSEvent) {
        let code = event.keyCode
        if let _ = self.arrayController?.selectedURLItems, code.isReturnKeyCode {
            // do nothing
        } else {
            super.keyDown(with: event)
        }
    }

    override func keyUp(with event: NSEvent) {
        let code = event.keyCode
        if let selectedItems = self.arrayController?.selectedURLItems, code.isReturnKeyCode {
            self.openOrBringFrontWindowControllers(for: selectedItems)
        } else {
            super.keyUp(with: event)
        }
    }
    
    // MARK: Handle Opening / Bringing to Front Windows
    
    private func openOrBringFrontWindowControllers(for items: [URLItem]) {
        items.forEach() { item in
            if let existingWC = self.openWindowsControllers[item] {
                existingWC.showWindow(self)
            } else {
                let newWC = URLItemWebViewWindowController(item: item)
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(self.itemWindowWillClose(_:)),
                                                       name: .NSWindowWillClose,
                                                       object: newWC.window!)
                self.openWindowsControllers[item] = newWC
                newWC.showWindow(self)
            }
        }
    }
}

fileprivate extension UInt16 {
    fileprivate var isReturnKeyCode: Bool {
        return self == 36 || self == 76
    }
}

extension URLListViewController: URLItemSelectionReceivable {
    func didSelect(_ selection: URLItem.Selection, from: NSOutlineView?) {
        // configure data source
        // also set title in same switch
        let realm = try! Realm()
//        let data: Data
        switch selection {
        case .unarchivedItems:
            self.title = "Hipstapaper"
            let archived = #keyPath(URLItem.iArchived)
            let creationDate = #keyPath(URLItem.creationDate)
            let results = realm.objects(URLItem.self).filter("\(archived) = NO").sorted(byProperty: creationDate, ascending: false)
            self.arrayController?.content = Array(results)
//            self.notificationToken = results.addNotificationBlock(self.tableResultsUpdateClosure)
//            data = .results(results)
        case .allItems:
            self.title = "All Items"
            let creationDate = #keyPath(URLItem.creationDate)
            let results = realm.objects(URLItem.self).sorted(byProperty: creationDate, ascending: false)
            self.arrayController?.content = Array(results)
//            self.notificationToken = results.addNotificationBlock(self.tableResultsUpdateClosure)
//            data = .results(results)
        case .tag(let tagItem):
            self.title = "🏷 \(tagItem.name)"
            let links = tagItem.items
            self.arrayController?.content = Array(links)
//            self.notificationToken = links.addNotificationBlock(self.tableLinksUpdateClosure)
//            data = .links(links)
        }
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
        self.openWindowsControllers[item] = .none
    }
}
