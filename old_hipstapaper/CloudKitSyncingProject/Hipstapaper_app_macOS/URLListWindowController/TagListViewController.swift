//
//  TagListViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/10/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import AppKit

class TagListViewController: NSViewController {
    
    weak var dataSource: URLItemDoublePersistanceType?
    
    @IBOutlet private weak var bindingManager: TagListBindingManager? {
        didSet {
            self.bindingManager?.dataSource = self.dataSource
        }
    }
    
    func windowSyncFinished(result: Result<Void>, sender: NSObject?) {
        self.bindingManager?.reloadData()
    }
}
