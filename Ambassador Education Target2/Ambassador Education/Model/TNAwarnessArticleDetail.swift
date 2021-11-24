//
//  TNAwarnessArticleDetail.swift
//  Ambassador Education
//
//  Created by Veena on 26/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import Foundation

class TNAwarnessArticleDetail{
    var id : String?
    var category : String?
    var articleCount : Int?
    var parentId : Int?
 
    init(values:NSDictionary) {
        
        
        self.id = values["CategoryId"] as? String
        self.category = values["Category"] as? String
        self.articleCount = values["ArticleCount"] as? Int
        self.parentId = values["PrentId"] as? Int
    
    }
}
