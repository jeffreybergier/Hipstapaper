//
//  TabAddRemoveViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import UIKit

class TagAddRemoveViewController: UIViewController {
    
    class func viewController(popoverSource: UIBarButtonItem, selectedItems: [URLItem]) -> UIViewController {
        let tagVC = TagAddRemoveViewController(selectedItems: selectedItems)
        let navVC = UINavigationController(rootViewController: tagVC)
        navVC.modalPresentationStyle = .popover
        navVC.popoverPresentationController!.barButtonItem = popoverSource
        navVC.presentationController!.delegate = tagVC
        return navVC
    }
    
    override var preferredContentSize: CGSize {
        get { return CGSize(width: 300, height: 400) }
        set { fatalError("Something is trying to set the preferredContentSize of: \(self)") }
    }
    
    @IBOutlet fileprivate weak var tableView: UITableView? {
        didSet {
            let nib = UINib(nibName: TagAddRemoveTableViewCell.nibName, bundle: Bundle(for: TagAddRemoveTableViewCell.self))
            self.tableView?.register(nib, forCellReuseIdentifier: TagAddRemoveTableViewCell.nibName)
        }
    }
    
    fileprivate var selectedItems = [URLItem]()
    fileprivate var tags: Results<TagItem>?
    
    convenience init(selectedItems: [URLItem]) {
        self.init()
        self.selectedItems = selectedItems
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        self.title = "Apply Tags"
        
        // configure dismiss buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addBBITapped(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneBBITapped(_:)))
        
        // get all the tags from realm
        let realm = try! Realm()
        self.tags = realm.objects(TagItem.self).sorted(byProperty: #keyPath(TagItem.name))
        self.notificationToken = self.tags?.addNotificationBlock(self.tableUpdateClosure)
    }
    
    private lazy var tableUpdateClosure: ((RealmCollectionChange<Results<TagItem>>) -> Void) = { [weak self] changes in
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
    
    @objc private func doneBBITapped(_ sender: NSObject?) {
        self.dismiss(animated: true, completion: .none)
    }
    
    @objc private func addBBITapped(_ sender: NSObject?) {
        let alertVC = UIAlertController(title: "New Tag", message: .none, preferredStyle: .alert)
        alertVC.addTextField(configurationHandler: { $0.placeholder = "tag name" })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: .none)
        let addAction = UIAlertAction(title: "Add", style: .default) { action in
            let newName = alertVC.textFields?.map({ $0.text }).flatMap({ $0 }).first ?? ""
            let tag = RealmConfig.newOrExistingTag(proposedName: newName)
            RealmConfig.apply(tag: tag, to: self.selectedItems)
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(addAction)
        self.present(alertVC, animated: true, completion: .none)
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

extension TagAddRemoveViewController: TagApplicationChangeDelegate {
    
    func didChangeTagApplication(_ newValue: Bool, sender: UITableViewCell) {
        guard let indexPath = self.tableView?.indexPath(for: sender), let tagItem = self.tags?[indexPath.row] else { return }
        switch newValue {
        case true:
            RealmConfig.apply(tag: tagItem, to: self.selectedItems)
        case false:
            RealmConfig.remove(tag: tagItem, from: self.selectedItems)
        }
    }
}

extension TagAddRemoveViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.tableView(tableView, numberOfRowsInSection: section) == 0 {
            return "No Tags Available"
        } else {
            return "\(self.selectedItems.count) Item(s) Selected"
        }
    }
}

extension TagAddRemoveViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagAddRemoveTableViewCell.nibName, for: indexPath)
        if let cell = cell as? TagAddRemoveTableViewCell, let tagItem = self.tags?[indexPath.row] {
            cell.tagNameLabel?.text = tagItem.name
            let state = RealmConfig.state(of: tagItem, with: self.selectedItems)
            cell.tagSwitch?.isOn = state.boolValue
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let tagItem = self.tags?[indexPath.row] else { return }
            RealmConfig.delete(items: [tagItem])
        case .insert, .none:
            break
        }
    }
}

extension TagAddRemoveViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

extension TagAddRemoveViewController: UIAdaptivePresentationControllerDelegate {
    // Returning UIModalPresentationNone will indicate that an adaptation should not happen.
    // @available(iOS 8.3, *)
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}


