//
//  TNCalendarEvent.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 11/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import Foundation

class TNCalendarEvent{
    
    var id : Int?
    var startDate : String?
    var endDate : String?
    var text : String?
    var details : String?
    
    
    init(values:NSDictionary) {
        
        
        self.id = values["id"] as? Int
        self.startDate = values["start_date"] as? String
        self.endDate = values["end_date"] as? String
        self.text = values["Text"] as? String
        self.details = values["Details"] as? String

    }
}
