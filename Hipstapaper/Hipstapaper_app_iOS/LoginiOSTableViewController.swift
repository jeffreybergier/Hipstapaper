//
//  LoginiOSTableViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import UIKit

class LoginiOSTableViewController: UITableViewController {
    
    // MARK: Custom Types
    
    enum CellKind: Int {
        case server, username, password1, password2
    }
    
    fileprivate struct Model {
        var server: String?
        var username: String?
        var password1: String?
        var password2: String?
        
        enum Validation {
            case valid, invalid(message: String)
        }
    }
    
    // MARK: Private State
    
    private weak var delegate: RealmControllable?
    private var createNewAccount = false
    fileprivate var model = Model()
    
    // MARK: Bar Button Items
    
    private typealias UIBBI = UIBarButtonItem
    private lazy var doneBBI: UIBBI = UIBBI(barButtonSystemItem: .done, target: self, action: #selector(self.doneBBITapped(_:)))
    private lazy var cancelBBI: UIBBI = UIBBI(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelBBITapped(_:)))
    private let loadBBI: UIBBI = {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        spinner.startAnimating()
        let bbi = UIBBI(customView: spinner)
        return bbi
    }()
    
    // MARK: Handle Loading
    
    convenience init(createAccount: Bool, delegate: RealmControllable) {
        self.init(style: .grouped)
        self.createNewAccount = createAccount
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load the custom cell nib
        let nib = UINib(nibName: LoginTextFieldTableViewCell.nibName, bundle: Bundle(for: LoginTextFieldTableViewCell.self))
        self.tableView.register(nib, forCellReuseIdentifier: LoginTextFieldTableViewCell.nibName)
        
        // configure the BBI
        self.navigationItem.leftBarButtonItem = self.cancelBBI
        self.navigationItem.rightBarButtonItem = self.doneBBI
        
        // set the title
        switch self.createNewAccount {
        case true:
            self.title = "Create Account"
        case false:
            self.title = "Login"
        }
    }
    
    // MARK: Handle User Input
    
    @objc private func doneBBITapped(_ sender: NSObject?) {
        self.view.endEditing(false)
        
        let formValid = self.validateModel()
        switch formValid {
        case .valid:
            self.updateUI(networkActivity: true)
            let model = self.model
            let register = self.createNewAccount
            let credentials = SyncCredentials.usernamePassword(username: model.username!, password: model.password1!, register: register)
            SyncUser.logIn(with: credentials, server: URL(string: model.server!)!) { user, error in
                DispatchQueue.main.async {
                    if let user = user {
                        self.updateUI(networkActivity: false)
                        let newController = RealmController(user: user)
                        self.delegate?.realmController = newController
                        self.dismiss(animated: true, completion: .none)
                    } else {
                        let message = error?.localizedDescription ?? "Unknown Error"
                        let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Dismiss", style: .cancel) { action in
                            self.updateUI(networkActivity: false)
                        }
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: .none)
                    }
                }
            }
        case .invalid(let message):
            let alert = UIAlertController(title: "Login Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: .none)
            alert.addAction(action)
            self.present(alert, animated: true, completion: .none)
        }
    }
    
    @objc private func cancelBBITapped(_ sender: NSObject?) {
        self.view.endEditing(false)
        self.dismiss(animated: true, completion: .none)
    }
    
    // MARK: Network Activity
    
    private func updateUI(networkActivity: Bool) {
        self.tableView?.isUserInteractionEnabled = !networkActivity
        self.cancelBBI.isEnabled = !networkActivity
        self.doneBBI.isEnabled = !networkActivity
        
        let newAlpha: CGFloat
        switch networkActivity {
        case true:
            newAlpha = 0.3
            self.navigationItem.setRightBarButton(self.loadBBI, animated: true)
        case false:
            newAlpha = 1.0
            self.navigationItem.setRightBarButton(self.doneBBI, animated: true)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.tableView?.alpha = newAlpha
        }
    }
    
    // MARK: Form Validation
    
    private func validateModel() -> Model.Validation {
        let model = self.model
        
        if URL(string: model.server ?? " ") == .none {
            return .invalid(message: "Server Address is Invalid")
        }
        
        if model.username == nil || model.username == "" {
            return .invalid(message: "Username is Invalid")
        }
        
        if model.password1 == nil || model.password1 == "" {
            return .invalid(message: "Password is Invalid")
        }
        
        if self.createNewAccount == true {
            if model.password2 == nil ||
                model.password2 == "" ||
                model.password2 != model.password1
            {
                return .invalid(message: "Passwords don't Match")
            }
        }
        
        return .valid
    }
    
    // MARK: TableView Scheiße
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        switch self.createNewAccount {
        case true:
            return 4
        case false:
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let cellKind = CellKind(rawValue: section) else { return .none }
        switch cellKind {
        case .server:
            return "Server Address"
        case .username:
            return "Username"
        case .password1:
            return "Password"
        case .password2:
            return "Confirm Password"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LoginTextFieldTableViewCell.nibName, for: indexPath)
        if let textFieldCell = cell as? LoginTextFieldTableViewCell {
            textFieldCell.textField?.delegate = self
            textFieldCell.kind = CellKind(rawValue: indexPath.section) ?? .server
        }
        return cell
    }
    
}

extension LoginiOSTableViewController: UITextFieldDelegate {
    
    // MARK: Handle TextField Input
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let cellKind = CellKind(rawValue: textField.tag) else { return }
        switch cellKind {
        case .server:
            self.model.server = textField.text
        case .username:
            self.model.username = textField.text
        case .password1:
            self.model.password1 = textField.text
        case .password2:
            self.model.password2 = textField.text
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LoginiOSTableViewController {
    
    // MARK: Custom Constructor
    
    class func dualLoginTabBarController(delegate: RealmControllable) -> UITabBarController {
        let tabVC = UITabBarController()
        let createVC = LoginiOSTableViewController(createAccount: true, delegate: delegate)
        let createNavVC = UINavigationController(rootViewController: createVC)
        let loginVC = LoginiOSTableViewController(createAccount: false, delegate: delegate)
        let loginNavVC = UINavigationController(rootViewController: loginVC)
        tabVC.viewControllers = [loginNavVC, createNavVC]
        tabVC.tabBar.items?.enumerated().forEach() { index, item in
            switch index {
            case 0:
                item.title = "Login"
            case 1:
                item.title = "Create Account"
            default:
                break
            }
        }
        tabVC.modalPresentationStyle = .formSheet
        return tabVC
    }
}
