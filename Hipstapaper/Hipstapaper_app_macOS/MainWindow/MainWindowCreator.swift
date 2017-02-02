//
//  MainWindowCreator.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 1/29/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import AppKit

final class MainWindowCreator: NSObject, NSWindowRestoration {
    
    static func restoreWindow(withIdentifier identifier: String, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Swift.Void) {
        guard let appDelegate = NSApp.delegate as? AppDelegate else { completionHandler(.none, .none); return; }
        let wc = self.newMainWindowController()
        appDelegate.rootWindowController = wc
        completionHandler(wc.window, .none)
    }
    
    static func newMainWindowController() -> MainWindowController {
        let wc = MainWindowController(windowNibName: "MainWindowController")
        wc.window?.isRestorable = true
        wc.window?.restorationClass = self
        wc.window?.identifier = "MainHipstapaperWindow"
        wc.windowFrameAutosaveName = "MainHipstapaperWindow"
        return wc
    }
}
