//
//  URLItemSavingShareViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Common
import WebKit
import UIKit

class ShareViewController: XPURLShareViewController {
    
    // MARK: IBOutlets
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    
    @IBOutlet private var pageTitleLabel: UILabel?
    @IBOutlet private var pageDateLabel: UILabel?
    @IBOutlet private var providedImageView: UIImageView?
    @IBOutlet private var loadingSpinner: UIActivityIndicatorView?
    @IBOutlet private var webImageViewParentView: UIView?
    @IBOutlet private var modalGrayView: UIView?
    @IBOutlet private var cardViewTopConstraint: NSLayoutConstraint?
    @IBOutlet private var cardView: UIView? {
        didSet {
            self.cardView?.clipsToBounds = true
            self.cardView?.layer.cornerRadius = 15
        }
    }
    
    // MARK: Internal State
    
    private var timer: Timer?
    private var webView: WKWebView?
    private var webViewTitleObserver: KeyValueObserver<String>?
    private var webViewDoneObserver: KeyValueObserver<Bool>?
    
    override var item: SerializableURLItem.Result? {
        didSet {
            self.slideIntoFrame()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cardViewTopConstraint?.constant = UIScreen.main.bounds.height
        self.modalGrayView?.alpha = 0
    }
    
    private func slideIntoFrame() {
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            let halfViewHeight = floor(UIScreen.main.bounds.height / 2)
            let halfCardHeight = floor((self.cardView?.bounds.height ?? 350) / 2)
            self.cardViewTopConstraint?.constant = halfViewHeight - halfCardHeight
            self.modalGrayView?.alpha = 0.5
            self.view.layoutIfNeeded()
        }, completion: .none)
    }
    
    // MARK: Stage 2 - Animate Card into View
    
    private func configureCard(item: SerializableURLItem) -> Bool {
        var webViewNeeded = false
        if let pageTitle = item.pageTitle {
            self.pageTitleLabel?.text = pageTitle
        } else {
            webViewNeeded = true
            self.pageTitleLabel?.text = "Loading..."
        }
        if let image = item.image {
            self.providedImageView?.image = image
        } else {
            webViewNeeded = true
        }
        self.pageDateLabel?.text = self.dateFormatter.string(from: item.date ?? Date())
        
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
        self.webViewTitleObserver = KeyValueObserver<String>(target: webView, keyPath: #keyPath(WKWebView.title))
        self.webViewTitleObserver?.startObserving() { [weak self] newTitle -> String? in
            self?.pageTitleLabel?.text = newTitle
            return .none
        }
        self.webViewDoneObserver = KeyValueObserver<Bool>(target: webView, keyPath: "loading") // #keyPath(WKWebView.isLoading) not working
        self.webViewDoneObserver?.startObserving() { [weak self] loading -> Bool? in
            guard loading == false else { return .none }
            self?.loadingSpinner?.stopAnimating()
            self?.timer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.timerFired(.none) // believe it or not, even when duck out early because the webview finished, we still need a delay to make it feel good
            }
            return .none
        }
        
        // add the webview to the view hierarchy
        // the autolayout for this makes it purposefully twice as big
        // then shrinks it down via a transform
        // this is so a 'normal' size page is what loads.
        self.webImageViewParentView?.addSubview(webView)
        self.webImageViewParentView?.centerYAnchor.constraint(equalTo: webView.centerYAnchor, constant: 0).isActive = true
        self.webImageViewParentView?.centerXAnchor.constraint(equalTo: webView.centerXAnchor, constant: 0).isActive = true
        self.webImageViewParentView?.widthAnchor.constraint(equalTo: webView.widthAnchor, multiplier: 0.5, constant: 0).isActive = true
        self.webImageViewParentView?.heightAnchor.constraint(equalTo: webView.heightAnchor, multiplier: 0.5, constant: 0).isActive = true
        webView.transform = webView.transform.scaledBy(x: 0.5, y: 0.5)
        
        // load the url in the webview
        let url = URL(string: item.urlString!)!
        // check if we should enable javascript for whitelisted sites
        webView.configuration.preferences.javaScriptEnabled = type(of: self).javascriptWhiteListed(for: url)
        // load the page
        webView.load(URLRequest(url: url))
    }
    
    // MARK: Stage 4 - Optional - Show Error
    
    private func configureError() {
        self.loadingSpinner?.stopAnimating()
        self.providedImageView?.image = .none
        self.webView?.removeFromSuperview()
        self.webView = .none
        self.pageDateLabel?.text = .none
        self.pageTitleLabel?.text = "Error 😔"
    }
    
    // MARK: Stage 5 - Slide Out
    
    @objc private func timerFired(_ timer: Timer?) {
        
        // clear all the time shit
        timer?.invalidate()
        self.timer?.invalidate()
        self.timer = .none
        
        // stop KVO
        self.webViewDoneObserver = .none
        self.webViewTitleObserver = .none
        
        // stop the spinner
        self.loadingSpinner?.stopAnimating()
        
        if let result = self.item, case .success(let item) = result {
            // we have an item
            if let webView = self.webView {
                // if we have  webview that means we need to take a snopshot
                item.pageTitle = webView.title
                item.image = type(of: self).snapshot(of: webView)
                self.save(item: item)
                self.slideOutOfFrame() { _ in
                    self.extensionContext?.completeRequest(returningItems: .none, completionHandler: .none)
                }
            } else {
                // if we don't we can just save and exit
                self.save(item: item)
                self.slideOutOfFrame() { _ in
                    self.extensionContext?.completeRequest(returningItems: .none, completionHandler: .none)
                }
            }
        } else {
            // if we have nothing we need to slide out can cancel with error
            self.slideOutOfFrame() { _ in
                self.extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0, userInfo: .none))
            }
        }
    }
    
    private func slideOutOfFrame(animationCompletion: @escaping (Bool) -> Void) {
        self.view.setNeedsLayout()
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseInOut], animations: {
            let cardViewHeight = self.cardView?.bounds.height ?? 350
            self.cardViewTopConstraint?.constant = -1 * cardViewHeight + 10 // add 10 for the shadow
            self.modalGrayView?.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: animationCompletion)
    }
    
    // some sites on mobile load faster / at all with Javascript enabled
    private static func javascriptWhiteListed(for url: URL) -> Bool {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let host = components?.host?.lowercased() else { return false }
        let whitelisted =
            host.contains("youtube.") ||
            host.contains("youtu.be") ||
            host.contains("instagram.") ||
            host.contains("instagr.am")
//            host.contains("theverge.com")
        return whitelisted
    }
}

