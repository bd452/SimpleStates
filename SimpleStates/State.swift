//
//  State.swift
//  Swift-React
//
//  Created by Bryce Dougherty on 5/13/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation

public typealias Binding = UUID

public typealias getterSetter<T> = (State<T>, () -> T, (T) -> ())


/// Creates a new state and binds it to the given object value
/// - Parameters:
///   - keyPath: A Bundled Key Path pointing to the object to change
///   - initialValue: The initial value to assign to the object
/// - Returns: The newly created state
public func bindState<T, U: AnyBundledKeyPath>(_ keyPath: U, _ initialValue: T)->State<T> {
    let newState = State<T>(initialValue)
    newState.bind(keyPath)
    return newState
}


/// Creates a new state, returning a tuple containing the getter and setter function
/// - Parameter initialValue: The initial value to assign to the object
/// - Returns: A tuple (State, Getter, Setter)
public func useState<T>(_ initialValue: T)->getterSetter<T> {
    let newState = State<T>(initialValue)
    return (newState, newState.get, newState.set)
}


/**
 * A State Object
 * Holds state values and delegates notifications to values that need to be changed
 */
open class State<T> {
    internal var data:T
    internal var listeners: [Binding: (T)->Void] = [:]
    var onDeinit: (()->Void)?
    
    public init(_ initialValue: T) {
        self.data = initialValue
    }
    
    /// Calls the given closure whenever the value is updated
    /// - Parameter cb: The closure
    /// - Returns: A Binding reference
    @discardableResult public func on(_ cb: @escaping (T)->Void)->Binding {
        let id = Binding()
        self.listeners[id] = cb
        cb(self.data)
        return id
    }
    
    public func updateListeners() {
        self.listeners.values.forEach { (callback) in
            DispatchQueue.main.async(execute: {[unowned self] in callback(self.data)})
        }
    }
    
    /// Updates the value of the state
    /// - Parameter newValue: the new value to update to
    public func set(_ newValue: T) {
        self.data = newValue
        self.updateListeners()
    }
    /// Gets the current value of the state
    /// - Returns: The current value of the state
    public func get()->T {
        return self.data
    }
    
    /// Bind a BundledKeyPath to the state
    /// - Parameter bundledKeyPath: KeyPath to target value
    /// - Returns: identifier of the binding
    @discardableResult public func bind<U: AnyBundledKeyPath>(_ bundledKeyPath: U)->Binding {
        self.on({ bundledKeyPath.object[keyPath: bundledKeyPath.path] = $0 as! U.U })
    }
    /// Bind a given keypath and object to the state
    /// - Parameters:
    ///   - obj: Object to bind
    ///   - keyPath: KeyPath to target value
    /// - Returns: identifier of the binding
    @discardableResult public func bind<U>(_ obj: U, _ keyPath: ReferenceWritableKeyPath<U,T>)->Binding {
        self.on({ obj[keyPath: keyPath] = $0 })
    }
    
    
    /// Same as bind(obj, keyPath) but for optionals
    /// - Parameters:
    ///   - obj: Object to bind
    ///   - keyPath: KeyPath to target value
    /// - Returns: identifier of the binding
    @discardableResult public func bind<U>(_ obj: U, _ keyPath: ReferenceWritableKeyPath<U,T?>)->Binding {
        self.on({ obj[keyPath: keyPath] = $0 })
    }
    
    /// Remove the specified binding
    /// - Parameter binding: The binding to remove
    public func unBind(binding: Binding) {
        self.listeners.removeValue(forKey: binding)
    }
}

/// Add multiple bindings at once
extension State {
    
    @discardableResult public func bind<T: AnyBundledKeyPath>(_ keyPaths: [T])->[Binding] {
        keyPaths.map { (kp) in
            self.bind(kp)
        }
    }
    
    @discardableResult public func bind<U>(_ tuples: [(U, ReferenceWritableKeyPath<U, T>)])->[Binding] {
        tuples.map { (arg0) in
            let (obj, kp) = arg0
            return self.bind(obj, kp)
        }
    }
    @discardableResult public func bind<U>(_ tuples: [(U, ReferenceWritableKeyPath<U, T?>)])->[Binding] {
        tuples.map { (arg0) in
            let (obj, kp) = arg0
            return self.bind(obj, kp)
        }
    }
}


/// Call as Function
extension State {
    /// Alias for State.bind(bundledKeyPath)
    /// - Parameter bundledKeyPath: Bundled KP to bind
    /// - Returns: Self
    @discardableResult public func callAsFunction<U: AnyBundledKeyPath>(_ bundledKeyPath:U)->Self {
        self.bind(bundledKeyPath)
        return self
    }
    
    /// Alias for State.bind(obj, keyPath)
    /// - Parameters:
    ///   - obj: Object to bind to
    ///   - keyPath: KeyPath for value on object
    /// - Returns: Self
    @discardableResult public func callAsFunction<U>(_ obj: U, _ keyPath: ReferenceWritableKeyPath<U,T>)->Self {
        self.bind(obj, keyPath)
        return self
    }
    
    
    /// Alias for State.bind(obj, keyPath?)
    /// - Parameters:
    ///   - obj: Object to bind to
    ///   - keyPath: KeyPath for value on object
    /// - Returns: Self
    @discardableResult public func callAsFunction<U>(_ obj: U, _ keyPath: ReferenceWritableKeyPath<U,T?>)->Self {
        self.bind(obj, keyPath)
        return self
    }
    
    /// Calls the given closure when the value is updated
    /// - Parameter cb: Closure to call when
    /// - Returns: Self
    @discardableResult public func callAsFunction(_ cb: @escaping (T)->Void)->Self {
        self.on(cb)
        return self
    }
}
