//
//  MenuItem.swift
//  Ambassador Education
//
//  Created by "" Kp on 15/09/17.
//  Copyright © 2017 "". All rights reserved.
//

import Foundation


class TNMenuItem{
    
    var label : String?
    var menuOrder : String?
    var id : String?
    var link : String?
    var parentid : String?
    var hashKey : String?
    var external : String?
    
    
    init(values:NSDictionary) {
        
        self.label = values["Label"] as? String
        self.menuOrder = values["MenuOrder"] as? String
        self.id = values["id"] as? String
        self.external = values["External"] as? String
        self.link = values["Link"] as? String
        self.parentid = values["ParentId"] as? String
        self.hashKey = values["HashKey"] as? String

    }
}


