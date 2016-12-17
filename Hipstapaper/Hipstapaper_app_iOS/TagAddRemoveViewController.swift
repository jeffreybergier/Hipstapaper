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
    
    fileprivate var closuresToExecuteOnSave = [() -> Void]()
    
    convenience init(selectedItems: [URLItem]) {
        self.init()
        self.selectedItems = selectedItems
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        self.title = "Apply Tags"
        
        // configure dismiss buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneBBITapped(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelBBITapped(_:)))
        
        // get all the tags from realm
        let realm = try! Realm()
        self.tags = realm.objects(TagItem.self).sorted(byProperty: "name")
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
        let realm = try! Realm()
        realm.beginWrite()
        self.closuresToExecuteOnSave.forEach({ $0() })
        try! realm.commitWrite()
        self.dismiss(animated: true, completion: .none)
    }
    
    @objc private func cancelBBITapped(_ sender: NSObject?) {
        self.dismiss(animated: true, completion: .none)
    }
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

extension TagAddRemoveViewController: TagApplicationChangeDelegate {
    func didChangeTagApplication(_ newValue: Bool, sender: UITableViewCell) {
        guard let indexPath = self.tableView?.indexPath(for: sender), let tagItem = self.tags?[indexPath.row] else { return }
        let urlItems = self.selectedItems
        self.closuresToExecuteOnSave.append() {
            for urlItem in urlItems {
                if newValue == true {
                    guard urlItem.tags.index(of: tagItem) == nil else { continue }
                    urlItem.tags.append(tagItem)
                    let name = tagItem.name
                    tagItem.name = name // hack to trigger Realm change notification
                } else {
                    guard let index = urlItem.tags.index(of: tagItem) else { continue }
                    urlItem.tags.remove(objectAtIndex: index)
                    let name = tagItem.name
                    tagItem.name = name // hack to trigger Realm change notification
                }
            }
        }
    }
}

extension TagAddRemoveViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(self.selectedItems.count) Item(s) Selected"
    }
}

extension TagAddRemoveViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tags?.count ?? 0
    }
    
    private func atLeastOneSelectedItemReferences(tag tagItem: TagItem) -> Bool {
        for urlItem in self.selectedItems {
            guard let _ = urlItem.tags.index(of: tagItem) else { continue }
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagAddRemoveTableViewCell.nibName, for: indexPath)
        if let cell = cell as? TagAddRemoveTableViewCell, let tagItem = self.tags?[indexPath.row] {
            cell.tagNameLabel?.text = tagItem.name
            cell.tagSwitch?.isOn = self.atLeastOneSelectedItemReferences(tag: tagItem)
            cell.delegate = self
        }
        return cell
    }
}

extension TagAddRemoveViewController: UIPopoverPresentationControllerDelegate {
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return false
    }
}

extension TagAddRemoveViewController: UIAdaptivePresentationControllerDelegate {
    // Returning UIModalPresentationNone will indicate that an adaptation should not happen.
    // @available(iOS 8.3, *)
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}


