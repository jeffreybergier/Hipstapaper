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
        
        // OMG kill me autolayout
        // why is WKWebView not in Interface Builder?!?!
        self.window?.contentView?.addSubview(self.webView)
        self.window?.contentView?.leadingAnchor.constraint(equalTo: self.webView.leadingAnchor, constant: 0).isActive = true
        self.window?.contentView?.trailingAnchor.constraint(equalTo: self.webView.trailingAnchor, constant: 0).isActive = true
        self.window?.contentView?.topAnchor.constraint(equalTo: self.webView.topAnchor, constant: 0).isActive = true
        self.window?.contentView?.bottomAnchor.constraint(equalTo: self.webView.bottomAnchor, constant: 0).isActive = true
        
        // KVO so I can always put my app name in the title when it changes
        self.window?.addObserver(self, forKeyPath: #keyPath(NSWindow.title), options: [.new, .old], context: .none)
        
        // Get the URL loading
        // could probably use a bail out here if this unwrapping fails
        if let item = self.item, let url = URL(string: String(urlStringFromRawString: item.urlString)) {
            self.window?.title = item.urlString
            self.webView.load(URLRequest(url: url))
        }
        
    }
    
    // this property prevents KVO infinite loop
    // I want to observe the title on the window and add my own string in front of it
    // however that requires setting the title property again
    // which triggers kvo again
    private var lastWindowTitle = ""
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // Window Title KVO if let statement
        if
            let window = object as? NSWindow, // make sure the object is a window
            window === self.window, // make sure its my window
            keyPath == #keyPath(NSWindow.title), // make sure the keyPath is title
            let newValue = change?[.newKey] as? String, // make sure the new value is a string
            self.lastWindowTitle != newValue // make sure the newValue is not what was previously set: this stops infinite loop
        {
            self.lastWindowTitle = "Hipstapaper: " + newValue
            window.title = self.lastWindowTitle
        }
    }
    
    deinit {
        // unregister KVO to prevent crash
        self.window!.removeObserver(self, forKeyPath: #keyPath(NSWindow.title))
    }
}
