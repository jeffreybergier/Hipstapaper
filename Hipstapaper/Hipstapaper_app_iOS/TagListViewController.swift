//
//  TagListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import UIKit

class TagListViewController: UIViewController, RealmControllable {
    
    fileprivate enum Section: Int {
        case readingList = 0, tags
    }
    
    @IBOutlet private weak var tableView: UITableView?
    fileprivate var tags: Results<TagItem>?
    weak var realmController: RealmController? {
        didSet {
            self.hardReloadData()
            self.presentedRealmControllables.forEach({ $0.realmController = self.realmController })
        }
    }
    
    private var immediatelyPresentNextVC = false
    
    convenience init(controller: RealmController, immediatelyPresentNextVC: Bool) {
        self.init()
        self.realmController = controller
        self.immediatelyPresentNextVC = immediatelyPresentNextVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        self.title = "Tags"
        
        if let controller = self.realmController, self.immediatelyPresentNextVC {
            // before we even load things, lets go to the main view of the app
            let newVC = URLListViewController(selection: .unarchived, controller: controller)
            self.navigationController?.pushViewController(newVC, animated: false)
            self.immediatelyPresentNextVC = false
        }
        
        // now lets load the data in the BG
        DispatchQueue.main.async {
            self.hardReloadData()
        }
    }
    
    private func hardReloadData() {
        // reset everything
        self.notificationToken?.stop()
        self.notificationToken = .none
        self.tags = .none
        self.tableView?.reloadData()
        
        // reload everything
        self.tags = self.realmController?.tags
        self.notificationToken = self.tags?.addNotificationBlock(self.tableUpdateClosure)
    }
    
    private lazy var tableUpdateClosure: ((RealmCollectionChange<Results<TagItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial:
            self?.tableView?.reloadData()
        case .update(_, let deletions, let insertions, let modifications):
            self?.tableView?.beginUpdates()
            self?.tableView?.insertRows(at: insertions.map({ IndexPath(row: $0, section: 1) }), with: .left)
            self?.tableView?.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 1)}), with: .left)
            self?.tableView?.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 1) }), with: .left)
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

extension TagListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return .none }
        switch section {
        case .readingList:
            return "Reading List"
        case .tags:
            return "Tags"
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let section = Section(rawValue: indexPath.section) else { return false }
        switch section {
        case .readingList:
            return false
        case .tags:
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section), section == .tags else { return }
        guard editingStyle == .delete else { return }
        guard let tagItem = self.tags?[indexPath.row] else { return }
        self.realmController?.delete(item: tagItem)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section), let controller = self.realmController else { return }
        let selection: URLItem.Selection
        switch section {
        case .readingList:
            selection = indexPath.row == 0 ? .unarchived : .all
        case .tags:
            guard let tagItem = self.tags?[indexPath.row] else { fatalError() }
            selection = .tag(tagItem)
        }
        let newVC = URLListViewController(selection: selection, controller: controller)
        self.navigationController?.pushViewController(newVC, animated: true)
    }
}

extension TagListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        switch section {
        case .readingList:
            return 2
        case .tags:
            return self.tags?.count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError() }
        
        let identifier = "BasicCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell(style: .value1, reuseIdentifier: identifier)
        
        switch section {
        case .readingList:
            cell.textLabel?.text = indexPath.row == 0 ? "Unread Items" : "All Items"
        case .tags:
            guard let tagItem = self.tags?[indexPath.row] else { return cell }
            cell.textLabel?.text = tagItem.name
            cell.detailTextLabel?.text = "\(tagItem.items.count)"
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}



