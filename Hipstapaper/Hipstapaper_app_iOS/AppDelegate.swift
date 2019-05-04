//
//  AppDelegate.swift
//  Hipstapaper_app_iOS
//
//  Created by Jeffrey Bergier on 12/4/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Common
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private let extensionFileProcessor = SaveExtensionFileProcessor()
    private let rootViewController = MainSplitViewController()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalNever)
//        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        if self.window == nil {
            self.window = UIWindow(frame: UIScreen.main.bounds)
        }
        
        UIView.appearance().tintColor = Color.tintColor
        
        self.window?.rootViewController = rootViewController
        self.window?.backgroundColor = .white
        self.window!.makeKeyAndVisible()
        
        if UIApplication.shared.applicationState != .background {
            self.extensionFileProcessor.processFiles(with: self.rootViewController.realmController)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        guard let id = identifierComponents.last, let identifier = StateRestorationIdentifier(rawValue: id) else { return nil }
        switch identifier {
        case .mainSplitViewController:
            return self.rootViewController
        case .tagListViewController:
            return self.rootViewController.sourceListViewController
        case .urlListViewController:
            return self.rootViewController.contentListViewController
        case .tagListNavVC, .urlListNavVC:
            // state restoration added to these, just so it gets added to their children
            return nil
        case .tertiaryPopOverViewController, .tertiaryPopOverNavVC, .searchController:
            // state restoration added to these just so the screenshot gets taken.
            // I don't actually want to restore state
            return nil
        case .safariViewController:
            fatalError() // should never be called. SafariViewController handles its own restoration
        }
    }
    
//    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        NSLog("BACKGROUNDFETCHOPEN")
//        self.extensionFileProcessor.processFiles(with: self.rootViewController.realmController) { success in
//            completionHandler(UIBackgroundFetchResult(rawValue: success.rawValue) ?? .failed)
//        }
//    }

}
