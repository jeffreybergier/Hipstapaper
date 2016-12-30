//
//  AppDelegate.swift
//  Hipstapaper_app_iOS
//
//  Created by Jeffrey Bergier on 12/4/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let extensionFileProcessor = SaveExtensionFileProcessor()
    private let rootViewController: HipstapaperSplitViewController = {
        let hpVC = HipstapaperSplitViewController()
        hpVC.delegate = hpVC
        return hpVC
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        if self.window == .none {
            self.window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        UIView.appearance().tintColor = UIColor(red: 0, green: 204/255.0, blue: 197/255.0, alpha: 1)

        self.window!.rootViewController = rootViewController
        self.window!.backgroundColor = .white
        self.window!.makeKeyAndVisible()
        
        self.extensionFileProcessor.processFiles(with: self.rootViewController.realmController)
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.extensionFileProcessor.processFiles(with: self.rootViewController.realmController)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.extensionFileProcessor.processFiles(with: self.rootViewController.realmController)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.extensionFileProcessor.processFiles(with: self.rootViewController.realmController)
    }


}

