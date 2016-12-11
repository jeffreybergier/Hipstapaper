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
    
    @IBOutlet private weak var bindingManager: TagListBindingManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func windowSyncFinished(result: Result<Void>, sender: NSObject?) {
    }
}
