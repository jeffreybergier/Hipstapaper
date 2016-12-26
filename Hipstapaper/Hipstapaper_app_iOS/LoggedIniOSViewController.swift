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
            for item in self.navigationController?.stackedRealmControllables ?? [] {
                guard item !== self else { continue }
                item.realmController = self.realmController
            }
            self.presentedRealmControllables.forEach({ $0.realmController = self.realmController })
        }
    }
    
    @IBOutlet private weak var primaryButtonTextLabel: UILabel?
    @IBOutlet private weak var primaryButton: UIButton?
    @IBOutlet private weak var secondaryButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Account"
        
        self.updateUILabels()
        
        if let controller = self.realmController {
            self.presentApp(animated: false, controller: controller)
        } else {
            self.presentLogin(animated: false)
        }
    }
    
    private func updateUILabels() {
        if let _ = realmController {
            self.primaryButtonTextLabel?.text = "You're logged in. ☺️"
            self.primaryButton?.setTitle("Go to App", for: .normal)
            self.secondaryButton?.setTitle("Logout", for: .normal)
            self.secondaryButton?.isEnabled = true
        } else {
            self.primaryButtonTextLabel?.text = "You need to login. 😱"
            self.primaryButton?.setTitle("Start Login", for: .normal)
            self.secondaryButton?.setTitle("Logout", for: .normal)
            self.secondaryButton?.isEnabled = false
        }
    }
    
    private func presentApp(animated: Bool, controller: RealmController) {
        let tagVC = TagListViewController(controller: controller, immediatelyPresentNextVC: !animated)
        self.navigationController?.pushViewController(tagVC, animated: animated)
    }
    
    private func presentLogin(animated: Bool) {
        let tabVC = LoginiOSTableViewController.dualLoginTabBarController(delegate: self)
        self.present(tabVC, animated: animated, completion: .none)
    }
    
    @IBAction private func primaryButtonTapped(_ sender: NSObject?) {
        if let controller = self.realmController {
            self.presentApp(animated: true, controller: controller)
        } else {
            self.presentLogin(animated: true)
        }
    }
    
    @IBAction private func secondaryButtonTapped(_ sender: NSObject?) {
        self.realmController?.logOut()
        self.realmController = .none
    }

}

extension UINavigationController {
    var stackedRealmControllables: [RealmControllable] {
        let realmControllable = self.viewControllers.map({ $0 as? RealmControllable }).flatMap({ $0 })
        return realmControllable
    }
}

extension UIViewController {
    var presentedRealmControllables: [RealmControllable] {
        var realmControllable = [RealmControllable]()
        var presentedVC = self.presentedViewController
        while presentedVC != nil {
            if let vc = presentedVC as? RealmControllable {
                realmControllable.append(vc)
            } else if let nav = presentedVC as? UINavigationController {
                realmControllable += nav.stackedRealmControllables
            }
            presentedVC = presentedVC?.presentedViewController
        }
        return realmControllable
    }
}
