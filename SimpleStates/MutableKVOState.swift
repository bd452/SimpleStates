//
//  MutableKVOState.swift
//  SimpleStates
//
//  Created by Bryce Dougherty on 5/18/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation

public class MutableKVOState<U: NSObject, T>: KVOState<U, T> {
    weak var obj: U?
    var keyPath: ReferenceWritableKeyPath<U,T>
    
    public init(obj: U, keyPath: ReferenceWritableKeyPath<U, T>) {
        self.obj = obj
        self.keyPath = keyPath
        super.init(obj: obj, keyPath: keyPath)
    }
    
    public convenience init(link: BundledKeyPath<U,T>) {
        self.init(obj: link.object, keyPath: link.path)
    }
    
    public func setValue(_ newValue: T) {
        obj?[keyPath: keyPath] = newValue
    }
}
