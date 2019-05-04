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

    private var token: Any?

    override func viewDidLoad() {
        super.viewDidLoad()
        //
        // First, force our own view to always be in light appearance.
        // This tells the system to always draw our text as if it has a light background.
        // Which it does
        //
        self.view.appearance = NSAppearance(named: .aqua)

        //
        // Observe when the notification fires for changing appearance (Private API 🙄)
        // NSViewController does not have an override point like NSView does 🙄
        // And even then, it wouldn't work on older systems
        //
        self.token = NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "HIMenuBarAppearanceDidChangeNotification"),
                                                            object: nil,
                                                            queue: nil,
                                                            using: { [weak self] _ in
                                                                //
                                                                // Delay things because the appearance changes after the notification
                                                                // 🙄🙄🙄🙄
                                                                //
                                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                                                    self?.updateAppearance()
                                                                }
                                                            })
        self.updateAppearance()
    }
    
    private func updateAppearance() {
        //
        // Change the background based on the appearance of our window.
        // Remember that we forcefully set it on our view, so using that one
        // doesn't help.
        //
        let isLightAppearance = self.view.window?.currentAppearance.isNormal ?? true
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
        NotificationCenter.default.removeObserver(self.token as Any)
    }
    
}
