//
//  UIViewController+Helper.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 17/06/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation
import UIKit


extension UIViewController {
       
    func topBarHeight() -> CGFloat {
        let application = UIApplication.shared
        let safeAreaInset = application.keyWindow?.safeAreaInsets
        var topLayoutGuide: CGFloat = application.isStatusBarHidden ? 0.0 : safeAreaInset?.top ?? 0.0
        if self.navigationController?.navigationBar.isTranslucent != false {
            if let nav = self.navigationController {
                topLayoutGuide += nav.navigationBar.frame.size.height
            }
        }
        return topLayoutGuide
    }
    
}



