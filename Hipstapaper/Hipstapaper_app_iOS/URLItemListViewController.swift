//
//  URLItemListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/4/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import UIKit

class URLItemListViewController: UIViewController {
    
    @IBOutlet fileprivate var uiBindingManager: UIBindingManager? // strong reference needed because XIB doesn't hold onto the object
    
    private var dataSelection: TagItem.Selection = .unarchivedItems
    private var dataSource: URLItemDoublePersistanceType?
    
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
        
        // configure UIBindingManager
        self.uiBindingManager?.dataSource = self.dataSource
        self.uiBindingManager?.delegate = self
        self.uiBindingManager?.dataSelection = self.dataSelection
    }
}

extension URLItemListViewController: UIBindingDelegate {
    func didSelect(item: URLItemType, within: UITableView, bindingManager: UIBindingManager) {
        let newVC = URLItemWebViewController(urlItem: item, delegate: self)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
}

extension URLItemListViewController: ViewControllerPresenterDelegate {
    func presented(viewController: UIViewController, didDisappearAnimated: Bool) {
        self.uiBindingManager?.simulateTableViewControllerAppearing()
    }
}
