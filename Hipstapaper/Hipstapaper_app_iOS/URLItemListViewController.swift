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
    
    fileprivate enum UIState {
        case notLoadingNotEditing
        case loadingNotEditing
        case notLoadingEditing
    }
    
    fileprivate lazy var uiBindingManager: URLListBindingManager = URLListBindingManager(selection: self.dataSelection, tableView: self.tableView, dataSource: self.dataSource, delegate: self)
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    private var dataSelection: TagItem.Selection = .unarchivedItems
    private weak var dataSource: URLItemDoublePersistanceType?
    
    private var delegate: ViewControllerPresenterDelegate?
    
    private var sortedIDs = [String]()
    
    // MARK: NavBar Items
    
    fileprivate var uiState = UIState.notLoadingNotEditing {
        didSet {
            DispatchQueue.main.async {
                switch self.uiState {
                case .notLoadingNotEditing:
                    self.reloadBar.isEnabled = true
                    self.editBar.isEnabled = true
                    self.doneBar.isEnabled = true
                    self.setToolbarItems([self.reloadBar, self.flexibleSpaceBar, self.editBar], animated: true)
                    self.tableView.setEditing(false, animated: true)
                case .loadingNotEditing:
                    self.editBar.isEnabled = false
                    self.doneBar.isEnabled = false
                    self.reloadBar.isEnabled = true
                    self.setToolbarItems([self.loadingBar, self.flexibleSpaceBar, self.editBar], animated: true)
                    self.tableView.setEditing(false, animated: true)
                case .notLoadingEditing:
                    self.editBar.isEnabled = false
                    self.doneBar.isEnabled = true
                    self.reloadBar.isEnabled = false
                    self.setToolbarItems([self.reloadBar, self.flexibleSpaceBar, self.doneBar], animated: true)
                    self.tableView.setEditing(true, animated: true)
                }
            }
        }
    }
    
    private lazy var reloadBar: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reloadButtonTapped(_:)))
    private lazy var doneBar: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped(_:)))
    private lazy var editBar: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editButtonTapped(_:)))
    private let flexibleSpaceBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: .none, action: .none)
    private let loadingBar: UIBarButtonItem = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.startAnimating()
        let barButtonItem = UIBarButtonItem(customView: view)
        return barButtonItem
    }()
    
    // MARK: - Lifecycle

    
    convenience init(selection: TagItem.Selection, dataSource: URLItemDoublePersistanceType?, delegate: ViewControllerPresenterDelegate?) {
        self.init()
        self.dataSelection = selection
        self.dataSource = dataSource
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure title
        switch self.dataSelection {
        case .allItems:
            self.title = "All Items"
        case .unarchivedItems:
            self.title = "Hipstapaper"
        case .tag(let tagName):
            self.title = tagName
        case .notSelectable:
            fatalError()
        }
        
        // configure the tableview
        self.tableView.allowsMultipleSelection = true
        
        // configure the toolbar
        self.uiState = .notLoadingNotEditing
        
        // tell the UI to quick load
        self.uiBindingManager.quickLoad()
    }
    
    fileprivate var viewDidAppearOnce = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.viewDidAppearOnce == false {
            self.simulateUITableViewController()
            self.viewDidAppearOnce = true
        }
    }
    
    fileprivate func simulateUITableViewController() {
        self.tableView?.flashScrollIndicators()
        if let selectedRows = self.tableView?.indexPathsForSelectedRows {
            selectedRows.forEach() { indexPath in
                self.tableView?.deselectRow(at: indexPath, animated: true)
            }
        }
    }
    
    // MARK: Handle User Input
    
    @objc fileprivate func reloadButtonTapped(_ sender: NSObject?) {
        self.uiState = .loadingNotEditing
        self.uiBindingManager.sync()
    }
    
    @objc fileprivate func editButtonTapped(_ sender: NSObject?) {
        self.uiState = .notLoadingEditing
    }
    
    @objc fileprivate func doneButtonTapped(_ sender: NSObject?) {
        self.uiState = .notLoadingNotEditing
    }
    
    // MARK: Handle View Going Away
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        // by the time this method is called, the navigation controller has been removed
        // i only want this to fire when that happens because i only want it to fire when going back
        // not when going forward
        if self.navigationController == .none {
            self.delegate?.presented(viewController: self, didDisappearAnimated: animated)
        }
    }
}


extension URLItemListViewController: URLListBindingManagerDelegate {
    
    func didSelect(item: URLItemType, within: UITableView, bindingManager: URLListBindingManager) {
        let newVC = URLItemWebViewController(urlItem: item, delegate: self)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    func didUpdate(operationsInProgress: Bool, bindingManager: URLListBindingManager) {
        if operationsInProgress {
            self.uiState = .loadingNotEditing
        } else {
            self.uiState = .notLoadingNotEditing
        }
    }

}

extension URLItemListViewController: ViewControllerPresenterDelegate {
    func presented(viewController: UIViewController, didDisappearAnimated: Bool) {
        self.simulateUITableViewController()
    }
}
