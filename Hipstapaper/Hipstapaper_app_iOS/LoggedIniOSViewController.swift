//
//  LoggedInViewContrller.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

class LoggedIniOSViewController: UIViewController, RealmControllable {
    
    var realmController = RealmController() {
        didSet {
            self.updateUILabels()
        }
    }
    
    @IBOutlet private weak var primaryTextLabel: UILabel?
    @IBOutlet private weak var loginButton: UIButton?
    @IBOutlet private weak var createButton: UIButton?
    @IBOutlet private weak var logoutButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure my title
        self.title = "Account"
        
        // configure the button so people can get out of here
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneBBITapped(_:)))
        
        // update the labels based on whether we're logged in
        self.updateUILabels()
        
        // Subscribe to changes in realm controller
        NotificationCenter.default.addObserver(self, selector: #selector(self.realmControllerChanged(_:)), name: NSNotification.Name("RealmControllerChanged"), object: .none)
    }
    
    @objc private func realmControllerChanged(_ notification: Notification?) {
        if let newController = notification?.userInfo?["NewRealmController"] as? RealmController {
            self.realmController = newController
        } else {
            self.realmController = nil
        }
    }
    
    @objc private func doneBBITapped(_ sender: NSObject?) {
        self.dismiss(animated: true, completion: .none)
    }

    private func updateUILabels() {
        if let _ = realmController {
            self.primaryTextLabel?.text = "You're logged in. ☺️"
            self.logoutButton?.setTitle("Logout", for: .normal)
            self.createButton?.setTitle("Create Account", for: .normal)
            self.loginButton?.setTitle("Login", for: .normal)
            self.logoutButton?.isEnabled = true
            self.createButton?.isEnabled = false
            self.loginButton?.isEnabled = false
        } else {
            self.primaryTextLabel?.text = "You need to login. 😱"
            self.logoutButton?.setTitle("Logout", for: .normal)
            self.createButton?.setTitle("Create Account", for: .normal)
            self.loginButton?.setTitle("Login", for: .normal)
            self.logoutButton?.isEnabled = false
            self.createButton?.isEnabled = true
            self.loginButton?.isEnabled = true
        }
    }
    
    private func newLoginVC(createAccount: Bool) -> UIViewController {
        let delegate = UIApplication.shared.delegate as? RealmControllable
        let tabVC = LoginiOSTableViewController(createAccount: createAccount, delegate: delegate)
        let navVC = UINavigationController(rootViewController: tabVC)
        navVC.modalPresentationStyle = .formSheet
        return navVC
    }
    
    @IBAction private func createButtonTapped(_ sender: NSObject?) {
        self.present(self.newLoginVC(createAccount: true), animated: true, completion: .none)
    }
    
    @IBAction private func loginButtonTapped(_ sender: NSObject?) {
        self.present(self.newLoginVC(createAccount: false), animated: true, completion: .none)
    }
    
    @IBAction private func logoutButtonTapped(_ sender: NSObject?) {
        self.realmController?.logOut()
        (UIApplication.shared.delegate as? RealmControllable)?.realmController = nil
    }

}
