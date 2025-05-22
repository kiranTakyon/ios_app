//
//  UITextField+Extension.swift
//  Ambassador Education
//
//  Created by IE14 on 22/05/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import Foundation
import UIKit
import ObjectiveC.runtime

private var activityIndicatorKey: UInt8 = 0

extension UITextField {
    
    private var loadingIndicator: UIActivityIndicatorView? {
        get {
            return objc_getAssociatedObject(self, &activityIndicatorKey) as? UIActivityIndicatorView
        }
        set {
            objc_setAssociatedObject(self, &activityIndicatorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func showLoadingIndicator(color: UIColor = .gray) {
        if loadingIndicator != nil { return } 

        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.color = color
        indicator.startAnimating()
        indicator.frame = CGRect(x: 0, y: 0, width: 20, height: 20)

        let container = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        indicator.center = container.center
        container.addSubview(indicator)

        self.rightView = container
        self.rightViewMode = .always

        self.loadingIndicator = indicator
    }

    /// Hide loading spinner
    func hideLoadingIndicator() {
        self.rightView = nil
        loadingIndicator?.stopAnimating()
        loadingIndicator = nil
    }
}
