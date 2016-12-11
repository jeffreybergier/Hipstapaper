//
//  URLListWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/11/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import AppKit

class URLListWindowController: NSWindowController {
    
    enum SyncController {
        case realmOnly, cloudKitOnly, combined
        
        var windowTitle: String {
            switch self {
            case .realmOnly:
                return "Realm"
            case .cloudKitOnly:
                return "CloudKit"
            case .combined:
                return "Hipstapaper"
            }
        }
    }
    
    // MARK: Operation Spinner
    
    var operationsInProgress: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                if self.operationsInProgress > 0 {
                    self.spinner?.startAnimation(self)
                } else {
                    self.spinner?.stopAnimation(self)
                }
            }
        }
    }
    
    // MARK: Data Source
    
    private var syncController: SyncController = .combined
    private(set) lazy var dataSource: URLItemCRUDDoublePersistanceType = {
        switch self.syncController {
        case .combined:
            return URLItemPersistanceController()
        case .realmOnly:
            return URLItemRealmController()
        case .cloudKitOnly:
            return URLItemCloudKitController()
        }
    }()
    
    // MARK: Outlets

    @IBOutlet private weak var debugWindowToolbarImageView: NSImageView?
    @IBOutlet private weak var spinner: NSProgressIndicator? {
        didSet {
            self.spinner?.stopAnimation(self)
            self.spinner?.isDisplayedWhenStopped = false
        }
    }
    @IBOutlet private weak var urlListViewController: URLListViewController? {
        didSet {
            self.urlListViewController?.dataSource = self.dataSource
        }
    }
    
    //MARK: Initialization
    
    convenience init(syncController: SyncController = .combined) {
        self.init(windowNibName: "URLListWindowController")
        self.syncController = syncController
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.title = self.syncController.windowTitle
        self.window?.titleVisibility = .hidden
        switch self.syncController {
        case .cloudKitOnly, .realmOnly:
            self.window?.isExcludedFromWindowsMenu = false
            self.debugWindowToolbarImageView?.isHidden = false
        case .combined:
            self.window?.isExcludedFromWindowsMenu = true
            self.debugWindowToolbarImageView?.isHidden = true
        }
    }
    
    // MARK: Handle Toolbar Buttons
    
    @IBAction private func refreshButonClicked(_ sender: NSObject?) { // IB can send anything and swift won't check unless I do.
        self.operationsInProgress += 1
        self.dataSource.sync() { syncResult in
            self.urlListViewController?.windowSyncFinished(result: syncResult, sender: sender)
            self.operationsInProgress -= 1
        }
    }
}
