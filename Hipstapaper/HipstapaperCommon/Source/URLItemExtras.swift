//
//  URLItemExtras.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/21/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift

final public class URLItemExtras: Object {
    
    public internal(set) dynamic var pageTitle: String?
    public fileprivate(set) dynamic var imageData: Data?
        
    public convenience init(title: String?, imageData: Data?) {
        self.init()
        self.pageTitle = title
        self.imageData = imageData
    }
    
    override public class func ignoredProperties() -> [String] {
        return ["image"]
    }
}

#if os(OSX)
    import AppKit
    
    public extension URLItemExtras {
        
        public convenience init(title: String?, image: NSImage?) {
            self.init()
            self.pageTitle = title
            self.image = image
        }
        
        public internal(set) var image: NSImage? {
            get {
                guard let data = self.imageData else { return nil }
                let image = NSImage(data: data)
                return image
            }
            set {
                guard let image = newValue else { self.imageData = nil; return }
                let data = image.tiffRepresentation
                self.imageData = data
            }
        }
    }
#else
    import UIKit
    
    public extension URLItemExtras {
        
        public convenience init(title: String?, image: UIImage?) {
            self.init()
            self.pageTitle = title
            self.image = image
        }
        
        public internal(set) var image: UIImage? {
            get {
                guard let data = self.imageData else { return nil }
                let image = UIImage(data: data)
                return image
            }
            set {
                guard let image = newValue else { self.imageData = nil; return }
                let data = UIImagePNGRepresentation(image)
                self.imageData = data
            }
        }
    }
#endif
