//
//  AppDelegate.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // this allows me to deallocate the window when all windows are closed
    // when its closed, the notification below fires and set this property to nil
//    let rootWindowController = URLListWindowController(syncController: .combined)
//    #if DEBUG
//    private let debugWindows: [NSWindowController] = [
//        URLListWindowController(syncController: .realmOnly),
//        URLListWindowController(syncController: .cloudKitOnly)
//    ]
//    #endif


    // open the main window when the app launches
    func applicationDidFinishLaunching(_ aNotification: Notification) {
//        self.rootWindowController.showWindow(self)
//        
//        #if DEBUG
//        for window in self.debugWindows {
//            window.showWindow(self)
//        }
//        #endif
        RealmConfig.configure() {
            let realm = try! Realm()
            try! realm.write {
                for i in 0..<10 {
                    let newItem = URLItem()
                    newItem.urlString = "http://www.\(i).com"
                    realm.add(newItem)
                }
                print("Done")
            }
//            let results = realm.objects(URLItem.self)
//            print(results)
        }

    }
    
    // opens the main window if the dock icon is clicked and there are no windows open
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag == false {
            //self.rootWindowController.showWindow(self)
        }
        return true
    }
    
    // responds to CMD+0 plus the Hipstaper window menu item to show the main window
    @IBAction func showMainWindowMenuChosen(_ sender: NSObject?) {
        guard
            let menuItem = sender as? NSMenuItem,
            menuItem.title == "Hipstapaper"
        else { return }
        //self.rootWindowController.showWindow(self)
    }
}

