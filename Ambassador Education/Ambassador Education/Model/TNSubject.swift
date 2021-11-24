//
//  TNSubject.swift
//  Ambassador Education
//
//  Created by Takyon Systems on 14/03/20.
//  Copyright © 2020 InApp. All rights reserved.
//

import Foundation
class TNSubject
{
    var subject_id : String?
    var subject_name : String?
    
    
    init(values:NSDictionary) {
        
        self.subject_id = values["subject_id"] as? String
        self.subject_name = values["subject_name"] as? String
        
    }
    
}
