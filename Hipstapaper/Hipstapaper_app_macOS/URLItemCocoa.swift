//
//  URLItemCocoa.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/20/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

extension URLItem {
    var image: NSImage? {
        get {
            guard let data = self.imageData else { return .none }
            let image = NSImage(data: data)
            return image
        }
        set {
            guard let image = newValue else { self.imageData = .none; return }
            let data = image.tiffRepresentation
            self.imageData = data
            self.modificationDate = Date()
        }
    }
}

