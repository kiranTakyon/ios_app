//
//  jsonKeys.swift
//  Ambassador Education
//
//     on 05/05/17.
//   . All rights reserved.
//

import Foundation

struct LogInKeys{
    
    let username = "UserName"
    let password = "Password"
    let language = "Language"
    let platform = "Platform"
    let Package = "Package"
}

struct UserIdKey {
    
    let id = "UserId"
    let name = "Name"
    let contact = "Contact"
    let contactNumber = "ContactNumber"
    let email = "EmailID"
    let profileImage = "ProfileImage"
    let profileName = "name"
    let profileMime = "mime"
    let profilePostName = "postname"
    let markType = "MarkType"
    let msgId = "MsgIds"
    let msgType = "MsgType"
}

struct DetailsKeys{
    
    let itemId = "Id"
 }
struct DetailsKeys2{
    
    let itemId = "item_id"
 }

struct LocationUpdate {
    
    let latitude = "Latitude"
    let longitude = "Longitude"
}


struct Communicate{
    
    let searchText = "SearchText"
    let paginationNumber = "PaginationNumber"
    let messageId = "MsgId"
    let groupId = "grp_id"
    let isMobile = "IsMobile"
    let ModuleCode = "ModuleCode"
}

struct GetGroups{
    
    let searchtext = "SearchText"
    
}

struct EmailVerifications{
    let getEmailVCode = "VEmail"
    let verificationKey = "Key"
}

class JsonKeys{
    
    let message = "MSG"
    let status = "status"
    
}

class WeeklyPlanKeys{
    
    let Div_Id = "Div_Id"
    let Sub_Id = "Sub_Id"
    let IsLatest = "IsLatest"
    let FromDate = "FromDate"
    let ToDate = "ToDate"
    let type = "Type"
    let OffSet = "OffSet"
    let Limit = "Limit"
    
    
}

class PasswordChange{
    
    static let currentPassword = "CurrentPassword"
    static let newPassword = "NewPassword"
    static let repeatPassword = "ReapeatNewPassword"
    static let client_ip = "client_ip"
    
}

class PasswordReset{
    
    static let newPassword = "NewPassword"
    static let email = "VEmail"
    static let key = "Key"
    
}


class GalleryCategory{
    
    static let searchText = "SearchText"
    static let paginationNumber = "PaginationNumber"
    static let categoryId = "CategoryId"
}


//{"UserId":"98189","CurrentPassword":"123456","NewPassword":"6789","ReapeatNewPassword":"6789"}


//MARK:- UserDefaults Keys


struct UserDefaultKeys{
    
    let userDetails = "UserDetails"
    let AccessToken = "AccessToken"
}
