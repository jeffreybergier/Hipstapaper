//
//  URLItemWebViewWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import WebKit
import AppKit

class WebViewTitleTransformer: ValueTransformer {
    override func transformedValue(_ value: Any?) -> Any? {
        if let value = value as? String {
            return "Hipstapaper: " + value
        } else {
            return super.transformedValue(value)
        }
    }
}

class URLItemWebViewWindowController: NSWindowController {
    
    // Create and register a value transformer for URLWebWindow title Bindings
    private static let titleValueTransformer: Void = {
        let transformer = WebViewTitleTransformer()
        let name = NSValueTransformerName("WebViewTitleTransformer")
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }()
    
    // MARK: Model Item
    
    private(set) var item: URLItem.Value?
    
    // MARK: Control Outlets
    
    private var javascriptEnabled: Bool = false {
        didSet {
            let newValueNumber = NSNumber(value: self.javascriptEnabled)
            self.javascriptCheckbox?.state = newValueNumber.intValue
            self.webView.configuration.preferences.javaScriptEnabled = self.javascriptEnabled
            self.webView.reload()
        }
    }
    
    @IBOutlet private weak var javascriptCheckbox: NSButton? {
        didSet {
            self.javascriptEnabled = self.webView.configuration.preferences.javaScriptEnabled
        }
    }
    
    // MARK: NSView Outlets
    
    @IBOutlet private weak var webViewParentView: NSView? {
        didSet {
            // WKWebView is not in IB so I have to add it manually
            self.webViewParentView?.addSubview(self.webView)
            self.webViewParentView?.leadingAnchor.constraint(equalTo: self.webView.leadingAnchor, constant: 0).isActive = true
            self.webViewParentView?.trailingAnchor.constraint(equalTo: self.webView.trailingAnchor, constant: 0).isActive = true
            self.webViewParentView?.topAnchor.constraint(equalTo: self.webView.topAnchor, constant: 0).isActive = true
            self.webViewParentView?.bottomAnchor.constraint(equalTo: self.webView.bottomAnchor, constant: 0).isActive = true
        }
    }
    
    @IBOutlet private weak var bottomToolbarView: NSView? {
        didSet {
            self.bottomToolbarView?.layer?.backgroundColor = NSColor(hue: 0, saturation: 0, brightness: 0.9, alpha: 1.0).cgColor
        }
    }
    
    @objc private let webView: WKWebView = {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = false
        preferences.plugInsEnabled = false
        preferences.javaScriptEnabled = false
        let config = WKWebViewConfiguration()
        config.preferences = preferences
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    // MARK: Initialization
    
    convenience init(urlItem: URLItem.Value) {
        URLItemWebViewWindowController.titleValueTransformer // activate the value transformer once
        self.init(windowNibName: "URLItemWebViewWindowController")
        self.item = urlItem
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Get the URL loading - could probably use a bail out here if this unwrapping fails
        if let item = self.item, let url = URL(string: String(urlStringFromRawString: item.urlString)) {
            self.window?.title = "Hipstapaper: " + item.urlString
            self.webView.load(URLRequest(url: url))
        }
    }
    
    // MARK: Actions from Bottom Toolbar
    
    @IBAction private func javascriptCheckboxToggled(_ sender: NSObject?) {
        guard let sender = sender as? NSButton else { return }
        let newValue = NSNumber(value: sender.state).boolValue
        self.javascriptEnabled = newValue
    }
    
    // MARK: Handle Menu Items
    
    @IBAction func javascriptMenuToggled(_ sender: NSObject?) {
        guard let sender = sender as? NSMenuItem else { return }
        print(sender.title)
        print(sender.state)
        let newValue = NSNumber(value: sender.state).boolValue
        self.javascriptEnabled = !newValue
    }
    
    override func validateMenuItem(_ sender: NSObject?) -> Bool {
        guard let sender = sender as? NSMenuItem, sender.title == "Enable Javascript" else { fatalError() }
        let value = NSNumber(value: self.webView.configuration.preferences.javaScriptEnabled)
        sender.state = value.intValue
        return true
    }
    
    
}
