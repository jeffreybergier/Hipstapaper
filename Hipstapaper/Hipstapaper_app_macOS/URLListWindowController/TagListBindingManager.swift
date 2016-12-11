//
//  TagListBindingManager.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/10/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import AppKit

extension NSTreeController: KVOCapable {}

class TagListBindingManager: NSObject {
    
    weak var dataSource: URLItemDoublePersistanceType? {
        didSet {
            self.reloadData()
        }
    }
    
    @IBOutlet private weak var parentWindow: NSWindow?
    @IBOutlet private weak var sourceList: NSOutlineView?
    @IBOutlet private weak var treeController: NSTreeController? {
        didSet {
            guard let treeController = self.treeController else { return }
            treeController.content = self.content
            self.selectionKVO = KeyValueObserver(target: treeController)
        }
    }
    
    private var selectionKVO: KeyValueObserver<NSNull>? {
        didSet {
            self.selectionKVO?.add(keyPath: #keyPath(NSTreeController.selectedNodes)) { nodes -> NSNull? in
                guard let selected = self.treeController?.selectedNodes.first?.representedObject as? TreeBindingObject else { return .none }
                let selector = #selector(URLListWindowController.didChangeTag(selection:))
                let _ = self.parentWindow?.firstResponder.try(toPerform: selector, with: TagSelectionContainer(selection: selected.kind, sender: self.sourceList))
                return .none
            }
        }
    }
    
    private var content: [TreeBindingObject] {
        return [self.mainItems, self.tagItems]
    }
    
    fileprivate let mainItems: TreeBindingObject = {
        let unread = TreeBindingObject(title: "Unread Items", kind: .unarchivedItems)
        let all = TreeBindingObject(title: "All Items", kind: .allItems)
        let root = TreeBindingObject(title: "Reading List", children: [unread, all], kind: .notSelectable)
        return root
    }()
    
    fileprivate let tagItems = TreeBindingObject(title: "Tags", kind: .notSelectable)
    
    func reloadData() {
        self.dataSource?.tagItems() { tagResult in
            switch tagResult {
            case .error(let errors):
                NSLog("Error Loading Tags: \(errors)")
                self.updateTagList(newTags: [])
            case .success(let tags):
                self.updateTagList(newTags: tags)
            }
        }
    }
    
    private func updateTagList(newTags: [TagItemType]) {
        let treeItems = newTags.map({ TreeBindingObject(title: $0.name, kind: .tag(name: $0.name)) })
        DispatchQueue.main.async {
            self.tagItems.children = treeItems
            self.treeController?.content = self.content
        }
    }
}

extension TagListBindingManager: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = (item as? NSTreeNode)?.representedObject as? TreeBindingObject else { return .none }
        let identifier: String
        if item === self.mainItems || item === self.tagItems {
            identifier = "HeaderCell"
        } else {
            identifier = "DataCell"
        }
        let view = outlineView.make(withIdentifier: identifier, owner: outlineView)
        return view
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        guard let item = (item as? NSTreeNode)?.representedObject as? TreeBindingObject else { return false }
        if item === self.mainItems || item === self.tagItems {
            return false
        } else {
            return true
        }
    }
}

@objc(TreeBindingObject)
private class TreeBindingObject: NSObject {
    
    var title = "untitled"
    var children: [TreeBindingObject] = []
    var kind = TagItem.Selection.notSelectable
    
    override init() {
        super.init()
    }
    
    init(title: String, children: [TreeBindingObject] = [], kind: TagItem.Selection = .notSelectable) {
        self.title = title
        self.children = children
        self.kind = kind
    }
}

class TagSelectionContainer: NSObject {
    let selection: TagItem.Selection
    let sender: AnyObject?
    
    init(selection: TagItem.Selection, sender: AnyObject?) {
        self.selection = selection
        self.sender = sender
        super.init()
    }
}

