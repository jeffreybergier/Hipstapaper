//
//  URLItemWebViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/8/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import HipstapaperPersistence
import WebKit
import UIKit

class URLItemWebViewController: UIViewController {
    
    private var javascriptEnabled: Bool = false {
        didSet {
            self.javascriptCheckbox?.isOn = self.javascriptEnabled
            self.webView.configuration.preferences.javaScriptEnabled = self.javascriptEnabled
            self.webView.reload()
        }
    }
    
    // MARK: IBOutlets
    
    @IBOutlet private weak var javascriptCheckbox: UISwitch? {
        didSet {
            self.javascriptEnabled = self.webView.configuration.preferences.javaScriptEnabled
        }
    }
    
    @IBOutlet private weak var webViewParentView: UIView? {
        didSet {
            // WKWebView is not in IB so I have to add it manually
            self.webViewParentView?.addSubview(self.webView)
            self.webViewParentView?.leadingAnchor.constraint(equalTo: self.webView.leadingAnchor, constant: 0).isActive = true
            self.webViewParentView?.trailingAnchor.constraint(equalTo: self.webView.trailingAnchor, constant: 0).isActive = true
            self.webViewParentView?.topAnchor.constraint(equalTo: self.webView.topAnchor, constant: 0).isActive = true
            self.webViewParentView?.bottomAnchor.constraint(equalTo: self.webView.bottomAnchor, constant: 0).isActive = true
        }
    }
    
    @IBOutlet private weak var bottomToolbarView: UIView? {
        didSet {
            self.bottomToolbarView?.backgroundColor = UIColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1.0)
        }
    }
    
    private let webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        preferences.javaScriptEnabled = false
        let config = WKWebViewConfiguration()
        config.preferences = preferences
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    // Model
    
    private(set) var item: URLItemType?
    
    // Lifecycle
    
    convenience init(urlItem: URLItemType) {
        self.init()
        self.item = urlItem
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.takeControlOfNavigationController(true)
        
        // Get the URL loading - could probably use a bail out here if this unwrapping fails
        if let item = self.item, let url = URL(string: String(urlStringFromRawString: item.urlString)) {
            self.webView.load(URLRequest(url: url))
        } else {
            self.webView.load(URLRequest(url: URL(string: "https://github.com/404")!))
        }

    }
    
    private func takeControlOfNavigationController(_ take: Bool) {
        self.navigationController?.hidesBarsWhenVerticallyCompact = take
        self.navigationController?.hidesBarsOnSwipe = take
    }
    
    // MARK: Actions from Bottom Toolbar
    
    @IBAction private func javascriptCheckboxToggled(_ sender: NSObject?) {
        guard let sender = sender as? UISwitch else { return }
        self.javascriptEnabled = sender.isOn
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.takeControlOfNavigationController(false)
    }

}
