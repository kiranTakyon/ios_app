//
//  TNGroup.swift
//  Ambassador Education
//
//  Created by    Kp on 24/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation

class TNGroup{
    
    var id : String?
    var name : String?
    var recipieType : Int?
    
    
    init(values:NSDictionary) {
        
        if let val = values["GroupId"] as? String{
            self.id = val
        }else if let val = values["id"] as? String{
            self.id = val
        }
        
        if let val = values["GroupName"] as? String{
            self.name = val
            
        }else if let val = values["name"] as? String{
            self.name = val
        }
//        self.id = values["GroupId"]
      //  self.name = values["GroupName"] as? String
    }
    
    func setRecipieValues(type:Int){
        self.recipieType = type
    }
}


class Attachments {
    
    var linkName : String?
    var link : String?
        
        init(values:NSDictionary) {
            
            if let val = values["LinkName"] as? String{
                self.linkName = val
                
            }else{
                self.linkName = ""
            }
            
            if let val = values["Link"] as? String{
                self.link = val
                
            }else {
                self.link = ""
            }
    }
    
}
