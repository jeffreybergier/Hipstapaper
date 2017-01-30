//
//  AppDelegate.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit
import Common

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let extensionFileProcessor = SaveExtensionFileProcessor()
    
    // during state restoration this property is set before the lazy getting does anything
    // if state restoration does not happen, then this just acts normally
    lazy var rootWindowController: MainWindowController = MainWindowCreator.newMainWindowController()

    // open the main window when the app launches
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if (self.rootWindowController.window?.isVisible ?? false) == false {
            self.rootWindowController.showWindow(self)
        }
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
            let kind = NSMenuItem.Kind(rawValue: menuItem.tag),
            kind == .showMainWindow
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

