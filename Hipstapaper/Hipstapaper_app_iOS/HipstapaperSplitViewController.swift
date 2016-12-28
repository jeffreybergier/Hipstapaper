//
//  HipstapaperSplitViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/27/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Aspects
import UIKit

class HipstapaperSplitViewController: UISplitViewController, RealmControllable {
    
    var realmController = RealmController() {
        didSet {
            self.sourceListVC.realmController = self.realmController
            self.contentListVC.realmController = self.realmController
        }
    }
    
    fileprivate lazy var sourceListNavVC: UINavigationController = {
        let tagVC = TagListViewController(selectionDelegate: self, controller: self.realmController)
        let navVC = UINavigationController(rootViewController: tagVC)
        return navVC
    }()
    
    fileprivate var sourceListVC: TagListViewController {
        return self.sourceListNavVC.viewControllers.first as! TagListViewController
    }
    
    fileprivate lazy var contentListNavVC: UINavigationController = {
        let urlVC = URLListViewController(selection: .unarchived, controller: self.realmController)
        let _ = try! urlVC.aspect_hook(#selector(urlVC.viewDidDisappear(_:)), with: .positionInstead, usingBlock: self.sourceListVC.presentedViewControllerDidDisappear)
        let navVC = UINavigationController(rootViewController: urlVC)
        return navVC
    }()
    
    fileprivate var contentListVC: URLListViewController {
        return self.contentListNavVC.viewControllers.first as! URLListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredDisplayMode = .allVisible
        self.viewControllers = [self.sourceListNavVC, self.contentListNavVC]
//        Timer.scheduledTimer(timeInterval: 10, target: self, selector: "timerFired:", userInfo: nil, repeats: false)
    }
    
    @objc func timerFired(_ timer: Timer?) {
        self.realmController = nil
    }
    
    private var viewDidAppearOnce = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.viewDidAppearOnce == false {
            if self.realmController == nil {
                self.presentAccountsVC(animated: true)
            }
        }
        self.viewDidAppearOnce = true
    }
    
    // Activated by Bar Button Item in tag list
    @objc func accountsBBITapped(_ sender: NSObject?) {
        self.presentAccountsVC(animated: true)
    }

    private func presentAccountsVC(animated: Bool) {
        let newVC = LoggedIniOSViewController(controllerNotifier: self)
        let navVC = UINavigationController(rootViewController: newVC)
        navVC.modalPresentationStyle = .formSheet
        self.present(navVC, animated: animated, completion: .none)
    }
}

extension HipstapaperSplitViewController: URLItemSelectionDelegate {
    
    var currentSelection: URLItem.Selection? {
        if self.isCollapsed == false {
            return self.contentListVC.selection
        } else {
            return nil
        }
    }
    
    func didSelect(_ newSelection: URLItem.Selection, from sender: NSObject?) {
        self.contentListVC.selection = newSelection
        if self.isCollapsed == true {
            self.showDetailViewController(self.contentListNavVC, sender: sender)
        }
    }
}

extension HipstapaperSplitViewController: UISplitViewControllerDelegate {
    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        return self.sourceListNavVC
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return false
    }
    
    func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        return self.sourceListNavVC
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        return self.contentListNavVC
    }
}
