//
//  TagListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/10/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import AppKit

class TagListViewController: NSViewController {
    
    @IBOutlet private weak var sourceList: NSOutlineView?
    @IBOutlet private weak var treeController: NSTreeController?
    
    private var content: [TreeBindingObject] {
        return [self.mainItems, self.tagItems]
    }
    
    @objc private let mainItems: TreeBindingObject = {
        let unread = TreeBindingObject(title: "Unread Items")
        let all = TreeBindingObject(title: "All Items")
        let root = TreeBindingObject(title: "Reading List", children: [unread, all])
        return root
    }()
    
    @objc private let tagItems = TreeBindingObject(title: "Tags")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.treeController?.content = self.content
        self.sourceList?.expandItem(.none, expandChildren: true)
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
            let newTree = TreeBindingObject(title: "Timer 123")
            self.tagItems.children.append(newTree)
            self.treeController?.content = self.content
        }
    }
    
    func windowSyncFinished(result: Result<Void>, sender: NSObject?) {
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
