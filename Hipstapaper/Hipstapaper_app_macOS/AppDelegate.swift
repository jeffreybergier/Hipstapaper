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
    
    let rootWindowController: HipstapaperWindowController = {
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle(for: AppDelegate.self))
        let initial = storyboard.instantiateInitialController()!
        let windowController = initial as! HipstapaperWindowController
        return windowController
    }()

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

