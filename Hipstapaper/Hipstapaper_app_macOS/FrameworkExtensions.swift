//
//  FrameworkExtensions.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/2/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Common
import AppKit

extension NSWindow: KVOCapable {}
extension NSSplitViewItem: KVOCapable {}


extension NSToolbarItem {
    
    // Load some types from the run time. We will use these to compare the type of toolbar item we are later
    // if we can't load these types from the runtime, then just set them to a class that a toolbar could never be (NSSet)
    private static let flexibleSpaceClass: AnyObject.Type = NSClassFromString("NSToolbarFlexibleSpaceItem") ?? NSSet.self
    private static let fixedSpaceClass: AnyObject.Type = NSClassFromString("NSToolbarSpaceItem") ?? NSSet.self
    
    func resizeIfNeeded() {
        guard
            self.isKind(of: type(of: self).flexibleSpaceClass) == false &&
            self.isKind(of: type(of: self).fixedSpaceClass) == false &&
            self.itemIdentifier != NSToolbarFlexibleSpaceItemIdentifier &&
            self.itemIdentifier != NSToolbarSpaceItemIdentifier &&
            self.itemIdentifier.contains("NORESIZE-") == false
        else { return }
        self.minSize = NSSize(width: 56, height: 34)
        self.maxSize = NSSize(width: 56, height: 34)
    }
}

extension NSTextField {
    enum Kind: Int {
        case backgroundStyleAdaptable = 756
    }
}

extension NSToolbarItem {
    enum Kind: Int {
        case unarchive = 544, archive = 555, tag = 222, share = 233, jsToggle = 766, quickLook = 764
    }
}

extension NSMenuItem {
    enum Kind: Int {
        case open = 999, copy = 444, archive = 555, unarchive = 544, delete = 666, share = 898, shareSubmenu = 897, javascript = 433, showMainWindow = 374, tags = 909, quickLook = 764
    }
}

extension NSMenu {
    convenience init(shareMenuWithItems items: [URL]) {
        self.init()
        let compatibleServices = NSSharingService.sharingServices(forItems: items)
        compatibleServices.forEach() { service in
            let title = service.title
            let image = service.image
            let newMenuItem = NSMenuItem(title: title, action: #selector(ContentListViewController.shareMenu(_:)), keyEquivalent: "")
            newMenuItem.image = image
            newMenuItem.representedObject = service
            newMenuItem.tag = NSMenuItem.Kind.shareSubmenu.rawValue
            self.addItem(newMenuItem)
        }
    }
}

// MARK: Autochanging Text Field Colors in TableViews

// The purpose of this is to change color when the selection changes on the tableview. There are some hacks in here.
// Normally NSTableCellView forwards the setBackgroundStyle message to all subviews.
// However, it doesn't do this recursiely.
// Since the labels are wthin a stackview they don't get the message.
// Below there is an NSView extension that always forwards the message on to all subviews

extension NSView {
    func setBackgroundStyle(_ newValue: NSBackgroundStyle) {
        for view in self.subviews {
            view.setBackgroundStyle(newValue)
        }
    }
}

extension NSTextField {
    override func setBackgroundStyle(_ newValue: NSBackgroundStyle) {
        defer {
            super.setBackgroundStyle(newValue)
        }
        
        guard let kind = Kind(rawValue: self.tag) else { return }
        
        switch kind {
        case .backgroundStyleAdaptable:
            switch newValue {
            case .dark:
                self.textColor = NSColor.controlLightHighlightColor
            case .light, .lowered, .raised:
                self.textColor = NSColor.labelColor
            }
        }
    }
}

/*
extension NSBackgroundStyle: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dark:
            return ".dark"
        case .light:
            return ".light"
        case .lowered:
            return ".lowered"
        case .raised:
            return ".raised"
        }
    }
}
 */
