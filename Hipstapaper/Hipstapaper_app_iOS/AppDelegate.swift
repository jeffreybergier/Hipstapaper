//
//  AppDelegate.swift
//  Hipstapaper_app_iOS
//
//  Created by Jeffrey Bergier on 12/4/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Aspects
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, RealmControllable {

    var window: UIWindow?
    
    private let rootViewController = TagListViewController()
    
    fileprivate lazy var splitVCDidAppear: @convention(block) (Void) -> Void = { [weak self] in
        guard let mySelf = self else { return }
        if mySelf.realmController == nil {
            mySelf.rootViewController.presentAccountsVC(animated: true)
        }
    }
    
    var realmController = RealmController() {
        didSet {
            NotificationCenter.default.post(name: NSNotification.Name("RealmControllerChanged"), object: self, userInfo: ["NewRealmController": self.realmController as Any])
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if self.window == .none {
            self.window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        self.rootViewController.realmController = self.realmController
        let navVC = UINavigationController(rootViewController: self.rootViewController)
        let splitVC = UISplitViewController()
        splitVC.preferredDisplayMode = .allVisible
        splitVC.viewControllers = [navVC]
        splitVC.showDetailViewController(URLListViewController.viewController(with: .unarchived, and: self.realmController, preparedFor: splitVC), sender: self)
        let _ = try! splitVC.aspect_hook(#selector(UIViewController.viewDidAppear(_:)), with: .positionInstead, usingBlock: self.splitVCDidAppear)
        self.window!.rootViewController = splitVC
        self.window?.backgroundColor = .white
        self.window?.makeKeyAndVisible()
        
        self.processItemsSavedByExtension()
        
        return true
    }
    
    private func processItemsSavedByExtension() {
        DispatchQueue.global(qos: .background).async {
            guard let realmController = self.rootViewController.realmController else { return }
            guard let itemsOnDisk = NSKeyedUnarchiver.unarchiveObject(withFile: SerializableURLItem.archiveURL.path) as? [SerializableURLItem] else {
                // delete the file if it exists and has incorrect data, or else this could fail forever and never get fixed
                try? FileManager.default.removeItem(at: SerializableURLItem.archiveURL)
                return
            }
            DispatchQueue.main.async {
                for item in itemsOnDisk {
                    guard let urlString = item.urlString else { continue }
                    let newURLItem = URLItem()
                    newURLItem.urlString = urlString
                    newURLItem.creationDate = item.date ?? newURLItem.creationDate
                    newURLItem.modificationDate = item.date ?? newURLItem.modificationDate
                    let newExtras = URLItemExtras()
                    newExtras.image = item.image
                    newExtras.pageTitle = item.pageTitle
                    if newExtras.pageTitle != nil || newExtras.imageData != nil {
                        newURLItem.extras = newExtras
                    }
                    realmController.add(item: newURLItem)
                }
                try? FileManager.default.removeItem(at: SerializableURLItem.archiveURL)
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.processItemsSavedByExtension()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.processItemsSavedByExtension()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.processItemsSavedByExtension()
    }


}

