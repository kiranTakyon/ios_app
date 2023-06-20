//
//  UIDevice+Helper.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 16/06/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    
    public static var is4inches: Bool {
        return UIScreen.main.bounds.width == 320
    }
    
    public static var isZoomed: Bool {
       return UIScreen.main.nativeScale > UIScreen.main.scale
   }
    
    /// Returns `true` if the device has a notch
    public static var hasNotch: Bool {
        guard #available(iOS 11.0, *), let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else { return false }
        if UIDevice.current.orientation.isLandscape {
            return window.safeAreaInsets.left > 0 || window.safeAreaInsets.right > 0
        } else {
            return window.safeAreaInsets.top >= 44
        }
    }
}
