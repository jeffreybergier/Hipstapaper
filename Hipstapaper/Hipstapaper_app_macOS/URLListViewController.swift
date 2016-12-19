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
    
    var bindingContent = [URLItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("URLListViewController Loaded")
    }
    
    // MARK: Handle Double click on TableView
    
    @IBAction func tableViewDoubleClicked(_ sender: NSObject?) {
        guard let selectedItems = self.arrayController?.selectedURLItems else { return }
        print(selectedItems)
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
        print(selectedItems)
    }
    
    // MARK: Handle Key Input 
    
//    override func keyUp(with event: NSEvent) {
//        let chars = event.charactersIgnoringModifiers
//        let aChar = chars?.characters[0]
//        if (aChar == 13 || aChar == 3) {
//            guard let selectedItems = self.arrayController?.selectedURLItems else { return }
//            print(selectedItems)
//        }
////        NSString *chars = event.charactersIgnoringModifiers;
////        unichar aChar = [chars characterAtIndex: 0];
////        if (aChar == 13 || aChar == 3)
//    }
    
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
            self.bindingContent = Array(results)
            self.arrayController?.content = self.bindingContent
//            self.notificationToken = results.addNotificationBlock(self.tableResultsUpdateClosure)
//            data = .results(results)
        case .allItems:
            self.title = "All Items"
            let creationDate = #keyPath(URLItem.creationDate)
            let results = realm.objects(URLItem.self).sorted(byProperty: creationDate, ascending: false)
            self.bindingContent = Array(results)
            self.arrayController?.content = self.bindingContent
//            self.notificationToken = results.addNotificationBlock(self.tableResultsUpdateClosure)
//            data = .results(results)
        case .tag(let tagItem):
            self.title = "🏷 \(tagItem.name)"
            let links = tagItem.items
            self.bindingContent = Array(links)
            self.arrayController?.content = self.bindingContent
//            self.notificationToken = links.addNotificationBlock(self.tableLinksUpdateClosure)
//            data = .links(links)
        }
    }
}
