//
//  TNPerson.swift
//  Ambassador Education
//
//  Copyright © 2017 //. All rights reserved.
//

import Foundation


class TNPerson{
    
    var id : String?
    var groupId : String?
    var name : String?
    var groupName : String?
    var recipieType : Int?
    
    
    
    init(values:NSDictionary) {
        
        if let val = values["UserId"] as? String{
            self.id = val
        
        }else if let val = values["id"] as? String{
            self.id = val
        }
        
        
        if let val = values["name"] as? String{
            self.name = val
            
        }else if let val = values["Name"] as? String{
            self.name = val
        }

        
        self.groupId = values["GroupId"] as? String
        
        self.recipieType = Int((values["RecipientType"] as? String).safeValue)
        self.groupName = values["GroupName"] as? String
    }
    
    
    func setRecipieValues(type:Int){
        self.recipieType = type
    }
}
