//
//  UIButton+Helper.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 17/06/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {

    func setImage(image: UIImage?, inSize size: CGSize?, forState state: UIControl.State){
        self.setImage(image, for: state)

        if let size = size {
            self.imageEdgeInsets = UIEdgeInsets(
                top: (self.frame.height - size.height) / 2,
                left: (self.frame.width - size.width) / 2,
                bottom: (self.frame.height - size.height) / 2,
                right: (self.frame.width - size.width) / 2
            )
        }
    }

}
