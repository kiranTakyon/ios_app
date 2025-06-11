//
//  TMyProfile.swift
//  Ambassador Education
//
//  Created by    Kp on 30/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation


class TMyProfile{
    
    var nameLabel: String?
    var usernameLabel : String?
    var contactLabel : String?
    var contactnameLabel : String?
    var emaillabel : String?
    var myLocaionLabel : String?
    var profileLabel: String?
    var changePasswordLabel: String?
    var EditAccountLabel: String?
    var SetMyLocationLabel: String?
    var myColleaguesLabel: String?
    var saveLabel: String?
    var currentPasswordLabel: String?
    var newPasswordLabel: String?
    var reapeatNewPasswordLabel: String?
    var parentCodeLabel: String?
    var name: String?
    var userName: String?
    var contact: String?
    var contactNumber: String?
    var emailID: String?
    var profileImage: String?
    var latitude: String?
    var longitude: String?
    var userType : String?
    var isEmailVerified: String?
    var parentCode: String?
    var EnableChangePassword: Int?
    
    init(values:NSDictionary) {
        self.isEmailVerified = values["VerifiedEmailLabel"] as? String
        self.name = values["Name"] as? String
        self.userName = values["UserName"] as? String
        self.contact = values["Contact"] as? String
        self.contactNumber = values["ContactNumber"] as? String
        self.emailID = values["EmailID"] as? String
        self.profileImage = values["ProfileImage"] as? String
        self.latitude = values["Latitude"] as? String
        self.longitude = values["Longitude"] as? String
        self.userType = values["UserType"] as? String
        self.parentCode = values["parent_code"] as? String
        self.EnableChangePassword = values["EnableChangePassword"] as? Int
    }
}
