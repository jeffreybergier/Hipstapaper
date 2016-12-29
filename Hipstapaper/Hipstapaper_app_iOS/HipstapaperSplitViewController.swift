//
//  HipstapaperSplitViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/27/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

// 
//
// The purpose of this class is to host the TagListVC and URLListVC for a single user
// This class manhandles the splitview controller so it always shows the correct view controllers as the Master/Detail
// This class also handles the responsibilities for spreading RealmController changes when the user changes / signs out
//

class HipstapaperSplitViewController: UISplitViewController, RealmControllable {
    
    // MARK: Master / Detail Navigation Controllers
    
    // The split view controller needs its master/detail panes to be contained
    // in Navigation Controllers. This is where we store the navigation controllers
    
    fileprivate lazy var sourceListNavVC: UINavigationController = {
        let tagVC = TagListViewController(selectionDelegate: self, controller: self.realmController)
        let navVC = UINavigationController(rootViewController: tagVC)
        return navVC
    }()
    
    fileprivate lazy var contentListNavVC: UINavigationController = {
        let urlVC = URLListViewController(selection: .unarchived, controller: self.realmController)
        let navVC = UINavigationController(rootViewController: urlVC)
        return navVC
    }()
    
    // MARK: Master / Detail View Controllers
    
    // These instances are recycled rather than being re-created every time the selection changes.
    
    fileprivate var sourceListVC: TagListViewController {
        return self.sourceListNavVC.viewControllers.first as! TagListViewController
    }
    
    fileprivate var contentListVC: URLListViewController {
        return self.contentListNavVC.viewControllers.first as! URLListViewController
    }
    
    // MARK: Realm Controller
    
    // DidSet notifiers master and detail view controllers that the controller changed.
    
    var realmController = RealmController() {
        didSet {
            self.sourceListVC.realmController = self.realmController
            self.contentListVC.realmController = self.realmController
            ((self.presentedViewController as? UINavigationController)?.viewControllers.first as? RealmControllable)?.realmController = self.realmController
        }
    }
    
    // MARK: Initial Configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // gives us the nice 2-up mode on ipads
        self.preferredDisplayMode = .allVisible
        
        // configure our view controllers for master / detail
        self.viewControllers = [self.sourceListNavVC, self.contentListNavVC]
        
        // Delete Later: Timer that tests whether clearing the realm controller propogates through all the view controllers
        // Timer.scheduledTimer(timeInterval: 10, target: self, selector: "timerFired:", userInfo: nil, repeats: false)
    }
    
    // MARK: Delete Later: Timer that tests whether clearing the realm controller propogates through all the view controllers
    
    @objc func timerFired(_ timer: Timer?) {
        self.realmController = nil
    }
    
    // MARK: Handle User Sign Up
    
    // Only try on the first time we show up
    // Doing this work in ViewDidLoad led to errors
    // The view controller was not yet in the view hierarchy
    private var viewDidAppearOnce = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.viewDidAppearOnce == false {
            
            // check to see if the realm controller could not be initialized
            // this happens when there is no signed in user
            if self.realmController == nil {
                
                // if thats the case, present the login screen
                self.presentAccountsVC(animated: true)
            }
        }
        
        // make sure we updated our state
        self.viewDidAppearOnce = true
    }
    
    // MARK: Responder Chain Bar Button Items
    
    // The accounts button in the TagListVC puts this method down the responder chain
    // here we can respond and open the accounts VC
    
    @objc func accountsBBITapped(_ sender: NSObject?) {
        self.presentAccountsVC(animated: true)
    }

    private func presentAccountsVC(animated: Bool) {
        let newVC = LoggedIniOSViewController(delegate: self)
        let navVC = UINavigationController(rootViewController: newVC)
        navVC.modalPresentationStyle = .formSheet
        self.present(navVC, animated: animated, completion: .none)
    }
}

extension HipstapaperSplitViewController: URLItemSelectionDelegate {
    
    // MARK: Selection Delegate
    
    // The tag list VC also occasionally needs to know the current selection
    // So we allow that information to be queried
    
    var currentSelection: URLItem.Selection? {
        return self.contentListVC.selection
    }
    
    // When the TagListVC chooses an item, it calls this method on its delegate (me)
    // Then my job is to propogate that selection to the URLListViewController
    // Remember, we're recycling the view controllers so we are not creating new ones every time
    // Just changing the selection and letting the URLList view controller do its own thing
    
    func didSelect(_ newSelection: URLItem.Selection, from sender: NSObject?) {
        // at the end of any selection validation we need to do some logic
        defer {
            // if the splitVC is collapsed, that means, we need to manually tell
            // the splitVC to show the detail view controller
            // otherwise, the detailVC is already visible, so we don't need to do anything
            if self.isCollapsed == true {
                self.showDetailViewController(self.contentListNavVC, sender: sender)
            }
        }
        // if the new selection is different than the last one, forward it on
        guard newSelection != self.currentSelection else { return }
        // this part is obvious
        self.contentListVC.selection = newSelection
    }
}

extension HipstapaperSplitViewController: UISplitViewControllerDelegate {
    
    // MARK: Manhandling the SplitView
    
    // these methods are called when panels open and close due to rotation
    // This primarily happens on the Plus sized iPhones
    
    // We basically just always return the SourceListVC for the master panel and the contentListVC for the detail panel
    
    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        return self.sourceListNavVC
    }
    
    func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        return self.sourceListNavVC
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        return self.contentListNavVC
    }
}
