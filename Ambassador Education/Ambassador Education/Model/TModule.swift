//
//  TModule.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 24/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation
import  UIKit
import WebKit

class TModule {
    
    var module : String?
    var data_count : String?

    init(values:NSDictionary) {
        self.module = values["module"] as? String
        self.data_count = values["data_count"] as? String

    }
}
