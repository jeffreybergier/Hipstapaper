//
//  ValidatingToolbarItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/22/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

fileprivate extension Bool {
    fileprivate static func bool(byPerformingSelector selector: Selector, onObject object: NSObject?) -> Bool {
        if let _ = object?.perform(selector)?.takeUnretainedValue() { // as? NSAtom // returns NSAtom when returning Bool.true
            return true
        } else {
            return false // returns nil when selector returns Bool.false
        }
    }
}

class ValidatingToolbar: NSToolbar {
    
    @IBOutlet private weak var window: NSWindow?
    
    private var firstResponder: NSResponder? {
        return self.window?.firstResponder
    }
    
    override func validateVisibleItems() {
        super.validateVisibleItems()
        let validateToolbarItemSelector = #selector(NSObject.validateToolbarItem(_:))
        for toolbarItem in self.visibleItems ?? [] {
            // only change toolbar items if they claim to self validate
            guard toolbarItem.autovalidates == true else { continue }
            // only change toolbar items if they have an action they connect to
            guard let toolbarAction = toolbarItem.action else { continue }
            // disable it pre-emptively, we only re-enable under special circumstances
            toolbarItem.isEnabled = false

            // while loop to go through all possible responders
            var currentResponder = self.firstResponder
            while currentResponder != nil {
                let respondsToAction = currentResponder?.responds(to: toolbarAction) ?? false
                let respondsToValidation = currentResponder?.responds(to: validateToolbarItemSelector) ?? false
                // make sure that the responder responds to the action of the tool bar item
                // make sure it also responds to validate tool bar item.
                // standard style says if it doesn't respond to toolbar validation, it automatically ignores the toolbar item
                if respondsToAction && respondsToValidation {
                    // this is hacky, but performSelector doesn't work with primitive types
                    // but when true was returned, I saw an NSAtom come back
                    // when false was returned, I got nil back. So thats good enough for me.
                    let toolbarItemValidated = Bool.bool(byPerformingSelector: validateToolbarItemSelector, onObject: currentResponder)
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
