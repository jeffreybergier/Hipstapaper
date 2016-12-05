//
//  URLItemListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/4/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import UIKit

class URLItemListViewController: UIViewController {
    
    private let dataSource: DoubleSourcePersistenceType = CombinedURLItemSyncingController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("URLItemListViewController Loaded")
    }
    
}
