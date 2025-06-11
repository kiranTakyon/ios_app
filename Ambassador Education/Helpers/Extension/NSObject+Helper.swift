//
//  NSObject+Helper.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 17/06/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    
    static var classAsString : String {
        return String(describing: self)
    }
    
    public var className: String {
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}
