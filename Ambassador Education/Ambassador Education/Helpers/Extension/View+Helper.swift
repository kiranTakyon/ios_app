//
//  View+Helper.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 16/06/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation
import UIKit


extension UIView {
    
    func loadViewFromNib() -> UIView? {
        let bundle = Bundle(for: self.classForCoder)
        let nib = UINib(nibName: "TopHeaderView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]))
        return view
    }
}
