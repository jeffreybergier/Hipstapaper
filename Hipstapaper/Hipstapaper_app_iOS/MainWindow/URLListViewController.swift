//
//  URLListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Common
import RealmSwift
import SafariServices
import UIKit

class URLListViewController: UIViewController, RealmControllable {
    
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
    fileprivate lazy var sortBBI: UIBBI = UIBBI(title: "Sort", style: .plain, target: self, action: #selector(self.sortBBITapped(_:)))
    fileprivate lazy var filterBBI: UIBBI = UIBBI(title: "Filter", style: .plain, target: self, action: #selector(self.filterBBITapped(_:)))
    fileprivate let flexibleSpaceBBI: UIBBI = UIBBI(barButtonSystemItem: .flexibleSpace, target: .none, action: .none)
    fileprivate let verticalBarSpaceBBI: UIBBI = {
        let bbi = UIBBI(title: "|", style: .plain, target: .none, action: .none)
        bbi.isEnabled = false
        return bbi
    }()
    
    
    // MARK: Selection
    
    var itemsToLoad = UserDefaults.standard.userSelection.itemsToLoad
    var filter = UserDefaults.standard.userSelection.filter
    var sortOrder = UserDefaults.standard.userSelection.sortOrder
    
    fileprivate weak var selectionDelegate: URLItemsToLoadChangeDelegate?
    
    // MARK: Data
    
    fileprivate var data: Results<URLItem>?
    
    weak var realmController: RealmController? {
        didSet {
            // forward the message to any presented view controllers
            let addRemoveTagPopoverVC = (self.presentedViewController as? UINavigationController)?.viewControllers.first as? RealmControllable
            addRemoveTagPopoverVC?.realmController = self.realmController
            
            // reload the data
            self.hardReloadData()
        }
    }
    
    fileprivate var selectedURLItems: [URLItem]? {
        guard
            let data = self.data,
            let indexPaths = self.tableView?.indexPathsForSelectedRows,
            indexPaths.isEmpty == false
        else { return .none}
        let items = indexPaths.map({ data[$0.row] })
        return items
    }
    
    convenience init(selectionDelegate: URLItemsToLoadChangeDelegate, controller: RealmController?) {
        self.init()
        self.selectionDelegate = selectionDelegate
        self.realmController = controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register for 3d touch events
        if case .available = self.traitCollection.forceTouchCapability {
            self.registerForPreviewing(with: self, sourceView: view)
        }
        
        // because we are in a split view, we fully own our own Navigation Controller
        // therefore we don't need to micromanage this when switching views.
        // its always present
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        // configure myself for splitview
        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true
        
        // put us into non-edit mode
        self.doneBBITapped(.none)
        self.disableAllBBI()
        
        // load the data
        self.hardReloadData()
    }
    
    fileprivate func hardReloadData() {
        // get values in case things change
        let itemsToLoad = self.itemsToLoad
        let filter = self.filter
        let sortOrder = self.sortOrder
        
        // set title
        switch itemsToLoad {
        case .all:
            switch self.filter {
            case .all:
                self.title = "All Items"
            case .unarchived:
                self.title = "Hipstapaper"
            }
        case .tag(let tagID):
            self.title = "🏷 \(tagID.displayName)"
        }
        
        // clear things out
        self.notificationToken?.stop()
        self.notificationToken = .none
        self.data = .none
        if self.tableView?.numberOfRows(inSection: 0) != 0 { self.tableView?.reloadData() } // helps reduce flickering the tableview is already empty
        self.doneBBITapped(.none)
        
        // configure data source
        self.data = self.realmController?.url_loadAll(for: itemsToLoad, sortedBy: sortOrder, filteredBy: filter)
        self.notificationToken = self.data?.addNotificationBlock(self.realmResultsChangeClosure)
        self.tableView?.reloadData()
    }
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<URLItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial:
            break // forcing reload synchronously to improve app state restoration behavior
        case .update(_, let deletions, let insertions, let modifications):
            self?.tableView?.beginUpdates()
            self?.tableView?.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .left)
            self?.tableView?.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .right)
            self?.tableView?.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
            self?.tableView?.endUpdates()
            let itemsSelectedAfterUpdate = self?.selectedURLItems ?? []
            self?.updateBBI(with: itemsSelectedAfterUpdate)
        case .error(let error):
            let alert = UIAlertController(title: "Error Loading Reading List", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: .none)
            alert.addAction(action)
            self?.present(alert, animated: true, completion: .none)
            self?.data = .none
            self?.tableView?.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateNavBarHiding(basedOn: self.view.traitCollection)
        self.tableView?.flashScrollIndicators()
        let isEditing = self.tableView?.isEditing ?? false
        if isEditing == false {
            // if we're not editing when we appear its probably because of fresh launch or because the user dismissed SafariVC
            // so we need to deselect the row
            self.tableView?.deselectAllRows(animated: true)
        } else {
            // if we are editing when we appear, we probably restored from state restoration
            // if so we need to update the BBI so that the user can tap the appropriate ones.
            let selectedItems = self.selectedURLItems ?? []
            self.updateBBI(with: selectedItems)
        }
    }
    
    // MARK: Watch for shake gesture for deleting
    
    private func validateDelete() -> Bool {
        guard self.presentedViewController == .none, let items = self.selectedURLItems, items.isEmpty == false else { return false }
        return true
    }
    
    private func shakeToDelete() {
        guard let realmController = self.realmController, let items = self.selectedURLItems, items.isEmpty == false else { return }
        let alert = UIAlertController(title: "Delete \(items.count) Item(s)?", message: "This action cannot be undone.", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: .none)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { action in
            realmController.delete(items)
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        self.emergencyDismiss(thenPresentViewController: alert)
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        switch motion {
        case .motionShake:
            guard self.validateDelete() else { super.motionEnded(motion, with: event); return; }
            self.shakeToDelete()
        default:
            super.motionEnded(motion, with: event)
        }
    }
    
    // MARK: Change Bar Hiding on Compact Vertical Size Class Change
    
    private func updateNavBarHiding(basedOn traitCollection: UITraitCollection) {
        switch traitCollection.verticalSizeClass {
        case .compact:
            self.navigationController?.hidesBarsOnSwipe = true
        case .regular, .unspecified:
            self.navigationController?.hidesBarsOnSwipe = false
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        self.updateNavBarHiding(basedOn: newCollection)
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    // MARK: State Restoration
    
    private static let kTableViewWasEditing = "kTableViewWasEditingKey"
    
    override func decodeRestorableState(with coder: NSCoder) {
        let wasEditing = coder.decodeBool(forKey: type(of: self).kTableViewWasEditing)
        if wasEditing == true {
            self.editBBITapped(self)
        }
        super.decodeRestorableState(with: coder)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        let wasEditing = self.tableView?.isEditing ?? false
        coder.encode(wasEditing, forKey: type(of: self).kTableViewWasEditing)
        super.encodeRestorableState(with: coder)
    }
    
    // MARK: Deinit
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

extension URLListViewController: URLItemsToLoadChangeDelegate {
    func didChange(itemsToLoad: URLItem.ItemsToLoad?, sortOrder: URLItem.SortOrder?, filter: URLItem.ArchiveFilter?, sender: ViewControllerSender) {
        switch sender {
        case .contentVC:
            fatalError()
        case .tertiaryVC:
            // if the user changes the selection in the custom VC, we need to notify the source list
            self.selectionDelegate?.didChange(itemsToLoad: itemsToLoad ?? self.itemsToLoad,
                                              sortOrder: sortOrder ?? self.sortOrder,
                                              filter: filter ?? self.filter,
                                              sender: .contentVC)
            // then fall through to follow the logic of normal selection coming from the source list
            fallthrough
        case .sourceListVC:
            var changedSomething = false
            if let itemsToLoad = itemsToLoad {
                self.itemsToLoad = itemsToLoad
                changedSomething = true
            }
            if let sortOrder = sortOrder {
                self.sortOrder = sortOrder
                changedSomething = true
            }
            if let filter = filter {
                self.filter = filter
                changedSomething = true
            }
            if changedSomething {
                self.hardReloadData()
            }
        }
    }
}

extension URLListViewController /* Handle BarButtonItems */ {
    @objc fileprivate func editBBITapped(_ sender: NSObject?) {
        let enterEditMode = {
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
        
        // HIG states that a popover should be dismissiable and a new one presentable in one tap
        self.emergencyDismiss(thenDo: enterEditMode)
    }
    
    @objc fileprivate func doneBBITapped(_ sender: NSObject?) {
        self.emergencyDismiss() { // dismisses any popovers and then does the action
            self.tableView?.setEditing(false, animated: true)
            let items = [
                self.sortBBI,
                self.verticalBarSpaceBBI,
                self.filterBBI,
                self.flexibleSpaceBBI,
                self.editBBI
            ]
            self.disableAllBBI()
            self.setToolbarItems(items, animated: true)
        }
    }
    
    @objc fileprivate func archiveBBITapped(_ sender: NSObject?) {
        self.emergencyDismiss() { // dismisses any popovers and then does the action
            guard let items = self.selectedURLItems else { return }
            self.realmController?.url_setArchived(to: true, on: items)
            self.disableAllBBI()
        }
    }
    
    @objc fileprivate func unarchiveBBITapped(_ sender: NSObject?) {
        self.emergencyDismiss() { // dismisses any popovers and then does the action
            guard let items = self.selectedURLItems else { return }
            self.realmController?.url_setArchived(to: false, on: items)
            self.disableAllBBI()
        }
    }
    
    @objc fileprivate func tagBBITapped(_ sender: NSObject?) {
        guard
            let bbi = sender as? UIBBI,
            let items = self.selectedURLItems,
            let realmController = self.realmController
        else { return }
        let tagVC = TagAddRemoveViewController.viewController(style: .popBBI(bbi), selectedItems: items, controller: realmController)
        self.present(tagVC, animated: true, completion: .none)
    }
    
    @objc fileprivate func sortBBITapped(_ sender: NSObject?) {
        guard let bbi = sender as? UIBBI else { return }
        let vc = SortSelectingiOSViewController.newPopover(kind: .sort(currentSort: self.sortOrder), delegate: self, from: bbi)
        // HIG states that a popover should be dismissiable and a new one presentable in one tap
        self.emergencyDismiss(thenPresentViewController: vc)
    }
    
    @objc fileprivate func filterBBITapped(_ sender: NSObject?) {
        guard let bbi = sender as? UIBBI else { return }
        let vc = SortSelectingiOSViewController.newPopover(kind: .filter(currentFilter: self.filter), delegate: self, from: bbi)
        // HIG states that a popover should be dismissiable and a new one presentable in one tap
        self.emergencyDismiss(thenPresentViewController: vc)
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
            self.archiveBBI.isEnabled = !items.filter({ $0.archived == false }).isEmpty
            self.unarchiveBBI.isEnabled = !items.filter({ $0.archived == true }).isEmpty
        }
    }
}

extension URLListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let realmController = self.realmController,
            let tableView = self.tableView,
            let indexPath = tableView.indexPathForRow(at: self.view.convert(location, to: tableView)),
            let cellView = tableView.cellForRow(at: indexPath),
            let item = self.data?[indexPath.row],
            let url = URL(string: item.urlString)
        else { return .none }
        
        // Lets create some cool 3d actions
        // this code is almost a duplicate of the row actions
        // but ever so slightly different
        // might be able to abstract later, but for now, it works
        let archiveActionTitle = item.archived ? "📤 Unarchive" : "📥 Archive"
        let archiveAction = UIPreviewAction(title: archiveActionTitle, style: .default) { _ in
            let newArchiveValue = !item.archived
            realmController.url_setArchived(to: newArchiveValue, on: [item])
        }
        let tagAction = UIPreviewAction(title: "🏷 Tag", style: .default) { [weak self] _ in
            let presentation = TagAddRemoveViewController.PresentationStyle.popCustom(rect: cellView.bounds, view: cellView)
            let tagVC = TagAddRemoveViewController.viewController(style: presentation, selectedItems: [item], controller: realmController)
            self?.present(tagVC, animated: true, completion: nil)
        }
        // use my special preview action injection SafariViewController
        // the actions are queried for on the presented view controller
        // but SFSafariViewController knows nothing about realm controller, no do I want it to
        let sfVC = URLSafariViewController(url: url, previewActions: [tagAction, archiveAction])
        
        // give the previewing context the Rect that the CellView is in so it knows where this 3d touch came from
        previewingContext.sourceRect = tableView.convert(cellView.frame, to: self.view)
        
        // return the configured view controller
        return sfVC
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        // i'm not sure why apple makes you do this
        // but they make you confirm that you actually want to present this new view controller
        // so I just check to make sure its a safari view controller of some kind
        // then present
        guard viewControllerToCommit is SFSafariViewController else { return }
        self.present(viewControllerToCommit, animated: true, completion: .none)
    }
}

extension URLListViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItems = self.selectedURLItems ?? []
        if tableView.isEditing {
            self.updateBBI(with: selectedItems)
        } else {
            guard let selectedItem = selectedItems.first, let url = URL(string: selectedItem.urlString) else { return }
            let sfVC = URLSafariViewController(url: url, previewActions: .none)
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
        guard
            let item = self.data?[indexPath.row],
            let cellView = tableView.cellForRow(at: indexPath),
            let realmController = self.realmController
        else { return .none }
        
        let archiveActionTitle = item.archived ? "📤Unarchive" : "📥Archive"
        let archiveToggleAction = UITableViewRowAction(style: .normal, title: archiveActionTitle) { action, indexPath in
            let newArchiveValue = !item.archived
            self.realmController?.url_setArchived(to: newArchiveValue, on: [item])
        }
        archiveToggleAction.backgroundColor = tableView.tintColor
        
        let tagAction = UITableViewRowAction(style: .normal, title: "🏷Tag") { [weak self] action, indexPath in
            let selector: Selector = "_button"
            let popoverView: UIView
            if action.responds(to: selector), let actionButton = action.perform(selector)?.takeUnretainedValue() as? UIView {
                // use 'private' api to get the actual rect and view of the button the user clicked on
                // then present the popover from that view
                popoverView = actionButton
            } else {
                // if we can't get that button, then just popover on the cell view
                popoverView = cellView
            }
            let presentation = TagAddRemoveViewController.PresentationStyle.popCustom(rect: popoverView.bounds, view: popoverView)
            let tagVC = TagAddRemoveViewController.viewController(style: presentation, selectedItems: [item], controller: realmController)
            self?.present(tagVC, animated: true, completion: nil)
        }
        return [archiveToggleAction, tagAction]
    }
}

extension URLListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.data?[indexPath.row]
        let identifier = item?.extras?.image == .none ? URLTableViewCell.withOutImageNIBName : URLTableViewCell.withImageNIBName
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = cell as? URLTableViewCell, let item = item {
            cell.configure(with: item)
        }
        return cell
    }
}

extension URLListViewController: UIDataSourceModelAssociation {
    
    // Framework was passing NIL for indexPath which was causing a crash
    func modelIdentifierForElement(at idx: IndexPath?, in view: UIView) -> String? {
        guard let indexPath = idx else { return .none }
        let uuid = self.data?[indexPath.row].uuid
        return uuid
    }
    
    // Afraid framework will pass NIL for identifier. So changing its optionality
    func indexPathForElement(withModelIdentifier identifier: String?, in view: UIView) -> IndexPath? {
        guard let identifier = identifier else { return .none }
        let _index = self.data?.index(matching: "uuid = '\(identifier)'")
        guard let index = _index else { return .none }
        return IndexPath(row: index, section: 0)
    }
}

