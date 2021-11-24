//
//  BusMsgModel.swift
//  Takyon360Buzz
//
//  Created by Veena on 18/04/18.
//  Copyright © 2018 Sreeshaj Kp. All rights reserved.
//

import Foundation
struct BusMsgModel : Codable {
        var statusCode : Int?
        var statusMessage : String?
        var eTA : String?
        var inboxMessages : [InboxMessages]?
        var sentMessages : [SentMessages]?
        var map : [Maps]?
        var userLatitude : String?
        var userLongitude : String?
    
    init(status: Int){
        self.statusCode = status
    }
        
        enum CodingKeys: String, CodingKey {
            
            case statusCode = "StatusCode"
            case statusMessage = "StatusMessage"
            case eTA = "ETA"
            case inboxMessages = "InboxMessages"
            case sentMessages = "SentMessages"
            case map = "Map"
            case userLatitude = "UserLatitude"
            case userLongitude = "UserLongitude"
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            statusCode = try values.decodeIfPresent(Int.self, forKey: .statusCode)
            statusMessage = try values.decodeIfPresent(String.self, forKey: .statusMessage)
            eTA = try values.decodeIfPresent(String.self, forKey: .eTA)
            inboxMessages = try values.decodeIfPresent([InboxMessages].self, forKey: .inboxMessages)
            sentMessages = try values.decodeIfPresent([SentMessages].self, forKey: .sentMessages)
            map = try values.decodeIfPresent([Maps].self, forKey: .map)
            userLatitude = try values.decodeIfPresent(String.self, forKey: .userLatitude)
            userLongitude = try values.decodeIfPresent(String.self, forKey: .userLongitude)
        }
        
    }


struct Maps : Codable {
    let brach : String?
    let branchId : String?
    let latitude : String?
    let longitude : String?
    
    enum CodingKeys: String, CodingKey {
        
        case brach = "Brach"
        case branchId = "BranchId"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        brach = try values.decodeIfPresent(String.self, forKey: .brach)
        branchId = try values.decodeIfPresent(String.self, forKey: .branchId)
        latitude = try values.decodeIfPresent(String.self, forKey: .latitude)
        longitude = try values.decodeIfPresent(String.self, forKey: .longitude)
    }
    
}

struct SentMessages : Codable {
    let sent_mess : String?
    
    enum CodingKeys: String, CodingKey {
        
        case sent_mess = "sent_mess"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        sent_mess = try values.decodeIfPresent(String.self, forKey: .sent_mess)
    }
    
}

struct InboxMessages : Codable {
    let inbox_mess : String?
    
    enum CodingKeys: String, CodingKey {
        
        case inbox_mess = "inbox_mess"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        inbox_mess = try values.decodeIfPresent(String.self, forKey: .inbox_mess)
    }
    
}

