//
//  URLItemSavingShareViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/21/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Common
import WebKit
import AppKit

extension WebView: KVOCapable {}

class ShareViewController: XPURLShareViewController {
    
    // MARK: Outlets

    @IBOutlet private var pageTitleLabel: NSTextField?
    @IBOutlet private var pageDateLabel: NSTextField?
    @IBOutlet private var providedImageView: NSImageView?
    @IBOutlet private var loadingSpinner: NSProgressIndicator?
    @IBOutlet private var webImageViewParentView: NSView?
    
    // MARK: Internal State
    
    private var timer: Timer?
    private var webView: WebView? // have to use old WebView because new one cannot be snapshotted - it just shows a white box
    private var webViewTitleObserver: KeyValueObserver<String>?
    
    override var item: SerializableURLItem.Result? {
        didSet {
            var duration: TimeInterval = 8
            if let result = self.item, case .success(let item) = result {
                // check to see if we have the info needed
                let fullyConfigured = self.configureCard(item: item)
                if fullyConfigured {
                    // if there is, shorten the timer duration and save immediately
                    duration = 1
                } else {
                    // if not, configure the webview.
                    // it gets 3 seconds to load and then we capture a snapshot
                    self.configureWebView(item: item)
                }
            } else {
                duration = 2
                self.configureError()
            }
            // all the missing information is filled in the timerFired method and the view is dismissed from there
            self.timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.timerFired(_:)), userInfo: .none, repeats: false)
        }
    }
    
    // MARK: Stage 1 - Prepare view offscreen
    
    // OS X does this automatically for us
    
    // MARK: Stage 2 - Animate Card into View
    
    private func configureCard(item: SerializableURLItem) -> Bool {
        self.loadingSpinner?.startAnimation(self)
        
        var webViewNeeded = false
        if let pageTitle = item.pageTitle {
            self.pageTitleLabel?.objectValue = pageTitle
        } else {
            webViewNeeded = true
            self.pageTitleLabel?.objectValue = "Loading..."
        }
        if let image = item.image {
            self.providedImageView?.objectValue = image
        } else {
            webViewNeeded = true
        }
        self.pageDateLabel?.objectValue = item.date ?? Date()
        
        return !webViewNeeded
    }
    
    // MARK: Stage 3 - Optional - Use webview to capture missing information
    
    private func configureWebView(item: SerializableURLItem) {
        // get a preconfigured new webview
        let webView = type(of: self).configuredWebView()
        self.webView = webView
        
        // remove the imageview from the view hierarchy
        self.providedImageView?.removeFromSuperview()
        
        // start observing the title and the finished loading
        self.webViewTitleObserver = KeyValueObserver<String>(target: webView, keyPath: #keyPath(WebView.mainFrameTitle))
        self.webViewTitleObserver?.startObserving() { [weak self] newTitle -> String? in
            self?.pageTitleLabel?.stringValue = newTitle
            return .none
        }
        
        // start observing for finished loading
        NotificationCenter.default.addObserver(forName: .WebViewProgressFinished, object: webView, queue: .none) { notification in
            self.loadingSpinner?.stopAnimation(self)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.timer?.fire() // believe it or not, even when duck out early because the webview finished, we still need a delay to make it feel good
            }
        }
        
        // add the webview to the view hierarchy
        // the autolayout for this makes it purposefully twice as big
        // then shrinks it down via a transform
        // this is so a 'normal' size page is what loads.
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webImageViewParentView?.addSubview(webView)
        self.webImageViewParentView?.centerYAnchor.constraint(equalTo: webView.centerYAnchor, constant: 0).isActive = true
        self.webImageViewParentView?.centerXAnchor.constraint(equalTo: webView.centerXAnchor, constant: 0).isActive = true
        self.webImageViewParentView?.widthAnchor.constraint(equalTo: webView.widthAnchor, multiplier: 0.5, constant: 0).isActive = true
        self.webImageViewParentView?.heightAnchor.constraint(equalTo: webView.heightAnchor, multiplier: 0.5, constant: 0).isActive = true
        self.webImageViewParentView?.layout()
        let webViewBounds = webView.bounds
        let originalTransform = webView.layer?.sublayerTransform ?? CATransform3DIdentity
        let scale = CATransform3DScale(originalTransform, 0.5, 0.5, 1.0)
        let translate = CATransform3DTranslate(scale, webViewBounds.size.width / 2, webViewBounds.size.height / 2, 0)
        webView.layer?.sublayerTransform = translate
        
        // load the url in the webview
        let url = URL(string: item.urlString!)!
        webView.mainFrame.load(URLRequest(url: url))
    }
    
    // MARK: Stage 4 - Optional - Show Error
    
    private func configureError() {
        self.loadingSpinner?.stopAnimation(self)
        self.providedImageView?.image = .none
        self.webView?.removeFromSuperview()
        self.webView = .none
        self.pageDateLabel?.objectValue = .none
        self.pageTitleLabel?.stringValue = "Error 😔"
    }
    
    // MARK: Stage 5 - Slide Out
    
    @objc private func timerFired(_ timer: Timer?) {
        // clear all the time shit
        timer?.invalidate()
        self.timer = .none
        
        // stop KVO
        self.webViewTitleObserver = .none
        
        // de-register observer
        NotificationCenter.default.removeObserver(self, name: .WebViewProgressFinished, object: self.webView)
        
        // stop the spinner
        self.loadingSpinner?.stopAnimation(self)
        
        if let result = self.item, case .success(let item) = result {
            // we have an item
            if let webView = self.webView {
                // if we have  webview that means we need to take a snopshot
                item.pageTitle = webView.mainFrameTitle
                item.image = type(of: self).snapshot(of: webView)
                self.save(item: item)
                self.extensionContext?.completeRequest(returningItems: .none, completionHandler: .none)
            } else {
                // if we don't we can just save and exit
                self.save(item: item)
                self.extensionContext?.completeRequest(returningItems: .none, completionHandler: .none)
            }
        } else {
            // if we have nothing we need to slide out can cancel with error
            self.extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0, userInfo: .none))
        }
    }
}
