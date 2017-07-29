//
//  LocalViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 7/29/17.
//  Copyright © 2017 Jeffrey Bergier. All rights reserved.
//

import Common
import AppKit

class LocalViewController: NSViewController {
    
    @IBOutlet private weak var parentWindowController: PreferencesWindowController?
    
    @IBAction private func localButtonClicked(_ sender: Any) {
        let realmController = RealmController(kind: .local)
        self.parentWindowController?.delegate?.realmController = realmController
        self.parentWindowController?.showWindow(sender)
    }
}
