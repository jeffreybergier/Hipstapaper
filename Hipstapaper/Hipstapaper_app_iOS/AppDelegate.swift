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
    private let rootViewController = HipstapaperSplitViewController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalNever)
//        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        if self.window == .none {
            self.window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        UIView.appearance().tintColor = UIColor(red: 0, green: 204/255.0, blue: 197/255.0, alpha: 1)

        self.window!.rootViewController = rootViewController
        self.window!.backgroundColor = .white
        self.window!.makeKeyAndVisible()
        
        if UIApplication.shared.applicationState != .background {
            self.extensionFileProcessor.processFiles(with: self.rootViewController.realmController)
        }
                
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
    
//    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        NSLog("BACKGROUNDFETCHOPEN")
//        self.extensionFileProcessor.processFiles(with: self.rootViewController.realmController) { success in
//            completionHandler(UIBackgroundFetchResult(rawValue: success.rawValue) ?? .failed)
//        }
//    }


}

