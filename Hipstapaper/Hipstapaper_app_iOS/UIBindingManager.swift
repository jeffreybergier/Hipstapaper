//
//  UIBindingManager.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/8/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import UIKit

protocol UIBindingDelegate: class {
    func didSelect(item: URLItemType, within: UITableView, bindingManager: UIBindingManager)
}

class UIBindingManager: NSObject {
    
    // Delegate
    
    weak var delegate: UIBindingDelegate?
    
    // Table View Property
    
    @IBOutlet private weak var tableView: UITableView?
    
    // Data Source Temp State
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
    
    // UILoading State
    
    private var spinnerOperationsInProgress = 0 {
        didSet {
            print("\(self.spinnerOperationsInProgress): Ops in Progress")
        }
    }
    
    // One Time Config
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: URLItemTableViewCell.nibName, bundle: Bundle(for: URLItemTableViewCell.self))
        self.tableView?.register(nib, forCellReuseIdentifier: URLItemTableViewCell.nibName)
    }
    
    // External Interface
    
    weak internal var dataSource: DoubleSourcePersistenceType? {
        didSet {
            self.reloadData()
        }
    }
    
    var selectedItems: [URLItemType]? {
        return .none
    }
    
    internal func reloadData() {
        self.spinnerOperationsInProgress += 1 // update the spinner
        self.dataSource?.sync(sortedBy: .modificationDate, ascending: false, quickResult: { quickResult in
            let sortedIDs: [String]
            switch quickResult {
            case .success(let ids):
                sortedIDs = ids
            case .error(let errors):
                NSLog("Errors While Syncing: \(errors)")
                sortedIDs = []
            }
            self.updateTableView(withNewSortedIDs: sortedIDs)
        }, fullResult: { fullResult in
            let sortedIDs: [String]
            switch fullResult {
            case .success(let ids):
                sortedIDs = ids
            case .error(let errors):
                NSLog("Errors While Syncing: \(errors)")
                sortedIDs = []
            }
            self.updateTableView(withNewSortedIDs: sortedIDs)
            self.spinnerOperationsInProgress -= 1 // update the spinner
        })
    }
}

extension UIBindingManager: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sortedIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: URLItemTableViewCell.nibName, for: indexPath)
        let castedCell = cell as? URLItemTableViewCell
        let itemID = self.sortedIDs[indexPath.row]
        castedCell?.id = itemID
        self.dataSource?.readItem(withID: itemID, quickResult: { result in
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
        }, fullResult: .none)
        return cell
    }
}

extension UIBindingManager: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? URLItemTableViewCell
        guard let item = cell?.item else { return }
        self.delegate?.didSelect(item: item, within: tableView, bindingManager: self)
    }
    
}
