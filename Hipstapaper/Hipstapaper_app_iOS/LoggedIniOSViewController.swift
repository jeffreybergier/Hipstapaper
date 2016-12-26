//
//  LoggedInViewContrller.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/26/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

class LoggedIniOSViewController: UIViewController {
    
    private var realmController = RealmController() {
        didSet {
            self.updateUILabels()
            self.navigationController!.realmControllableChildren.forEach({ $0.realmController = self.realmController })
        }
    }
    
    @IBOutlet private weak var primaryButtonTextLabel: UILabel?
    @IBOutlet private weak var primaryButton: UIButton?
    @IBOutlet private weak var secondaryButton: UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Login"
        self.updateUILabels()

        self.primaryButtonTapped(.none)
    }
    
    private func updateUILabels() {
        if let _ = realmController {
            self.primaryButtonTextLabel?.text = "You're already logged in."
            self.primaryButton?.setTitle("Go to App", for: .normal)
            self.secondaryButton?.setTitle("Logout", for: .normal)
            self.secondaryButton?.isEnabled = true
        } else {
            self.primaryButtonTextLabel?.text = "You need to login."
            self.primaryButton?.setTitle("Start Login", for: .normal)
            self.secondaryButton?.setTitle("Logout", for: .normal)
            self.secondaryButton?.isEnabled = false
        }
    }
    
    @IBAction private func primaryButtonTapped(_ sender: NSObject?) {
        // if this method is called without user involvement, do not animate
        let animated = sender == .none ? false : true
        
        if let controller = realmController {
            let tagVC = TagListViewController(controller: controller)
            self.navigationController!.pushViewController(tagVC, animated: animated)
        } else {
            NSLog("Needs to log in")
        }
    }
    
    @IBAction private func secondaryButtonTapped(_ sender: NSObject?) {
    }

}

extension UINavigationController {
    var realmControllableChildren: [RealmControllable] {
        let realmControllable = self.viewControllers.map({ $0 as? RealmControllable }).flatMap({ $0 })
        return realmControllable
    }
}
