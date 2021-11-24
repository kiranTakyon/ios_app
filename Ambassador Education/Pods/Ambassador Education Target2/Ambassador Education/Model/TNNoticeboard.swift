//
//  TNNoticeboard.swift
//  Ambassador Education
//
//  Created by // Kp on 29/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation


class TNNoticeboardCategory {
    
    var id : Int?
    var category : String?
    var parentId : Int?
    var Items : [TNNoticeBoardDetail]?
    
    
    init(values:NSDictionary) {
        
        self.id = values["id"] as? Int
        self.category = values["Category"] as? String
        self.parentId = values["ParentId"] as? Int
        
        if let itemVals = values["Items"] as? NSArray{
            
            var itemObjs = [TNNoticeBoardDetail]()
            
            for itemVal in itemVals{
                itemObjs.append(TNNoticeBoardDetail(values: itemVal as! NSDictionary))
            }
            
            self.Items = itemObjs
        }

    }
}
