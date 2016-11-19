//
//  TitlePrefixer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

protocol KVOCapable: class {
    func setValue(_ value: Any?, forKey key: String)
    func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?)
    func removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context: UnsafeMutableRawPointer?)
}

class KeyObserver: NSObject {
    
    let keyPath: String //#keyPath(NSWindow.title)
    private var kvoHandler: ((String) -> String?)?
    private weak var target: KVOCapable? {
        didSet {
            oldValue?.removeObserver(self, forKeyPath: self.keyPath, context: .none)
            self.target?.addObserver(self, forKeyPath: self.keyPath, options: [.new], context: .none)
        }
    }
    
    init(keyPath: String) {
        self.keyPath = keyPath
        super.init()
    }
    
    func set(target: KVOCapable?, kvoHandler: (((String) -> String?))?) {
        self.target = target
        self.kvoHandler = kvoHandler
    }
    
    // this property prevents KVO infinite loop
    private var newestValue = ""
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if
            let titleable = self.target, // make sure we have an object we're monitoring
            (object as AnyObject) === titleable, // make sure the object passed in in KVO is our object
            keyPath == self.keyPath, // make sure the keypath passed in is our key path
            let newValue = change?[.newKey] as? String, // make sure we have a valid new title that is a string
            self.newestValue != newValue // make sure it doesn't match the previous value (this stops an infinite loop)
        {
            let modifiedValue = self.kvoHandler?(newValue)
            if let modifiedValue = modifiedValue {
                self.newestValue = modifiedValue
                self.target?.setValue(modifiedValue, forKey: self.keyPath)
            }
        }
    }
    
    deinit {
        self.target?.removeObserver(self, forKeyPath: self.keyPath, context: .none)
    }
    
}
