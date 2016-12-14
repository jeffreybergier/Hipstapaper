//
//  UserFlowNavigationController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import UIKit

class UserFlowNavigationController: UINavigationController {
    
    // MARK: Data Source
    
    private let dataSource: URLItemDoublePersistanceType = URLItemPersistanceController()
//    private let dataSource: URLItemDoublePersistanceType = URLItemRealmController()
//    private let dataSource: URLItemDoublePersistanceType = URLItemCloudKitController()
    
    // MARK: Permanent View Controllers
    
    private let tagVC = TagItemListViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tagVC.dataSource = self.dataSource
        let unarchivedVC = URLItemListViewController(selection: TagItem.Selection.unarchivedItems, dataSource: self.dataSource, delegate: self.tagVC)
        
        self.pushViewController(self.tagVC, animated: false)
        self.pushViewController(unarchivedVC, animated: true)
        
        self.setToolbarHidden(false, animated: false)
    }
}
