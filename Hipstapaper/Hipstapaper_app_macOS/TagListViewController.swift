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
        self.outlineView?.reloadData()
        
        // refresh the content with new data
        self.data = self.realmController?.tags
        self.notificationToken = self.data?.addNotificationBlock(self.realmResultsChangeClosure)
    }
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<TagItem>>) -> Void) = { [weak self] changes in
        switch changes {
        case .initial(let results):
            self?.outlineView?.reloadData()
            self?.outlineView?.expandItem(.none, expandChildren: true)
            self?.outlineView?.selectRowIndexes(IndexSet([1]), byExtendingSelection: false)
        case .update(let results, _, _, _):
            self?.outlineView?.reloadData()
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
    
    fileprivate var selectedTags: TagItem.UIIdentifier? {
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
        alert.beginSheetModal(for: self.view.window!) { buttonNumber in
            guard buttonNumber == 1000 else { return }
            realmController.deleteTag(with: selectedTag)
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
        if let tree = item as? TreeBindingObject {
            return tree.children[index]
        } else {
            switch index {
            case 0:
                return TreeBindingObject.parentTreeObject()
            case 1:
                return TreeBindingObject.parentTreeObject(from: self.data)
            default:
                fatalError()
            }
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let tree = item as? TreeBindingObject else { return 2 }
        return tree.children.count
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let tree = item as? TreeBindingObject else { return false }
        return !tree.children.isEmpty
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
        case .selectable:
            identifier = "DataCell"
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

@objc(TreeBindingObject)
private class TreeBindingObject: NSObject {
    
    class func parentTreeObject() -> TreeBindingObject {
        
        // Make Children for the top part of the list
        // these are always present
        let unarchivedChild = TreeBindingObject(title: "Unread Items", kind: .selectable(.unarchived))
        let allChild = TreeBindingObject(title: "All Items", kind: .selectable(.all))
        
        // create the parent for the top part
        let mainTree = TreeBindingObject(title: "Reading List", children: [unarchivedChild, allChild], kind: .notSelectable(.main))

        return mainTree
    }
    
    class func parentTreeObject(from results: Results<TagItem>?) -> TreeBindingObject {
        // Iterate through the tags and create children for them
        let tagChildren = results?.map() { tagItem -> TreeBindingObject in
            let uiIdentifier = TagItem.UIIdentifier(idName: tagItem.normalizedNameHash, displayName: tagItem.name)
            let child = TreeBindingObject(title: tagItem.name, kind: .selectable(.tag(uiIdentifier)))
            return child
        }
        
        // Cannot wrap optional lazy protocol sequence craziness that comes back from realm in Array()
        // so we need to check its optionality before making the parent of the tags
        // the parent always exists, even if it has no children
        let tagTree: TreeBindingObject
        if let tagChildren = tagChildren {
            tagTree = TreeBindingObject(title: "Tags", children: Array(tagChildren), kind: .notSelectable(.tags))
        } else {
            tagTree = TreeBindingObject(title: "Tags", children: .none, kind: .notSelectable(.tags))
        }
        
        return tagTree
    }
    
    var title = "untitled"
    var children: [TreeBindingObject] = []
    var kind = Selection.notSelectable(.main)
    
    convenience init(title: String, children: [TreeBindingObject]? = nil, kind: Selection = .notSelectable(.main)) {
        self.init()
        self.title = title
        self.children = children ?? []
        self.kind = kind
    }
    
    enum Selection {
        case notSelectable(Section), selectable(URLItem.Selection)
    }
    
    enum Section {
        case main, tags
    }
}
