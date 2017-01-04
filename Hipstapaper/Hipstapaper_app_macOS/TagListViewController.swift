//
//  TagListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

class TagListViewController: NSViewController {
    
    // MARK: External Interface
    
    weak var realmController: RealmController? {
        didSet {
            self.hardReloadData()
        }
    }
    
    weak var selectionDelegate: URLItemSelectionDelegate?
    
    // MARK: Tag Data
    
    fileprivate var data: Results<TagItem>?
    
    fileprivate let mainParent = TreeBindingObject(title: "Reading List", kind: .notSelectable(.main), childCount: 2)
    fileprivate let tagParent = TreeBindingObject(title: "Tags", kind: .notSelectable(.tags))
    
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
        self.data = .none
        self.notificationToken?.stop()
        self.notificationToken = .none
        self.tagParent.childCount = 0
        self.outlineView?.reloadData()
        
        // refresh the content with new data
        self.data = self.realmController?.tags
        self.notificationToken = self.data?.addNotificationBlock(self.realmResultsChangeClosure)
    }
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<TagItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial:
            self?.tagParent.childCount = self?.data?.count ?? 0
            self?.outlineView?.reloadData()
            self?.outlineView?.expandItem(.none, expandChildren: true)
            self?.outlineView?.selectRowIndexes(IndexSet([1]), byExtendingSelection: false)
        case .update(_, let deletions, let insertions, let modifications):
            self?.tagParent.childCount = self?.data?.count ?? 0
            self?.outlineView?.beginUpdates()
            self?.outlineView?.insertItems(at: IndexSet(insertions), inParent: self?.tagParent, withAnimation: .slideLeft)
            self?.outlineView?.removeItems(at: IndexSet(deletions), inParent: self?.tagParent, withAnimation: .slideLeft)
            modifications.forEach() { childIndex in
                let parentRow = self?.outlineView?.row(forItem: self?.tagParent) ?? 3
                let childObject = self?.outlineView?.item(atRow: parentRow + childIndex + 1)
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
    
    fileprivate var selection: URLItem.Selection? {
        let tree = self.outlineView?.selectedRowIndexes.map({ self.outlineView?.item(atRow: $0) as? TreeBindingObject }).flatMap({ $0 }).first
        guard let item = tree else { return .none }
        if case .selectable(let selection) = item.kind {
            return selection
        }
        return .none
    }
    
    private var selectedTags: TagItem.UIIdentifier? {
        guard let selection = self.selection else { return .none }
        if case .tag(let tag) = selection {
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
            realmController.deleteTag(with: selectedTag)
            // MARK: HACK, reload data in the table because the callback is not being called
            self?.outlineView?.reloadItem(self?.tagParent, reloadChildren: true)
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

extension TagListViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let item = item as? TreeBindingObject {
            guard case .notSelectable(let section) = item.kind else { fatalError("Only the main items should have children") }
            switch section {
            case .main:
                switch index {
                case 0:
                    return TreeBindingObject(title: "Unread Items", kind: .selectable(.unarchived))
                case 1:
                    return TreeBindingObject(title: "All Items", kind: .selectable(.all))
                default:
                    fatalError("There shouldn't be more than 2 children under the main section")
                }
            case .tags:
                let tagItem = self.data?[index]
                let tagID = TagItem.UIIdentifier(idName: tagItem?.normalizedNameHash ?? "ErrorLoadingTag", displayName: tagItem?.name ?? "Error Loading Tag")
                return TreeBindingObject(title: tagID.displayName, kind: .selectable(.tag(tagID)), itemCount: tagItem?.items.count ?? 0)
            }
        } else {
            switch index {
            case 0:
                return self.mainParent
            case 1:
                return self.tagParent
            default:
                fatalError("Too many root level items requested by NSOutlineView. There should only be the main parent and the tag parent.")
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let tree = item as? TreeBindingObject else { return 2 }
        return tree.childCount
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let tree = item as? TreeBindingObject else { return false }
        return !(tree.childCount == 0)
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return item
    }
    
}

extension TagListViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? TreeBindingObject else { return .none }
        let identifier: String
        switch item.kind {
        case .notSelectable(let section):
            switch section {
            case .main:
                identifier = "MainHeaderCell"
            case .tags:
                identifier = "TagHeaderCell"
            }
        case .selectable(let selection):
            switch selection {
            case .all, .unarchived:
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
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        guard let selection = self.selection else { return }
        self.selectionDelegate?.didSelect(selection, from: self.outlineView)
    }
}

private class TreeBindingObject: NSObject {
    
    let title: String
    let kind: Selection
    fileprivate(set) var childCount: Int
    let itemCount: String
    
    init(title: String, kind: Selection, childCount: Int = 0, itemCount: Int = 0) {
        self.title = title
        self.kind = kind
        self.childCount = childCount
        self.itemCount = String(itemCount)
        super.init()
    }
    
    enum Selection {
        case notSelectable(Section), selectable(URLItem.Selection)
    }
    
    enum Section {
        case main, tags
    }
}
