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
    
    private(set) var item: URLBindingItem?
        
    private let webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRect.zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    convenience init(urlItem: URLBindingItem) {
        self.init(windowNibName: "URLItemWebViewWindowController")
        self.item = urlItem
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.window?.contentView?.addSubview(self.webView)
        self.window?.contentView?.leadingAnchor.constraint(equalTo: self.webView.leadingAnchor, constant: 0).isActive = true
        self.window?.contentView?.trailingAnchor.constraint(equalTo: self.webView.trailingAnchor, constant: 0).isActive = true
        self.window?.contentView?.topAnchor.constraint(equalTo: self.webView.topAnchor, constant: 0).isActive = true
        self.window?.contentView?.bottomAnchor.constraint(equalTo: self.webView.bottomAnchor, constant: 0).isActive = true
        
        if let item = self.item, let url = URL(string: item.urlString) {
            self.window?.title = item.urlString
            self.webView.load(URLRequest(url: url))
        }
        
    }
}
