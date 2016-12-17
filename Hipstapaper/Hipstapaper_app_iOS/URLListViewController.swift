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

extension UITableView: KVOCapable {}

class URLListViewController: UIViewController {
    
    enum Selection {
        case unarchivedItems, allItems, tag(TagItem)
    }
    
    private var selection: Selection?
    
    fileprivate var urlItems: Results<URLItem>?
    
    @IBOutlet fileprivate weak var tableView: UITableView? {
        didSet {
            let nib = UINib(nibName: URLTableViewCell.nibName, bundle: Bundle(for: URLTableViewCell.self))
            self.tableView?.register(nib, forCellReuseIdentifier: URLTableViewCell.nibName)
            self.tableView?.allowsMultipleSelectionDuringEditing = true
        }
    }
    
    fileprivate typealias UIBBI = UIBarButtonItem
    fileprivate lazy var editBBI: UIBBI = UIBBI(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(self.editBBITapped(_:)))
    fileprivate lazy var doneBBI: UIBBI = UIBBI(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneBBITapped(_:)))
    fileprivate lazy var archiveBBI: UIBBI = UIBBI(title: "📦", style: .plain, target: self, action: #selector(self.archiveBBITapped(_:)))
    fileprivate lazy var unarchiveBBI: UIBBI = UIBBI(title: "🎁", style: .plain, target: self, action: #selector(self.unarchiveBBITapped(_:)))
    fileprivate lazy var tagBBI: UIBBI = UIBBI(title: "🏷", style: .plain, target: self, action: #selector(self.tagBBITapped(_:)))
    fileprivate lazy var flexibleSpaceBBI: UIBBI = UIBBI(barButtonSystemItem: .flexibleSpace, target: .none, action: .none)
    
    
    convenience init(selection: Selection) {
        self.init()
        self.selection = selection
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // put us into non-edit mode
        self.doneBBITapped(.none)
        self.updateBBIEnableState(itemsSelectedInTableView: false)

        // configure data source
        // also set title in same switch
        let realm = try! Realm()
        let urlItems: Results<URLItem>?
        switch self.selection! {
        case .unarchivedItems:
            self.title = "Hipstapaper"
            let archived = #keyPath(URLItem.archived)
            let creationDate = #keyPath(URLItem.creationDate)
            urlItems = realm.objects(URLItem.self).filter("\(archived) = NO").sorted(byProperty: creationDate, ascending: false)
        case .allItems:
            self.title = "All Items"
            let creationDate = #keyPath(URLItem.creationDate)
            urlItems = realm.objects(URLItem.self).sorted(byProperty: creationDate, ascending: false)
        case .tag(let tagItem):
            self.title = "Tag: \(tagItem.name)"
            urlItems = .none
            let urlItems2 = tagItem.items
        }
        
        // set data source
        
        self.urlItems = urlItems
        self.notificationToken = urlItems?.addNotificationBlock(self.tableUpdateClosure)
        
//        var count = 1
//        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { timer in
//            let realm = try! Realm()
//            try! realm.write {
//                let newURL = URLItem()
//                newURL.urlString = "http://www.\(count).com"
//                realm.add(newURL)
//                count += 1
//            }
//        }
    }
    
    private lazy var tableUpdateClosure: ((RealmCollectionChange<Results<URLItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial:
            self?.tableView?.reloadData()
        case .update(_, let deletions, let insertions, let modifications):
            self?.tableView?.beginUpdates()
            self?.tableView?.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .right)
            self?.tableView?.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .left)
            self?.tableView?.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
            self?.tableView?.endUpdates()
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
        self.tableView?.setEditing(true, animated: true)
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
        self.setToolbarItems(items, animated: true)
    }
    
    @objc fileprivate func doneBBITapped(_ sender: NSObject?) {
        self.tableView?.setEditing(false, animated: true)
        let items = [
            self.flexibleSpaceBBI,
            self.editBBI
        ]
        self.setToolbarItems(items, animated: true)
    }
    
    @objc fileprivate func archiveBBITapped(_ sender: NSObject?) {
        guard let items = self.tableView?.selectedURLItems else { return }
        self.archive(true, items: items)
    }
    
    @objc fileprivate func unarchiveBBITapped(_ sender: NSObject?) {
        guard let items = self.tableView?.selectedURLItems else { return }
        self.archive(false, items: items)
    }
    
    private func archive(_ archive: Bool, items: [URLItem]) {
        let realm = try! Realm()
        realm.beginWrite()
        items.forEach() { item in
            item.archived = archive
        }
        try! realm.commitWrite()
    }
    
    @objc fileprivate func tagBBITapped(_ sender: NSObject?) {
        guard let bbi = sender as? UIBBI else { return }
        guard let items = self.tableView?.selectedURLItems else { return }
        let tagVC = TagAddRemoveViewController.viewController(popoverSource: bbi, selectedItems: items)
        self.present(tagVC, animated: true, completion: .none)
    }
    
    fileprivate func updateBBIEnableState(itemsSelectedInTableView selected: Bool) {
        self.archiveBBI.isEnabled = selected
        self.unarchiveBBI.isEnabled = selected
        self.tagBBI.isEnabled = selected
    }
}

extension URLListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItems = tableView.selectedURLItems ?? []
        if tableView.isEditing {
            let anythingSelected = selectedItems.isEmpty ? false : true
            self.updateBBIEnableState(itemsSelectedInTableView: anythingSelected)
        } else {
            guard let selectedItem = selectedItems.first, let url = URL(string: selectedItem.urlString) else { return }
            let sfVC = SFSafariViewController(url: url, entersReaderIfAvailable: false)
            self.present(sfVC, animated: true, completion: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedItems = tableView.selectedURLItems ?? []
        let anythingSelected = selectedItems.isEmpty ? false : true
        self.updateBBIEnableState(itemsSelectedInTableView: anythingSelected)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let item = tableView.urlItemFor(row: indexPath) else { return .none }
        //let archiveActionTitle = item.archived ? "📤" : "📥"
        let archiveActionTitle = item.archived ? "🎁" : "📦"
        let archiveToggleAction = UITableViewRowAction(style: .normal, title: archiveActionTitle) { action, indexPath in
            let realm = try! Realm()
            realm.beginWrite()
            item.archived = !item.archived
            try! realm.commitWrite()
        }
        archiveToggleAction.backgroundColor = tableView.tintColor
        
        let tagAction = UITableViewRowAction(style: .normal, title: "🏷") { action, indexPath in
            print("tag: \(item.urlString)")
        }
        return [archiveToggleAction, tagAction]
    }
}

extension URLListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.urlItems?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: URLTableViewCell.nibName, for: indexPath)
        if let cell = cell as? URLTableViewCell, let item = self.urlItems?[indexPath.row] {
            cell.item = item
        }
        return cell
    }
}
