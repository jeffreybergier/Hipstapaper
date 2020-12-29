//
//  Created by Jeffrey Bergier on 2020/12/29.
//
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of Hipstapaper.
//
//  Hipstapaper is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Hipstapaper is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Hipstapaper.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUI
import UIKit
import Combine
import Browse

class ApplicationDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     configurationForConnecting session: UISceneSession,
                     options: UIScene.ConnectionOptions)
                     -> UISceneConfiguration
    {
        guard
            let activity = options.userActivities.first,
            activity.activityType == "Browser"
        else { return .init() } // Happens on initial app launch
        return .init(name: "Browser", sessionRole: .windowApplication)
    }
    
    // TODO: Can Probably delete this
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
}

class BrowserWindowControllerDelegate: NSObject, UIWindowSceneDelegate {
    
    private var app: UIApplication { UIApplication.shared }
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        let scene = scene as! UIWindowScene
        let window = UIWindow(windowScene: scene)
        let url = connectionOptions.userActivities.first!.referrerURL!
        let browser = Browser(url: url) { [unowned self] in
            self.app.requestSceneSessionDestruction(session, options: nil)
            { error in
                print(error)
                print("")
            }
            
        }
        window.rootViewController = UIHostingController(rootView: browser)
        self.window = window
        window.makeKeyAndVisible()
    }

    // TODO: Can Probably delete this
    func sceneDidDisconnect(_ scene: UIScene) { }
}

class WindowManager: ObservableObject {
    
    private var app: UIApplication { UIApplication.shared }
    
    func show(_ url: URL) {
        let activity = NSUserActivity(activityType: "Browser")
        activity.referrerURL = url
        self.app.requestSceneSessionActivation(nil,
                                               userActivity: activity,
                                               options: nil)
        { error in
            print(error)
            print("")
        }
    }
}
