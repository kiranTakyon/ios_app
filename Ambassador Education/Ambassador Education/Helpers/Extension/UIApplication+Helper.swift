//
//  UIApplication+Helper.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 30/06/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation
import UIKit


extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}
