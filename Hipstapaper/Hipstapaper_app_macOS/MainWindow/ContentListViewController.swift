//
//  URLListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Aspects
import RealmSwift
import Common
import Social
import AppKit

class ContentListViewController: NSViewController, RealmControllable {
    
    // MARK: External Interface
    
    // these 3 properties are used to load and sort the data
    // they are user changeable from a special UI
    // they are also changeable by selecting items in the source list
    var itemsToLoad = UserDefaults.standard.userSelection.itemsToLoad
    var filter = UserDefaults.standard.userSelection.filter
    var sortOrder = UserDefaults.standard.userSelection.sortOrder
    
    // this selection delegate allows us to notify the source list of changing selection
    // this way the source list can update its selection if needed
    weak var selectionDelegate: URLItemsToLoadChangeDelegate?
    
    // MARK: Data
    
    private(set) fileprivate var data: Results<URLItem>?
    
    fileprivate var selectedURLItems: [URLItem]? {
        let items = self.tableView?.selectedRowIndexes.map({ self.data?[$0] }).flatMap({ $0 }) ?? []
        if items.isEmpty { return .none } else { return items }
    }
    
    weak var realmController: RealmController? {
        didSet {
            self.loadingIndicatorViewController?.realmController = self.realmController
            self.hardReloadData()
        }
    }
    
    // MARK Outlets
    
    @IBOutlet private(set) fileprivate weak var tableView: NSTableView?
    @IBOutlet private weak var scrollView: NSScrollView?
    @IBOutlet private weak var loadingIndicatorViewController: LoadingIndicatorViewController?
    @IBOutlet private weak var sortVC: SortSelectingViewController? {
        didSet {
            guard let sortVC = self.sortVC else { return }
            sortVC.delegate = self
            self.addChildViewController(sortVC)
        }
    }
    
    // MARK: Manage Open Child Windows
    
    let windowLoader = WebBrowserCreator()
    
    // MARK: View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.windowLoader.windowControllerDelegate = self
        
        if let sortVC = self.sortVC {
            let sortVCMovedToWindow: @convention(block) (Void) -> Void = { [weak self] in self?.sortSelectingViewDidMoveToWindow() }
            self.sortVCMoveToWindowToken = try? sortVC.view.aspect_hook(#selector(NSView.viewDidMoveToWindow), with: [], usingBlock: sortVCMovedToWindow)
        }
    }
    
    func sortSelectingViewDidMoveToWindow() {
        if let layoutGuide = self.view.window?.contentLayoutGuide as? NSLayoutGuide {
            self.sortVC?.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 0).isActive = true
        } else {
            self.sortVC?.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        }
        let height = (self.scrollView?.contentInsets.top ?? 0) + (self.sortVC?.view.bounds.height ?? 0)
        self.scrollView?.automaticallyAdjustsContentInsets = false
        self.scrollView?.contentInsets.top = height
    }
    
    // MARK: Reload Data
    
    fileprivate func hardReloadData() {
        // grab these values in case things change before we get to the end
        let itemsToLoad = self.itemsToLoad
        let sortOrder = self.sortOrder
        let filter = self.filter
        
        // clear out all previous update tokens and tableview
        self.data = .none
        self.notificationToken?.stop()
        self.notificationToken = .none
        self.tableView?.reloadData()
        
        // now ask realm for new data and give it our closure to get updates
        switch itemsToLoad {
        case .all:
            self.title = "Hipstapaper"
        case .tag(let tagID):
            self.title = "🏷 \(tagID.displayName)"
        }
        
        // update the filter vc
        self.sortVC?.sortOrder = sortOrder
        self.sortVC?.filter = filter
        
        // load the data
        self.data = self.realmController?.url_loadAll(for: itemsToLoad, sortedBy: sortOrder, filteredBy: filter)
        self.notificationToken = self.data?.addNotificationBlock({ self.realmResultsChanged($0) })
    }
    
    private func realmResultsChanged(_ changes: RealmCollectionChange<Results<URLItem>>) {
        switch changes {
        case .initial:
            let previousSelectionPredicates = UserDefaults.standard.selectedURLItemUUIDStrings?.map({ "\(#keyPath(URLItem.uuid)) = '\($0)'" })
            let previousSelectionIndexes = self.data?.indexes(matchingPredicates: previousSelectionPredicates ?? [])
            self.tableView?.reloadData()
            self.tableView?.selectRowIndexes(IndexSet(previousSelectionIndexes ?? []), byExtendingSelection: false)
        case .update(_, let deletions, let insertions, let modifications):
            self.tableView?.beginUpdates()
            self.tableView?.removeRows(at: IndexSet(deletions), withAnimation: .slideLeft)
            self.tableView?.insertRows(at: IndexSet(insertions), withAnimation: .slideRight)
            self.tableView?.reloadData(forRowIndexes: IndexSet(modifications), columnIndexes: IndexSet([0]))
            self.tableView?.endUpdates()
        case .error(let error):
            guard let window = self.view.window else { break }
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: window, completionHandler: .none)
        }
    }
    
    // MARK: Handle Double click on TableView
    
    @IBAction func tableViewDoubleClicked(_ sender: NSObject?) {
        guard let selectedItems = self.selectedURLItems else { return }
        self.openOrBringFrontWindowControllers(for: selectedItems)
    }
    
    // MARK: Handle Menu Bar Items
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard
            let kind = NSMenuItem.Kind(rawValue: menuItem.tag),
            let selectedItems = self.selectedURLItems
        else { return false }
        
        switch kind {
        case .unarchive:
            return !selectedItems.filter({ $0.archived == true }).isEmpty
        case .archive:
            return !selectedItems.filter({ $0.archived == false }).isEmpty
        case .copy:
            return selectedItems.count == 1
        case .delete:
            return true
        case .open:
            return true
        case .share:
            let items = selectedItems.map({ URL(string: $0.urlString) }).flatMap({ $0 })
            guard items.isEmpty == false else { return false }
            menuItem.submenu = NSMenu(shareMenuWithItems: items)
            return true
        case .shareSubmenu:
            return true
        case .javascript:
            return false
        case .showMainWindow:
            return false
        }
    }
    
    @objc private func open(_ sender: NSObject?) {
        guard let selectedItems = self.selectedURLItems else { return }
        self.openOrBringFrontWindowControllers(for: selectedItems)
    }
    
    @objc private func delete(_ sender: NSObject?) {
        guard let selectedItems = self.selectedURLItems else { return }
        self.realmController?.delete(selectedItems)
    }
    
    @objc private func copy(_ sender: NSObject?) {
        guard let selectedItems = self.selectedURLItems, let item = selectedItems.first else { NSBeep(); return; }
        NSPasteboard.general().declareTypes([NSStringPboardType], owner: self)
        NSPasteboard.general().setString(item.urlString, forType: NSStringPboardType)
    }
    
    // MARK: Handle Key Events
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 36, 76: // enter keys
            break
        case 53: // escape key
            break
        default:
            super.keyDown(with: event)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 36, 76: // enter keys
            self.open(event)
        case 53: // escape key
            self.view.window?.firstResponder.try(toPerform: #selector(NSTableView.deselectAll(_:)), with: event)
            self.view.window?.toolbar?.validateVisibleItems() // it was taking almost a full second to re-validate toolbar items without forcing it manually
        default:
            super.keyUp(with: event)
        }
    }
    
    // MARK: Handle Toolbar Items
    
    @objc private func archive(_ sender: NSObject?) {
        guard let selectedItems = self.selectedURLItems else { return }
        self.realmController?.url_setArchived(to: true, on: selectedItems)
    }
    
    @objc private func unarchive(_ sender: NSObject?) {
        guard let selectedItems = self.selectedURLItems else { return }
        self.realmController?.url_setArchived(to: false, on: selectedItems)
    }
    
    @objc private func tag(_ sender: NSObject?) {
        guard
            let item = sender as? NSButton,
            let realmController = self.realmController,
            let itemIDs = self.selectedURLItems?.map({ URLItem.UIIdentifier(uuid: $0.uuid, urlString: $0.urlString, archived: $0.archived) })
        else { return }
        let tagVC = TagAddRemoveViewController(itemsToTag: itemIDs, controller: realmController)
        self.presentViewController(tagVC, asPopoverRelativeTo: .zero, of: item, preferredEdge: .maxY, behavior: .semitransient)
    }
    
    @objc private func share(_ sender: NSObject?) {
        guard
            let button = sender as? NSButton,
            let urls = self.selectedURLItems?.map({ URL(string: $0.urlString) }).flatMap({ $0 }),
            urls.isEmpty == false
        else { return }
        NSSharingServicePicker(items: urls).show(relativeTo: .zero, of: button, preferredEdge: .minY)
    }
    
    @objc func shareMenu(_ sender: NSObject?) {
        guard let urls = self.selectedURLItems?.map({ URL(string: $0.urlString) }).flatMap({ $0 }), urls.isEmpty == false else { return }
        ((sender as? NSMenuItem)?.representedObject as? NSSharingService)?.perform(withItems: urls)
    }
    
    override func validateToolbarItem(_ item: NSObject?) -> Bool {
        guard
            let item = item as? NSToolbarItem,
            let kind = NSToolbarItem.Kind(rawValue: item.tag),
            let _ = self.realmController,
            let selectedItems = self.selectedURLItems
        else { return false }
        switch kind {
        case .unarchive:
            return !selectedItems.filter({ $0.archived == true }).isEmpty
        case .archive:
            return !selectedItems.filter({ $0.archived == false }).isEmpty
        case .tag:
            return !selectedItems.isEmpty
        case .share:
            return !selectedItems.isEmpty
        case .jsToggle:
            return false
        }
    }
    
    // MARK: Handle Opening / Bringing to Front Windows
    
    private func openOrBringFrontWindowControllers(for items: [URLItem]) {
        items.forEach() { item in
            let itemID = URLItem.UIIdentifier(uuid: item.uuid, urlString: item.urlString, archived: item.archived)
            let wc = self.windowLoader[itemID]
            wc?.showWindow(self)
        }
    }
    
    // MARK: Handle Going Away
    
    private var sortVCMoveToWindowToken: AspectToken?
    private var notificationToken: NotificationToken?

    deinit {
        self.sortVCMoveToWindowToken?.remove()
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
                if sender == .sourceListVC {
                    // double check this.
                    // during fallthrough from tertiaryvc
                    // we don't want the selection to be cleared
                    self.tableView?.deselectAll(self)
                }
                self.hardReloadData()
            }
        }
    }
}

extension ContentListViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.data?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return self.data?[row]
    }
    
}

extension ContentListViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableRowActionEdge) -> [NSTableViewRowAction] {
        guard
            edge == .trailing,
            let rowView = tableView.rowView(atRow: row, makeIfNecessary: false),
            let item = self.data?[row],
            let realmController = self.realmController
        else { return [] }
        
        let archiveActionTitle = item.archived ? "📤Unarchive" : "📥Archive"
        let archiveToggleAction = NSTableViewRowAction(style: .regular, title: archiveActionTitle) { _ in
            let newArchiveValue = !item.archived
            realmController.url_setArchived(to: newArchiveValue, on: [item])
        }
        let tagAction = NSTableViewRowAction(style: .regular, title: "🏷Tag") { action, index in
            let actionButtonView = tableView.tableViewActionButtons?.first ?? rowView
            let itemID = URLItem.UIIdentifier(uuid: item.uuid, urlString: item.urlString, archived: item.archived)
            let tagVC = TagAddRemoveViewController(itemsToTag: [itemID], controller: realmController)
            self.presentViewController(tagVC, asPopoverRelativeTo: .zero, of: actionButtonView, preferredEdge: .minY, behavior: .transient)
        }
        
        tagAction.backgroundColor = NSColor.lightGray
        archiveToggleAction.backgroundColor = Color.tintColor
        
        return [tagAction, archiveToggleAction]
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        UserDefaults.standard.selectedURLItemUUIDStrings = self.selectedURLItems?.map({ $0.uuid })
    }
}

fileprivate extension NSView {
    
    fileprivate var tableViewActionButtons: [NSView]? {
        guard let type = NSClassFromString("NSTableViewActionButton") else { return .none }
        let matches = self.subviews(matchingType: type)
        if matches.isEmpty { return .none } else { return matches }
    }
    
    private func subviews(matchingType type: AnyClass) -> [NSView] {
        var matches = [NSView]()
        if self.classForCoder == type {
            matches.append(self)
        }
        for subview in self.subviews {
            matches += subview.subviews(matchingType: type)
        }
        return matches
    }
}

// MARK: Handle Showing URL if there is no Title

private extension URLItem {
    @objc private var bindingTitle: String {
        return self.extras?.pageTitle ?? self.urlString
    }
}
