//
//  URLItemWebViewWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import WebKit
import AppKit

class URLItemWebViewWindowController: NSWindowController {
    
    // MARK: Model Item
    
    private(set) var item: URLBindingItem?
    
    // MARK: KVO Helper Objects
    private let webViewTitleObserver = KeyValueObserver<String>()
    
    // MARK: WebView Objects
//    private let webViewNavigationDelegate = WebViewNavigationDelegate()
//    private let webViewUIDelegate = WebViewUIDelegate()
    
    @objc private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    // MARK: Initialization
    
    convenience init(urlItem: URLBindingItem) {
        self.init(windowNibName: "URLItemWebViewWindowController")
        self.item = urlItem
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // configure KVO to prefix the window title
        self.webViewTitleObserver.add(target: self.window, forKeyPath: #keyPath(NSWindow.title)) { newValue -> String? in
            return "Hipstapaper: \(newValue)"
        }
        // configure KVO to listen for title changes on the webview
        self.webViewTitleObserver.add(target: self.webView, forKeyPath: #keyPath(WKWebView.title)) { [weak self] newValue -> String? in
            self?.window?.title = newValue
            return .none
        }
        
        // OMG kill me autolayout
        // why is WKWebView not in Interface Builder?!?!
        self.window?.contentView?.addSubview(self.webView)
        self.window?.contentView?.leadingAnchor.constraint(equalTo: self.webView.leadingAnchor, constant: 0).isActive = true
        self.window?.contentView?.trailingAnchor.constraint(equalTo: self.webView.trailingAnchor, constant: 0).isActive = true
        self.window?.contentView?.topAnchor.constraint(equalTo: self.webView.topAnchor, constant: 0).isActive = true
        self.window?.contentView?.bottomAnchor.constraint(equalTo: self.webView.bottomAnchor, constant: 0).isActive = true
        
//        // configure webview delegates
//        self.webView.navigationDelegate = self.webViewNavigationDelegate
//        self.webView.uiDelegate = self.webViewUIDelegate
        
        // Get the URL loading
        // could probably use a bail out here if this unwrapping fails
        if let item = self.item, let url = URL(string: String(urlStringFromRawString: item.urlString)) {
            self.window?.title = item.urlString
            let _ = self.webView.load(URLRequest(url: url))
        }
    }
}
