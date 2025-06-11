//
//  TNAwarenessDetail.swift
//  Ambassador Education
//
//  Created by Veena on 27/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import Foundation
class TNAwarenessDetail{
    var id : Int?
    var name : String?
    var description : String?
    var image : String?
    var mediaType : String?
    var date : String?
    
    init(values:NSDictionary) {
        
        
        self.id = values["ArticleId"] as? Int
        self.name = values["ArticleName"] as? String
        self.description = values["ArticleDescription"] as? String
        self.image = values["Articleimage"] as? String
        self.mediaType = values["MediaType"] as? String
        self.date = values["ArticleDate"] as? String

    }
}
