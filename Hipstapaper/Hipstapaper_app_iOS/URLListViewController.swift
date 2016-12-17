//
//  URLListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import UIKit

class URLListViewController: UIViewController {
    
    enum Selection {
        case unarchivedItems, allItems, tag(TagItem)
    }
    
    private var selection: Selection?
    
    fileprivate var urlItems: Results<URLItem>?
    
    @IBOutlet private weak var tableView: UITableView? {
        didSet {
            let nib = UINib(nibName: URLItemTableViewCell.nibName, bundle: Bundle(for: URLItemTableViewCell.self))
            self.tableView?.register(nib, forCellReuseIdentifier: URLItemTableViewCell.nibName)
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
            urlItems = realm.objects(URLItem.self).filter("archived = NO").sorted(byProperty: "creationDate", ascending: false)
        case .allItems:
            self.title = "All Items"
            urlItems = realm.objects(URLItem.self).sorted(byProperty: "creationDate", ascending: false)
        case .tag(let tagItem):
            self.title = "Tag: \(tagItem.name)"
            urlItems = .none
            let urlItems2 = tagItem.items
        }
        
        self.urlItems = urlItems
        self.notificationToken = urlItems?.addNotificationBlock() { changes in
            switch changes {
            case .initial:
                self.tableView?.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.tableView?.beginUpdates()
                self.tableView?.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .right)
                self.tableView?.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .left)
                self.tableView?.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
                self.tableView?.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
        
//        Timer.scheduledTimer(withTimeInterval: 20, repeats: true) { timer in
//            let realm = try! Realm()
//            try! realm.write {
//                let newURL = URLItem()
//                realm.add(newURL)
//            }
//        }
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

extension URLListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension URLListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.urlItems?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: URLItemTableViewCell.nibName, for: indexPath)
        if let cell = cell as? URLItemTableViewCell, let item = self.urlItems?[indexPath.row] {
            cell.item = item
        }
        return cell
    }
}
