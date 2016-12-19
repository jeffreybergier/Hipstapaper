//
//  URLListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

class URLListViewController: NSViewController {
    
    @IBOutlet weak var arrayController: NSArrayController?
    var bindingContent = [URLItem]() {
        didSet {
            print(self.bindingContent.count)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("URLListViewController Loaded")
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
