//
//  Storyboard.swift
//  Ambassador Education
//
//  Created by IE14 on 17/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import Foundation

enum StoryboardName: String {
    case video                   = "Video"
    case UpComingEvent           = "UpComingEvent"
    case tabbar                  = "Tabbar"
    case common                  = "Common"
    case home                    = "Home"
    case noticeboard             = "Noticeboard"
    case gallery                 = "Gallery"
    case communicateLand         = "CommunicateLand"
    case weeklyPlan              = "WeeklyPlan"
    case awareness               = "Awareness"
    case digitalResource         = "DigitalResource"
    case grade                   = "Grade"
    case paymentDetails          = "PaymentDetails"
    case calendar                = "Calendar"
    case myProfile               = "MyProfile"
    case main                    = "Main"
}

extension UIViewController {
    static func instantiate(from storyboard: StoryboardName) -> Self {
        return UIStoryboard(name: storyboard.rawValue, bundle: nil).instantiateViewController(withIdentifier: String(describing:self)) as! Self
    }

    static func instantiateInitialController(from storyboard: StoryboardName) -> Self {
        return UIStoryboard(name: storyboard.rawValue, bundle: nil).instantiateInitialViewController() as! Self
    }
}
