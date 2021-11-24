//
//  TNGalleryCategory.swift
//  Ambassador Education
//
//  Created by    Kp on 25/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation


class GalleryItems{
    var categoryLabel : String?
    var headLabel : String?
    var statusCode : Int?
    var viewMore : String?
    
    init(values: NSDictionary) {
        self.categoryLabel = values["CategoryLabel"] as? String
        self.headLabel = values["HeadLabel"] as? String
        self.statusCode = values["StatusCode"] as? Int
        self.viewMore = values["ViewMoreLabel"] as? String
    }
}

class TNGalleryCategory{
    
    var categoryId: String?
    var category: String?
    var parentId: Int?
    var thumbnail : String?
    
    
    init(values:NSDictionary) {
        
        self.categoryId = values["CategoryId"] as? String
        self.category = values["Category"] as? String
//        self.categoryId = values["CategoryId"] as? Int
        self.thumbnail = values["Thumbnail"] as? String
        
    }
    
}
