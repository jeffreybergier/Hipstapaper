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
    
    private let rootWindowController: HipstapaperWindowController = {
        let storyboard = NSStoryboard(name: "Main", bundle: Bundle(for: AppDelegate.self))
        let initial = storyboard.instantiateInitialController()!
        let windowController = initial as! HipstapaperWindowController
        return windowController
    }()

    // open the main window when the app launches
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.rootWindowController.showWindow(self)
        self.processItemsSavedByExtension()
    }
    
    // opens the main window if the dock icon is clicked and there are no windows open
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            self.rootWindowController.showWindow(self)
        }
        self.processItemsSavedByExtension()
        return true
    }
    
    // responds to CMD+0 plus the Hipstaper window menu item to show the main window
    @IBAction func showMainWindowMenuChosen(_ sender: NSObject?) {
        guard
            let menuItem = sender as? NSMenuItem,
            menuItem.title == "Hipstapaper"
        else { return }
        self.processItemsSavedByExtension()
        self.rootWindowController.showWindow(self)
    }
    
    private func processItemsSavedByExtension() {
        DispatchQueue.global(qos: .background).async {
            guard let realmController = self.rootWindowController.realmController else { return }
            guard let itemsOnDisk = NSKeyedUnarchiver.unarchiveObject(withFile: SerializableURLItem.archiveURL.path) as? [SerializableURLItem] else {
                // delete the file if it exists and has incorrect data, or else this could fail forever and never get fixed
                try? FileManager.default.removeItem(at: SerializableURLItem.archiveURL)
                return
            }
            DispatchQueue.main.async {
                for item in itemsOnDisk {
                    guard let urlString = item.urlString else { continue }
                    let newURLItem = URLItem()
                    newURLItem.urlString = urlString
                    newURLItem.creationDate = item.date ?? newURLItem.creationDate
                    newURLItem.modificationDate = item.date ?? newURLItem.modificationDate
                    let newExtras = URLItemExtras()
                    newExtras.image = item.image
                    newExtras.pageTitle = item.pageTitle
                    if newExtras.pageTitle != nil || newExtras.imageData != nil {
                        newURLItem.extras = newExtras
                    }
                    realmController.add(item: newURLItem)
                }
                try? FileManager.default.removeItem(at: SerializableURLItem.archiveURL)
            }
        }
    }
}

