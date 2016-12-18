//
//  TagListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

class TagListViewController: NSViewController {
    
    @IBOutlet private weak var outlineView: NSOutlineView?
    @IBOutlet private weak var treeController: NSTreeController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let child1 = TreeBindingObject(title: "child1", kind: .selectable(.unarchivedItems))
        let child2 = TreeBindingObject(title: "child2", kind: .selectable(.unarchivedItems))
        let initialThing = TreeBindingObject(title: "Parent1", children: [child1, child2])
        let child3 = TreeBindingObject(title: "child3", kind: .selectable(.unarchivedItems))
        let child4 = TreeBindingObject(title: "child4", kind: .selectable(.unarchivedItems))
        let secondThing = TreeBindingObject(title: "Parent2", children: [child3, child4], kind: .notSelectable(.tags))
        self.treeController?.content = [initialThing, secondThing]
        self.treeController?.setSelectionIndexPath(.none)
        self.outlineView?.expandItem(.none, expandChildren: true)
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
    
    var title = "untitled"
    var children: [TreeBindingObject] = []
    var kind = Selection.notSelectable(.main)
    
    convenience init(title: String, children: [TreeBindingObject] = [], kind: Selection = .notSelectable(.main)) {
        self.init()
        self.title = title
        self.children = children
        self.kind = kind
    }
    
    enum Selection {
        case notSelectable(Section), selectable(URLItem.Selection)
    }
    
    enum Section {
        case main, tags
    }
}
