//
//  URLItemListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/4/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import UIKit

class URLItemListViewController: UITableViewController {
    
    private lazy var uiBindingManager: URLListBindingManager = URLListBindingManager(selection: self.dataSelection, tableView: self.tableView, dataSource: self.dataSource, delegate: self)
    
    private var dataSelection: TagItem.Selection = .unarchivedItems
    private weak var dataSource: URLItemDoublePersistanceType?
    
    private var sortedIDs = [String]()
    
    // MARK: - Lifecycle
    
    convenience init(selection: TagItem.Selection, dataSource: URLItemDoublePersistanceType?) {
        self.init()
        self.dataSelection = selection
        self.dataSource = dataSource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure title
        switch self.dataSelection {
        case .allItems:
            self.title = "All Items"
        case .unarchivedItems:
            self.title = "Unread Items"
        case .tag(let tagName):
            self.title = tagName
        case .notSelectable:
            fatalError()
        }
        
        // tell the UI to reload
        self.uiBindingManager.initialLoad()
    }
}

extension URLItemListViewController: URLListBindingManagerDelegate {
    func didSelect(item: URLItemType, within: UITableView, bindingManager: URLListBindingManager) {
        let newVC = URLItemWebViewController(urlItem: item, delegate: self)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
}

extension URLItemListViewController: ViewControllerPresenterDelegate {
    func presented(viewController: UIViewController, didDisappearAnimated: Bool) {
        
    }
}
