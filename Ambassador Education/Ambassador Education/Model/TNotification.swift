//
//  TNotification.swift
//  Ambassador Education
//
//  Created by    Kp on 30/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation
import  UIKit
import WebKit

class TNotification: Codable {
    
    var id : String?
    var title : String?
    var details : String?
    var date : String?
    var createdBy : String?
    var hashKey : String?
    var type : String?
    var catid : String?
    var processid : String?
    var usrReactionType: String?
    var reactions: TReaction?
    var alertId: Int?
    var url: String?

    init(values:NSDictionary) {
        self.id = values["id"] as? String
        self.title = values["Title"] as? String
        self.details = values["details"] as? String
        self.date = values["Date"] as? String
        self.createdBy = values["CreatedBy"] as? String
        self.hashKey = values["HashKey"] as? String
        self.type = values["Type"] as? String
        self.catid = values["cat_id"] as? String
        self.processid = values["id"] as? String
        self.usrReactionType = values["usr_reaction_type"] as? String
        self.url = values["url"] as? String
        self.alertId = values["alert_id"] as? Int

        if let itemVals = values["reactions"] as? NSDictionary {
            self.reactions = TReaction(values: itemVals)
        }
    }

    func changeUserReactionType(type: String) {
        if let usrReactionType = usrReactionType, usrReactionType.isEmpty {
            reactions?.increaseReactionCount(type: type)
        } else if type != usrReactionType {
            reactions?.decreaseReactionCount(type: usrReactionType ?? "")
            reactions?.increaseReactionCount(type: type)
        }
        self.usrReactionType = type
    }
}
