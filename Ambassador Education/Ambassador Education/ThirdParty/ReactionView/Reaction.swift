//
//  Reaction.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 29/07/24.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation


public class Reaction {
    public var title:String!
    public var imageName:String!
    public var tag: Int?
    
    public init(title: String, imageName: String) {
        self.title = title
        self.imageName = imageName
    }
}

