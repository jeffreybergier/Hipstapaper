//
//  XPlatformURLSharingViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/24/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

#if os(OSX)
    import AppKit
    typealias XPViewController = NSViewController
#else
    import UIKit
    typealias XPViewController = UIViewController
#endif
import WebKit

extension WKWebView: KVOCapable {}

class XPURLShareViewController: XPViewController {
    
    var item: SerializableURLItem.Result?
    
    #if os(OSX)
    override func viewDidAppear() {
        super.viewDidAppear()
        self.start()
    }
    #else
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.start()
    }
    #endif
    
    func start() {
        guard let extensionItem = self.extensionContext?.inputItems.first as? NSExtensionItem else {
            self.extensionContext?.cancelRequest(withError: NSError(domain: "", code: 0, userInfo: nil))
            return
        }
        SerializableURLItem.item(from: extensionItem) { result in
            DispatchQueue.main.async {
                self.item = result
            }
        }
    }
    
    func save(item: SerializableURLItem) {
        let itemsToSave: [SerializableURLItem]
        if let itemsOnDisk = NSKeyedUnarchiver.unarchiveObject(withFile: SerializableURLItem.archiveURL.path) as? [SerializableURLItem] {
            itemsToSave = itemsOnDisk + [item]
        } else {
            // delete the file if it exists and has incorrect data, or else this could fail forever and never get fixed
            try? FileManager.default.removeItem(at: SerializableURLItem.archiveURL)
            itemsToSave = [item]
        }
        NSKeyedArchiver.archiveRootObject(itemsToSave, toFile: SerializableURLItem.archiveURL.path)
    }
    
    #if os(OSX)
    class func configuredWebView() -> WebView {
        let webView = WebView()
        let prefs = WebPreferences()
        prefs.isJavaEnabled = false
        prefs.isJavaScriptEnabled = false
        prefs.javaScriptCanOpenWindowsAutomatically = false
        prefs.arePlugInsEnabled = false
        prefs.userStyleSheetEnabled = false
        prefs.allowsAnimatedImages = false
        prefs.allowsAnimatedImageLooping = false
        prefs.allowsAirPlayForMediaPlayback = false
        webView.preferences = prefs
        return webView
    }
    #else
    class func configuredWebView() -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsAirPlayForMediaPlayback = false
        config.preferences.javaScriptEnabled = false
        config.allowsInlineMediaPlayback = false
        config.allowsPictureInPictureMediaPlayback = false
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isUserInteractionEnabled = false
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }
    #endif
    
    #if os(OSX)
    class func snapshot(of view: NSView) -> NSImage? {
        return self.xpSnapshot(of: view)
    }
    #else
    class func snapshot(of view: UIView) -> UIImage? {
        return self.xpSnapshot(of: view)
    }
    #endif
}

#if os(OSX)
    fileprivate typealias XPImage = NSImage
    fileprivate typealias XPView = NSView
#else
    fileprivate typealias XPImage = UIImage
    fileprivate typealias XPView = UIView
#endif
fileprivate extension XPURLShareViewController {
    fileprivate class func xpSnapshot(of view: XPView) -> XPImage? {
        // the sublayer shows the pure transform. so try and grab that
        // the primary layer works but it shows a bunch of empty space where there is a view but nothing rendered because of the transform
        #if os(OSX)
            let _layer = view.layer?.sublayers?.first
            guard let theLayer = _layer else { return .none }
        #else
            let theLayer = view.layer
        #endif
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return .none }
        let theBounds = theLayer.bounds
        
        let pixelsHigh = Int(floor(theBounds.size.height))
        let pixelsWide = Int(floor(theBounds.size.width))
        
        let _context = CGContext(data: nil,
                                 width: pixelsWide,
                                 height: pixelsHigh,
                                 bitsPerComponent: 8,
                                 bytesPerRow: 0,
                                 space: colorSpace,
                                 bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = _context else { return .none }
        #if os(iOS)
            let iOSFlip = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: theBounds.size.height)
            context.concatenate(iOSFlip)
        #endif
        theLayer.render(in: context)
        
        guard let _image = context.makeImage() else { return .none }
        #if os(OSX)
            let image = NSImage(cgImage: _image, size: NSSize.zero)
        #else
            let image = UIImage(cgImage: _image, scale: 1.0, orientation: .up)
        #endif
        return image
    }
}
