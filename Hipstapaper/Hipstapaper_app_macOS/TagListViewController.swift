//
//  TagListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

extension NSTreeController: KVOCapable {}

class TagListViewController: NSViewController {
    
    weak var realmController: RealmController? {
        didSet {
            self.hardReloadData()
        }
    }
    
    weak var selectionDelegate: URLItemSelectionDelegate?
    
    @IBOutlet private weak var outlineView: NSOutlineView?
    @IBOutlet private weak var treeController: NSTreeController?
    private lazy var selectionObserver: KeyValueObserver<NSNull> = KeyValueObserver<NSNull>(target: self.treeController!, keyPath: #keyPath(NSTreeController.selectionIndexPath))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hardReloadData()
        
        self.selectionObserver.startObserving() { [weak self] _ -> NSNull? in
            guard
                let selectedObject = self?.treeController?.selectedObjects.first as? TreeBindingObject,
                case .selectable(let selection) = selectedObject.kind
            else { return nil }
            self?.selectionDelegate?.didSelect(selection, from: self?.outlineView)
            return nil
        }
    }
    
    // MARK: Reload Data
    
    private func hardReloadData() {
        // clear out all previous update tokens and tableview
        self.notificationToken?.stop()
        self.notificationToken = .none
        self.treeController?.content = TreeBindingObject.treeObjects(from: .none)
        self.outlineView?.expandItem(.none, expandChildren: true)
        
        // refresh the content with new data
        let items = self.realmController?.tags
        self.notificationToken = items?.addNotificationBlock(self.realmResultsChangeClosure)
    }
    
    private lazy var realmResultsChangeClosure: ((RealmCollectionChange<Results<TagItem>>) -> Void) = { [weak self] changes in
        let newResults: Results<TagItem>?
        let newSelection: [IndexPath]
        switch changes {
        case .initial(let results):
            newResults = results
            newSelection = [IndexPath(item: 0, section: 0)]
        case .update(let results, _, _, _):
            newResults = results
            newSelection = self?.treeController?.selectionIndexPaths ?? [IndexPath(item: 0, section: 0)]
        case .error(let error):
            newResults = .none
            newSelection = []
            guard let window = self?.view.window else { break }
            let alert = NSAlert(error: error)
            alert.beginSheetModal(for: window, completionHandler: .none)
        }
        
        let content = TreeBindingObject.treeObjects(from: newResults)
        self?.treeController?.content = content
        self?.treeController?.setSelectionIndexPaths(newSelection)
        self?.outlineView?.expandItem(.none, expandChildren: true)
    }
    
    // MARK: Handle Going Away
    
    private var notificationToken: NotificationToken?
    
    deinit {
        self.notificationToken?.stop()
        self.selectionObserver.endObserving()
    }

}

extension TagListViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = (item as? NSTreeNode)?.representedObject as? TreeBindingObject else { return .none }
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
        guard let item = (item as? NSTreeNode)?.representedObject as? TreeBindingObject else { return false }
        switch item.kind {
        case .notSelectable:
            return false
        case .selectable:
            return true
        }
    }
}

@objc(TreeBindingObject)
private class TreeBindingObject: NSObject {
    
    class func treeObjects(from results: Results<TagItem>?) -> [TreeBindingObject] {
        
        // Make Children for the top part of the list
        // these are always present
        let unarchivedChild = TreeBindingObject(title: "Unread Items", kind: .selectable(.unarchived))
        let allChild = TreeBindingObject(title: "All Items", kind: .selectable(.all))
        
        // create the parent for the top part
        let mainTree = TreeBindingObject(title: "Reading List", children: [unarchivedChild, allChild], kind: .notSelectable(.main))
        
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

        return [mainTree, tagTree]
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
