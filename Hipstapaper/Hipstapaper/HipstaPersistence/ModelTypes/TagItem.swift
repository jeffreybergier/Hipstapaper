//
//  TagItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Foundation

protocol TagItemType {
    var name: String { get set }
}

enum TagItem {
    struct Value: TagItemType {
        var name: String
    }
}

extension String: TagItemType {
    var name: String {
        get {
            return self
        }
        set {
            self = newValue
        }
    }
}
