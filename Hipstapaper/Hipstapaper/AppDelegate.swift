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
    
    let rootWindowController: URLListWindowController
    
    override init() {
        let windowController = URLListWindowController()
        self.rootWindowController = windowController
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.rootWindowController.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) { }
}

