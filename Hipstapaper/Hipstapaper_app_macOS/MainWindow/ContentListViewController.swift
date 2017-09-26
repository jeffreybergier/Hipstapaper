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
import Quartz
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
    
    private(set) fileprivate var data: AnyRealmCollection<URLItem>?
    
    internal var selectedURLItems: [URLItem] {
        let items = self.tableView?.selectedRowIndexes.flatMap({ self.data?[$0] })
        return items ?? []
    }
    
    weak var realmController: RealmController? {
        didSet {
            self.loadingIndicatorViewController?.realmController = self.realmController
            self.hardReloadData()
        }
    }
    
    // MARK Outlets
    
    @IBOutlet private(set) weak var tableView: NSTableView?
    @IBOutlet private weak var loadingIndicatorViewController: LoadingIndicatorViewController?
    @IBOutlet private weak var sortSelectingViewController: SortSelectingViewController?
    /*@IBOutlet*/ weak var searchField: NSSearchField? {
        didSet {
            self.searchField?.action = #selector(ContentListViewController.textFieldChanged(_:))
            self.searchField?.target = self
        }
    }
    var scrollView: NSScrollView? {
        return self.tableView?.enclosingScrollView
    }
    
    // MARK: Manage Open Child Windows
    
    let windowLoader = WebBrowserCreator()
    fileprivate let quickLookPanelController = QuickLookPanelController()
    
    // MARK: View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure the web browser window loader
        self.windowLoader.windowControllerDelegate = self
        
        // insert quicklook controller into the responder chain, when we land in the window
        let viewMovedToWindow: @convention(block) () -> Void = {
            self.quickLookPanelController.delegate = self
            self.quickLookPanelController.nextResponder = self.nextResponder
            self.nextResponder = self.quickLookPanelController
        }
        self.viewMoveToWindowToken = try? self.view.aspect_hook(#selector(NSView.viewDidMoveToWindow), with: [], usingBlock: viewMovedToWindow)
        
        // configure the sortvc
        if let sortVC = self.sortSelectingViewController {
            sortVC.delegate = self
            self.addChildViewController(sortVC)
            let sortVCMovedToWindow: @convention(block) () -> Void = { [weak self] in self?.sortSelectingViewDidMoveToWindow() }
            self.sortVCMoveToWindowToken = try? sortVC.view.aspect_hook(#selector(NSView.viewDidMoveToWindow), with: [], usingBlock: sortVCMovedToWindow)
        }
        
        // configure the loadingVC
        if let loadingVC = self.loadingIndicatorViewController {
            self.addChildViewController(loadingVC)
        }
    }
    
    func sortSelectingViewDidMoveToWindow() {
        if let layoutGuide = self.view.window?.contentLayoutGuide as? NSLayoutGuide {
            self.sortSelectingViewController?.view.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 0).isActive = true
        } else {
            self.sortSelectingViewController?.view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        }
        let height = (self.scrollView?.contentInsets.top ?? 0) + (self.sortSelectingViewController?.view.bounds.height ?? 0)
        self.scrollView?.automaticallyAdjustsContentInsets = false
        self.scrollView?.contentInsets.top = height
    }
    
    // MARK: Reload Data
    
    var visibleUUIDsStateRestoration: [String]?
    var selectedUUIDsStateRestoration: [String]?
    
    func hardReloadData() {
        // grab these values in case things change before we get to the end
        let itemsToLoad = self.itemsToLoad
        let sortOrder = self.sortOrder
        let filter = self.filter
        let searchFilter = self.searchField?.searchString
        
        // preserve any selection
        if self.selectedUUIDsStateRestoration == nil {
            self.selectedUUIDsStateRestoration = self.selectedURLItems.map({ $0.uuid })
        }
        
        // clear out all previous update tokens and tableview
        self.notificationToken?.stop()
        self.notificationToken = nil
        self.data = nil
        self.tableView?.reloadData()
        
        // now ask realm for new data and give it our closure to get updates
        switch itemsToLoad {
        case .all:
            self.title = "Hipstapaper"
        case .tag(let tagID):
            self.title = "🏷 \(tagID.displayName)"
        }
        
        // update the filter vc
        self.sortSelectingViewController?.sortOrder = sortOrder
        self.sortSelectingViewController?.filter = filter
                
        // load the data
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
            
            // scroll the tableview to the previous scroll point if needed
            if let index = previouslyVisibleIndex.last {
                self.tableView?.scrollRowToVisible(index)
            }
            
            // select the needed rows
            self.tableView?.selectRowIndexes(IndexSet(previousSelectionIndexes), byExtendingSelection: false)
        case .update(_, let deletions, let insertions, let modifications):
            // NSTableView doesn't require manually re-selecting all the selected rows like UITableView does
            // So I can save some code here
            
            // update the table
            self.tableView?.beginUpdates()
            self.tableView?.insertRows(at: IndexSet(insertions), withAnimation: .slideRight)
            self.tableView?.removeRows(at: IndexSet(deletions), withAnimation: .slideLeft)
            self.tableView?.reloadData(forRowIndexes: IndexSet(modifications), columnIndexes: IndexSet([0]))
            self.tableView?.endUpdates()
        case .error(let error):
            guard let window = self.view.window else { break }
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: window, completionHandler: nil)
        }
    }
    
    func uuidStrings(for indexes: [Int]) -> [String] {
        return indexes.flatMap({ self.data?[$0].uuid })
    }
    
    // MARK: Handle Double click on TableView
    
    @IBAction func tableViewDoubleClicked(_ sender: NSObject?) {
        let selectedItems = self.selectedURLItems
        guard selectedItems.isEmpty == false else { return }
        self.openOrBringFrontWindowControllers(for: selectedItems)
    }
    
    // MARK: Handle Menu Bar Items
    
    // swiftlint:disable:next cyclomatic_complexity
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        let selectedItems = self.selectedURLItems
        guard
            let kind = NSMenuItem.Kind(rawValue: menuItem.tag),
            selectedItems.isEmpty == false
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
            let items = selectedItems.flatMap({ URL(string: $0.urlString) })
            guard items.isEmpty == false else { return false }
            menuItem.submenu = NSMenu(shareMenuWithItems: items)
            return true
        case .shareSubmenu:
            return true
        case .javascript:
            return false
        case .showMainWindow:
            return false
        case .tags:
            return true
        case .quickLook:
            guard self.nextResponder === self.quickLookPanelController else { return false }
            return true
        case .openInBrowser:
            return true
        }
    }
    
    @objc private func open(_ sender: NSObject?) {
        let selectedItems = self.selectedURLItems
        guard selectedItems.isEmpty == false else { __NSBeep(); return; }
        self.openOrBringFrontWindowControllers(for: selectedItems)
    }
    
    @objc private func openInBrowser(_ sender: NSObject?) {
        let urls = self.selectedURLItems.flatMap({ URL(string: $0.urlString) })
        guard urls.isEmpty == false else { return }
        NSWorkspace.shared.open(urls, withAppBundleIdentifier: nil, options: [], additionalEventParamDescriptor: nil, launchIdentifiers: nil)
    }
    
    @objc private func delete(_ sender: NSObject?) {
        let selectedItems = self.selectedURLItems
        guard selectedItems.isEmpty == false else { __NSBeep(); return; }
        self.realmController?.delete(selectedItems)
    }
    
    @objc private func copy(_ sender: NSObject?) {
        guard let item = self.selectedURLItems.first else { __NSBeep(); return; }
        NSPasteboard.general.declareTypes([NSPasteboard.PasteboardType.string], owner: self)
        NSPasteboard.general.setString(item.urlString, forType: NSPasteboard.PasteboardType.string)
    }
    
    // MARK: Handle Quicklook
    
    @objc private func toggleQuickLookPreviewPanel(_ sender: NSObject?) {
        guard self.nextResponder === self.quickLookPanelController else { __NSBeep(); return; }
        self.quickLookPanelController.togglePanel(sender)
    }
    
    // MARK: Handle Key Events
    
    fileprivate func shouldHandle(keyEvent event: NSEvent) -> Bool {
        switch event.keyCode {
        case 36, 76: // enter keys
            return true
        case 53: // escape key
            return true
        case 49: // space bar - quicklook
            return true
        default:
            return false
        }
    }
    
    override func keyDown(with event: NSEvent) {
        guard shouldHandle(keyEvent: event) == false else { return }
        super.keyDown(with: event)
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 36, 76: // enter keys
            self.open(event)
        case 53: // escape key
            self.view.window?.firstResponder?.try(toPerform: #selector(NSTableView.deselectAll(_:)), with: event)
            self.view.window?.toolbar?.validateVisibleItems() // it was taking almost a full second to re-validate toolbar items without forcing it manually
        case 49: // space bar - quicklook
            self.toggleQuickLookPreviewPanel(event)
        default:
            super.keyUp(with: event)
        }
    }
    
    // MARK: Handle Toolbar Items
    
    @objc private func archive(_ sender: NSObject?) {
        let selectedItems = self.selectedURLItems
        guard selectedItems.isEmpty == false else { return }
        self.realmController?.url_setArchived(to: true, on: selectedItems)
    }
    
    @objc private func unarchive(_ sender: NSObject?) {
        let selectedItems = self.selectedURLItems
        guard selectedItems.isEmpty == false else { return }
        self.realmController?.url_setArchived(to: false, on: selectedItems)
    }
    
    @objc private func tag(_ sender: NSObject?) {
        let itemIDs = self.selectedURLItems.map({ URLItem.UIIdentifier(uuid: $0.uuid, urlString: $0.urlString, archived: $0.archived) })
        guard
            let realmController = self.realmController,
            itemIDs.isEmpty == false
        else { __NSBeep(); return; }
        let tagVC = TagAddRemoveViewController(itemsToTag: itemIDs, controller: realmController)
        let view = (sender as? NSView) ?? self.view
        self.presentViewController(tagVC, asPopoverRelativeTo: .zero, of: view, preferredEdge: .maxY, behavior: .semitransient)
    }
    
    @objc private func share(_ sender: NSObject?) {
        let urls = self.selectedURLItems.flatMap({ URL(string: $0.urlString) })
        guard urls.isEmpty == false else { __NSBeep(); return; }
        let view = (sender as? NSView) ?? self.view
        NSSharingServicePicker(items: urls).show(relativeTo: .zero, of: view, preferredEdge: .minY)
    }
    
    @objc func shareMenu(_ sender: NSObject?) {
        let urls = self.selectedURLItems.flatMap({ URL(string: $0.urlString) })
        guard urls.isEmpty == false else { __NSBeep(); return; }
        ((sender as? NSMenuItem)?.representedObject as? NSSharingService)?.perform(withItems: urls)
    }
    
    override func validateToolbarItem(_ item: NSObject?) -> Bool {
        let selectedItems = self.selectedURLItems
        guard
            let item = item as? NSToolbarItem,
            let kind = NSToolbarItem.Kind(rawValue: item.tag),
            self.realmController != nil,
            selectedItems.isEmpty == false
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
        case .quickLook:
            guard self.nextResponder === self.quickLookPanelController else { return false }
            return true
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
    private var viewMoveToWindowToken: AspectToken?
    private var notificationToken: NotificationToken?

    deinit {
        self.viewMoveToWindowToken?.remove()
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
                    self.searchField?.searchString = nil
                }
                self.hardReloadData()
            }
        }
    }
}

extension ContentListViewController /*: NSSearchFieldDelegate */ {
    @objc fileprivate func textFieldChanged(_ sender: NSObject?) {
        guard sender === self.searchField else { return }
        
        // ugh. annoyingly, calling InvalidateRestorable State only works on the WindowController, not the ViewController
        // need to call this to save the current search
        (self.view.window?.delegate as? NSWindowController)?.invalidateRestorableState()
        
        // now need to reload the data
        self.hardReloadData()
    }
}

extension ContentListViewController: QLPreviewPanelDelegate {
    func previewPanel(_ panel: QLPreviewPanel?, sourceFrameOnScreenFor item: QLPreviewItem?) -> NSRect {
        guard
            let urlString = (item as? NSURL)?.absoluteString,
            let window = self.view.window,
            let windowView = window.contentView,
            let index = self.data?.index(matching: "\(#keyPath(URLItem.urlString)) = '\(urlString)'"),
            let rowView = self.tableView?.rowView(atRow: index, makeIfNecessary: false)
        else { return NSRect.zero }
        let windowRect = rowView.convert(rowView.bounds, to: windowView)
        let screenRect = window.convertToScreen(windowRect)
        return screenRect
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
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        guard
            edge == .trailing,
            let rowView = tableView.rowView(atRow: row, makeIfNecessary: false),
            let item = self.data?[row],
            let realmController = self.realmController
        else { return [] }
        
        let archiveActionTitle = item.archived ? "📤Unarchive" : "📥Archive"
        let archiveToggleAction = NSTableViewRowAction(style: .regular, title: archiveActionTitle) { _, _ in
            let newArchiveValue = !item.archived
            realmController.url_setArchived(to: newArchiveValue, on: [item])
        }
        let tagAction = NSTableViewRowAction(style: .regular, title: "🏷Tag") { _, _ in
            let actionButtonView = tableView.tableViewActionButtons.first ?? rowView
            let itemID = URLItem.UIIdentifier(uuid: item.uuid, urlString: item.urlString, archived: item.archived)
            let tagVC = TagAddRemoveViewController(itemsToTag: [itemID], controller: realmController)
            self.presentViewController(tagVC, asPopoverRelativeTo: .zero, of: actionButtonView, preferredEdge: .minY, behavior: .transient)
        }
        
        tagAction.backgroundColor = NSColor.lightGray
        archiveToggleAction.backgroundColor = Color.tintColor
        
        return [tagAction, archiveToggleAction]
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        self.quickLookPanelController.previewItems = self.selectedURLItems.flatMap({ NSURL(string: $0.urlString) })
    }
    
    func tableView(_ tableView: NSTableView, shouldTypeSelectFor event: NSEvent, withCurrentSearch searchString: String?) -> Bool {
        // makes it so we don't try to search the table when doing a key event that the view controller controls anyway
        if searchString == nil && self.shouldHandle(keyEvent: event) == true {
            return false
        } else {
            return true
        }
    }
}

// MARK: Handle Showing URL if there is no Title

private extension URLItem {
    @objc private var bindingTitle: String {
        return self.extras?.pageTitle ?? self.urlString
    }
}
