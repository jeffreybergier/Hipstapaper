//
//  LoggedInViewContrller.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Common
import UIKit

class LoggedInViewController: UIViewController, RealmControllable {
    
    var realmController: RealmController? {
        didSet {
            self.updateUILabels()
        }
    }
    
    fileprivate weak var delegate: RealmControllable?
    
    @IBOutlet private weak var primaryTextLabel: UILabel?
    @IBOutlet private weak var localButton: UIButton?
    @IBOutlet private weak var loginButton: UIButton?
    @IBOutlet private weak var createButton: UIButton?
    @IBOutlet private weak var logoutButton: UIButton?
    
    convenience init(delegate: RealmControllable) {
        self.init()
        self.realmController = delegate.realmController
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure my title
        self.title = "Account"
        
        // configure the button so people can get out of here
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneBBITapped(_:)))
        
        // update the labels based on whether we're logged in
        self.updateUILabels()
    }
    
    @objc private func doneBBITapped(_ sender: NSObject?) {
        self.dismiss(animated: true, completion: nil)
    }

    private func updateUILabels() {
        if self.realmController != nil {
            self.primaryTextLabel?.text = "You're All Set"
            self.logoutButton?.setTitle("Logout", for: .normal)
            self.createButton?.setTitle("Create Account", for: .normal)
            self.loginButton?.setTitle("Login", for: .normal)
            self.localButton?.setTitle("Local (No Sync)", for: .normal)
            self.localButton?.isEnabled = false
            self.logoutButton?.isEnabled = true
            self.createButton?.isEnabled = false
            self.loginButton?.isEnabled = false
        } else {
            self.primaryTextLabel?.text = "Choose a Sync Option"
            self.logoutButton?.setTitle("Logout", for: .normal)
            self.createButton?.setTitle("Create Account", for: .normal)
            self.loginButton?.setTitle("Login", for: .normal)
            self.localButton?.setTitle("Local (No Sync)", for: .normal)
            self.localButton?.isEnabled = true
            self.logoutButton?.isEnabled = false
            self.createButton?.isEnabled = true
            self.loginButton?.isEnabled = true
        }
    }
    
    private func newLoginVC(createAccount: Bool) -> UIViewController {
        let tabVC = LoginViewController(createAccount: createAccount, delegate: self.delegate)
        let navVC = UINavigationController(rootViewController: tabVC)
        navVC.modalPresentationStyle = .formSheet
        return navVC
    }
    
    @IBAction private func localButtonTapped(_ sender: Any) {
        let realmController = RealmController(kind: .local)
        self.delegate?.realmController = realmController
        self.realmController = realmController
    }
    
    @IBAction private func createButtonTapped(_ sender: NSObject?) {
        self.present(self.newLoginVC(createAccount: true), animated: true, completion: nil)
    }
    
    @IBAction private func loginButtonTapped(_ sender: NSObject?) {
        self.present(self.newLoginVC(createAccount: false), animated: true, completion: nil)
    }
    
    @IBAction private func logoutButtonTapped(_ sender: NSObject?) {
        self.realmController?.logOut()
        self.delegate?.realmController = nil
    }

}
