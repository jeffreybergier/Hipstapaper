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
    
    private let dataSource: URLItemCRUDDoublePersistanceType = URLItemPersistanceController()
    private var sortedIDs = [String]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure title
        self.title = "♓️ Hipstapaper"
        
        // configure UIBindingManager
        self.uiBindingManager?.dataSource = self.dataSource
        self.uiBindingManager?.delegate = self
        
        // configure bar button items
        let reloadBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reloadButtonTapped(_:)))
        reloadBarButtonItem.style = .done // I thought this made bar button items thicker, but it appears to make it thinner
        let addBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped(_:)))
        addBarButtonItem.style = .plain // I thought this made bar buttom items thinner, but it appears to make it thicker
        self.navigationItem.leftBarButtonItem = reloadBarButtonItem
        self.navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    @objc private func reloadButtonTapped(_ sender: NSObject?) {
        self.uiBindingManager?.reloadData()
    }
    
    @objc private func addButtonTapped(_ sender: NSObject?) {
        
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
