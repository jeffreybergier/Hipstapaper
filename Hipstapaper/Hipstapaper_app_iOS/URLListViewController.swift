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
    
    enum Selection {
        case unarchivedItems, allItems, tag(TagItem)
    }
    
    private var selection: Selection?
    
    fileprivate var urlItems: Results<URLItem>?
    
    @IBOutlet private weak var tableView: UITableView? {
        didSet {
            let nib = UINib(nibName: URLTableViewCell.nibName, bundle: Bundle(for: URLTableViewCell.self))
            self.tableView?.register(nib, forCellReuseIdentifier: URLTableViewCell.nibName)
            self.tableView?.allowsMultipleSelectionDuringEditing = true
        }
    }
    
    convenience init(selection: Selection) {
        self.init()
        self.selection = selection
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        self.urlItems = urlItems
        self.notificationToken = urlItems?.addNotificationBlock(self.tableUpdateClosure)
        
//        Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { timer in
//            let realm = try! Realm()
//            try! realm.write {
//                let newURL = URLItem()
//                realm.add(newURL)
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
            self?.tableView?.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .left)
            self?.tableView?.endUpdates()
        case .error(let error):
            fatalError("\(error)")
        }

    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

extension URLListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let selectedItem = tableView.selectedURLItems?.first,
            let url = URL(string: selectedItem.urlString)
        else { return }
        
        let sfVC = SFSafariViewController(url: url, entersReaderIfAvailable: false)
        self.present(sfVC, animated: true, completion: .none)
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
