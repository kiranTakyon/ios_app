//
//  TNDigitalResource.swift
//  Ambassador Education
//
//  Created by // Kp on 29/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation


class TNDigitalResourceCategory{
    
    var categoryId : String?
    var caetgory : String?
    var categoryCount : Int?
    var parentId : Int?
    
    
    init(values:NSDictionary) {
        
        self.categoryId = values["CategoryId"]  as? String
        self.caetgory = values["Category"] as? String

        self.categoryCount = values["CategoryCount"] as? Int
        self.parentId = values["ParentId"] as? Int

    }
}

class TNDigitalResourceSubList{
    
    var id : Int?
    var title : String?
    var content : String?
    var contentType : String?
    var attacthIcon : Int?
    var attachment : String?
    var docLinks : [String]?
    var attachments : [Attachment]?
    var date : String?
    
    
    init(values:NSDictionary) {
        
        self.id = values["Id"] as? Int
        self.title = values["Title"] as? String
        self.content = values["Content"] as? String
        self.contentType = values["ContentType"] as? String
        self.attacthIcon = values["AttachIcon"] as? Int
        self.attachment = values["Attachment"] as? String
        self.docLinks = values["DocLinks"] as? [String]
        
        if let attachmentValues = values["MultipleAttachment"] as? NSArray{
            var attachment = [Attachment]()
            if attachmentValues.count > 0{
                for each in attachmentValues{
                    attachment.append(Attachment(values: (each as? NSDictionary)!))
                }
                self.attachments = attachment
            }
            
        }
        self.date = values["Date"] as? String


    }
}
