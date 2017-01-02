//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/2/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import AppKit

extension NSToolbarItem {
    enum Kind: Int {
        case unarchive = 544, archive = 555, tag = 222, share = 233
    }
}

extension NSMenuItem {
    enum Kind: Int {
        case open = 999, copy = 444, archive = 555, unarchive = 544, delete = 666, share = 898, shareSubmenu = 897, javascript = 433
    }
}

extension NSMenu {
    convenience init(shareMenuWithItems items: [URL]) {
        self.init()
        let compatibleServices = NSSharingService.sharingServices(forItems: items)
        compatibleServices.forEach() { service in
            let title = service.title
            let image = service.image
            let newMenuItem = NSMenuItem(title: title, action: #selector(URLListViewController.shareMenu(_:)), keyEquivalent: "")
            newMenuItem.image = image
            newMenuItem.representedObject = service
            newMenuItem.tag = NSMenuItem.Kind.shareSubmenu.rawValue
            self.addItem(newMenuItem)
        }
    }
}
