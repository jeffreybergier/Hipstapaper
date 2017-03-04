//
//  URLItemWebViewWindowController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/16/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Common
import WebKit
import AppKit

class WebBrowserWindowController: NSWindowController {
    
    // MARK: Appearance
    
    private lazy var appearanceSwitcher: AppleInterfaceStyleWindowAppearanceSwitcher = AppleInterfaceStyleWindowAppearanceSwitcher(window: self.window!)
    
    // MARK: Model Item
    
    private(set) var itemID: URLItem.UIIdentifier?
    weak var delegate: RealmControllable?
    
    // MARK: Control Outlets
    
    @IBOutlet private weak var shareToolbarButton: NSButton? {
        didSet {
            self.shareToolbarButton?.sendAction(on: .leftMouseDown)
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
    
    // owning a strong reference to the webview and its delegate does not create a retain cycle
    // swiftlint:disable:next weak_delegate
    private let webViewDelegate = WebBrowserDelegate()
    
    // MARK: Initialization
    
    convenience init(itemID: URLItem.UIIdentifier?) {
        self.init(windowNibName: "WebBrowserWindowController")
        self.itemID = itemID
        self.invalidateRestorableState()
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // make the titlebar skinny and sexy
        self.window?.titleVisibility = .hidden
        let _ = self.appearanceSwitcher
        
        // hack to force the toolbar to lay itself out
        let existingToolBar = self.window?.toolbar
        self.window?.toolbar = existingToolBar
        
        // Get the URL loading - could probably use a bail out here if this unwrapping fails
        if let itemID = self.itemID, let url = URL(string: itemID.urlString) {
            self.window?.title = "Hipstapaper: " + itemID.urlString
            self.webView.uiDelegate = self.webViewDelegate
            self.webView.navigationDelegate = self.webViewDelegate
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
            let item = realmController.url_existingItem(itemID: itemID)
        else { return }
        realmController.url_setArchived(to: true, on: [item])
        self.window?.close()
    }
    
    @objc private func unarchive(_ sender: NSObject?) {
        guard
            let realmController = self.delegate?.realmController,
            let itemID = self.itemID,
            let item = realmController.url_existingItem(itemID: itemID)
        else { return }
        realmController.url_setArchived(to: false, on: [item])
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
    
    @objc private func toggleJS(_ sender: NSObject?) {
        let oldValue = self.webView.configuration.preferences.javaScriptEnabled
        self.webView.configuration.preferences.javaScriptEnabled = !oldValue
        self.webView.reload()
        self.invalidateRestorableState()
    }
    
    @objc private func openInBrowser(_ sender: NSObject?) {
        guard let urlString = self.itemID?.urlString, let url = URL(string: urlString) else { return }
        NSWorkspace.shared().open(url)
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
        case .jsToggle:
            guard let button = toolbarItem.view as? NSButton else { return false }
            button.state = self.webView.configuration.preferences.javaScriptEnabled ? 1 : 0
            return true
        case .quickLook:
            return false
        }
    }
    
    // MARK: Handle Menu Items

    @objc fileprivate func shareMenu(_ sender: NSObject?) {
        guard
            let item = self.itemID,
            let url = URL(string: item.urlString)
        else { return }
        ((sender as? NSMenuItem)?.representedObject as? NSSharingService)?.perform(withItems: [url])
        (sender as? NSMenuItem)?.representedObject = .none
    }
    
    // swiftlint:disable:next cyclomatic_complexity
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
        case .copy, .open, .delete, .showMainWindow:
            return false
        case .tags:
            return false
        case .quickLook:
            return false
        case .openInBrowser:
            return true
        }
    }
    
    // MARK: State Restoration
    
    enum StateRestorationConstants {
        static let kJavascriptEnabled = "kJavascriptEnabledKey"
        static let kURLItemUUID = "kURLItemUUIDKey"
        static let kURLItemURLString = "kURLItemURLStringKey"
        static let kURLItemArchived = "kURLItemArchivedKey"
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        // save all the state
        coder.encode(self.itemID?.uuid, forKey: StateRestorationConstants.kURLItemUUID)
        coder.encode(self.itemID?.urlString, forKey: StateRestorationConstants.kURLItemURLString)
        coder.encode(NSNumber(value: self.itemID?.archived ?? false), forKey: StateRestorationConstants.kURLItemArchived)
        coder.encode(NSNumber(value: self.webView.configuration.preferences.javaScriptEnabled), forKey: StateRestorationConstants.kJavascriptEnabled)
        super.encodeRestorableState(with: coder)
    }
    
    override func restoreState(with coder: NSCoder) {
        // only restore the javascript state
        let javascriptEnabled = coder.decodeObject(forKey: StateRestorationConstants.kJavascriptEnabled) as? NSNumber
        let restoredValue = javascriptEnabled?.boolValue ?? self.webView.configuration.preferences.javaScriptEnabled
        self.webView.configuration.preferences.javaScriptEnabled = restoredValue
        super.restoreState(with: coder)
    }
}
