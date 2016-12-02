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
}

public enum TagItem {
    struct Value: TagItemType {
        var name: String
    }
}

extension String: TagItemType {
    public var name: String {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}
