//
//  CalendarSection.swift
//  Ambassador Education
//
//  Created by Sreeshaj  on 13/04/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit

class CalendarSection: UIView {

    @IBOutlet var containerView: UIView!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViewForXib()
          }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupViewForXib()
        
    }
    func loadFromNib() ->UIView{
        let bundle = Bundle(for: self.classForCoder)//NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "CalendarSection", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        //        view.backgroundColor = UIColor.red
        return view
    }
    
    func setupViewForXib(){
        containerView = loadFromNib()
        containerView.frame = bounds
        containerView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(containerView)
        
    }

    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
