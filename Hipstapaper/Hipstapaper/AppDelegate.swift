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
    
    let dataSource: SyncingPersistenceType = CombinedURLItemSyncingController()
//    let dataSource: SyncingPersistenceType = RealmURLItemSyncingController()
//    let dataSource: SyncingPersistenceType = CloudKitURLItemSyncingController()
    
    // this allows me to deallocate the window when all windows are closed
    // when its closed, the notification below fires and set this property to nil
    fileprivate var _rootWC: URLListWindowController?
    var rootWindowController: URLListWindowController {
        if let rootWC = self._rootWC {
            return rootWC
        } else {
            let windowController = URLListWindowController()
            self._rootWC = windowController
            return windowController
        }
    }

    // open the main window when the app launches
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemWindowWillClose(_:)), name: .NSWindowWillClose, object: .none)
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
}

// listen for all window closes.
// if the primary window is not hosting any other windows, then release it
// otherwise, keep it because its needed to keep the other windows
extension AppDelegate /*NSWindowDelegate*/ {
    @objc fileprivate func itemWindowWillClose(_ notification: NSNotification) {
        // dispatch after because there is no NSWindowDidClose
        // so when this is called, the previous window is still open
        // need to kill some time before checking to see if we should clean up memory
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            if
                let mainWC = self._rootWC, // make sure the window exists
                let mainWindow = mainWC.window, // make sure the window exists
                mainWC.isPresentingChildWindows == false, // make sure its not presenting any windows
                mainWindow.isVisible == false // make sure it is also not visible
            {
                self._rootWC = .none
            }
        }
    }
}

