//
//  TNGallery.swift
//  Ambassador Education
//
//  Created by    Kp on 25/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation


class TNGallery{
    
    var galleryId : Int?
    var media : String?
    var thumbnail : String?
    var galleryTitle : String?
    var mediaType : String?
    
    
    init(values:NSDictionary) {
        
        self.galleryId = values["GalleryId"] as? Int
        self.media =  values["Media"] as? String
        self.thumbnail =  values["Thumbnail"] as? String
        self.galleryTitle =  values["GalleryTitle"] as? String
        self.mediaType =  values["MediaType"] as? String

    }
}
