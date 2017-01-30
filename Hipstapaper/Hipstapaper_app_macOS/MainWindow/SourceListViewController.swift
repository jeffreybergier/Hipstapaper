//
//  TagListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Common
import RealmSwift
import AppKit

class SourceListViewController: NSViewController {
    
    // MARK: External Interface
    
    weak var realmController: RealmController? {
        didSet {
            self.hardReloadData()
        }
    }
    
    weak var selectionDelegate: URLItemsToLoadChangeDelegate?
    
    // MARK: Tag Data
    
    fileprivate var data: Results<TagItem>?
    
    // this property needs to be permanent to help with dynamically refreshing the outline view
    fileprivate let tagParent = TreeBindingObject(title: "Tags  🏷", kind: .notSelectable(.tags))
    
    // MARK: Outlets
    
    @IBOutlet fileprivate weak var outlineView: NSOutlineView?
    
    // MARK View Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hardReloadData()
    }
    
    // MARK: Reload Data
    
    private func hardReloadData() {
        // clear out all previous update tokens and tableview
        self.notificationToken?.stop()
        self.notificationToken = .none
        self.data = .none
        self.tagParent.childCount = 0
        self.outlineView?.reloadData()
        
        // refresh the content with new data
        self.data = self.realmController?.tag_loadAll()
        self.notificationToken = self.data?.addNotificationBlock(self.realmResultsChangeClosure)
        
        // manually update the child count of the tag parent
        self.tagParent.childCount = self.data?.count ?? 0
        // hard reload the data
        self.outlineView?.reloadData()
        // expand all items in the outline
        self.outlineView?.expandItem(.none, expandChildren: true)
        // select the item after that row... the unread row
        self.didChange(itemsToLoad: self.selectionDelegate?.itemsToLoad,
                        sortOrder: self.selectionDelegate?.sortOrder,
                        filter: self.selectionDelegate?.filter,
                        sender: .sourceListVC)
    }
    
    fileprivate var changingSelectionProgrammaticaly = false // refer to MARK Selection Super Hack
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<TagItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial:
            break
        case .update(_, let deletions, let insertions, let modifications):
            // manually update the child count of the tag parent
            self?.tagParent.childCount = self?.data?.count ?? 0
            // add and remove changed rows
            self?.outlineView?.beginUpdates()
            self?.outlineView?.removeItems(at: IndexSet(deletions), inParent: self?.tagParent, withAnimation: .slideLeft)
            self?.outlineView?.insertItems(at: IndexSet(insertions), inParent: self?.tagParent, withAnimation: .slideRight)
            // updating rows is different, there is no bulk method
            modifications.forEach() { childIndex in
                // no good way to find the parentRowindex... should always be 3
                let parentIndex = 3
                // get the item that needs to be updated.
                let childObject = self?.outlineView?.item(atRow: parentIndex + childIndex + 1)
                // tell the outline view to update that object
                self?.outlineView?.reloadItem(childObject, reloadChildren: false)
            }
            self?.outlineView?.endUpdates()
        case .error(let error):
            guard let window = self?.view.window else { break }
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: window, completionHandler: .none)
        }
    }
    
    // MARK: Handle NSOutlineView Menus
    
    fileprivate var selection: TreeBindingObject.Selection? {
        let tree = self.outlineView?.selectedRowIndexes.map({ self.outlineView?.item(atRow: $0) as? TreeBindingObject }).flatMap({ $0 }).first
        guard let item = tree else { return .none }
        if case .selectable(let selection) = item.kind {
            return selection
        }
        return .none
    }
    
    private var selectedTags: TagItem.UIIdentifier? {
        guard let selection = self.selection else { return .none }
        if case .tag(let tag) = selection.itemsToLoad {
            return tag
        }
        return .none
    }
    
    @objc private func delete(_ menuItem: NSMenuItem) {
        guard let realmController = self.realmController, menuItem.tag == 666, let selectedTag = self.selectedTags else { return }
        let alert = NSAlert()
        alert.messageText = "Delete '\(selectedTag.displayName)'?"
        alert.informativeText = "This action cannot be undone"
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: self.view.window!) { [weak self] buttonNumber in
            guard buttonNumber == 1000 else { return }
            realmController.tag_deleteTag(with: selectedTag)
            // MARK: HACK, reload data in the table because the callback is not being called
            Thread.sleep(forTimeInterval: 0.2)
            self?.hardReloadData()
        }
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let _ = self.realmController, menuItem.tag == 666, let _ = self.selectedTags else { return false }
        return true
    }
    
    // MARK: Handle Going Away
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
    }

}

extension SourceListViewController: URLItemsToLoadChangeDelegate {
    var itemsToLoad: URLItem.ItemsToLoad {
        return self.selectionDelegate!.itemsToLoad
    }
    var filter: URLItem.ArchiveFilter {
        return self.selectionDelegate!.filter
    }
    var sortOrder: URLItem.SortOrder {
        return self.selectionDelegate!.sortOrder
    }
    func didChange(itemsToLoad: URLItem.ItemsToLoad?, sortOrder: URLItem.SortOrder?, filter: URLItem.ArchiveFilter?, sender: ViewControllerSender) {
        switch sender {
        case .tertiaryVC:
            fatalError()
        case .sourceListVC:
            self.changingSelectionProgrammaticaly = true
            fallthrough
        case .contentVC:
            guard let itemsToLoad = itemsToLoad else { return }
            switch itemsToLoad {
            case .all:
                let parentIndex = 0
                switch filter ?? .unarchived {
                case .unarchived:
                    self.outlineView?.selectRowIndexes(IndexSet([parentIndex + 1]), byExtendingSelection: false)
                case .all:
                    self.outlineView?.selectRowIndexes(IndexSet([parentIndex + 2]), byExtendingSelection: false)
                }
            case .tag(let tagID):
                guard
                    let parentIndex = self.outlineView?.row(forItem: self.tagParent),
                    let matchingTagIndex = self.data?.enumerated().filter({ $0.element.normalizedNameHash == tagID.idName }).map({ $0.offset }).first
                else { break }
                self.outlineView?.selectRowIndexes(IndexSet([parentIndex + matchingTagIndex + 1]), byExtendingSelection: false)
            }
        }
    }
}

extension SourceListViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? TreeBindingObject {
            guard case .notSelectable(let section) = item.kind else { fatalError("Only the main items should have children") }
            switch section {
            case .main:
                let selection: TreeBindingObject.Selection
                let title: String
                switch index {
                case 0:
                    title = "Unread Items"
                    selection = TreeBindingObject.Selection(itemsToLoad: .all, filter: .unarchived, sortOrder: .none)
                case 1:
                    title = "All Items"
                    selection = TreeBindingObject.Selection(itemsToLoad: .all, filter: .all, sortOrder: .none)
                default:
                    fatalError("There shouldn't be more than 2 children under the main section")
                }
                return TreeBindingObject(title: title, kind: .selectable(selection))
            case .tags:
                let tagItem = self.data?[index]
                let tagID = TagItem.UIIdentifier(idName: tagItem?.normalizedNameHash ?? "ErrorLoadingTag", displayName: tagItem?.name ?? "Error Loading Tag")
                let selection = TreeBindingObject.Selection(itemsToLoad: .tag(tagID), filter: .all, sortOrder: .none)
                return TreeBindingObject(title: tagID.displayName, kind: .selectable(selection), itemCount: tagItem?.items.count ?? 0)
            }
        } else {
            switch index {
            case 0:
                return TreeBindingObject(title: "Reading List  🎁", kind: .notSelectable(.main), childCount: 2)
            case 1:
                return self.tagParent
            default:
                fatalError("Too many root level items requested by NSOutlineView. There should only be the main parent and the tag parent.")
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        // if this is NIL, we have not given it any objects yet
        // so we just need to tell it there are 2 children at the root
        // 1) is the main area with Unread/All children 2) is the tag area with N children
        guard let tree = item as? TreeBindingObject else { return 2 }
        return tree.childCount
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let tree = item as? TreeBindingObject else { return false }
        return !(tree.childCount == 0)
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        // this method just populates the view with an object value so that bindings work from IB
        return item
    }
    
}

extension SourceListViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? TreeBindingObject else { return .none }
        let identifier: String
        switch item.kind {
        case .notSelectable:
            identifier = "HeaderCell"
        case .selectable(let selection):
            switch selection.itemsToLoad {
            case .all:
                identifier = "DataCellWithoutNumber"
            case .tag:
                identifier = "DataCellWithNumber"
            }
        }
        let view = outlineView.make(withIdentifier: identifier, owner: outlineView)
        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        guard let item = item as? TreeBindingObject else { return false }
        switch item.kind {
        case .notSelectable:
            return false
        case .selectable:
            return true
        }
    }
    
    // MARK: Selection Super Hack
    
    // Normally programmatically causing something to change does not cause delegate callbacks for that change to be called
    // However, for Outline view, programatically selecting things does cause the selectionDidChange callback to be called
    // So now I am storing some state that says whether the selection was changed programatically or not
    
    // // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/TableView/RowSelection/RowSelection.html
    // // The selectRowIndexes:byExtendingSelection: method expects an NSIndexSet containing the indexes (zero-based) of 
    // // the rows to be selected, and a parameter that specifies whether the current selection should be extended. 
    // // If the extending selection parameter is YES, the specified row indexes are selected in addition to any previously selected rows; 
    // // if it’s NO, the selection is changed to the newly specified rows. When this method is called, the delegate receives 
    // // only the tableViewSelectionDidChange: notification.
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        defer {
            self.changingSelectionProgrammaticaly = false
        }
        guard let selection = self.selection, self.changingSelectionProgrammaticaly == false else { return }
        self.selectionDelegate?.didChange(itemsToLoad: selection.itemsToLoad, sortOrder: selection.sortOrder, filter: selection.filter, sender: .sourceListVC)
    }
}

@objc fileprivate class TreeBindingObject: NSObject {
    
    // MARK: Bindings Properties for Cell View
    @objc fileprivate let title: String
    @objc fileprivate let itemCount: String
    
    // MARK: Properties for getting data back from the outlineview
    fileprivate let kind: Kind
    fileprivate(set) var childCount: Int
    
    // MARK: Initialization
    
    fileprivate init(title: String, kind: Kind, childCount: Int = 0, itemCount: Int = 0) {
        self.title = title
        self.kind = kind
        self.childCount = childCount
        self.itemCount = String(itemCount)
        super.init()
    }
    
    // MARK: Custom Types to make things easier
    
    fileprivate enum Kind {
        case notSelectable(Section), selectable(Selection)
    }
    
    fileprivate enum Section {
        case main, tags
    }
    
    fileprivate struct Selection {
        var itemsToLoad: URLItem.ItemsToLoad
        var filter: URLItem.ArchiveFilter
        var sortOrder: URLItem.SortOrder?
    }
}
