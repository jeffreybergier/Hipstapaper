//
//  MainWindowCreator.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/29/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import AppKit

final class MainWindowCreator: NSObject, NSWindowRestoration {
    
    static func restoreWindow(withIdentifier identifier: NSUserInterfaceItemIdentifier, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Swift.Void) {
        guard let appDelegate = NSApp.delegate as? AppDelegate else { completionHandler(nil, nil); return; }
        let wc = self.newMainWindowController()
        appDelegate.rootWindowController = wc
        completionHandler(wc.window, nil)
    }
    
    static func newMainWindowController() -> MainWindowController {
        let wc = MainWindowController(windowNibName: "MainWindowController")
        wc.window?.isRestorable = true
        wc.window?.restorationClass = self
        wc.window?.identifier = NSUserInterfaceItemIdentifier(rawValue: "MainHipstapaperWindow")
        wc.windowFrameAutosaveName = "MainHipstapaperWindow"
        return wc
    }
}
