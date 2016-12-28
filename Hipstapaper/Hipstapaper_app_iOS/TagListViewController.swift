//
//  TagListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Aspects
import RealmSwift
import UIKit

extension UITableView {
    func deselectAllRows(animated: Bool) {
        for indexPath in self.indexPathsForSelectedRows ?? [] {
            self.deselectRow(at: indexPath, animated: animated)
        }
    }
}

class TagListViewController: UIViewController, RealmControllable {
    
    fileprivate enum Section: Int {
        case readingList = 0, tags
    }
    
    @IBOutlet private weak var tableView: UITableView?
    fileprivate var tags: Results<TagItem>?
    weak var realmController: RealmController? {
        didSet {
            self.hardReloadData()
        }
    }
    
    convenience init(controller: RealmController?) {
        self.init()
        self.realmController = controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        self.title = "Tags"
        
        // accounts button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Account", style: .plain, target: self, action: #selector(self.accountsBBITapped(_:)))
        
        // load tag data
        self.hardReloadData()
        
        // Subscribe to changes in realm controller
        NotificationCenter.default.addObserver(self, selector: #selector(self.realmControllerChanged(_:)), name: NSNotification.Name("RealmControllerChanged"), object: .none)
    }
    
    @objc private func realmControllerChanged(_ notification: Notification?) {
        if let newController = notification?.userInfo?["NewRealmController"] as? RealmController {
            self.realmController = newController
        } else {
            self.realmController = nil
        }
    }
    
    @objc private func accountsBBITapped(_ sender: NSObject?) {
        self.presentAccountsVC(animated: true)
    }
    
    func presentAccountsVC(animated: Bool) {
        let newVC = LoggedIniOSViewController()
        let navVC = UINavigationController(rootViewController: newVC)
        navVC.modalPresentationStyle = .formSheet
        self.splitViewController?.present(navVC, animated: animated, completion: .none)
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
        
        let displayedSelection = self?.splitViewController?.viewControllers.map({ ($0 as? UINavigationController)?.viewControllers.map({ ($0 as? URLListViewController)?.selection }) }).flatMap({$0}).flatMap({$0}).flatMap({$0}).first
        if let displayedSelection = displayedSelection {
            switch displayedSelection {
            case .unarchived:
                self?.tableView?.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
            case .all:
                self?.tableView?.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .none)
            case .tag(let tag):
                guard let index = self?.tags?.index(of: tag) else { return }
                self?.tableView?.selectRow(at: IndexPath(row: index, section: 1), animated: false, scrollPosition: .none)
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView?.flashScrollIndicators()
    }
    
    fileprivate lazy var presentedViewControllerDidDisappear: @convention(block) (Void) -> Void = { [weak self] in
        guard let topViewController = (self?.splitViewController?.viewControllers.last as? UINavigationController)?.topViewController, topViewController === self else { return }
        self?.tableView?.deselectAllRows(animated: true)
        self?.tableView?.flashScrollIndicators()
    }
    
    private var notificationToken: NotificationToken?
    fileprivate var deselectionToken: AspectToken?
    
    deinit {
        self.deselectionToken?.remove()
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
        guard let section = Section(rawValue: indexPath.section) else { return }
        let selection: URLItem.Selection
        switch section {
        case .readingList:
            selection = indexPath.row == 0 ? .unarchived : .all
        case .tags:
            guard let tagItem = self.tags?[indexPath.row] else { fatalError() }
            selection = .tag(tagItem)
        }
        
        self.deselectionToken?.remove()
        let newVC = URLListViewController.viewController(with: selection, and: self.realmController, preparedFor: self.splitViewController)
        self.deselectionToken = try? newVC.aspect_hook(#selector(UIViewController.viewDidDisappear(_:)), with: .positionBefore, usingBlock: self.presentedViewControllerDidDisappear)
        self.splitViewController?.showDetailViewController(newVC, sender: self)
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



