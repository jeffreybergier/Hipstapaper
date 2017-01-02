//
//  MouseDownToolbarItem.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/2/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import AppKit

class MouseDownButton: NSButton {
    
    override func mouseDown(with event: NSEvent) {
        // if we don't have an action, just work like a regular button
        guard let action = self.action else { super.mouseDown(with: event); return; }
    
        // now we need to perform the appropriate selector on mouse down instead of mouse up
        if let target = self.target {
            // if we have a target, perform a crashable action on it
            // this is normal behavior
            let _ = target.perform(action, with: self)
        } else {
            // if we don't have an explicit target, we just need to send this message to the first responder
            let _ = super.window!.firstResponder.try(toPerform: action, with: self)
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        // if we don't have an action, just work like a regular button
        guard let _ = self.action else { super.mouseUp(with: event); return; }
        // ignore everything after this as its all handled in the mouseDown method
    }
    
}
