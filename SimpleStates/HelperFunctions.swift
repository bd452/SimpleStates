//
//  HelperFunctions.swift
//  SimpleStates
//
//  Created by Bryce Dougherty on 5/13/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation

infix operator ..

/// Create a bundled keypath given an object and a keypath on it
/// - Parameters:
///   - arg1: The Object on which the keypath resides
///   - path: the keypath itself
/// - Returns: The Bundled KeyPath
public func ..<T,U>(arg1: T, path: ReferenceWritableKeyPath<T, U>)->BundledKeyPath<T,U>{
    return BundledKeyPath(arg1, path)
}

infix operator <->: AssignmentPrecedence

@discardableResult public func <-><T, U>(arg1: BundledKeyPath<U, T>, state: State<T>)->Binding {
    return state.bind(arg1)
}
@discardableResult public func <-><T, U>(arg1: BundledKeyPath<U, T?>, state: State<T>)->Binding {
    return state.bind(arg1)
}
