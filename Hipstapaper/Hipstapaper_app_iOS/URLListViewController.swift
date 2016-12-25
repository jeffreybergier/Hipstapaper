//
//  URLListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import SafariServices
import UIKit

class URLListViewController: UIViewController {
    
    private var selection: URLItem.Selection = .unarchived
    fileprivate var data: Results<URLItem>?
    
    fileprivate var selectedURLItems: [URLItem]? {
        guard
            let data = self.data,
            let indexPaths = self.tableView?.indexPathsForSelectedRows,
            indexPaths.isEmpty == false
        else { return .none}
        let items = indexPaths.map({ data[$0.row] })
        return items
    }
    
    @IBOutlet fileprivate weak var tableView: UITableView? {
        didSet {
            let imageNib = UINib(nibName: URLTableViewCell.withImageNIBName, bundle: Bundle(for: URLTableViewCell.self))
            let noImageNib = UINib(nibName: URLTableViewCell.withOutImageNIBName, bundle: Bundle(for: URLTableViewCell.self))
            self.tableView?.register(imageNib, forCellReuseIdentifier: URLTableViewCell.withImageNIBName)
            self.tableView?.register(noImageNib, forCellReuseIdentifier: URLTableViewCell.withOutImageNIBName)
            self.tableView?.allowsMultipleSelectionDuringEditing = true
            self.tableView?.rowHeight = URLTableViewCell.cellHeight
            self.tableView?.estimatedRowHeight = URLTableViewCell.cellHeight
        }
    }
    
    fileprivate typealias UIBBI = UIBarButtonItem
    fileprivate lazy var editBBI: UIBBI = UIBBI(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(self.editBBITapped(_:)))
    fileprivate lazy var doneBBI: UIBBI = UIBBI(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneBBITapped(_:)))
    fileprivate lazy var archiveBBI: UIBBI = UIBBI(title: "📥Archive", style: .plain, target: self, action: #selector(self.archiveBBITapped(_:)))
    fileprivate lazy var unarchiveBBI: UIBBI = UIBBI(title: "📤Unarchive", style: .plain, target: self, action: #selector(self.unarchiveBBITapped(_:)))
    fileprivate lazy var tagBBI: UIBBI = UIBBI(title: "🏷Tag", style: .plain, target: self, action: #selector(self.tagBBITapped(_:)))
    fileprivate let flexibleSpaceBBI: UIBBI = UIBBI(barButtonSystemItem: .flexibleSpace, target: .none, action: .none)
    
    convenience init(selection: URLItem.Selection) {
        self.init()
        self.selection = selection
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // put us into non-edit mode
        self.doneBBITapped(.none)
        self.disableAllBBI()

        // set title
        switch self.selection {
        case .unarchived:
            self.title = "Hipstapaper"
        case .all:
            self.title = "All Items"
        case .tag(let tagItem):
            self.title = "🏷 \(tagItem.name)"
        }
        
        // configure data source
        let items = RealmConfig.urlItems(for: selection, sortOrder: URLItem.SortOrder.creationDate(newestFirst: true))
        self.data = items
        self.notificationToken = items.addNotificationBlock(self.realmResultsChangeClosure)
    }
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<URLItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial:
            self?.tableView?.reloadData()
        case .update(_, let deletions, let insertions, let modifications):
            self?.tableView?.beginUpdates()
            self?.tableView?.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .right)
            self?.tableView?.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .left)
            self?.tableView?.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
            self?.tableView?.endUpdates()
            let itemsSelectedAfterUpdate = self?.selectedURLItems ?? []
            self?.updateBBI(with: itemsSelectedAfterUpdate)
        case .error(let error):
            fatalError("\(error)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

extension URLListViewController /* Handle BarButtonItems */ {
    @objc fileprivate func editBBITapped(_ sender: NSObject?) {
        
        // manage the table view
        // if a row is slidden over, we need to close it
        if self.tableView?.isEditing ?? false { self.tableView?.setEditing(false, animated: true) }
        // then switch the table view to editing mode
        self.tableView?.setEditing(true, animated: true)
        
        // manage the toolbar item
        let items = [
            self.flexibleSpaceBBI,
            self.tagBBI,
            self.flexibleSpaceBBI,
            self.unarchiveBBI,
            self.flexibleSpaceBBI,
            self.archiveBBI,
            self.flexibleSpaceBBI,
            self.doneBBI
        ]
        self.disableAllBBI()
        self.setToolbarItems(items, animated: true)
    }
    
    @objc fileprivate func doneBBITapped(_ sender: NSObject?) {
        self.tableView?.setEditing(false, animated: true)
        let items = [
            self.flexibleSpaceBBI,
            self.editBBI
        ]
        self.disableAllBBI()
        self.setToolbarItems(items, animated: true)
    }
    
    @objc fileprivate func archiveBBITapped(_ sender: NSObject?) {
        guard let items = self.selectedURLItems else { return }
        RealmConfig.updateArchived(to: true, on: items)
        self.disableAllBBI()
    }
    
    @objc fileprivate func unarchiveBBITapped(_ sender: NSObject?) {
        guard let items = self.selectedURLItems else { return }
        RealmConfig.updateArchived(to: false, on: items)
        self.disableAllBBI()
    }
    
    @objc fileprivate func tagBBITapped(_ sender: NSObject?) {
        guard let bbi = sender as? UIBBI else { return }
        guard let items = self.selectedURLItems else { return }
        let tagVC = TagAddRemoveViewController.viewController(style: .popBBI(bbi), selectedItems: items)
        self.present(tagVC, animated: true, completion: .none)
        self.tableView?.setEditing(false, animated: true)
    }
    
    fileprivate func disableAllBBI() {
        self.archiveBBI.isEnabled = false
        self.unarchiveBBI.isEnabled = false
        self.tagBBI.isEnabled = false
    }
    
    fileprivate func updateBBI(with items: [URLItem]) {
        if items.isEmpty {
            self.disableAllBBI()
        } else {
            self.tagBBI.isEnabled = true
            self.archiveBBI.isEnabled = RealmConfig.atLeastOneItem(in: items, canBeArchived: true)
            self.unarchiveBBI.isEnabled = RealmConfig.atLeastOneItem(in: items, canBeArchived: false)
        }
    }
}

extension URLListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItems = self.selectedURLItems ?? []
        if tableView.isEditing {
            self.updateBBI(with: selectedItems)
        } else {
            guard let selectedItem = selectedItems.first, let url = URL(string: selectedItem.urlString) else { return }
            let sfVC = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            self.present(sfVC, animated: true, completion: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedItems = self.selectedURLItems ?? []
        self.updateBBI(with: selectedItems)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return URLTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let item = self.data?[indexPath.row] else { return .none }
        let archiveActionTitle = item.archived ? "📤Unarchive" : "📥Archive"
        let archiveToggleAction = UITableViewRowAction(style: .normal, title: archiveActionTitle) { action, indexPath in
            let realm = try! Realm()
            realm.beginWrite()
            item.archived = !item.archived
            try! realm.commitWrite()
        }
        archiveToggleAction.backgroundColor = tableView.tintColor
        
        let tagAction = UITableViewRowAction(style: .normal, title: "🏷Tag") { action, indexPath in
            if let actionButton = action.perform("_button")?.takeUnretainedValue() as? UIButton {
                // use 'private' api to get the actual rect and view of the button the user clicked on
                // then present the popover from that view
                let rect = actionButton.frame
                let tagVC = TagAddRemoveViewController.viewController(style: .popCustom(rect: rect, view: actionButton), selectedItems: [item])
                self.present(tagVC, animated: true, completion: nil)
            } else {
                // if that fails
                // present as generic form sheet
                let tagVC = TagAddRemoveViewController.viewController(style: .formSheet, selectedItems: [item])
                self.present(tagVC, animated: true, completion: nil)
            }
        }
        return [archiveToggleAction, tagAction]
    }
}

extension URLListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.data![indexPath.row]
        
        let cell: URLTableViewCell
        if let _ = item.extras?.image {
            cell = tableView.dequeueReusableCell(withIdentifier: URLTableViewCell.withImageNIBName, for: indexPath) as! URLTableViewCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: URLTableViewCell.withOutImageNIBName, for: indexPath) as! URLTableViewCell
        }
        
        cell.configure(with: item)
        
        return cell
    }
}
