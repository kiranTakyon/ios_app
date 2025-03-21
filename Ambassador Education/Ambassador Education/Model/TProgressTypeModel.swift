//
//  TProgressTypeMode.swift
//  Ambassador Education
//
//  Created by IE14 on 26/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import Foundation

struct TProgressTypeModel: Codable {
    let statusCode: Int?
    let statusMessage, userID: String?
    let fuelPercentage: Int?
    let journeyPercentage: Int?
    let challengesPercentage: Int?
    let quizPercentage: Int?
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "StatusCode"
        case statusMessage = "StatusMessage"
        case userID = "user_id"
        case fuelPercentage = "fuel_percentage"
        case journeyPercentage = "journey_percentage"
        case challengesPercentage = "challenges_percentage"
        case quizPercentage = "quiz_percentage"
    }
    
    init(values:NSDictionary) {
        self.statusCode = values["StatusCode"] as? Int
        self.statusMessage = values["StatusMessage"] as? String
        self.userID = values["user_id"] as? String
        self.fuelPercentage = values["fuel_percentage"] as? Int
        self.journeyPercentage = values["journey_percentage"] as? Int
        self.challengesPercentage = values["challenges_percentage"] as? Int
        self.quizPercentage = values["quiz_percentage"] as? Int
    }
}
