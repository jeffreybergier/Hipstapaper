//
//  ValidatingToolbarItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/22/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

fileprivate extension NSToolbarItem {
    
    static fileprivate let validateToolbarItemSelector = #selector(NSObject.validateToolbarItem(_:))

    fileprivate func isValid(for object: NSObject?) -> Bool {
        // returns NSAtom when returning Bool.true
        if let _ = object?.perform(type(of: self).validateToolbarItemSelector, with: self)?.takeUnretainedValue() { // as? NSAtom
            return true
        } else {
            return false // returns nil when selector returns Bool.false
        }
    }
}

class ValidatingToolbar: NSToolbar {
    
    @IBOutlet private weak var window: NSWindow?
    
    private var splitView: NSSplitView? {
        return self.window?.contentView?.subviews.first as? NSSplitView
    }
    
    private var firstResponder: NSResponder? {
        return self.window?.firstResponder
    }
    
    private func setLeadingFlexibleSpaceToolbarItemTrackedSplitView() {
        let items = self.items
        items.forEach({ self.removeSplitView(from: $0) })
        let flexibleItems = items.filter({ $0.isKind(of: NSToolbarItem.flexibleSpaceClass) })
        guard let item = flexibleItems.first else { return }
        self.setSplitView(on: item)
    }
    
    private func setSplitView(on item: NSToolbarItem) {
        guard item.isKind(of: NSToolbarItem.flexibleSpaceClass) == true, let splitView = self.splitView else { return }
        let selector = NSToolbarItem.setTrackedSplitViewSelector
        let responds = item.responds(to: selector)
        if responds {
            item.perform(selector, with: splitView)
        }
    }
    
    private func removeSplitView(from item: NSToolbarItem) {
        guard item.isKind(of: NSToolbarItem.flexibleSpaceClass) == true else { return }
        let selector = NSToolbarItem.setTrackedSplitViewSelector
        let responds = item.responds(to: selector)
        if responds {
            item.perform(selector, with: nil)
        }
    }
    
    override func validateVisibleItems() {
        super.validateVisibleItems()
        
        self.setLeadingFlexibleSpaceToolbarItemTrackedSplitView()
        
        for toolbarItem in self.items {
            // only change toolbar items if they claim to self validate
            guard toolbarItem.autovalidates == true else { continue }
            // disable it pre-emptively, we only re-enable under special circumstances
            toolbarItem.isEnabled = false
            // only change toolbar items if they have an action they connect to
            guard let toolbarAction = toolbarItem.action else { continue }
            // while loop to go through all possible responders
            var currentResponder = self.firstResponder
            while currentResponder != nil {
                let respondsToAction = currentResponder?.responds(to: toolbarAction) ?? false
                let respondsToValidation = currentResponder?.responds(to: type(of: toolbarItem).validateToolbarItemSelector) ?? false
                // make sure that the responder responds to the action of the tool bar item
                // make sure it also responds to validate tool bar item.
                // standard style says if it doesn't respond to toolbar validation, it automatically ignores the toolbar item
                if respondsToAction && respondsToValidation {
                    // this is hacky, but performSelector doesn't work with primitive types
                    // but when true was returned, I saw an NSAtom come back
                    // when false was returned, I got nil back. So thats good enough for me.
                    let toolbarItemValidated = toolbarItem.isValid(for: currentResponder)
                    // update the toolbar item with the validation value
                    toolbarItem.isEnabled = toolbarItemValidated
                    // break out of the loop because the responder chain won't go any further
                    break
                }
                currentResponder = currentResponder?.nextResponder
            }
        }
    }
}
