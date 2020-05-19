//
//  ViewController.swift
//  StatefulTests
//
//  Created by Bryce Dougherty on 5/13/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import UIKit
import SimpleStates

class observed: NSObject {
    @objc dynamic var status: String = "hello"
}

class ViewController: UIViewController {
    
    /// Create a new state for our labels
    let labelState = State("Initial Label")

    let orientationState = NotificationState(UIDevice.orientationDidChangeNotification, getter: UIDevice.current.orientation)
    
    let obs = observed()
    var orientationKVO: MutableKVOState<observed, String>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let theLabel = UILabel(frame: CGRect(x: 0,y: 50,width: 200,height: 50))
        let orientationLabel = UILabel(frame: CGRect(x: 0,y: 100,width: 200,height: 50))
        let KVOLabel = UILabel(frame: CGRect(x: 0,y: 150,width: 200,height: 50))
        
        self.view.addSubview(theLabel)
        self.view.addSubview(orientationLabel)
        self.view.addSubview(KVOLabel)
        
        /// Create binding with an object and KeyPath
        theLabel..\.text <-> labelState

        orientationState.on { (orientation) in
            orientationLabel.text = "the device is " + (orientation.isPortrait ? "" : "not") + "portrait"
        }
        
        self.orientationKVO = MutableKVOState(obj: obs, keyPath: \.status)
//        self.orientationKVO?.bind(KVOLabel..\.text)
        KVOLabel..\.text <-> self.orientationKVO!
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            self?.orientationKVO?.setValue("world")
            self?.labelState.set("second")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[weak self] in
            self?.orientationKVO?.setValue("world v2")
            self?.labelState.set("endingLabel")
        }
    }


}

