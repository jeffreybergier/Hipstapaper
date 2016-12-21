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

protocol URLItemSelectionReceivable: class {
    func didSelect(_: URLItem.Selection, from: NSOutlineView?)
}

class TagListViewController: NSViewController {
    
    weak var selectionDelegate: URLItemSelectionReceivable?
    
    @IBOutlet private weak var outlineView: NSOutlineView?
    @IBOutlet private weak var treeController: NSTreeController?
    private lazy var selectionObserver: KeyValueObserver<NSNull> = KeyValueObserver<NSNull>(target: self.treeController!, keyPath: #keyPath(NSTreeController.selectionIndexPath))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tags = RealmConfig.tags
        let content = TreeBindingObject.treeObjects(from: tags)
        
        self.treeController?.content = content
        self.treeController?.setSelectionIndexPath(.none)
        self.outlineView?.expandItem(.none, expandChildren: true)
        
        self.selectionObserver.startObserving() { [weak self] _ -> NSNull? in
            guard let selectedObject = self?.treeController?.selectedObjects.first as? TreeBindingObject else { return nil }
            if case .selectable(let selection) = selectedObject.kind {
                self?.selectionDelegate?.didSelect(selection, from: self?.outlineView)
            }
            return nil
        }
    }
    
    deinit {
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
    
    class func treeObjects(from results: Results<TagItem>) -> [TreeBindingObject] {
        let tagChildren = Array(results.map({ TreeBindingObject(title: $0.name, kind: .selectable(.tag($0))) }))
        
        let unarchivedChild = TreeBindingObject(title: "Unread Items", kind: .selectable(.unarchived))
        let allChild = TreeBindingObject(title: "All Items", kind: .selectable(.all))
        
        let mainTree = TreeBindingObject(title: "Reading List", children: [unarchivedChild, allChild], kind: .notSelectable(.main))
        let tagTree = TreeBindingObject(title: "Tags", children: tagChildren, kind: .notSelectable(.tags))
        
        return [mainTree, tagTree]
    }
    
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
