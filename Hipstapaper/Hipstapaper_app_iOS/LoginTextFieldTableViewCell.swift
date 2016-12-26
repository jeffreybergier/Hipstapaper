//
//  LoginTextFieldTableViewCell.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

class LoginTextFieldTableViewCell: UITableViewCell {
    
    static let nibName = "LoginTextFieldTableViewCell"
    
    var kind = LoginiOSTableViewController.CellKind.server {
        didSet {
            self.textField?.tag = self.kind.rawValue
            switch self.kind {
            case .server:
                self.textField?.isSecureTextEntry = false
                self.textField?.keyboardType = .URL
                self.textField?.keyboardAppearance = .default
            case .username:
                self.textField?.isSecureTextEntry = false
                self.textField?.keyboardType = .emailAddress
                self.textField?.keyboardAppearance = .default
            case .password1, .password2:
                self.textField?.isSecureTextEntry = true
                self.textField?.keyboardType = .default
                self.textField?.keyboardAppearance = .dark
            }
        }
    }

    @IBOutlet weak var textField: UITextField?
    
}
