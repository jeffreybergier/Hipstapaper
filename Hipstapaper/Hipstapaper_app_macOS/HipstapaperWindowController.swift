//
//  HipstapaperWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

class HipstapaperWindowController: NSWindowController {
    
    /*@IBOutlet*/ private weak var sidebarViewController: TagListViewController?
    /*@IBOutlet*/ fileprivate weak var mainViewController: URLListViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.titleVisibility = .hidden
        
        for childVC in self.window?.contentViewController?.childViewControllers ?? [] {
            if let sidebarVC = childVC as? TagListViewController {
                self.sidebarViewController = sidebarVC
            } else if let mainVC = childVC as? URLListViewController {
                self.mainViewController = mainVC
            }
        }
        
        self.sidebarViewController!.selectionDelegate = self
    }
    
}

extension HipstapaperWindowController: URLItemSelectionReceivable {
    func didSelect(_ selection: URLItem.Selection, from outlineView: NSOutlineView?) {
        self.mainViewController!.didSelect(selection, from: outlineView)
    }
}
