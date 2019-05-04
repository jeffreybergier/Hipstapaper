//
//  PreviewActionInjectionSafariViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/29/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import SafariServices
import UIKit

class WebBrowserViewController: SFSafariViewController, UIViewControllerRestoration {
    
    private static let kOriginalURLString = "kOriginalURLStringKey"
    
    class func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        guard
            let urlString = coder.decodeObject(forKey: self.kOriginalURLString) as? String,
            let url = URL(string: urlString)
        else { return nil }
        let vc = WebBrowserViewController(url: url, previewActions: nil)
        return vc
    }
    
    private var myPreviewActions = [UIPreviewActionItem]()
    override var previewActionItems: [UIPreviewActionItem] {
        return self.myPreviewActions
    }
    
    private var originalURL: URL?
    
    convenience init(url URL: URL, previewActions: [UIPreviewActionItem]?) {
        self.init(url: URL)
        self.originalURL = URL
        self.myPreviewActions = previewActions ?? []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restorationIdentifier = StateRestorationIdentifier.safariViewController.rawValue
        self.restorationClass = type(of: self)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(self.originalURL?.absoluteString, forKey: type(of: self).kOriginalURLString)
        super.encodeRestorableState(with: coder)
    }
    
}
