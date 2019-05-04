//
//  TitlePrefixer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import Foundation

public protocol KVOCapable: class {
    var hashValue: Int { get }
    func setValue(_ value: Any?, forKey key: String)
    func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?)
    func removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context: UnsafeMutableRawPointer?)
}

open class KeyValueObserver<T: Equatable>: NSObject {
    
    private weak var target: KVOCapable?
    private var callback: ((T) -> T?)?
    private let keyPath: String
    
    private var previousValue: T?
    private var kKVOContext = UUID().hashValue
    
    public init(target: KVOCapable, keyPath: String) {
        self.keyPath = keyPath
        self.target = target
        super.init()
    }
    
    public func startObserving(_ callback: @escaping ((T) -> T?)) {
        self.callback = callback
        self.startObserving(keyPath: self.keyPath)
    }
    
    public func endObserving() {
        self.callback = nil
        self.endObserving(keyPath: self.keyPath)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        
        // make sure the context is my own objects context
        // otherwise it might be a system or other KVO context and I don't want to step on it
        guard context == &kKVOContext else { return }
        
        if
            let keyPath = keyPath, // make sure we have a valid key path
            let newValue = change?[.newKey] as? T, // make sure we have a valid new value and its the right type
            let callback = self.callback, // make sure we have a completion handler for this keypath
            self.previousValue != newValue // make sure the previous value is not the same as the new value
        {
            // check to see if the observing object wants to update the value
            if let updatedValue = callback(newValue) {
                self.previousValue = updatedValue // if they do, save it as the previous value to stop infinite loop
                if NSNull().isEqual(updatedValue) == false { // if the value is NSNull, don't save it because it can never change
                    self.target?.setValue(updatedValue, forKey: keyPath) // then set the value
                }
            } else {
                if NSNull().isEqual(newValue) == false {
                    self.previousValue = newValue // if not, just make sure to store the previous value just in case KVO gets called again
                }
            }
        }
    }
    
    private func startObserving(keyPath: String) {
        self.target?.addObserver(self, forKeyPath: keyPath, options: [.new], context: &kKVOContext)
    }
    
    private func endObserving(keyPath: String) {
        self.target?.removeObserver(self, forKeyPath: keyPath, context: &kKVOContext)
    }
    
    deinit {
        self.endObserving(keyPath: self.keyPath)
    }
}
