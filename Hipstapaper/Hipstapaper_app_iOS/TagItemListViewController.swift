//
//  TagItemListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import UIKit

class TagItemListViewController: UITableViewController {
    
    private enum Section: Int {
        case mainItems, tagItems
    }
    
    // MARK: Data Source
    
    var dataSource: URLItemDoublePersistanceType?
    
    fileprivate let mainItems: TreeBindingObject = {
        let unread = TreeBindingObject(title: "Unread Items", kind: .unarchivedItems)
        let all = TreeBindingObject(title: "All Items", kind: .allItems)
        let root = TreeBindingObject(title: "Reading List", children: [unread, all], kind: .notSelectable)
        return root
    }()
    
    fileprivate let tagItems = TreeBindingObject(title: "Tags", kind: .notSelectable)
    
    // MARK: NavBar Items
    
    private lazy var reloadBar: UIBarButtonItem = {
        let item = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reloadButtonTapped(_:)))
        //item.style = .done // I thought this made bar button items thicker, but it appears to make it thinne
        return item
    }()
    private let loadingBar: UIBarButtonItem = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.stopAnimating()
        view.hidesWhenStopped = true
        let barButtonItem = UIBarButtonItem(customView: view)
        return barButtonItem
    }()
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Hipstapaper"
        
        // configure bar button items
        self.navigationItem.leftBarButtonItem = self.reloadBar
        self.setToolbarItems([self.reloadBar, self.loadingBar], animated: false)
    }
    
    // MARK: Handle User Input
    
    @objc private func reloadButtonTapped(_ sender: NSObject?) {
        self.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        let selection: TagItem.Selection
        switch section {
        case .mainItems:
            selection = self.mainItems.children[indexPath.row].kind
        case .tagItems:
            selection = self.tagItems.children[indexPath.row].kind
        }
        let newVC = URLItemListViewController(selection: selection, dataSource: self.dataSource)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
    
    // MARK: Handle Loading Data
    
    private func showLoadingSpinner() {
        (self.loadingBar.customView as! UIActivityIndicatorView).startAnimating()
        self.reloadBar.isEnabled = false
    }
    
    private func showReloadButton() {
        (self.loadingBar.customView as! UIActivityIndicatorView).stopAnimating()
        self.reloadBar.isEnabled = true
    }
    
    private func reloadData() {
        self.showLoadingSpinner()
        self.dataSource?.sync() { result in
            DispatchQueue.main.async {
                switch result {
                case .error(let errors):
                    NSLog("Error Syncing Data: \(errors)")
                    self.tagItems.children = []
                    self.tableView.reloadData()
                    self.showReloadButton()
                case .success:
                    self.dataSource?.tagItems() { tagResult in
                        DispatchQueue.main.async {
                            switch tagResult {
                            case .error(let errors):
                                NSLog("Error Loading Tags: \(errors)")
                                self.tagItems.children = []
                            case .success(let tags):
                                let items = tags.map({ TreeBindingObject(title: $0.name, kind: .tag(name: $0.name)) })
                                self.tagItems.children = items
                            }
                            self.tableView.reloadData()
                            self.showReloadButton()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: Table View Data
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.tagItems.children.isEmpty == true {
            return 1
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .mainItems:
            return self.mainItems.children.count
        case .tagItems:
            return self.tagItems.children.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError() }
        let identifier = "Basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .default, reuseIdentifier: identifier)
        let labelText: String
        switch section {
        case .mainItems:
            labelText = self.mainItems.children[indexPath.row].title
        case .tagItems:
            labelText = self.tagItems.children[indexPath.row].title
        }
        cell.textLabel?.text = labelText
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return .none }
        switch section {
        case .mainItems:
            return "Reading List"
        case .tagItems:
            return "Tags"
        }
    }

}
