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
    
    public init(notification: NSNotification.Name, defaultValue: T, mutator: @escaping (Notification)->T) {
        super.init(defaultValue)
        self.observer = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: .main) { notif in
            super.set(mutator(notif))
        }
    }
    
    @available (*, unavailable)
    public override func set(_ newValue: T) {
        super.set(newValue)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self.observer!)
    }
    
}
