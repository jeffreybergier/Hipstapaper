//
//  TitlePrefixer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

protocol Titleable: class {
    var title: String { get set }
    func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?)
    func removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context: UnsafeMutableRawPointer?)
}

class TitlePrefixer: NSObject {
    
    let keyPath = "title" //#keyPath(NSWindow.title)
    let titlePrefix: String
    
    weak var target: Titleable? {
        didSet {
            oldValue?.removeObserver(self, forKeyPath: self.keyPath, context: .none)
            self.target?.addObserver(self, forKeyPath: self.keyPath, options: [.new], context: .none)
        }
    }
    
    init(titlePrefix: String) { //(keyPath: String, titlePrefix: String) {
        //self.keyPath = keyPath
        self.titlePrefix = titlePrefix
        super.init()
    }
    
    // this property prevents KVO infinite loop
    private var previousTitle = ""
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if
            let titleable = self.target, // make sure we have an object we're monitoring
            (object as AnyObject) === titleable, // make sure the object passed in in KVO is our object
            keyPath == self.keyPath, // make sure the keypath passed in is our key path
            let newValue = change?[.newKey] as? String, // make sure we have a valid new title that is a string
            self.previousTitle != newValue // make sure it doesn't match the previous value (this stops an infinite loop)
        {
            self.previousTitle = self.titlePrefix + newValue
            titleable.title = self.previousTitle
        }
    }
    
    deinit {
        self.target?.removeObserver(self, forKeyPath: self.keyPath, context: .none)
    }
    
}
