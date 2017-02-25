//
//  HipstapaperWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import RealmSwift
import Common
import AppKit

class MainWindowController: NSWindowController, RealmControllable {
    
    @IBOutlet private(set) weak var searchField: NSSearchField? {
        didSet {
            self.contentListViewController.searchField = self.searchField
        }
    }
    @IBOutlet private weak var shareToolbarButton: NSButton? {
        didSet {
            // configure the share button to send its action on mousedown
            self.shareToolbarButton?.sendAction(on: .leftMouseDown)
        }
    }
    
    // MARK: References to child view controllers
    
    let contentListViewController = ContentListViewController()
    fileprivate let sourceListViewController = SourceListViewController()
    
    private lazy var appearanceSwitcher: AppleInterfaceStyleWindowAppearanceSwitcher = AppleInterfaceStyleWindowAppearanceSwitcher(window: self.window!)
    
    // MARK: Realm Controller Owner
    
    var realmController = RealmController() {
        didSet {
            self.sourceListViewController.realmController = self.realmController
            self.contentListViewController.realmController = self.realmController
        }
    }
    
    // MARK: KVO SourceList Collapsed
    
    private var sourceListCallapsedObserver: KeyValueObserver<Bool>?
    
    // MARK: Configure the window
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Get that OSX Yosemite 'look'
        self.window?.titleVisibility = .hidden
        let _ = self.appearanceSwitcher
        
        // configure the splitview within the window
        let splitViewController = NSSplitViewController()
        splitViewController.view.wantsLayer = true
        self.window!.contentView = splitViewController.view
        self.window!.contentViewController = splitViewController
        
        // configure the splitview
        let sourceListItem = NSSplitViewItem(sidebarWithViewController: self.sourceListViewController)
        sourceListItem.isCollapsed = !UserDefaults.standard.wasSourceListOpen
        let contentListItem = NSSplitViewItem(contentListWithViewController: self.contentListViewController)
        splitViewController.addSplitViewItem(sourceListItem)
        splitViewController.addSplitViewItem(contentListItem)
        
        // Register to save SourceListView Width when the SplitView is Resized
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).splitViewDidResizeSubviews(_:)),
            name: .NSSplitViewDidResizeSubviews,
            object: splitViewController.splitView
        )
        
        // KVO the sourceListItem Collapsed
        self.sourceListCallapsedObserver = KeyValueObserver(target: sourceListItem, keyPath: "collapsed") // #keyPath(NSSplitViewItem.isCollapsed)
        self.sourceListCallapsedObserver?.startObserving() { isCollapsed -> Bool? in
            UserDefaults.standard.wasSourceListOpen = !isCollapsed
            return .none
        }
        
        // Become the selection delegate for the sidebar
        // This lets us update the content view controller when the selection changes in the sidebar
        self.sourceListViewController.selectionDelegate = self
        
        // Become the selection delegate for the contentVC
        // This lets us update the sourceListVC when the user changes selection settings in the contentVC
        self.contentListViewController.selectionDelegate = self
        
        // check to see if the realm controller loaded
        // if it didn't load, then we're not logged in
        if let realmController = self.realmController {
            self.sourceListViewController.realmController = realmController
            self.contentListViewController.realmController = realmController
        }
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        // check to see if the realm controller loaded
        // if it didn't load, then we're not logged in
        // if we're not logged in, show an alert
        if self.realmController == nil {
            let loginAlert = NSAlert()
            loginAlert.messageText = "You need to login. 😱"
            loginAlert.informativeText = "Hipstapaper uses a Realm Mobile Platform server to synchronize your Reading list between all of your devices."
            loginAlert.addButton(withTitle: "Open Preferences")
            loginAlert.addButton(withTitle: "Dismiss")
            loginAlert.beginSheetModal(for: self.window!) { finished in
                if finished == 1000 { self.showPreferencesWindow(loginAlert) }
            }
        }
    }
    
    // MARK: Ownership of the preferences window
    
    private lazy var preferencesWindowController: PreferencesWindowController = {
        let wc = PreferencesWindowController()
        wc.delegate = self
        return wc
    }()
    
    @IBAction private func showPreferencesWindow(_ sender: NSObject?) {
        self.preferencesWindowController.showWindow(sender)
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.tag == 333 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: State Restoration
    
    enum StateRestorationConstants {
        static let kSearchString = "kSearchStringKey"
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        // save all the state
        coder.encode(self.searchField?.searchString, forKey: StateRestorationConstants.kSearchString)
        super.encodeRestorableState(with: coder)
    }
    
    override func restoreState(with coder: NSCoder) {
        // only restore the javascript state
        if let searchString = coder.decodeObject(forKey: StateRestorationConstants.kSearchString) as? String {
            // only reload the data if we got a valid search back
            // this is needed because this method is called too late and the data has already loaded
            self.searchField?.searchString = searchString
            self.contentListViewController.hardReloadData()
            
            // invalidate the state again, otherwise if launched over and over the state is lost
            self.invalidateRestorableState()
        }
        super.restoreState(with: coder)
    }
    
    // MARK: Handle Going Away
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .NSSplitViewDidResizeSubviews, object: .none)
    }
}

extension MainWindowController: URLItemsToLoadChangeDelegate {
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
            fatalError()
        case .contentVC:
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
            // if the new selection is different than the last one, forward it on
            // since the items can be nil, I only want to compare them if they are not nill
            // to accomplish that, if they're nil I set them to the same value that they're being compared with
            guard
                (itemsToLoad ?? self.itemsToLoad) != self.itemsToLoad ||
                (filter ?? self.filter) != self.filter ||
                (sortOrder ?? self.sortOrder) != self.sortOrder
            else { return }
            self.contentListViewController.didChange(itemsToLoad: itemsToLoad, sortOrder: sortOrder, filter: filter, sender: sender)
        }
    }
}

fileprivate extension MainWindowController /*: NSSplitViewDelegate */ {
    @objc fileprivate func splitViewDidResizeSubviews(_ notification: Notification) {
        UserDefaults.standard.sourceListWidth = self.sourceListViewController.view.frame.width
    }
}
