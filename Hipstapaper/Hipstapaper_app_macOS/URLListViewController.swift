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
    fileprivate var selection: URLItem.Selection?
    
    fileprivate var openWindowsControllers = [URLItem : NSWindowController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("URLListViewController Loaded")
    }
    
    // MARK: Reload Data
    
    fileprivate func hardReloadData() {
        // clear out all previous update tokens and tableview
        self.notificationToken?.stop()
        self.notificationToken = .none
        self.arrayController?.content = []
        
        guard let selection = self.selection else { return }
        
        // now ask realm for new data and give it our closure to get updates
        switch selection {
        case .unarchived:
            self.title = "Hipstapaper"
        case .all:
            self.title = "All Items"
        case .tag(let tagItem):
            self.title = "🏷 \(tagItem.name)"
        }
        
        let items = RealmConfig.urlItems(for: selection, sortOrder: URLItem.SortOrder.creationDate(newestFirst: false))
        self.notificationToken = items.addNotificationBlock(self.realmResultsChangeClosure)
    }
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<URLItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial(let results):
            self?.arrayController?.content = Array(results)
        case .update(let results, _, _, _):
            self?.arrayController?.content = Array(results)
        case .error(let error):
            fatalError("\(error)")
        }
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

extension URLListViewController: URLItemSelectionReceivable {
    func didSelect(_ selection: URLItem.Selection, from: NSOutlineView?) {
        self.selection = selection
        self.hardReloadData()
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
