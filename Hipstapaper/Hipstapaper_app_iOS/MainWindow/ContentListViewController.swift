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

class ContentListViewController: UIViewController, RealmControllable {
    
    @IBOutlet fileprivate weak var loadingIndicatorViewController: LoadingIndicatorViewController?
    @IBOutlet fileprivate weak var tableView: UITableView? {
        didSet {
            let imageNib = UINib(nibName: ContentTableViewCell.withImageNIBName, bundle: Bundle(for: ContentTableViewCell.self))
            let noImageNib = UINib(nibName: ContentTableViewCell.withOutImageNIBName, bundle: Bundle(for: ContentTableViewCell.self))
            self.tableView?.register(imageNib, forCellReuseIdentifier: ContentTableViewCell.withImageNIBName)
            self.tableView?.register(noImageNib, forCellReuseIdentifier: ContentTableViewCell.withOutImageNIBName)
            self.tableView?.rowHeight = ContentTableViewCell.cellHeight
            self.tableView?.estimatedRowHeight = ContentTableViewCell.cellHeight
            self.tableView?.tableHeaderView = self.searchController.searchBar
        }
    }
    fileprivate lazy var searchController: UISearchController = {
        // lazy vs let fixes a bug where the searchBar icon was pixelated
        // probably caused by initializing before the screen is all configured
        let sc = UISearchController(searchResultsController: nil)
        sc.dimsBackgroundDuringPresentation = false
        sc.restorationIdentifier = StateRestorationIdentifier.searchController.rawValue
        return sc
    }()
    
    fileprivate typealias UIBBI = UIBarButtonItem
    fileprivate lazy var editBBI: UIBBI = UIBBI(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: #selector(self.editBBITapped(_:)))
    fileprivate lazy var doneBBI: UIBBI = UIBBI(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneBBITapped(_:)))
    fileprivate lazy var archiveBBI: UIBBI = UIBBI(title: "📥Archive", style: .plain, target: self, action: #selector(self.archiveBBITapped(_:)))
    fileprivate lazy var unarchiveBBI: UIBBI = UIBBI(title: "📤Unarchive", style: .plain, target: self, action: #selector(self.unarchiveBBITapped(_:)))
    fileprivate lazy var tagBBI: UIBBI = UIBBI(title: "🏷Tag", style: .plain, target: self, action: #selector(self.tagBBITapped(_:)))
    fileprivate lazy var sortBBI: UIBBI = UIBBI(title: "Sort", style: .plain, target: self, action: #selector(self.sortBBITapped(_:)))
    fileprivate lazy var filterBBI: UIBBI = UIBBI(title: "Filter", style: .plain, target: self, action: #selector(self.filterBBITapped(_:)))
    fileprivate let flexibleSpaceBBI: UIBBI = UIBBI(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    fileprivate let verticalBarSpaceBBI: UIBBI = {
        let bbi = UIBBI(title: "|", style: .plain, target: nil, action: nil)
        bbi.isEnabled = false
        return bbi
    }()
    
    // MARK: Selection
    
    var itemsToLoad = UserDefaults.standard.userSelection.itemsToLoad
    var filter = UserDefaults.standard.userSelection.filter
    var sortOrder = UserDefaults.standard.userSelection.sortOrder
    
    fileprivate weak var selectionDelegate: URLItemsToLoadChangeDelegate?
    
    // MARK: Data
    
    fileprivate var data: AnyRealmCollection<URLItem>?
    
    weak var realmController: RealmController? {
        didSet {
            // forward the message to any presented view controllers
            let addRemoveTagPopoverVC = (self.presentedViewController as? UINavigationController)?.viewControllers.first as? RealmControllable
            addRemoveTagPopoverVC?.realmController = self.realmController
            self.loadingIndicatorViewController?.realmController = self.realmController
            
            // reload the data
            self.hardReloadData()
        }
    }
    
    fileprivate var selectedURLItems: [URLItem] {
        let data = self.data
        let indexPaths = self.tableView?.indexPathsForSelectedRows
        let items = indexPaths?.flatMap({ data?[$0.row] })
        return items ?? []
    }
    
    convenience init(selectionDelegate: URLItemsToLoadChangeDelegate, controller: RealmController?) {
        self.init()
        self.selectionDelegate = selectionDelegate
        self.realmController = controller
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure the search delegate
        self.searchController.searchResultsUpdater = self
        
        // needed for the search delegate so it presents correctly
        self.definesPresentationContext = true
        
        // set the top constraint on the LoadingIndicatorViewController
        // this can't be done in the XIB
        if let loadingIndicatorViewController = self.loadingIndicatorViewController {
            self.addChildViewController(loadingIndicatorViewController)
            loadingIndicatorViewController.realmController = self.realmController
            loadingIndicatorViewController.view.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: 10).isActive = true
        }
        
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
        self.resetToolbar()
        self.disableAllBBI()
        
        // load the data
        self.hardReloadData()
    }
    
    fileprivate func hardReloadData() {
        // get values in case things change
        let itemsToLoad = self.itemsToLoad
        let filter = self.filter
        let sortOrder = self.sortOrder
        let searchFilter = self.searchController.searchString
        
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
        
        // preserve any selection
        if self.selectedUUIDsStateRestoration == nil {
            self.selectedUUIDsStateRestoration = self.selectedURLItems.map({ $0.uuid })
        }
        
        // clear things out
        self.notificationToken?.stop()
        self.notificationToken = nil
        self.data = nil
        self.tableView?.reloadData()
        
        // configure data source
        let data = self.realmController?.url_loadAll(for: itemsToLoad, sortedBy: sortOrder, filteredBy: filter, searchFilter: searchFilter)
        self.notificationToken = data?.addNotificationBlock({ [weak self] in self?.realmResultsChanged($0) })
    }
    
    private func realmResultsChanged(_ changes: RealmCollectionChange<AnyRealmCollection<URLItem>>) {
        switch changes {
        case .initial(let data):
            // set the data
            self.data = data
            // find the previously selected items
            let previousSelectionIndexes = RealmController.indexes(ofItemUUIDs: self.selectedUUIDsStateRestoration ?? [], within: data)
            self.selectedUUIDsStateRestoration = nil // reset this so we don't do this on next refresh
            // find previously visible index
            let previouslyVisibleIndex = RealmController.indexes(ofItemUUIDs: self.visibleUUIDsStateRestoration ?? [], within: data)
            self.visibleUUIDsStateRestoration = nil // reset this so we don't do this on next refresh
            // hard reload the data
            self.tableView?.reloadData()
            
            // check if state restoration left us a scroll position
            if let index = previouslyVisibleIndex.last {
                self.tableView?.scrollToRow(at: IndexPath(row: index, section: 0), at: .bottom, animated: false)
            // otherwise we can check for conditions where we might want to hide the search bar
            } else if let topVisibleRow = self.tableView?.indexPathsForVisibleRows?.first, // there is a visible row
                self.searchController.isActive == false, // if the search controller is active, don't hijack scrolling
                self.searchController.isVisible == false // if the search controller is visible, don't hijack scrolling (this fixes a bug that caused it to scroll when cancelling the search controller
            {
                self.tableView?.scrollToRow(at: topVisibleRow, at: .top, animated: true)
            }
        
            // select the items found after updating the table
            self.selectRowsAfterHardRefresh(atIndexes: previousSelectionIndexes)
        case .update(let data, let deletions, let insertions, let modifications):
            // UITableView does not automatically reselect updated rows like NSTableView does
            // So I need manual selection code here
            // find the previously selected items
            let previousSelectionIndexes = RealmController.indexes(ofItemUUIDs: self.selectedURLItems.map({ $0.uuid }), within: data)
            
            // update the table
            self.tableView?.beginUpdates()
            self.tableView?.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }), with: .right)
            self.tableView?.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}), with: .left)
            self.tableView?.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }), with: .automatic)
            self.tableView?.endUpdates()
            
            // select the items found after updating the table
            self.selectRowsAfterHardRefresh(atIndexes: previousSelectionIndexes)
        case .error(let error):
            let alert = UIAlertController(title: "Error Loading Reading List", message: error.localizedDescription, preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            self.data = nil
            self.tableView?.reloadData()
        }
    }
    
    private func selectRowsAfterHardRefresh(atIndexes indexes: [Int]) {
        guard indexes.isEmpty == false else { return }
        indexes.forEach({ self.tableView?.selectRow(at: IndexPath(row: $0, section: 0), animated: false, scrollPosition: .none) })
        let selectedItems = self.selectedURLItems
        self.updateBBI(with: selectedItems)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView?.flashScrollIndicators()
        let isEditing = self.tableView?.isEditing ?? false
        if isEditing == false {
            // if we're not editing when we appear its probably because of fresh launch or because the user dismissed SafariVC
            // so we need to deselect the row
            self.tableView?.deselectAllRows(animated: true)
        }
        
        // Hack to reload UISearchController
        // See DecodeStateRestoration for more info
        if let searchControllerStateRestoration = self.searchControllerStateRestoration {
            self.hideLoadingView(searchControllerStateRestoration.wasActive)
            self.searchController.searchString = searchControllerStateRestoration.searchFilter
            self.searchControllerStateRestoration = nil
        }
    }
    
    // MARK: Watch for shake gesture for deleting
    
    private func validateDelete() -> Bool {
        guard self.presentedViewController == nil, self.selectedURLItems.isEmpty == false else { return false }
        return true
    }
    
    private func shakeToDelete() {
        let items = self.selectedURLItems
        guard let realmController = self.realmController, items.isEmpty == false else { return }
        let alert = UIAlertController(title: "Delete \(items.count) Item(s)?", message: "This action cannot be undone.", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { _ in
            realmController.delete(items)
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        self.emergencyDismissPopover(thenPresentViewController: alert)
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
    
    // MARK: State Restoration
    
    private enum StateRestoration {
        fileprivate static let kTableViewWasEditing = "kTableViewWasEditingKey"
        fileprivate static let kSearchWasActive = "kSearchWasActiveKey"
        fileprivate static let kSearchString = "kSearchStringKey"
        fileprivate static let kVisibleItems = "kVisibleItemsKey"
        fileprivate static let kSelectedItems = "kSelectedItemsKey"
    }
    
    // Horrible Hack
    // Apple's Code Sample shows repopulating the SearchController in ViewDidAppear
    // Not in DecodeStateRestoration
    // This Struct and this propery make that possible
    // https://developer.apple.com/library/content/samplecode/TableSearch_UISearchController/Listings/Swift_TableSearch_MainTableViewController_swift.html
    
    private struct SearchControllerRestoration {
        fileprivate var wasActive: Bool
        fileprivate var searchFilter: String?
    }
    
    private var searchControllerStateRestoration: SearchControllerRestoration?
    private var visibleUUIDsStateRestoration: [String]?
    private var selectedUUIDsStateRestoration: [String]?
    
    override func decodeRestorableState(with coder: NSCoder) {
        let wasEditing = coder.decodeBool(forKey: StateRestoration.kTableViewWasEditing)
        if wasEditing == true {
            self.editBBITapped(self)
        }
        let wasActive = coder.decodeBool(forKey: StateRestoration.kSearchWasActive)
        if wasActive == true {
            let searchString = coder.decodeObject(forKey: StateRestoration.kSearchString) as? String
            self.searchControllerStateRestoration = SearchControllerRestoration(wasActive: wasActive, searchFilter: searchString)
        }
        self.visibleUUIDsStateRestoration = coder.decodeObject(forKey: StateRestoration.kVisibleItems) as? [String]
        self.selectedUUIDsStateRestoration = coder.decodeObject(forKey: StateRestoration.kSelectedItems) as? [String]
        
        super.decodeRestorableState(with: coder)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(self.tableView?.isEditing ?? false, forKey: StateRestoration.kTableViewWasEditing)
        coder.encode(self.searchController.isActive, forKey: StateRestoration.kSearchWasActive)
        coder.encode(self.searchController.searchBar.text, forKey: StateRestoration.kSearchString)
        let selectedUUIDs = self.selectedURLItems.map({ $0.uuid })
        coder.encode(selectedUUIDs, forKey: StateRestoration.kSelectedItems)
        if let visibleIndexPaths = self.tableView?.indexPathsForVisibleRows,
            visibleIndexPaths.first != IndexPath(row: 0, section: 0) // don't save anything if we're scrolled at the top
        {
            let visibleUUIDs = visibleIndexPaths.flatMap({ self.data?[$0.row].uuid })
            coder.encode(visibleUUIDs, forKey: StateRestoration.kVisibleItems)
        }
        
        super.encodeRestorableState(with: coder)
    }
    
    // MARK: Deinit
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }
}

extension ContentListViewController: URLItemsToLoadChangeDelegate {
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
                // only clear the search if this did not come from a tertiaryVC
                if sender == .sourceListVC {
                    self.searchController.searchString = nil
                    self.doneBBITapped(nil)
                }
                self.hardReloadData()
            }
        }
    }
}

extension ContentListViewController /* Handle BarButtonItems */ {
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
        self.emergencyDismissPopover(thenDo: enterEditMode)
    }
    
    @objc fileprivate func doneBBITapped(_ sender: NSObject?) {
        self.emergencyDismissPopover() { // dismisses any popovers and then does the action
            self.tableView?.setEditing(false, animated: true)
            self.resetToolbar()
        }
    }
    
    fileprivate func resetToolbar() {
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
    
    @objc fileprivate func archiveBBITapped(_ sender: NSObject?) {
        self.emergencyDismissPopover() { // dismisses any popovers and then does the action
            let items = self.selectedURLItems
            guard items.isEmpty == false else { return }
            self.realmController?.url_setArchived(to: true, on: items)
            self.disableAllBBI()
        }
    }
    
    @objc fileprivate func unarchiveBBITapped(_ sender: NSObject?) {
        self.emergencyDismissPopover() { // dismisses any popovers and then does the action
            let items = self.selectedURLItems
            guard items.isEmpty == false else { return }
            self.realmController?.url_setArchived(to: false, on: items)
            self.disableAllBBI()
        }
    }
    
    @objc fileprivate func tagBBITapped(_ sender: NSObject?) {
        let selectedItems = self.selectedURLItems
        guard
            let bbi = sender as? UIBBI,
            let realmController = self.realmController,
            selectedItems.isEmpty == false
        else { return }
        let itemIDs = selectedItems.map({ URLItem.UIIdentifier(uuid: $0.uuid, urlString: $0.urlString, archived: $0.archived) })
        let tagVC = TagAddRemoveViewController.viewController(style: .popBBI(bbi), selectedItems: itemIDs, controller: realmController)
        self.present(tagVC, animated: true, completion: nil)
    }
    
    @objc fileprivate func sortBBITapped(_ sender: NSObject?) {
        guard let bbi = sender as? UIBBI else { return }
        let vc = SortSelectingViewController.newPopover(kind: .sort(currentSort: self.sortOrder), delegate: self, from: bbi)
        // HIG states that a popover should be dismissiable and a new one presentable in one tap
        self.emergencyDismissPopover(thenPresentViewController: vc)
    }
    
    @objc fileprivate func filterBBITapped(_ sender: NSObject?) {
        guard let bbi = sender as? UIBBI else { return }
        let vc = SortSelectingViewController.newPopover(kind: .filter(currentFilter: self.filter), delegate: self, from: bbi)
        // HIG states that a popover should be dismissiable and a new one presentable in one tap
        self.emergencyDismissPopover(thenPresentViewController: vc)
    }
    
    fileprivate func disableAllBBI() {
        self.archiveBBI.isEnabled = false
        self.unarchiveBBI.isEnabled = false
        self.tagBBI.isEnabled = false
    }
    
    fileprivate func updateBBI(with items: [URLItem]) {
        if self.tableView?.isEditing == true {
            if items.isEmpty {
                self.disableAllBBI()
            } else {
                self.tagBBI.isEnabled = true
                self.archiveBBI.isEnabled = !items.filter({ $0.archived == false }).isEmpty
                self.unarchiveBBI.isEnabled = !items.filter({ $0.archived == true }).isEmpty
            }
        } else {
            self.resetToolbar()
        }
    }
}

extension ContentListViewController: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard
            let realmController = self.realmController,
            let tableView = self.tableView,
            let indexPath = tableView.indexPathForRow(at: self.view.convert(location, to: tableView)),
            let cellView = tableView.cellForRow(at: indexPath),
            let item = self.data?[indexPath.row],
            let url = URL(string: item.urlString)
        else { return nil }
        
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
            let itemID = URLItem.UIIdentifier(uuid: item.uuid, urlString: item.urlString, archived: item.archived)
            let tagVC = TagAddRemoveViewController.viewController(style: presentation, selectedItems: [itemID], controller: realmController)
            self?.present(tagVC, animated: true, completion: nil)
        }
        // use my special preview action injection SafariViewController
        // the actions are queried for on the presented view controller
        // but SFSafariViewController knows nothing about realm controller, no do I want it to
        let sfVC = WebBrowserViewController(url: url, previewActions: [tagAction, archiveAction])
        
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
        self.present(viewControllerToCommit, animated: true, completion: nil)
    }
}

extension ContentListViewController: UISearchResultsUpdating {
    
    fileprivate func hideLoadingView(_ hide: Bool) {
        // hide the syncronization view if searching is active
        // this is needed because the search VC appears above the sync view
        // it looks weird if syncronizing shows when searces are happening
        if hide == true {
            self.loadingIndicatorViewController?.view?.alpha = 0
        } else {
            self.loadingIndicatorViewController?.view?.alpha = 1
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        self.hideLoadingView(searchController.isActive)
        self.hardReloadData()
    }
}

extension ContentListViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItems = self.selectedURLItems
        if tableView.isEditing {
            self.updateBBI(with: selectedItems)
        } else {
            guard let selectedItem = selectedItems.first, let url = URL(string: selectedItem.urlString) else { return }
            let sfVC = WebBrowserViewController(url: url, previewActions: nil)
            self.present(sfVC, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.updateBBI(with: self.selectedURLItems)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ContentTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard
            let item = self.data?[indexPath.row],
            let cellView = tableView.cellForRow(at: indexPath),
            let realmController = self.realmController
        else { return nil }
        
        let archiveActionTitle = item.archived ? "📤Unarchive" : "📥Archive"
        let archiveToggleAction = UITableViewRowAction(style: .normal, title: archiveActionTitle) { _ in
            let newArchiveValue = !item.archived
            self.realmController?.url_setArchived(to: newArchiveValue, on: [item])
        }
        archiveToggleAction.backgroundColor = tableView.tintColor
        
        let tagAction = UITableViewRowAction(style: .normal, title: "🏷Tag") { action, _ in
            let selector = Selector("_button")
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
            let itemID = URLItem.UIIdentifier(uuid: item.uuid, urlString: item.urlString, archived: item.archived)
            let tagVC = TagAddRemoveViewController.viewController(style: presentation, selectedItems: [itemID], controller: realmController)
            self.present(tagVC, animated: true, completion: nil)
        }
        return [archiveToggleAction, tagAction]
    }
}

extension ContentListViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.data?[indexPath.row]
        let identifier = item?.extras?.image == nil ? ContentTableViewCell.withOutImageNIBName : ContentTableViewCell.withImageNIBName
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = cell as? ContentTableViewCell, let item = item {
            cell.configure(with: item)
        }
        return cell
    }
}
