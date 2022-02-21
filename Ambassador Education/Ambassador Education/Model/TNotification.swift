//
//  TNotification.swift
//  Ambassador Education
//
//  Created by    Kp on 30/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation
import  UIKit
import WebKit

class TNotification{
    
    var id : String?
    var title : String?
    var details : String?
    var date : String?
    var createdBy : String?
    var hashKey : String?
    var type : String?
    var catid : String?

    
    init(values:NSDictionary) {
        self.id = values["id"] as? String
        self.title = values["Title"] as? String
        self.details = values["details"] as? String
        self.date = values["Date"] as? String
        self.createdBy = values["CreatedBy"] as? String
        self.hashKey = values["HashKey"] as? String
        self.type = values["Type"] as? String
        self.catid = values["cat_id"] as? String
    }
}
