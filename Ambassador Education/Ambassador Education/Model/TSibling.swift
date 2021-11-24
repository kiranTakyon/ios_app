//
//  TSibling.swift
//  Ambassador Education
//
//  Created by    Kp on 30/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation


class TSibling{
    
    var studendtId : String?
    var studentName : String?
    var proileImage : String?
    var classValue : String?
    var userId : String?
    var logInUserName : String?
    var logInPasword : String?
    
    
    init(values:NSDictionary) {
        
        self.studendtId = values["studentID"] as? String
        self.studentName = values["studentName"] as? String
        self.proileImage = values["ProfileImage"] as? String
        self.classValue = values["Class"] as? String
        self.userId = values["UserId"] as? String
        self.logInUserName = values["login_username"] as? String
        self.logInPasword = values["login_password"] as? String

    }
    
}
