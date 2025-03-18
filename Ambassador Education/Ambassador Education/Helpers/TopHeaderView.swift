//
//  TopHeaderView.swift
//  Ambassador Education
//
//  Created by Mayur Shrivas on 11/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import Foundation
import UIKit

protocol TopHeaderDelegate: AnyObject {
    func backButtonClicked(_ button: UIButton)
    func searchButtonClicked(_ button: UIButton)
    func secondRightButtonClicked(_ button: UIButton)
    func thirdRightButtonClicked(_ button: UIButton)
}

protocol ViewControllerWithTopHeader: TopHeaderDelegate where Self: UIViewController {
    associatedtype T
    var topHeader: T! { get set }
}

extension TopHeaderDelegate where Self: UIViewController {
    func backButtonClicked(_ button: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
//    func backButtonClicked(_ button: UIButton) {
//        if let navigationController = navigationController {
//            navigationController.popViewController(animated: true)
//        } else {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
    
    func thirdRightButtonClicked(_ button: UIButton) {
        
    }
}

@IBDesignable
class TopHeaderView: UIView {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondRightButton: UIButton!
    @IBOutlet weak var stackViewRightButtons: UIStackView!
    @IBOutlet weak var thirdRightButton: UIButton!
    @IBOutlet weak var backButtonWidth: NSLayoutConstraint!
    
    // MARK: - Properties
    @IBInspectable
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var height: CGFloat {
        get {
            return viewHeightConstraint.constant
        }
    }
    
    @IBInspectable
    var titleTextColor: UIColor = .white {
        didSet {
            titleLabel.textColor = titleTextColor
        }
    }
    
    @IBInspectable
    var backButtonTintColor: UIColor = .white {
        didSet {
            backButton.tintColor = backButtonTintColor
        }
    }
    
    @IBInspectable
    var shouldShowBackButton: Bool = false {
        didSet {
            backButton.isHidden = !shouldShowBackButton
            backButtonWidth.constant = 0
        }
    }
    
    @IBInspectable
    var shouldShowSecondRightButton: Bool = false {
        didSet {
            secondRightButton.isHidden = !shouldShowSecondRightButton
        }
    }
    
    @IBInspectable
    var shouldShowFirstRightButton: Bool = false {
        didSet {
            searchButton.isHidden = !shouldShowFirstRightButton
        }
    }
    
    @IBInspectable
    var shouldShowRightButtons: Bool = false {
        didSet {
            stackViewRightButtons.isHidden = !shouldShowRightButtons
        }
    }
    
    @IBInspectable
    var shouldShowThirdRightButtons: Bool = false {
        didSet {
            thirdRightButton.isHidden = !shouldShowThirdRightButtons
        }
    }
    
    @IBInspectable
    var setLeftButtonImage: UIImage = UIImage(imageLiteralResourceName: "Back2") {
        didSet {
            backButton.setImage(setLeftButtonImage, for: .normal)
        }
    }
    
    @IBInspectable
    var setFirstRightButtonImage: UIImage = UIImage(imageLiteralResourceName: "Back2") {
        didSet {
            searchButton.setImage(setFirstRightButtonImage, for: .normal)
        }
    }
    
    @IBInspectable
    var setSecondRightButtonImage: UIImage = UIImage(imageLiteralResourceName: "Back2") {
        didSet {
            secondRightButton.setImage(setSecondRightButtonImage, for: .normal)
        }
    }
    
    
    
    @IBInspectable
    var setThirdRightButtonImage: UIImage = UIImage(imageLiteralResourceName: "Back2") {
        didSet {
            thirdRightButton.setImage(setThirdRightButtonImage, for: .normal)
        }
    }
    
    weak var delegate: TopHeaderDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        view = loadViewFromNib()
        viewHeightConstraint.constant = UIDevice.hasNotch ? 88 : 75
        searchTextField.isHidden = true
        backButton.tintColor = .white
        searchButton.tintColor = .white
        secondRightButton.tintColor = .white
        thirdRightButton.isHidden = true
        setBorderAtBottom()
    }
    
    func shouldShowBackButton(_ show: Bool) {
        backButton.isHidden = !show
    }
    
    func shouldShowSecondRightButton(_ show: Bool) {
        secondRightButton.isHidden = !show
    }
    
    func shouldShowFirstRightButtons(_ show: Bool) {
        searchButton.isHidden = !show
    }
    
    func shouldShowRightButtons(_ show: Bool) {
        stackViewRightButtons.isHidden = !show
    }
    
    func shouldShowThirdRightButtons(_ show: Bool) {
        thirdRightButton.isHidden = !show
    }
    
    func setMenuButton(){
        backButton.setImage(UIImage(named: "Menu2"), for: .normal)
    }
    
    func setBorderAtBottom() {
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: searchTextField.frame.size.height - width, width:  searchTextField.frame.size.width, height: searchTextField.frame.size.height)
        
        border.borderWidth = width
        searchTextField.layer.addSublayer(border)
        searchTextField.layer.masksToBounds = true
    }
    
    //MARK: - Actions
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        delegate?.backButtonClicked(sender)
    }
    
    @IBAction func searchButtonAction(_ sender: UIButton) {
        delegate?.searchButtonClicked(sender)
    }
    
    @IBAction func secondRightButtonAction(_ sender: UIButton) {
        delegate?.secondRightButtonClicked(sender)
    }
    
    @IBAction func thirdRightButtonAction(_ sender: UIButton) {
        delegate?.thirdRightButtonClicked(sender)
    }
}

