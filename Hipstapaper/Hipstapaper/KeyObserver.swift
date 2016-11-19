//
//  TitlePrefixer.swift
//  Hipstapaper
//
//  Created by Jeffrey Bergier on 11/18/16.
//  Copyright © 2016 Jeffrey Bergier. All rights reserved.
//

import AppKit

public protocol KVOCapable: class {
    var hashValue: Int { get }
    func setValue(_ value: Any?, forKey key: String)
    func addObserver(_ observer: NSObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, context: UnsafeMutableRawPointer?)
    func removeObserver(_ observer: NSObject, forKeyPath keyPath: String, context: UnsafeMutableRawPointer?)
}

open class KeyValueObserver<T: Equatable>: NSObject {
    
    public typealias NewValueOrNilCallback = ((T) -> T?)
    
    private var targets = Set<WeakObjectHolder<T>>()
    private var kKVOContext = UUID().hashValue
    
    public override init() {
        super.init()
    }
    
    public func add(target: KVOCapable?, forKeyPath keyPath: String, kvoHandler: @escaping NewValueOrNilCallback) {
        // unregister older observer if needed
        self.remove(target: target, forKeyPath: keyPath)
        
        // set up new holder
        let newHolder = WeakObjectHolder(object: target, keyPath: keyPath, kvoHandler: kvoHandler)
        self.startObserving(object: target, forKeyPath: keyPath)
        
        // store the object holder
        self.targets.insert(newHolder)
    }
    
    public func remove(target: KVOCapable?, forKeyPath keyPath: String?) {
        if let keyPath = keyPath {
            // if we are given a key path, then remove the specific holder for that
            guard let holder = self.holder(for: target, forKeyPath: keyPath) else { return }
            self.endObserving(object: holder.object, forKeyPath: holder.keyPath)
            self.targets.remove(holder)
        } else {
            // if we are not given the key path, remove all observers for the object
            let holders = self.holdersWithAnyKeyPath(for: target)
            for holder in holders {
                self.endObserving(object: holder.object, forKeyPath: holder.keyPath)
                self.targets.remove(holder)
            }
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        // make sure the context is my own objects context
        // otherwise it might be a system or other KVO context and I don't want to step on it
        guard context == &kKVOContext else { return }
        
        if
            let keyPath = keyPath, // make sure we have a valid key path
            let newValue = change?[.newKey] as? T, // make sure we have a valid new value and its the right type
            let holder = self.holder(for: object as AnyObject, forKeyPath: keyPath), // make sure we have an object that matches this object and this key path
            holder.newestValue != newValue // make sure that the latest value is not the new value. This stops infinite loop
        {
            // now check with the callback that was registered for this observer to see if we need to override the value
            if let modifiedValue = holder.kvoHandler(newValue) {
                holder.newestValue = modifiedValue // update the value in the holder. Prevents infinite loop
                holder.object?.setValue(modifiedValue, forKey: holder.keyPath) // set the value for the keypath on the object
            }
        }
    }
    
    
    private func holdersWithAnyKeyPath(for object: AnyObject?) -> [WeakObjectHolder<T>] {
        return self.targets.filter({ $0.object === object })
    }
    
    private func holder(for object: AnyObject?, forKeyPath keyPath: String) -> WeakObjectHolder<T>? {
        return self.targets.filter({ $0.object === object && $0.keyPath == keyPath }).first
    }
    
    private func startObserving(object: AnyObject?, forKeyPath keyPath: String) {
        object?.addObserver(self, forKeyPath: keyPath, options: [.new], context: &kKVOContext)
    }
    
    private func endObserving(object: AnyObject?, forKeyPath keyPath: String) {
        object?.removeObserver(self, forKeyPath: keyPath, context: &kKVOContext)
    }
    
    deinit {
        for holder in self.targets {
            self.endObserving(object: holder.object, forKeyPath: holder.keyPath)
        }
        self.targets.removeAll()
    }
}

fileprivate class WeakObjectHolder<T: Equatable> {
    weak var object: KVOCapable?
    let keyPath: String
    let kvoHandler: KeyValueObserver<T>.NewValueOrNilCallback
    var newestValue: T?
    
    init(object: KVOCapable?, keyPath: String, kvoHandler: @escaping KeyValueObserver<T>.NewValueOrNilCallback) {
        self.keyPath = keyPath
        self.object = object
        self.kvoHandler = kvoHandler
    }
}

extension WeakObjectHolder: Equatable {}
private func ==<T>(lhs: WeakObjectHolder<T>, rhs: WeakObjectHolder<T>) -> Bool {
    return lhs.object === rhs.object
}
extension WeakObjectHolder: Hashable {
    var hashValue: Int {
        if let object = self.object {
            return (String(object.hashValue) + self.keyPath).hashValue
        } else {
            return 0
        }
    }
}
