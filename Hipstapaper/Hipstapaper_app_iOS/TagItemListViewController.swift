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
    
    private let dataSource: URLItemDoublePersistanceType? = URLItemPersistanceController()
    
    fileprivate let mainItems: TreeBindingObject = {
        let unread = TreeBindingObject(title: "Unread Items", kind: .unarchivedItems)
        let all = TreeBindingObject(title: "All Items", kind: .allItems)
        let root = TreeBindingObject(title: "Reading List", children: [unread, all], kind: .notSelectable)
        return root
    }()
    
    fileprivate let tagItems = TreeBindingObject(title: "Tags", kind: .notSelectable)
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "♓️ Hipstapaper"
        
        // configure bar button items
        let reloadBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(self.reloadButtonTapped(_:)))
        reloadBarButtonItem.style = .done // I thought this made bar button items thicker, but it appears to make it thinner
        self.navigationItem.leftBarButtonItem = reloadBarButtonItem
    }
    
    // MARK: Handle User Input
    
    @objc private func reloadButtonTapped(_ sender: NSObject?) {
        self.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        switch section {
        case .mainItems:
            let selection = self.mainItems.children[indexPath.row].kind
            print("selected \(selection)")
        case .tagItems:
            let selection = self.tagItems.children[indexPath.row].kind
            print("selected \(selection)")
        }
    }
    
    // MARK: Handle Loading Data
    
    private func reloadData() {
        self.dataSource?.sync() { result in
            DispatchQueue.main.async {
                switch result {
                case .error(let errors):
                    NSLog("Error Syncing Data: \(errors)")
                    self.tagItems.children = []
                    self.tableView.reloadData()
                case .success:
                    self.dataSource?.tagItems() { tagResult in
                        DispatchQueue.main.async {
                            switch tagResult {
                            case .error(let errors):
                                NSLog("Error Loading Tags: \(errors)")
                                self.tagItems.children = []
                                self.tableView.reloadData()
                            case .success(let tags):
                                let items = tags.map({ TreeBindingObject(title: $0.name, kind: .tag(name: $0.name)) })
                                self.tagItems.children = items
                                self.tableView.reloadData()
                            }
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
