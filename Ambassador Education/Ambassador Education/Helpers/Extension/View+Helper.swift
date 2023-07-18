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



extension UIView {
    
    /// A property that accesses the backing layer's opacity.
    @IBInspectable
    open var opacity: Float {
        get {
            return layer.opacity
        }
        set(value) {
            layer.opacity = value
        }
    }
    
    /// A property that accesses the backing layer's shadow
    @IBInspectable
    open var viewshadowColor: UIColor? {
        get {
            guard let v = layer.shadowColor else {
                return nil
            }
            
            return UIColor(cgColor: v)
        }
        set(value) {
            layer.shadowColor = value?.cgColor
        }
    }
    
    /// A property that accesses the backing layer's shadowOffset.
    @IBInspectable
    open var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set(value) {
            layer.shadowOffset = value
        }
    }
    
    /// A property that accesses the backing layer's shadowOpacity.
    @IBInspectable
    open var viewshadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set(value) {
            layer.shadowOpacity = value
        }
    }
    
    /// A property that accesses the backing layer's shadowRadius.
    @IBInspectable
    open var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set(value) {
            layer.shadowRadius = value
        }
    }
    
    /// A property that accesses the backing layer's shadowPath.
    @IBInspectable
    open var shadowPath: CGPath? {
        get {
            return layer.shadowPath
        }
        set(value) {
            layer.shadowPath = value
        }
    }
    
    
    /// A property that accesses the layer.cornerRadius.
    @IBInspectable
    open var viewcornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set(value) {
            layer.cornerRadius = value
        }
    }
    
    
    /// A property that accesses the layer.borderWith.
    @IBInspectable
    open var viewborderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set(value) {
            layer.borderWidth = value
        }
    }
    
    /// A property that accesses the layer.borderColor property.
    @IBInspectable
    open var viewBorderColor: UIColor? {
        get {
            guard let bcolor = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: bcolor)
        }
        set(value) {
            layer.borderColor = value?.cgColor
        }
    }
}
