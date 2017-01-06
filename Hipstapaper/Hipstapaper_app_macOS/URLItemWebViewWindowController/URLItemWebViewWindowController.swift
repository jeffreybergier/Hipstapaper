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
    
    private(set) var itemID: URLItem.UIIdentifier?
    private weak var delegate: RealmControllable?
    
    // MARK: Control Outlets
    
    @IBOutlet private weak var shareToolbarButton: NSButton? {
        didSet {
            self.shareToolbarButton?.sendAction(on: .leftMouseDown)
        }
    }
    
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
    
    convenience init(itemID: URLItem.UIIdentifier, delegate: RealmControllable?) {
        self.init(windowNibName: "URLItemWebViewWindowController")
        self.itemID = itemID
        self.delegate = delegate
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // make the titlebar skinny and sexy
        self.window?.titleVisibility = .hidden
        
        // hack to force the toolbar to lay itself out
        let existingToolBar = self.window?.toolbar
        self.window?.toolbar = existingToolBar
        
        // Get the URL loading - could probably use a bail out here if this unwrapping fails
        if let itemID = self.itemID, let url = URL(string: itemID.urlString) {
            self.window?.title = "Hipstapaper: " + itemID.urlString
            self.webView.load(URLRequest(url: url))
        } else {
            self.webView.load(URLRequest(url: URL(string: "https://github.com/404")!))
        }
        
    }
    
    // MARK: Handle Toolbar Items
    
    @objc private func archive(_ sender: NSObject?) {
        guard
            let realmController = self.delegate?.realmController,
            let itemID = self.itemID,
            let item = realmController.urlItem(withUUIDString: itemID.uuid)
        else { return }
        realmController.updateArchived(to: true, on: [item])
        self.window?.close()
    }
    
    @objc private func unarchive(_ sender: NSObject?) {
        guard
            let realmController = self.delegate?.realmController,
            let itemID = self.itemID,
            let item = realmController.urlItem(withUUIDString: itemID.uuid)
        else { return }
        realmController.updateArchived(to: false, on: [item])
        self.window?.close()
    }
    
    @objc private func share(_ sender: NSObject?) {
        guard
            let button = sender as? NSButton,
            let item = self.itemID,
            let url = URL(string: item.urlString)
        else { return }
        NSSharingServicePicker(items: [url]).show(relativeTo: .zero, of: button, preferredEdge: .minY)
    }
    
    override func validateToolbarItem(_ sender: NSObject?) -> Bool {
        guard
            let toolbarItem = sender as? NSToolbarItem,
            let kind = NSToolbarItem.Kind(rawValue: toolbarItem.tag),
            let _ = self.delegate?.realmController,
            let itemID = self.itemID
        else { return false }
        switch kind {
        case .unarchive:
            return itemID.archived
        case .archive:
            return !itemID.archived
        case .tag:
            return false
        case .share:
            return true
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
    
    @objc fileprivate func shareMenu(_ sender: NSObject?) {
        guard
            let item = self.itemID,
            let url = URL(string: item.urlString)
        else { return }
        ((sender as? NSMenuItem)?.representedObject as? NSSharingService)?.perform(withItems: [url])
        (sender as? NSMenuItem)?.representedObject = .none
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        guard let itemID = self.itemID, let kind = NSMenuItem.Kind(rawValue: menuItem.tag), let _ = self.delegate?.realmController else { return false }
        switch kind {
        case .javascript:
            let value = NSNumber(value: self.webView.configuration.preferences.javaScriptEnabled)
            menuItem.state = value.intValue
            return true
        case .archive:
            return !itemID.archived
        case .unarchive:
            return itemID.archived
        case .share:
            guard let itemURL = URL(string: itemID.urlString) else { return false }
            menuItem.submenu = NSMenu(shareMenuWithItems: [itemURL])
            return true
        case .shareSubmenu:
            return true
        case .copy, .open, .delete:
            return false
        }
    }
    
    
}
