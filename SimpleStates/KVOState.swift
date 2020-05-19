//
//  KVOState.swift
//  HookSwift
//
//  Created by Bryce Dougherty on 5/18/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation


public class KVOState<T>: State<T> {
    
    private var observer: NSKeyValueObservation!
    
    public init<U: NSObject>(link: BundledKeyPath<U,T>) {
        let defaultValue = link.object[keyPath: link.path]
        super.init(defaultValue)
        self.observer = link.object.observe(link.path, options: [.new]) { (obj, change) in
            if let newValue = change.newValue {
                super.set(newValue)
            }
        }
    }
    
    public init<U: NSObject>(obj: U, keyPath: KeyPath<U, T>) {
        let defaultValue = obj[keyPath: keyPath]
        super.init(defaultValue)
        self.observer = obj.observe(keyPath, options: .new, changeHandler: { (obj, change) in
            if let newValue = change.newValue {
                super.set(newValue)
            }
        })
    }
    
    @available (*, unavailable)
    public override func set(_ newValue: T) {
        super.set(newValue)
    }
    
    deinit {
        self.observer.invalidate()
    }
}
