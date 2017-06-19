//
//  OKAlertGenerator.swift
//  OnTheMap
//
//  Created by VICTOR ASSELTA on 2/4/17.
//  Copyright © 2017 TomTheToad. All rights reserved.
//

import UIKit

// Class created to streamline the configuration of basic alerts.
// More complex alerts were left as is.
class OKAlertGenerator {
    
    // fields
    var title = "Error"
    var message: String
    var buttonOneText = "ok"
    var handler: ((UIAlertAction) -> Void)? = nil
    
    
    // class init
    // Takes an alert message
    init(alertMessage: String) {
        message = alertMessage
    }
    
    // Returns an alert configured with given fields
    func getAlertToPresent() -> UIAlertController {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: handler)
        
        alert.addAction(alertAction)
        
        return alert
    }
    
}
