//
//  LoadingIndicatorViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 2/2/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Common
import Aspects

//
////
////// Ok, this is a pile of hacks, so lets get started
////
//

// swiftlint:disable:next type_name
class AppearanceObservingLoadingIndicatorViewController: LoadingIndicatorViewController {

    private var viewDidMoveToWindowToken: AspectToken?
    private var appearanceKVOToken: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // We need to wait for the view to move into the window.
        // NSViewController has no override for this but NSView does 🙄.
        //
        let viewDidMoveToWindowClosure: @convention(block) () -> Void = { [unowned self] in
            //
            // Once the view is in the window we'll update the appearance manually
            //
            self.updateAppearance()

            //
            // Now we need to make sure the window is set
            // The view could be moved out of the window as well
            //
            guard let window = self.view.window else {
                // If we move it out, we clear our KVO token to break the relationship
                self.appearanceKVOToken = nil
                return
            }

            //
            // Now we observe whenever the effective appearance changes
            // When that happens, we can update the appearance
            //
            self.appearanceKVOToken = window.observe(\.effectiveAppearance) { _, _ in
                self.updateAppearance()
            }
        }

        // Do the NSView viewDidMoveToWindow observation.
        self.viewDidMoveToWindowToken = try? self.view.aspect_hook(#selector(self.view.viewDidMoveToWindow),
                                                                   with: [], usingBlock: viewDidMoveToWindowClosure)
    }
    
    private func updateAppearance() {
        //
        // Change the background based on the appearance of our window.
        // Remember that we forcefully set it on our view, so using that one
        // doesn't help.
        //
        let isLightAppearance = self.view.window?.effectiveAppearance.isNormal ?? true
        switch isLightAppearance {
        case true:
            // icon color is the default
            // unless we have a valid appearance and that appearance is dark, we want to set it to icon color
            self.setBackgroundColor(Color.iconColor)
        case false:
            // if we have a valid appearance and that appearance is dark, set the background color accordingly.
            self.setBackgroundColor(NSColor.windowBackgroundColor)
        }
    }
    
    deinit {
        self.viewDidMoveToWindowToken?.remove()
    }
    
}
