//
//  KVOState.swift
//  HookSwift
//
//  Created by Bryce Dougherty on 5/18/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation


public class KVOState<U: NSObject, T>: State<T> {
    
    private var observer: NSKeyValueObservation!
    private weak var obj: U?
    private var keyPath: KeyPath<U,T>
    
    public init(obj: U, keyPath: KeyPath<U, T>) {
        let defaultValue = obj[keyPath: keyPath]
        self.obj = obj
        self.keyPath = keyPath
        super.init(defaultValue)
        self.observer = obj.observe(keyPath, options: .new, changeHandler: { (obj, change) in
            if let newValue = change.newValue {
                super.set(newValue)
            }
        })
    }
    
    @available (*, unavailable , message: "Can't change the value of a KVOState. Try MutableKVOState.setValue")
    public override func set(_ newValue: T) {
        
    }
    
    deinit {
        self.observer.invalidate()
    }
}
