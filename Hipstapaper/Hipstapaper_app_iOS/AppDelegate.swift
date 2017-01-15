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
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        NSLog("Saving: AppDelegate")
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        NSLog("Restoring: AppDelegate")
        return true
    }
    
    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
        print("uAppDelegate: VCforID: \(identifierComponents.last!)")
        guard let id = identifierComponents.last as? String, let identifier = StateRestorationIdentifier(rawValue: id) else { return .none }
        print("cAppDelegate: VCforID: \(identifier.rawValue)")
        switch identifier {
        case .hipstapaperSplitViewController:
            return self.rootViewController
        case .tagListViewController:
            return self.rootViewController.sourceListVC
        case .urlListViewController:
            return self.rootViewController.contentListVC
        case .tagListNavVC:
            return nil
        case .urlListNavVC:
            return nil
        }
    }
    
//    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        NSLog("BACKGROUNDFETCHOPEN")
//        self.extensionFileProcessor.processFiles(with: self.rootViewController.realmController) { success in
//            completionHandler(UIBackgroundFetchResult(rawValue: success.rawValue) ?? .failed)
//        }
//    }


}

