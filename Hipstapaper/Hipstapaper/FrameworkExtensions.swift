//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/13/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

extension Array where Element: Hashable {
    func deletedItems(from oldArray: Array<Element>) -> Array<Element>? {
        let oldSet = Set(oldArray)
        let selfSet = Set(self)
        let deleted = oldSet.subtracting(selfSet)
        return deleted.isEmpty == false ? Array(deleted) : .none
    }
    func addedItems(to oldArray: Array<Element>) -> Array<Element>? {
        let oldSet = Set(oldArray)
        let selfSet = Set(self)
        let added = selfSet.subtracting(oldSet)
        return added.isEmpty == false ? Array(added) : .none
    }
}

extension String {
    init(urlStringFromRawString rawString: String) {
        var components = URLComponents(string: rawString)
        if components?.host == nil {
            // if the host is nil, then it probably couldn't parse the URL
            // adding http:// to it and then generating new components sometimes helps this.
            components = URLComponents(string: "http://" + rawString)
        }
        self = components?.url?.absoluteString ?? rawString
    }
}

extension NSWindow: KVOCapable { } // makes NSWindow work with Title Prefixer
