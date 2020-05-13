//
//  BundledKeyPath.swift
//  Swift-React
//
//  Created by Bryce Dougherty on 5/13/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation

public protocol AnyBundledKeyPath {
    associatedtype T
    associatedtype U
    var object: T { get }
    var path: ReferenceWritableKeyPath<T,U> { get }
    init(_ object: T, _ path: ReferenceWritableKeyPath<T, U>)
    func bind(_ state: State<U>)
}

/// An object that holds both a keypath and an object it can refer to
public struct BundledKeyPath<T,U>: AnyBundledKeyPath {
    public let object: T
    public let path: ReferenceWritableKeyPath<T,U>
    public init(_ object: T, _ path: ReferenceWritableKeyPath<T, U>) {
        self.object = object
        self.path = path
    }
    public func bind(_ state: State<U>) {
        state(self)
    }
}
