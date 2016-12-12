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
    
    // Delegate
    
    private weak var delegate: ViewControllerPresenterDelegate?
    
    // Model
    
    private(set) var item: URLItemType?
    
    // MARK: IBOutlets
    
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
    
    // Internal State for UI
    
    private var javascriptEnabled: Bool = false {
        didSet {
//            self.javascriptCheckbox?.isOn = self.javascriptEnabled
            self.webView.configuration.preferences.javaScriptEnabled = self.javascriptEnabled
            self.webView.reload()
        }
    }
    
    // KVO Helpers
    
    private lazy var webViewTitleObserver: KeyValueObserver<String> = KeyValueObserver<String>(target: self.webView)
    private lazy var vcTitleObserver: KeyValueObserver<String> = KeyValueObserver<String>(target: self)
    
    // MARK: Toolbar Items
    
    private lazy var archiveBar: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(self.archiveButtonTapped(_:)))
    private lazy var tagBar: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(self.tagButtonTapped(_:)))
    private lazy var jsBar: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.jsButtonTapped(_:)))
    private let flexibleSpaceBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: .none, action: .none)
    
    // Lifecycle
    
    convenience init(urlItem: URLItemType, delegate: ViewControllerPresenterDelegate) {
        self.init()
        self.item = urlItem
        self.delegate = delegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Loading…"
        self.takeControlOfNavigationController(true)
        
        self.vcTitleObserver.add(keyPath: #keyPath(UIViewController.title)) { newValue -> String? in
            return "♓️ " + newValue
        }
        
        self.webViewTitleObserver.add(keyPath: #keyPath(WKWebView.title)) { newValue -> String? in
            self.title = newValue
            return .none
        }
        
        // configure toolbar
        self.setToolbarItems([self.archiveBar, self.tagBar, self.flexibleSpaceBar, self.jsBar], animated: false)
        
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
        if take == false {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    // MARK: Actions from Bottom Toolbar
    
    @IBAction private func javascriptCheckboxToggled(_ sender: NSObject?) {
        guard let sender = sender as? UISwitch else { return }
        self.javascriptEnabled = sender.isOn
    }
    
    @objc private func archiveButtonTapped(_ sender: NSObject?) {
        
    }
    
    @objc private func tagButtonTapped(_ sender: NSObject?) {
        
    }
    
    @objc private func jsButtonTapped(_ sender: NSObject?) {
        self.javascriptEnabled = !self.javascriptEnabled
    }
    
    // Handle Going Away
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.takeControlOfNavigationController(false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.delegate?.presented(viewController: self, didDisappearAnimated: animated)
    }

}

extension WKWebView: KVOCapable {}
extension UIViewController: KVOCapable {}
