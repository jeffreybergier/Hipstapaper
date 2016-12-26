//
//  LoginViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/25/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import AppKit

class LoginMacViewController: NSViewController {
    
    private enum Purpose {
        case login, create
    }
    
    @IBOutlet private weak var serverTextField: NSTextField?
    @IBOutlet private weak var usernameTextField: NSTextField?
    @IBOutlet private weak var password1TextField: NSTextField?
    @IBOutlet private weak var password2TextField: NSTextField?
    @IBOutlet private weak var primaryButton: NSButton?
    @IBOutlet private weak var spinner: NSProgressIndicator?
    @IBOutlet private weak var parentWindowController: PreferencesWindowController?
    
    private var purpose = Purpose.login

    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = self.password2TextField {
            self.purpose = .create
        } else {
            self.purpose = .login
        }
        self.setButtonState(fieldValid: false)
    }
    
    private func networkActivity(ocurring: Bool) {
        self.serverTextField?.isEnabled = !ocurring
        self.usernameTextField?.isEnabled = !ocurring
        self.password1TextField?.isEnabled = !ocurring
        self.password2TextField?.isEnabled = !ocurring
        self.primaryButton?.isEnabled = !ocurring
        switch ocurring {
        case false:
            self.spinner?.stopAnimation(nil)
        case true:
            self.spinner?.startAnimation(nil)
        }
    }
    
    private func setButtonState(fieldValid valid: Bool) {
        self.primaryButton?.isEnabled = valid
    }
    
    @IBAction private func textFieldChanged(_ sender: NSObject?) {
        let serverValid: Bool
        if let _ = URL(string: self.serverTextField?.stringValue ?? " ") {
            serverValid = true
        } else {
            serverValid = false
        }
        
        let usernameValid: Bool
        if self.usernameTextField?.stringValue != nil && self.usernameTextField?.stringValue != "" {
            usernameValid = true
        } else {
            usernameValid = false
        }
        
        let password1Valid: Bool
        if self.password1TextField?.stringValue != nil && self.password1TextField?.stringValue != "" {
            password1Valid = true
        } else {
            password1Valid = false
        }
        
        let password2Valid: Bool
        if case .create = self.purpose {
            if self.password2TextField?.stringValue != nil &&
                self.password2TextField?.stringValue != "" &&
                self.password2TextField?.stringValue == self.password1TextField?.stringValue
            {
                password2Valid = true
            } else {
                password2Valid = false
            }
        } else {
            password2Valid = true
        }
        
        self.setButtonState(fieldValid: serverValid && usernameValid && password1Valid && password2Valid)
    }
    
    @IBAction private func primaryButtonClicked(_ sender: NSObject?) {
        self.networkActivity(ocurring: true)
        
        let register: Bool
        switch self.purpose {
        case .login:
            register = false
        case .create:
            register = true
        }
        
        let server = URL(string: self.serverTextField?.stringValue ?? "")!
        let username = self.usernameTextField?.stringValue ?? ""
        let password = self.password1TextField?.stringValue ?? ""
        
        let credentials = SyncCredentials.usernamePassword(username: username, password: password, register: register)
        SyncUser.logIn(with: credentials, server: server) { user, error in
            DispatchQueue.main.async {
                if let user = user {
                    self.parentWindowController?.realmController = RealmController(user: user)
                    self.parentWindowController?.showWindow(sender)
                    self.networkActivity(ocurring: false)
                } else {
                    let alert = NSAlert(error: error!)
                    alert.beginSheetModal(for: self.view.window!) { _ in
                        self.networkActivity(ocurring: false)
                    }
                }
            }
        }
    }
}
