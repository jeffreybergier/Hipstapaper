//
//  TagItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Foundation

public protocol TagItemType {
    var name: String { get set }
    var itemCount: Int { get }
}

public enum TagItem {
    public struct Value: TagItemType {
        public var name: String
        public var itemCount: Int
    }
    
    public enum Selection {
        case notSelectable, allItems, unarchivedItems, tag(name: String)
    }
}

extension String: TagItemType {
    public var itemCount: Int { return 0 }
    public var name: String {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}

@objc(TreeBindingObject)
public class TreeBindingObject: NSObject {
    
    public var title = "untitled"
    public var children: [TreeBindingObject] = []
    public var kind = TagItem.Selection.notSelectable
    
    public override init() {
        super.init()
    }
    
    public init(title: String, children: [TreeBindingObject] = [], kind: TagItem.Selection = .notSelectable) {
        self.title = title
        self.children = children
        self.kind = kind
    }
}
