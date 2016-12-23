//
//  URLTaggingViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/23/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Cocoa

@objc(TagSelection)
fileprivate class TagSelection: NSObject {
    
    var state: NSCellStateValue = 0
    var name: String = "unknown"
    
    convenience init(name: String, state: NSCellStateValue) {
        self.init()
        self.state = state
        self.name = name
    }
    
}

class URLTaggingViewController: NSViewController {
    
    private var selectedItems = [URLItem]()
    
    convenience init(items: [URLItem]) {
        self.init()
        self.selectedItems = items
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("tagging view did load")
    }
    
}
