//
//  URLListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

class URLListViewController: UIViewController {
    
    enum Selection {
        case unarchivedItems, allItems, tag(TagItem)
    }
    
    private var selection: Selection?
    
    convenience init(selection: Selection) {
        self.init()
        self.selection = selection
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
