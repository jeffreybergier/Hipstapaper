//
//  XPViewController.swift
//  Pods
//
//  Created by Jeffrey Bergier on 2/2/17.
//
//

import Foundation

#if os(OSX)
    import AppKit
    public typealias XPViewController = NSViewController
    internal typealias XPLabel = NSTextField
    internal typealias XPView = NSView
    internal typealias XPActivityIndicatorView = NSProgressIndicator
    internal typealias XPImage = NSImage
#else
    import UIKit
    public typealias XPViewController = UIViewController
    internal typealias XPLabel = UILabel
    internal typealias XPView = UIView
    internal typealias XPActivityIndicatorView = UIActivityIndicatorView
    internal typealias XPImage = UIImage
#endif

#if os(OSX)
    extension XPView {
        var xpLayer: CALayer? {
            if self.layer == .none {
                self.wantsLayer = true
            }
            return self.layer
        }
    }
#else
    extension XPView {
        var xpLayer: CALayer? {
            return self.layer
        }
    }
#endif

public enum Color {
    #if os(OSX)
    public static let tintColor = NSColor(red: 0, green: 204/255.0, blue: 197/255.0, alpha: 1)
    public static let iconColor = NSColor(red: 136/255.0, green: 255/255.0, blue: 226/255.0, alpha: 1)
    #else
    public static let tintColor = UIColor(red: 0, green: 204/255.0, blue: 197/255.0, alpha: 1)
    public static let iconColor = UIColor(red: 136/255.0, green: 255/255.0, blue: 226/255.0, alpha: 1)
    #endif
}

