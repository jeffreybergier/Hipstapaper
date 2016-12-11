//
//  TagListBindingManager.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/10/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

class TagListBindingManager: NSObject {
        
    @IBOutlet private weak var sourceList: NSOutlineView?
    @IBOutlet private weak var treeController: NSTreeController? {
        didSet {
            self.treeController?.content = self.content
        }
    }
    
    private var content: [TreeBindingObject] {
        return [self.mainItems, self.tagItems]
    }
    
    fileprivate let mainItems: TreeBindingObject = {
        let unread = TreeBindingObject(title: "Unread Items")
        let all = TreeBindingObject(title: "All Items")
        let root = TreeBindingObject(title: "Reading List", children: [unread, all])
        return root
    }()
    
    fileprivate let tagItems = TreeBindingObject(title: "Tags")
    
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
    
    override init() {
        super.init()
    }
    
    init(title: String, children: [TreeBindingObject] = []) {
        self.title = title
        self.children = children
    }
}
