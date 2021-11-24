//
//  TNNoticeBoardDetail.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 11/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import Foundation

class TNNoticeBoardDetail{
    
    var id : String?
    var title : String?
    var shortDesc : String?

    var description : String?
    var date : String?
    var image : String?
    var thumbnail : String?
    var readStatus : String?
    init(values:NSDictionary) {
        
        
        self.id = values["Id"] as? String
        self.title = values["Title"] as? String
        self.shortDesc = values["ShortDesc"] as? String

        self.date = values["Date"] as? String
        self.image = values["Image"] as? String
        self.thumbnail = values["thumbnail"] as? String
        self.readStatus = values["ReadStatus"] as? String
        self.description = values["Description"] as? String

        
    }

}
