//
//  ViewController.swift
//  StatefulTests
//
//  Created by Bryce Dougherty on 5/13/20.
//  Copyright © 2020 Bryce Dougherty. All rights reserved.
//

import UIKit
import SimpleStates

class ViewController: UIViewController {
    
    /// Create a new state for our labels
    let labelState = State("Initial Label")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let theLabel = UILabel(frame: CGRect(x: 0,y: 50,width: 200,height: 50))
        let theOtherLabel = UILabel(frame: CGRect(x: 0,y: 100,width: 200,height: 50))
        let theThirdLabel = UILabel(frame: CGRect(x: 0,y: 150,width: 200,height: 50))
        let theFourthLabel = UILabel(frame: CGRect(x: 0,y: 200,width: 200,height: 50))
        
        self.view.addSubview(theLabel)
        self.view.addSubview(theOtherLabel)
        self.view.addSubview(theThirdLabel)
        self.view.addSubview(theFourthLabel)
        
        /// Create binding with an object and KeyPath
        labelState.bind(theLabel, \.text)
        
        /// Create a binding with a BundledKeyPath
        theOtherLabel..\.text <-> labelState

        /// Create a custom binding with a closure, and save the binding so we can remove it later
        let thirdLabelBinding = labelState.on { val in
            let newValue = val + "test123"
            theThirdLabel.text = newValue
        }
        
        /// Create a new state for our 4th label, and bind it immediately
        /// Can also be written as `bindState(theFourthLabel..\.text, "4thLabel)`
        let fourthLabelState = State("4thLabel")(theFourthLabel..\.text)
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
            self?.labelState.set("second")
            fourthLabelState.set("4th label second value")
            self?.labelState.unBind(binding: thirdLabelBinding)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {[weak self] in
            self?.labelState.set("endingLabel")
            fourthLabelState.set("4th label 3rd value")
        }
    }


}

