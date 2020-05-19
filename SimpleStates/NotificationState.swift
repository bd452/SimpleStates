//
//  NotificationState.swift
//  HookSwift
//
//  Created by Bryce Dougherty on 5/18/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import Foundation


public class NotificationState<T>: State<T> {
    
    var observer: Any!
    
    public init(_ notification: NSNotification.Name, default defaultValue: T, mutator: @escaping (Notification)->T) {
        super.init(defaultValue)
        self.observer = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: .main) { notif in
            super.set(mutator(notif))
        }
    }
    public init(_ notification: NSNotification.Name, getter: @autoclosure @escaping ()->T) {
        let defaultValue = getter()
        super.init(defaultValue)
        self.observer = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: .main) { _ in
            super.set(getter())
        }
    }
    
    @available (*, unavailable, message: "Can't change the value of a NotificationState")
    public override func set(_ newValue: T) {
        super.set(newValue)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self.observer!)
    }
    
}
