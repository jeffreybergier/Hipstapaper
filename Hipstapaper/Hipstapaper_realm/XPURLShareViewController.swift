//
//  XPlatformURLSharingViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/24/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

enum UIState {
    case start, loggingIn, saving, saved, error
}

#if os(OSX)
    import AppKit
    typealias XPViewController = NSViewController
#else
    import UIKit
    typealias XPViewController = UIViewController
#endif
import RealmSwift

class XPURLShareViewController: XPViewController {
    
    var uiState = UIState.start
    
    #if os(OSX)
    override func viewDidAppear() {
        super.viewDidAppear()
        self.start()
    }
    #else
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.start()
    }
    #endif
    
    func start() {
        self.uiState = .loggingIn
        
        RealmConfig.configure() {
            self.uiState = .saving
            
            guard let extensionItem = self.extensionContext?.inputItems.first as? NSExtensionItem else {
                self.uiState = .error
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                    self.extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0, userInfo: nil))
                }
                return
            }
            
            URLItemExtras.extras(from: extensionItem) { tuple in
                guard let tuple = tuple else {
                    self.uiState = .error
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0, userInfo: nil))
                    }
                    return
                }
                
                DispatchQueue.global(qos: .userInitiated).async {
                    let realm = try! Realm()
                    realm.beginWrite()
                    let newURLItem = URLItem()
                    newURLItem.urlString = tuple.1
                    newURLItem.extras = tuple.0
                    realm.add(newURLItem)
                    try! realm.commitWrite()
                    self.uiState = .saved
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.7) {
                        self.extensionContext?.completeRequest(returningItems: .none, completionHandler: { _ in })
                    }
                    
                }
            }
        }
    }
}
