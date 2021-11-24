//
//  TNGroupMember.swift
//  Ambassador Education
//
//  Created by    Kp on 27/08/17.
//  Copyright © 2017  . All rights reserved.
//

import Foundation

class TNGroupMember {
    
    var  groupId : Int?
    var groupName : String?
    var id : Int?
    var name : String?//"Farhan Abdul Azeem Azeem (Abdul Arafat Shaikh Farhan
    
    
    init(values:NSDictionary) {
        
        self.id = values["Id"] as? Int
        self.groupId = values["GroupId"] as? Int
        self.groupName = values["GroupName"] as? String
        self.name = values["name"] as? String
    }
    
}
