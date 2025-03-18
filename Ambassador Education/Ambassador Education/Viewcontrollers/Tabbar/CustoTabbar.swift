//
//  CustoTabbar.swift
//  CredenceSchool
//
//  Created by IE14 on 18/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import Foundation

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let items = tabBar.items, items.indices.contains(1) {
            let secondTabBarItem = items[1]
            secondTabBarItem.image = secondTabBarItem.image?.withRenderingMode(.alwaysOriginal)
        }
    }
    
}
