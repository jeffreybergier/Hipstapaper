//
//  LoggedInViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

class LoggedInViewController: NSViewController {
    
    @IBOutlet private weak var parentWindowController: PreferencesWindowController?
    
    @IBAction private func logoutButtonClicked(_ sender: NSObject?) {
        self.parentWindowController?.realmController?.logOut()
        self.parentWindowController?.realmController = nil
        self.parentWindowController?.showWindow(sender)
    }
    
}
