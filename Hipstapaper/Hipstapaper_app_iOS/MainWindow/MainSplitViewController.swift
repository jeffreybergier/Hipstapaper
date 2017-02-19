//
//  HipstapaperSplitViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/27/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Common
import UIKit

// 
//
// The purpose of this class is to host the TagListVC and URLListVC for a single user
// This class manhandles the splitview controller so it always shows the correct view controllers as the Master/Detail
// This class also handles the responsibilities for spreading RealmController changes when the user changes / signs out
//

class MainSplitViewController: UISplitViewController, RealmControllable {
    
    // MARK: Overriding Inits to configure oneself
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        // configure my delegate
        self.delegate = self
        // configure our view controllers for master / detail
        self.viewControllers = [self.sourceListNavigationController, self.contentListNavigationController]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // configure my delegate
        self.delegate = self
        // configure our view controllers for master / detail
        self.viewControllers = [self.sourceListNavigationController, self.contentListNavigationController]
    }
    
    // MARK: Master / Detail Navigation Controllers
    
    // The split view controller needs its master/detail panes to be contained
    // in Navigation Controllers. This is where we store the navigation controllers
    
    fileprivate lazy var sourceListNavigationController: UINavigationController = {
        let tagVC = SourceListViewController(selectionDelegate: self, controller: self.realmController)
        let navVC = UINavigationController(rootViewController: tagVC)
        
        // register for state restoration
        tagVC.restorationIdentifier = StateRestorationIdentifier.tagListViewController.rawValue
        navVC.restorationIdentifier = StateRestorationIdentifier.tagListNavVC.rawValue
        
        return navVC
    }()
    
    fileprivate lazy var contentListNavigationController: UINavigationController = {
        let urlVC = ContentListViewController(selectionDelegate: self, controller: self.realmController)
        let navVC = UINavigationController(rootViewController: urlVC)
        
        // register for state restoration
        urlVC.restorationIdentifier = StateRestorationIdentifier.urlListViewController.rawValue
        navVC.restorationIdentifier = StateRestorationIdentifier.urlListNavVC.rawValue
        
        return navVC
    }()
    
    // MARK: Master / Detail View Controllers
    
    // These instances are recycled rather than being re-created every time the selection changes.
    
    internal var sourceListViewController: SourceListViewController {
        return self.sourceListNavigationController.viewControllers.first as! SourceListViewController
    }
    
    internal var contentListViewController: ContentListViewController {
        return self.contentListNavigationController.viewControllers.first as! ContentListViewController
    }
    
    // MARK: Realm Controller
    
    // DidSet notifiers master and detail view controllers that the controller changed.
    
    var realmController = RealmController() {
        didSet {
            self.sourceListViewController.realmController = self.realmController
            self.contentListViewController.realmController = self.realmController
            ((self.presentedViewController as? UINavigationController)?.viewControllers.first as? RealmControllable)?.realmController = self.realmController
        }
    }
    
    // MARK: Initial Configuration
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register for state restoration
        self.restorationIdentifier = StateRestorationIdentifier.mainSplitViewController.rawValue

        // gives us the nice 2-up mode on ipads
        self.preferredDisplayMode = .allVisible
        
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
    fileprivate var viewDidAppearOnce = false
    
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
        let newVC = LoggedInViewController(delegate: self)
        let navVC = UINavigationController(rootViewController: newVC)
        navVC.modalPresentationStyle = .formSheet
        self.present(navVC, animated: animated, completion: .none)
    }
    
    // MARK: Handle State Restoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        // if the contentListView is not visible then that means only the source list is
        // so when we wake next time we want only the source list to be shown
        let wasSourceListOpen: Bool
        if let _ = self.contentListViewController.view.window {
            wasSourceListOpen = false
        } else {
            wasSourceListOpen = true
        }
        
        // we need to save this in NSUserDefaults, not in the coder
        // this is because the appropriate UISplitViewControllerDelegate method is called before
        // the state is decoded from the decoder.
        // This requires reading the setting off disk
        UserDefaults.standard.wasSourceListOpen = wasSourceListOpen
        
        // call super to continue saving state
        super.encodeRestorableState(with: coder)
    }
}

extension MainSplitViewController: URLItemsToLoadChangeDelegate {
    var itemsToLoad: URLItem.ItemsToLoad {
        return self.contentListViewController.itemsToLoad
    }
    var filter: URLItem.ArchiveFilter {
        return self.contentListViewController.filter
    }
    var sortOrder: URLItem.SortOrder {
        return self.contentListViewController.sortOrder
    }
    func didChange(itemsToLoad: URLItem.ItemsToLoad?, sortOrder: URLItem.SortOrder?, filter: URLItem.ArchiveFilter?, sender: ViewControllerSender) {
        switch sender {
        case .tertiaryVC:
            break
        case .contentVC:
            // let the source list know this. It needs to update its selected row
            self.sourceListViewController.didChange(itemsToLoad: itemsToLoad, sortOrder: sortOrder, filter: filter, sender: sender)
            // save the changes in NSUserDefaults
            UserDefaults.standard.userSelection = (itemsToLoad: itemsToLoad ?? self.itemsToLoad,
                                                      sortOrder: sortOrder ?? self.sortOrder,
                                                      filter: filter ?? self.filter)
        case .sourceListVC:
            // save the changes in NSUserDefaults
            UserDefaults.standard.userSelection = (itemsToLoad: itemsToLoad ?? self.itemsToLoad,
                                                      sortOrder: sortOrder ?? self.sortOrder,
                                                      filter: filter ?? self.filter)
            // at the end of any selection validation we need to do some logic
            defer {
                // if the splitVC is collapsed, that means, we need to manually tell
                // the splitVC to show the detail view controller
                // otherwise, the detailVC is already visible, so we don't need to do anything
                if self.isCollapsed == true {
                    self.showDetailViewController(self.contentListNavigationController, sender: sender)
                }
            }
            // if the new selection is different than the last one, forward it on
            // since the items can be nil, I only want to compare them if they are not nill
            // to accomplish that, if they're nil I set them to the same value that they're being compared with
            guard
                (itemsToLoad ?? self.itemsToLoad) != self.itemsToLoad ||
                (filter ?? self.filter) != self.filter ||
                (sortOrder ?? self.sortOrder) != self.sortOrder
            else { break }
            self.contentListViewController.didChange(itemsToLoad: itemsToLoad, sortOrder: sortOrder, filter: filter, sender: sender)
        }
    }
}

extension MainSplitViewController: UISplitViewControllerDelegate {
    
    // MARK: Manhandling the SplitView
    
    // these methods are called when panels open and close due to rotation
    // This primarily happens on the Plus sized iPhones
    
    // We basically just always return the SourceListVC for the master panel and the contentListVC for the detail panel
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        // this is a state restoration feature
        // but this delegate is called before state restoration happens
        // so if the view has never appeared once
        // we can assume the state restoration value can be used
        if self.viewDidAppearOnce == false {
            return UserDefaults.standard.wasSourceListOpen
        } else {
            // otherwise, just always return the desired value
            return false
        }
    }
    
    func primaryViewController(forCollapsing splitViewController: UISplitViewController) -> UIViewController? {
        return self.sourceListNavigationController
    }
    
    func primaryViewController(forExpanding splitViewController: UISplitViewController) -> UIViewController? {
        return self.sourceListNavigationController
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, separateSecondaryFrom primaryViewController: UIViewController) -> UIViewController? {
        return self.contentListNavigationController
    }
}
