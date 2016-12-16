//
//  PresenterDelegateSafariViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/14/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import SafariServices

class PresenterDelegateSafariViewController: SFSafariViewController {
    
    weak var presenterDelegate: ViewControllerPresenterDelegate?
    
    convenience init(url: URL, entersReaderIfAvailable: Bool, presenterDelegate: ViewControllerPresenterDelegate) {
        self.init(url: url, entersReaderIfAvailable: entersReaderIfAvailable)
        self.delegate = self
        self.presenterDelegate = presenterDelegate
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.presenterDelegate?.presented(viewController: self, didDisappearAnimated: animated)
    }
    
}

extension PresenterDelegateSafariViewController: SFSafariViewControllerDelegate {
    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        return []
    }
}
