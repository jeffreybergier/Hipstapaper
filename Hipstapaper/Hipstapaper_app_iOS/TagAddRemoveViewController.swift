//
//  TabAddRemoveViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import UIKit

class TagAddRemoveViewController: UIViewController, RealmControllable {
    
    enum PresentationStyle {
        case popBBI(UIBarButtonItem)
        case popCustom(rect: CGRect, view: UIView)
        case formSheet
    }
    
    class func viewController(style: PresentationStyle, selectedItems: [URLItem], controller: RealmController) -> UIViewController {
        let tagVC = TagAddRemoveViewController(selectedItems: selectedItems, controller: controller)
        let navVC = UINavigationController(rootViewController: tagVC)
        tagVC.presentationStyle = style
        switch style {
        case .popBBI(let bbi):
            navVC.modalPresentationStyle = .popover
            navVC.popoverPresentationController!.barButtonItem = bbi
        case .popCustom(let rect, let view):
            navVC.modalPresentationStyle = .popover
            navVC.popoverPresentationController!.sourceRect = rect
            navVC.popoverPresentationController!.sourceView = view
        case .formSheet:
            navVC.modalPresentationStyle = .formSheet
        }
        navVC.presentationController!.delegate = tagVC
        return navVC
    }
    
    @IBOutlet fileprivate weak var tableView: UITableView? {
        didSet {
            let nib = UINib(nibName: TagAddRemoveTableViewCell.nibName, bundle: Bundle(for: TagAddRemoveTableViewCell.self))
            self.tableView?.register(nib, forCellReuseIdentifier: TagAddRemoveTableViewCell.nibName)
        }
    }
    
    fileprivate var tags: Results<TagItem>?
    fileprivate var selectedItems = [URLItem]()
    fileprivate private(set) var presentationStyle = PresentationStyle.formSheet
    weak var realmController: RealmController? {
        didSet {
            self.hardReloadData()
            self.presentedRealmControllables.forEach({ $0.realmController = self.realmController })
        }
    }
    
    convenience init(selectedItems: [URLItem], controller: RealmController) {
        self.init()
        self.selectedItems = selectedItems
        self.realmController = controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        self.title = "Apply Tags"
        
        // configure dismiss buttons
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addBBITapped(_:)))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneBBITapped(_:)))
        
        // load the data
        self.hardReloadData()
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
            guard let realmController = self.realmController else { return }
            let newName = alertVC.textFields?.map({ $0.text }).flatMap({ $0 }).first ?? ""
            let tag = realmController.newOrExistingTag(proposedName: newName)
            realmController.apply(tag: tag, to: self.selectedItems)
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
            self.realmController?.apply(tag: tagItem, to: self.selectedItems)
        case false:
            self.realmController?.remove(tag: tagItem, from: self.selectedItems)
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
            let state = self.realmController?.state(of: tagItem, with: self.selectedItems) ?? .mixed
            cell.tagSwitch?.isOn = state.boolValue
            cell.delegate = self
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            guard let tagItem = self.tags?[indexPath.row] else { return }
            self.realmController?.delete(items: [tagItem])
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

    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        
        switch self.presentationStyle {
        case .popBBI, .popCustom:
            // if we were able to present as popover
            // always present as popover, on any device
            // returning .none tells the system DO NOT adapt, so it stays as a popover
            return .none
        case .formSheet:
            return .formSheet
        }
    }

}


