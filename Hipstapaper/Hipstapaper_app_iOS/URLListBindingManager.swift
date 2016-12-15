//
//  UIBindingManager.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/8/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import UIKit

protocol URLListBindingManagerDelegate: class {
    func didChooseToTag(item: URLItemType, within: UITableView, bindingManager: URLListBindingManager)
    func didChooseToArchive(item: URLItemType, within: UITableView, bindingManager: URLListBindingManager)
    func didChangeSelection(items: [URLItemType], within: UITableView, bindingManager: URLListBindingManager)
    func didChoose(item: URLItemType, within: UITableView, bindingManager: URLListBindingManager)
    func didUpdate(operationsInProgress: Bool, bindingManager: URLListBindingManager)
}

class URLListBindingManager: NSObject {
    
    // MARK: Selection Delegate
    
    fileprivate weak var delegate: URLListBindingManagerDelegate?
    
    // MARK: Data Source
    
    private let dataSelection: TagItem.Selection
    
    fileprivate weak var dataSource: URLItemDoublePersistanceType?
    
    private weak var tableView: UITableView?
    
    // MARK: Keep Track of Operations in Progress
    
    fileprivate var operationsInProgress = 0 {
        didSet {
            if oldValue != self.operationsInProgress {
                if self.operationsInProgress > 0 {
                    self.delegate?.didUpdate(operationsInProgress: true, bindingManager: self)
                } else {
                    self.delegate?.didUpdate(operationsInProgress: false, bindingManager: self)
                }
            }
        }
    }
    
    // MARK: External Properties that Need to be Set
    
    func quickLoad() {
        DispatchQueue.main.async {
            self.operationsInProgress += 1 // update the spinner
            
            let completionHandler: URLItemIDsResult = { result in
                let sortedIDs: [String]
                switch result {
                case .success(let ids):
                    sortedIDs = ids
                case .error(let errors):
                    NSLog("Errors While Loading: \(errors)")
                    sortedIDs = []
                }
                DispatchQueue.main.async {
                    self.updateTableView(withNewSortedIDs: sortedIDs)
                    self.operationsInProgress -= 1 // update the spinner
                }
            }
            
            switch self.dataSelection {
            case .allItems:
                self.dataSource?.allItems(sortedBy: .modificationDate, ascending: false, result: completionHandler)
            case .unarchivedItems:
                self.dataSource?.unarchivedItems(sortedBy: .modificationDate, ascending: false, result: completionHandler)
            case .tag(let tagName):
                self.dataSource?.allItems(for: tagName, sortedBy: .modificationDate, ascending: false, result: completionHandler)
            case .notSelectable:
                fatalError()
            }
        }
    }
    
    func sync() {
        self.operationsInProgress += 1
        self.dataSource?.sync() { result in
            DispatchQueue.main.async {
                //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10, execute: {
                self.operationsInProgress -= 1
                self.quickLoad()
                //})
            }
        }
    }
    
    init(selection: TagItem.Selection, tableView: UITableView?, dataSource: URLItemDoublePersistanceType?, delegate: URLListBindingManagerDelegate?) {
        let nib = UINib(nibName: URLItemTableViewCell.nibName, bundle: Bundle(for: URLItemTableViewCell.self))
        tableView?.register(nib, forCellReuseIdentifier: URLItemTableViewCell.nibName)
        
        self.dataSource = dataSource
        self.dataSelection = selection
        self.tableView = tableView
        self.delegate = delegate
        
        super.init()
        
        tableView?.allowsMultipleSelectionDuringEditing = true
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
    // MARK: Table View Data and Updating
    
    fileprivate var sortedIDs = [String]()
    
    private func updateTableView(withNewSortedIDs newSortedIDs: [String]) {
        DispatchQueue.main.async {
            let oldSortedIDs = self.sortedIDs
            DispatchQueue.global(qos: .userInteractive).async {
                if oldSortedIDs != newSortedIDs {
                    DispatchQueue.main.async {
                        self.sortedIDs = newSortedIDs
                        self.tableView?.reloadData()
                    }
                }
            }
        }
    }
}

extension URLListBindingManager: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: URLItemTableViewCell.nibName, for: indexPath)
        let castedCell = cell as? URLItemTableViewCell
        let itemID = self.sortedIDs[indexPath.row]
        castedCell?.id = itemID
        self.dataSource?.readItem(withID: itemID) { result in
            DispatchQueue.main.async {
                switch result {
                case .error(let errors):
                    NSLog("Cell ItemID: \(itemID), Error: \(errors)")
                    castedCell?.id = .none
                    castedCell?.item = .none
                case .success(let item):
                    castedCell?.item = item
                }
            }
        }
        return cell
    }
}

extension URLListBindingManager: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = tableView.urlItem(at: indexPath) else { return }
        if tableView.isEditing {
            self.delegate?.didChangeSelection(items: tableView.selectedURLItems, within: tableView, bindingManager: self)
        } else {
            self.delegate?.didChoose(item: item, within: tableView, bindingManager: self)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.delegate?.didChangeSelection(items: tableView.selectedURLItems, within: tableView, bindingManager: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard self.operationsInProgress == 0 else { return [] } // stops editing while syncing
        let archiveAction = UITableViewRowAction(style: .normal, title: "Archive") { rowAction, indexPath in
            guard let item = tableView.urlItem(at: indexPath) else { return }
            self.delegate?.didChooseToArchive(item: item, within: tableView, bindingManager: self)
        }
        archiveAction.backgroundColor = tableView.tintColor
        let tagAction = UITableViewRowAction(style: .normal, title: "Tag") { rowAction, indexPath in
            guard let item = tableView.urlItem(at: indexPath) else { return }
            self.delegate?.didChooseToTag(item: item, within: tableView, bindingManager: self)
        }
        return [archiveAction, tagAction]
    }
}

extension UITableView {
    var selectedURLItems: [URLItemType] {
        let selectedIndexPaths = self.indexPathsForSelectedRows ?? []
        let items = selectedIndexPaths.map({ (self.cellForRow(at: $0) as? URLItemTableViewCell)?.item }).flatMap({ $0 })
        return items
    }
    
    func urlItem(at indexPath: IndexPath) -> URLItemType? {
        let cell = self.cellForRow(at: indexPath) as? URLItemTableViewCell
        return cell?.item
    }
}


