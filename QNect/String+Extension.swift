//
//  String+Extension.swift
//  QNect
//
//  Created by Panucci, Julian R on 4/14/17.
//  Copyright © 2017 Julian Panucci. All rights reserved.
//

import Foundation

extension String {
    
    var isValidEmail:Bool {
        get {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            return emailTest.evaluate(with: self)
        }
    }
    
    /// A valid password must be between 6 to 15 characters and have one upper case and lowercase letter
    var isValidPassword:Bool {
        get {
            let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{6,15}$"
            let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
            return passwordTest.evaluate(with: self)
        }
    }
    
    func asDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let date = dateFormatter.date(from: self)
        return date
    }
}