//
//  LoginViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

class LoginViewController: NSViewController {
    
    private enum Purpose {
        case login, create
    }
    
    @IBOutlet private weak var serverTextField: NSTextField?
    @IBOutlet private weak var usernameTextField: NSTextField?
    @IBOutlet private weak var password1TextField: NSTextField?
    @IBOutlet private weak var password2TextField: NSTextField?
    @IBOutlet private weak var spinner: NSProgressIndicator?
    
    private var purpose = Purpose.login

    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = self.password2TextField {
            self.purpose = .create
        } else {
            self.purpose = .login
        }
    }
    
    @IBAction private func primaryButtonClicked(_ sender: NSObject?) {
        switch self.purpose {
        case .login:
            print("Login Button Clicked")
        case .create:
            print("Create Button Clicked")
        }
    }
}
