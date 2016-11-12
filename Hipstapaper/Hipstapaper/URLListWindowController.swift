//
//  URLListWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Cocoa

class URLListWindowController: NSWindowController {
    
    var listItems: [URLItem] = [
            URLItem(urlString: "http://www.apple.com"),
            URLItem(urlString: "http://www.microsoft.com"),
            URLItem(urlString: "http://www.google.com")
        ] {
        didSet {
            print("array changed")
        }
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.titleVisibility = .hidden
    }
    
}

@objc(URLItem)
class URLItem: NSObject {
    
    let id = UUID().uuidString
    var modifiedDate = Date()
    var urlString: String {
        didSet {
            self.modifiedDate = Date()
        }
    }
    
    override init() {
        self.urlString = "url"
        super.init()
    }
    
    init(urlString: String) {
        self.urlString = urlString
        super.init()
    }
}
