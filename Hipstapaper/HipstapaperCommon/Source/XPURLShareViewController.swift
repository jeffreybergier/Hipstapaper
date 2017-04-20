//
//  XPlatformURLSharingViewController.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 12/24/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import WebKit

open class XPURLShareViewController: XPViewController {
    
    open var item: SerializableURLItem.Result?
    
    #if os(OSX)
    override open func viewDidAppear() {
        super.viewDidAppear()
        self.start()
    }
    #else
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.start()
    }
    #endif
    
    public func start() {
        guard let extensionItem = self.extensionContext?.inputItems.first as? NSExtensionItem else { self.item = .error; return; }
        SerializableURLItem.item(from: extensionItem) { result in
            DispatchQueue.main.async {
                self.item = result
            }
        }
    }
    
    public func save(item: SerializableURLItem) {
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
    public class func configuredWebView() -> WebView {
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
    public class func configuredWebView() -> WKWebView {
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
    public class func snapshot(of view: NSView) -> NSImage? {
        return self.xpSnapshot(of: view)
    }
    #else
    public class func snapshot(of view: UIView) -> UIImage? {
        return self.xpSnapshot(of: view)
    }
    #endif
}

fileprivate extension XPURLShareViewController {
    
    #if os(OSX)
    private class func macOS_render(view: XPView) -> XPImage? {
        // the sublayer shows the pure transform. so try and grab that
        // the primary layer works but it shows a bunch of empty space where there is a view but nothing rendered because of the transform
        let _layer = view.layer?.sublayers?.first
        guard let theLayer = _layer else { return nil }
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
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
        
        guard let context = _context else { return nil }
        theLayer.render(in: context)
    
        guard let _image = context.makeImage() else { return nil }
        let maxDimension = XPImageProcessor.maxDimensionSize
        let image = NSImage(cgImage: _image, size: NSSize(width: maxDimension, height: maxDimension))
        return image
    }
    #else
    private class func iOS_render(view: XPView) -> XPImage? {
        let bounds = view.bounds
        let maxDimension = XPImageProcessor.maxDimensionSize
        let maxRect = CGRect(x: 0, y: 0, width: maxDimension, height: maxDimension)
        UIGraphicsBeginImageContext(bounds.size)
        view.drawHierarchy(in: bounds, afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIGraphicsBeginImageContext(maxRect.size)
        img?.draw(in: maxRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    #endif
    
    fileprivate class func xpSnapshot(of view: XPView) -> XPImage? {
        #if os(OSX)
            return self.macOS_render(view: view)
        #else
            return self.iOS_render(view: view)
        #endif
    }
}
