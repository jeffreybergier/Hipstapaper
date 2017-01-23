//
//  AppDelegate.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let extensionFileProcessor = SaveExtensionFileProcessor()
    
    // during state restoration this property is set before the lazy getting does anything
    // if state restoration does not happen, then this just acts normally
    fileprivate(set) lazy var rootWindowController: HipstapaperWindowController = HipstapaperWindowCreator.windowController()

    // open the main window when the app launches
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.rootWindowController.showWindow(self)
    }
    
    // opens the main window if the dock icon is clicked and there are no windows open
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            self.rootWindowController.showWindow(self)
        }
        return true
    }
    
    // responds to CMD+0 plus the Hipstaper window menu item to show the main window
    @IBAction func showMainWindowMenuChosen(_ sender: NSObject?) {
        guard
            let menuItem = sender as? NSMenuItem,
            menuItem.title == "Hipstapaper"
        else { return }
        self.rootWindowController.showWindow(self)
    }
    
    // MARK: Load Items from Extension when App Comes or Goes
    
    func applicationDidBecomeActive(_ notification: Notification) {
        self.extensionFileProcessor.processFiles(with: self.rootWindowController.realmController)
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        self.extensionFileProcessor.processFiles(with: self.rootWindowController.realmController)
    }
}

fileprivate class HipstapaperWindowCreator: NSObject, NSWindowRestoration {
    
    fileprivate static func restoreWindow(withIdentifier identifier: String, state: NSCoder, completionHandler: @escaping (NSWindow?, Error?) -> Swift.Void) {
        let wc = self.windowController()
        guard let appDelegate = NSApp.delegate as? AppDelegate else {
            completionHandler(.none, .none)
            return
        }
        appDelegate.rootWindowController = wc
        completionHandler(wc.window, .none)
    }
    
    fileprivate static func windowController() -> HipstapaperWindowController {
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle(for: self))
        let initial = storyboard.instantiateInitialController()!
        let wc = initial as! HipstapaperWindowController
        wc.window?.isRestorable = true
        wc.window?.restorationClass = self
        wc.window?.identifier = "MainHipstapaperWindow"
        wc.windowFrameAutosaveName = "MainHipstapaperWindow"
        return wc
    }
}

