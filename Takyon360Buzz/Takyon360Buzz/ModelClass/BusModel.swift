//
//  BusModel.swift
//  Takyon360Buzz
//
//  Created by Veena on 18/04/18.
//  Copyright © 2018 Sreeshaj Kp. All rights reserved.
//

import Foundation

import Foundation
struct BusModel : Codable {
    var statusCode : Int?
    var statusMessage : String?
    var messages : [Messages]?
    var headLabel : String?
    var messageToBusLabel : String?
    var messageFromBusLabel : String?
    var messageToDriverLabel : String?
    var pickupDropLabel : String?
    var distanceLabel : String?
    var eTALabel : String?
    var map : [Map]?
    var trip_id : String?
    var staff_id : String?
    
    init(status : Int){
        self.statusCode = status
    }
    
    enum CodingKeys: String, CodingKey {
        
        case statusCode = "StatusCode"
        case statusMessage = "StatusMessage"
        case messages = "Messages"
        case headLabel = "HeadLabel"
        case messageToBusLabel = "MessageToBusLabel"
        case messageFromBusLabel = "MessageFromBusLabel"
        case messageToDriverLabel = "MessageToDriverLabel"
        case pickupDropLabel = "PickupDropLabel"
        case distanceLabel = "DistanceLabel"
        case eTALabel = "ETALabel"
        case map = "Map"
        case trip_id = "trip_id"
        case staff_id = "staff_id"
    }
    
   
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        statusCode = try values.decodeIfPresent(Int.self, forKey: .statusCode)
        statusMessage = try values.decodeIfPresent(String.self, forKey: .statusMessage)
        messages = try values.decodeIfPresent([Messages].self, forKey: .messages)
        headLabel = try values.decodeIfPresent(String.self, forKey: .headLabel)
        messageToBusLabel = try values.decodeIfPresent(String.self, forKey: .messageToBusLabel)
        messageFromBusLabel = try values.decodeIfPresent(String.self, forKey: .messageFromBusLabel)
        messageToDriverLabel = try values.decodeIfPresent(String.self, forKey: .messageToDriverLabel)
        pickupDropLabel = try values.decodeIfPresent(String.self, forKey: .pickupDropLabel)
        distanceLabel = try values.decodeIfPresent(String.self, forKey: .distanceLabel)
        eTALabel = try values.decodeIfPresent(String.self, forKey: .eTALabel)
        map = try values.decodeIfPresent([Map].self, forKey: .map)
        trip_id = try values.decodeIfPresent(String.self, forKey: .trip_id)
        staff_id = try values.decodeIfPresent(String.self, forKey: .staff_id)
    }
    
}

struct Map : Codable {
    let brach : String?
    let branchId : String?
    
    enum CodingKeys: String, CodingKey {
        
        case brach = "Brach"
        case branchId = "BranchId"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        brach = try values.decodeIfPresent(String.self, forKey: .brach)
        branchId = try values.decodeIfPresent(String.self, forKey: .branchId)
    }
    
}

