//
//  ProgressViewBar.swift
//  LightHouse
//
//  Created by Veena on 31/05/18.
//  Copyright © 2018 InApp Information Technologies. All rights reserved.
//

import UIKit

class ProgressViewBar: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var progressMainView: UIView!
    @IBOutlet weak var progressSecondView: UIView!
    @IBOutlet weak var progressTitleField: UILabel!
    @IBOutlet weak var progressBar: LinearProgressView!
    
    var titleText : String = ""{
        didSet{
            progressTitleField.text = titleText
        }
    }
    var progressValue : Float = 0.0{
        didSet{
              progressBar.setProgress(progressValue, animated: true)
        }
    }
  
    var isHide : Bool = false{
        didSet{
            progressBar.isHidden = isHide
        }
    }
    
    func setProgressViewBorderColor(){
        progressSecondView.layer.borderWidth = 0.6
        progressSecondView.layer.borderColor = UIColor.red.cgColor
    }

    func setProgressBar(){
        setProgressViewBorderColor()
        progressBar.animationDuration = 0.5
        progressBar.isCornersRounded = true
        progressBar.trackColor = UIColor.red
        progressBar.barColor = UIColor.white
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewForXib()
        setProgressBar()

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewForXib()
        setProgressBar()

    }

    
    //MARK:- Loading navigation bar from nib
     func loadFromNib() -> UIView{
        let nib = UINib(nibName: "ProgressViewBar", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
    
    func setupViewForXib(){
        containerView = loadFromNib()
        containerView.frame = bounds
        containerView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        self.clipsToBounds = true
        addSubview(containerView)
    }

    
    
}
