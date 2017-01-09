//
//  URLItemSavingShareViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/17/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import WebKit
import UIKit

extension WKWebView: KVOCapable {}

class URLShareiOSViewController: XPURLShareViewController {
    
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    
    @IBOutlet private var containerViewCenterYConstraint: NSLayoutConstraint?
    @IBOutlet private var pageTitleLabel: UILabel?
    @IBOutlet private var pageDateLabel: UILabel?
    @IBOutlet private var providedImageView: UIImageView?
    @IBOutlet private var loadingSpinner: UIActivityIndicatorView?
    @IBOutlet private var webImageViewParentView: UIView?
    @IBOutlet private var modalGrayView: UIView?
    @IBOutlet private var cardView: UIView? {
        didSet {
            self.cardView?.layer.shadowColor = UIColor.black.cgColor
            self.cardView?.layer.shadowOffset = CGSize(width: 2, height: 3)
            self.cardView?.layer.shadowOpacity = 0.4
            self.cardView?.layer.cornerRadius = 5
        }
    }
    
    override var item: SerializableURLItem.Result? {
        didSet {
            self.slideIntoFrame()
            var duration: TimeInterval = 5
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
            }
            // all the missing information is filled in the timerFired method and the view is dismissed from there
            self.timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(self.timerFired(_:)), userInfo: .none, repeats: false)
        }
    }
    
    // MARK: Stage 1 - Prepare view offscreen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerViewCenterYConstraint?.constant = floor(UIScreen.main.bounds.height / 2) + 150
        self.modalGrayView?.alpha = 0
    }
    
    private func slideIntoFrame() {
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.8, options: [], animations: {
            self.containerViewCenterYConstraint?.constant = 0
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
        self.providedImageView?.removeFromSuperview()
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = false
        config.allowsInlineMediaPlayback = false
        config.allowsPictureInPictureMediaPlayback = false
        config.preferences.javaScriptEnabled = false
        let webView = WKWebView(frame: .zero, configuration: config)
        self.webView = webView
        self.webViewTitleObserver = KeyValueObserver<String>(target: webView, keyPath: #keyPath(WKWebView.title))
        self.webViewTitleObserver?.startObserving() { [weak self] newTitle -> String? in
            self?.pageTitleLabel?.text = newTitle
            return .none
        }
        self.webViewDoneObserver = KeyValueObserver<Bool>(target: webView, keyPath: "loading") // #keyPath(WKWebView.isLoading) not working
        self.webViewDoneObserver?.startObserving() { [weak self] loading -> Bool? in
            guard loading == false else { return .none }
            self?.loadingSpinner?.stopAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self?.timer?.fire()
            }
            return .none
        }
        webView.isUserInteractionEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webImageViewParentView?.addSubview(webView)
        self.webImageViewParentView?.centerYAnchor.constraint(equalTo: webView.centerYAnchor, constant: 0).isActive = true
        self.webImageViewParentView?.centerXAnchor.constraint(equalTo: webView.centerXAnchor, constant: 0).isActive = true
        self.webImageViewParentView?.widthAnchor.constraint(equalTo: webView.widthAnchor, multiplier: 0.5, constant: 0).isActive = true
        self.webImageViewParentView?.heightAnchor.constraint(equalTo: webView.heightAnchor, multiplier: 0.5, constant: 0).isActive = true
        webView.transform = webView.transform.scaledBy(x: 0.5, y: 0.5)
        let url = URL(string: item.urlString!)!
        webView.load(URLRequest(url: url))
    }
    
    // MARK: Stage 4 - Slide Out
    
    private var timer: Timer?
    private var webView: WKWebView?
    private var webViewTitleObserver: KeyValueObserver<String>?
    private var webViewDoneObserver: KeyValueObserver<Bool>?

    
    @objc private func timerFired(_ timer: Timer?) {
        // clear all the time shit
        timer?.invalidate()
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
                if item.pageTitle == nil {
                    item.pageTitle = webView.title
                }
                if item.image == nil {
                    item.image = webView.snapshot
                }
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
            self.containerViewCenterYConstraint?.constant = -1 * (floor(UIScreen.main.bounds.height / 2) + 150 + 10) //10 extra for the shadow
            self.modalGrayView?.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: animationCompletion)
    }
}

extension WKWebView {
    var snapshot: UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage!
    }
}

