//
//  DOAlertController.swift
//  DOAlertController
//
//  Created by Daiki Okumura on 2015/06/14.
//  Copyright (c) 2015 Daiki Okumura. All rights reserved.
//
//  This software is released under the MIT License.
//  http://opensource.org/licenses/mit-license.php
//

import Foundation
//import UIKit
import WebKit

let DOAlertActionEnabledDidChangeNotification = "DOAlertActionEnabledDidChangeNotification"

enum DOAlertActionStyle : Int {
    case `default`
    case cancel
    case destructive
}

enum DOAlertControllerStyle : Int {
    case actionSheet
    case alert
}

// MARK: DOAlertAction Class

class DOAlertAction : NSObject, NSCopying {
    var title: String
    var style: DOAlertActionStyle
    var handler: ((DOAlertAction?) -> Void)!
    var enabled: Bool {
        didSet {
            if (oldValue != enabled) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: DOAlertActionEnabledDidChangeNotification), object: nil)
            }
        }
    }
    
    required init(title: String, style: DOAlertActionStyle, handler: ((DOAlertAction?) -> Void)!) {
        self.title = title
        self.style = style
        self.handler = handler
        self.enabled = true
    }
    
    func copy(with zone: NSZone?) -> Any {
        let copy = type(of: self).init(title: title, style: style, handler: handler)
        copy.enabled = self.enabled
        return copy
    }
}

// MARK: DOAlertAnimation Class

class DOAlertAnimation : NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresenting: Bool
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if (isPresenting) {
            return 0.45
        } else {
            return 0.25
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if (isPresenting) {
            self.presentAnimateTransition(transitionContext)
        } else {
            self.dismissAnimateTransition(transitionContext)
        }
    }
    
    func presentAnimateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let alertController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! DOAlertController
        let containerView = transitionContext.containerView
        
        alertController.overlayView.alpha = 0.0
        if (alertController.isAlert()) {
            alertController.alertView.alpha = 0.0
            alertController.alertView.center = alertController.view.center
            alertController.alertView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } else {
            alertController.alertView.transform = CGAffineTransform(translationX: 0, y: alertController.alertView.frame.height)
        }
        containerView.addSubview(alertController.view)
        
        UIView.animate(withDuration: 0.25,
                                   animations: {
                                    alertController.overlayView.alpha = 1.0
                                    if (alertController.isAlert()) {
                                        alertController.alertView.alpha = 1.0
                                        alertController.alertView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                                    } else {
                                        let bounce = alertController.alertView.frame.height / 480 * 10.0 + 10.0
                                        alertController.alertView.transform = CGAffineTransform(translationX: 0, y: -bounce)
                                    }
            },
                                   completion: { finished in
                                    UIView.animate(withDuration: 0.2,
                                        animations: {
                                            alertController.alertView.transform = CGAffineTransform.identity
                                        },
                                        completion: { finished in
                                            if (finished) {
                                                transitionContext.completeTransition(true)
                                            }
                                    })
        })
    }
    
    func dismissAnimateTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let alertController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! DOAlertController
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                                   animations: {
                                    alertController.overlayView.alpha = 0.0
                                    if (alertController.isAlert()) {
                                        alertController.alertView.alpha = 0.0
                                        alertController.alertView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                                    } else {
                                        alertController.containerView.transform = CGAffineTransform(translationX: 0, y: alertController.alertView.frame.height)
                                    }
            },
                                   completion: { finished in
                                    transitionContext.completeTransition(true)
        })
    }
}

// MARK: DOAlertController Class

class DOAlertController : UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {
    
    // Message
    var message: String?
    
    // AlertController Style
    fileprivate(set) var preferredStyle: DOAlertControllerStyle?
    
    // OverlayView
    fileprivate var overlayView = UIView()
    var overlayColor = UIColor(red:0, green:0, blue:0, alpha:0.5)
    
    // ContainerView
    fileprivate var containerView = UIView()
    fileprivate var containerViewBottomSpaceConstraint: NSLayoutConstraint!
    
    // AlertView
    fileprivate var alertView = UIView()
    var alertViewBgColor = UIColor.appOrangeColor()  // AlertView Background color
    fileprivate var alertViewWidth: CGFloat = 270.0
    fileprivate var alertViewHeightConstraint: NSLayoutConstraint!
    fileprivate var alertViewPadding: CGFloat = 15.0
    fileprivate var innerContentWidth: CGFloat = 240.0
    fileprivate let actionSheetBounceHeight: CGFloat = 20.0
    
    
    // TextAreaScrollView
    fileprivate var textAreaScrollView = UIScrollView()
    fileprivate var textAreaHeight: CGFloat = 0.0
    
    // TextAreaView
    fileprivate var textAreaView = UIView()
    
    // TextContainer
    fileprivate var textContainer = UIView()
    fileprivate var textContainerHeightConstraint: NSLayoutConstraint!
    
    // TitleLabel
    fileprivate var titleLabel = UILabel()
    var titleFont = UIFont(name: "HelveticaNeue-Bold", size: 18)
    var titleTextColor = UIColor.white
    
    // MessageView
    fileprivate var messageView = UILabel()
    var messageFont = UIFont(name: "HelveticaNeue", size: 15)
    var messageTextColor = UIColor.white
    
    // TextFieldContainerView
    fileprivate var textFieldContainerView = UIView()
    var textFieldBorderColor = UIColor(red: 203.0/255, green: 203.0/255, blue: 203.0/255, alpha: 1.0)
    
    // TextFields
    fileprivate(set) var textFields: [AnyObject]?
    fileprivate let textFieldHeight: CGFloat = 30.0
    var textFieldBgColor = UIColor.white
    fileprivate let textFieldCornerRadius: CGFloat = 4.0
    
    // ButtonAreaScrollView
    fileprivate var buttonAreaScrollView = UIScrollView()
    fileprivate var buttonAreaScrollViewHeightConstraint: NSLayoutConstraint!
    fileprivate var buttonAreaHeight: CGFloat = 0.0
    
    // ButtonAreaView
    fileprivate var buttonAreaView = UIView()
    
    // ButtonContainer
    fileprivate var buttonContainer = UIView()
    fileprivate var buttonContainerHeightConstraint: NSLayoutConstraint!
    fileprivate let buttonHeight: CGFloat = 44.0
    fileprivate var buttonMargin: CGFloat = 10.0
    
    // Actions
    fileprivate(set) var actions: [AnyObject] = []
    
    // Buttons
    fileprivate var buttons = [UIButton]()
    var buttonFont: [DOAlertActionStyle : UIFont?] = [
        .default : UIFont(name: "HelveticaNeue-Bold", size: 16),
        .cancel  : UIFont(name: "HelveticaNeue-Bold", size: 16),
        .destructive  : UIFont(name: "HelveticaNeue-Bold", size: 16)
    ]
    var buttonTextColor: [DOAlertActionStyle : UIColor] = [
        .default : UIColor.white,
        .cancel  : UIColor.black,
        .destructive  : UIColor.white
    ]
    var buttonBgColor: [DOAlertActionStyle : UIColor] = [
        .default : UIColor(red:52/255, green:152/255, blue:219/255, alpha:1),
        .cancel  : UIColor.white,
        .destructive  : UIColor.yellow
    ]
    var buttonBgColorHighlighted: [DOAlertActionStyle : UIColor] = [
        .default : UIColor(red:74/255, green:163/255, blue:223/255, alpha:1),
        .cancel  : UIColor(red:140/255, green:152/255, blue:153/255, alpha:1),
        .destructive  : UIColor(red:234/255, green:97/255, blue:83/255, alpha:1)
    ]
    fileprivate var buttonCornerRadius: CGFloat = 4.0
    
    fileprivate var layoutFlg = false
    fileprivate var keyboardHeight: CGFloat = 0.0
    fileprivate var cancelButtonTag = 0
    
    // Initializer
    convenience init(title: String?, message: String?, preferredStyle: DOAlertControllerStyle) {
        self.init(nibName: nil, bundle: nil)
        
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        
        self.providesPresentationContextTransitionStyle = true
        self.definesPresentationContext = true
        self.modalPresentationStyle = UIModalPresentationStyle.custom
        
        // NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(DOAlertController.handleAlertActionEnabledDidChangeNotification(_:)), name: NSNotification.Name(rawValue: DOAlertActionEnabledDidChangeNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DOAlertController.handleKeyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DOAlertController.handleKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Delegate
        self.transitioningDelegate = self
        
        // Screen Size
        var screenSize = UIScreen.main.bounds.size
        if ((UIDevice.current.systemVersion as NSString).floatValue < 8.0) {
            if (UIApplication.shared.statusBarOrientation.isLandscape) {
                screenSize = CGSize(width: screenSize.height, height: screenSize.width)
            }
        }
        
        // variable for ActionSheet
        if (!isAlert()) {
            alertViewWidth =  screenSize.width
            alertViewPadding = 8.0
            innerContentWidth = (screenSize.height > screenSize.width) ? screenSize.width - alertViewPadding * 2 : screenSize.height - alertViewPadding * 2
            buttonMargin = 8.0
            buttonCornerRadius = 6.0
        }
        
        
        alertView.layer.cornerRadius = 8   // set Up corner radius for ALertVIew
        alertView.layer.borderColor = UIColor.white.cgColor
        alertView.layer.borderWidth = 0.5
        // self.view
        self.view.frame.size = screenSize
        
        // OverlayView
        self.view.addSubview(overlayView)
        
        // ContainerView
        self.view.addSubview(containerView)
        
        // AlertView
        containerView.addSubview(alertView)
        
        // TextAreaScrollView
        alertView.addSubview(textAreaScrollView)
        
        // TextAreaView
        textAreaScrollView.addSubview(textAreaView)
        
        // TextContainer
        textAreaView.addSubview(textContainer)
        
        // ButtonAreaScrollView
        alertView.addSubview(buttonAreaScrollView)
        
        // ButtonAreaView
        
        buttonAreaScrollView.addSubview(buttonAreaView)
        
        // ButtonContainer
        buttonAreaView.addSubview(buttonContainer)
        
        //------------------------------
        // Layout Constraint
        //------------------------------
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false
        alertView.translatesAutoresizingMaskIntoConstraints = false
        textAreaScrollView.translatesAutoresizingMaskIntoConstraints = false
        textAreaView.translatesAutoresizingMaskIntoConstraints = false
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        buttonAreaScrollView.translatesAutoresizingMaskIntoConstraints = false
        buttonAreaView.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // self.view
        let overlayViewTopSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let overlayViewRightSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
        let overlayViewLeftSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let overlayViewBottomSpaceConstraint = NSLayoutConstraint(item: overlayView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let containerViewTopSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let containerViewRightSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
        let containerViewLeftSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        containerViewBottomSpaceConstraint = NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        self.view.addConstraints([overlayViewTopSpaceConstraint, overlayViewRightSpaceConstraint, overlayViewLeftSpaceConstraint, overlayViewBottomSpaceConstraint, containerViewTopSpaceConstraint, containerViewRightSpaceConstraint, containerViewLeftSpaceConstraint, containerViewBottomSpaceConstraint])
        
        if (isAlert()) {
            // ContainerView
            let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let alertViewCenterYConstraint = NSLayoutConstraint(item: alertView, attribute: .centerY, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1.0, constant: 0.0)
            containerView.addConstraints([alertViewCenterXConstraint, alertViewCenterYConstraint])
            
            // AlertView
            let alertViewWidthConstraint = NSLayoutConstraint(item: alertView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: alertViewWidth)
            alertViewHeightConstraint = NSLayoutConstraint(item: alertView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 1000.0)
            alertView.addConstraints([alertViewWidthConstraint, alertViewHeightConstraint])
            
        } else {
            // ContainerView
            let alertViewCenterXConstraint = NSLayoutConstraint(item: alertView, attribute: .centerX, relatedBy: .equal, toItem: containerView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
            let alertViewBottomSpaceConstraint = NSLayoutConstraint(item: alertView, attribute: .bottom, relatedBy: .equal, toItem: containerView, attribute: .bottom, multiplier: 1.0, constant: actionSheetBounceHeight)
            let alertViewWidthConstraint = NSLayoutConstraint(item: alertView, attribute: .width, relatedBy: .equal, toItem: containerView, attribute: .width, multiplier: 1.0, constant: 0.0)
            containerView.addConstraints([alertViewCenterXConstraint, alertViewBottomSpaceConstraint, alertViewWidthConstraint])
            
            // AlertView
            alertViewHeightConstraint = NSLayoutConstraint(item: alertView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 1000.0)
            alertView.addConstraint(alertViewHeightConstraint)
        }
        
        // AlertView
        let textAreaScrollViewTopSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .top, relatedBy: .equal, toItem: alertView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .right, relatedBy: .equal, toItem: alertView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .left, relatedBy: .equal, toItem: alertView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let textAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: textAreaScrollView, attribute: .bottom, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewRightSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .right, relatedBy: .equal, toItem: alertView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewLeftSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .left, relatedBy: .equal, toItem: alertView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let buttonAreaScrollViewBottomSpaceConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .bottom, relatedBy: .equal, toItem: alertView, attribute: .bottom, multiplier: 1.0, constant: isAlert() ? 0.0 : -actionSheetBounceHeight)
        alertView.addConstraints([textAreaScrollViewTopSpaceConstraint, textAreaScrollViewRightSpaceConstraint, textAreaScrollViewLeftSpaceConstraint, textAreaScrollViewBottomSpaceConstraint, buttonAreaScrollViewRightSpaceConstraint, buttonAreaScrollViewLeftSpaceConstraint, buttonAreaScrollViewBottomSpaceConstraint])
        
        // TextAreaScrollView
        let textAreaViewTopSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .top, relatedBy: .equal, toItem: textAreaScrollView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let textAreaViewRightSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .right, relatedBy: .equal, toItem: textAreaScrollView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let textAreaViewLeftSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .left, relatedBy: .equal, toItem: textAreaScrollView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let textAreaViewBottomSpaceConstraint = NSLayoutConstraint(item: textAreaView, attribute: .bottom, relatedBy: .equal, toItem: textAreaScrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let textAreaViewWidthConstraint = NSLayoutConstraint(item: textAreaView, attribute: .width, relatedBy: .equal, toItem: textAreaScrollView, attribute: .width, multiplier: 1.0, constant: 0.0)
        textAreaScrollView.addConstraints([textAreaViewTopSpaceConstraint, textAreaViewRightSpaceConstraint, textAreaViewLeftSpaceConstraint, textAreaViewBottomSpaceConstraint, textAreaViewWidthConstraint])
        
        // TextArea
        let textAreaViewHeightConstraint = NSLayoutConstraint(item: textAreaView, attribute: .height, relatedBy: .equal, toItem: textContainer, attribute: .height, multiplier: 1.0, constant: 0.0)
        let textContainerTopSpaceConstraint = NSLayoutConstraint(item: textContainer, attribute: .top, relatedBy: .equal, toItem: textAreaView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let textContainerCenterXConstraint = NSLayoutConstraint(item: textContainer, attribute: .centerX, relatedBy: .equal, toItem: textAreaView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        textAreaView.addConstraints([textAreaViewHeightConstraint, textContainerTopSpaceConstraint, textContainerCenterXConstraint])
        
        // TextContainer
        let textContainerWidthConstraint = NSLayoutConstraint(item: textContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: innerContentWidth)
        textContainerHeightConstraint = NSLayoutConstraint(item: textContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0.0)
        textContainer.addConstraints([textContainerWidthConstraint, textContainerHeightConstraint])
        
        // ButtonAreaScrollView
        buttonAreaScrollViewHeightConstraint = NSLayoutConstraint(item: buttonAreaScrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewTopSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .top, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewRightSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .right, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewLeftSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .left, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewBottomSpaceConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .bottom, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        let buttonAreaViewWidthConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .width, relatedBy: .equal, toItem: buttonAreaScrollView, attribute: .width, multiplier: 1.0, constant: 0.0)
        buttonAreaScrollView.addConstraints([buttonAreaScrollViewHeightConstraint, buttonAreaViewTopSpaceConstraint, buttonAreaViewRightSpaceConstraint, buttonAreaViewLeftSpaceConstraint, buttonAreaViewBottomSpaceConstraint, buttonAreaViewWidthConstraint])
        
        // ButtonArea
        let buttonAreaViewHeightConstraint = NSLayoutConstraint(item: buttonAreaView, attribute: .height, relatedBy: .equal, toItem: buttonContainer, attribute: .height, multiplier: 1.0, constant: 0.0)
        let buttonContainerTopSpaceConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .top, relatedBy: .equal, toItem: buttonAreaView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let buttonContainerCenterXConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .centerX, relatedBy: .equal, toItem: buttonAreaView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        buttonAreaView.addConstraints([buttonAreaViewHeightConstraint, buttonContainerTopSpaceConstraint, buttonContainerCenterXConstraint])
        
        // ButtonContainer
        let buttonContainerWidthConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: innerContentWidth)
        buttonContainerHeightConstraint = NSLayoutConstraint(item: buttonContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: 0.0)
        buttonContainer.addConstraints([buttonContainerWidthConstraint, buttonContainerHeightConstraint])
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        layoutView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!isAlert() && cancelButtonTag != 0) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DOAlertController.handleContainerViewTapGesture(_:)))
            containerView.addGestureRecognizer(tapGesture)
        }
    }
    
    func layoutView() {
        if (layoutFlg) { return }
        layoutFlg = true
        
        //------------------------------
        // Layout & Color Settings
        //------------------------------
        overlayView.backgroundColor = overlayColor
        alertView.backgroundColor = alertViewBgColor
        
        //------------------------------
        // TextArea Layout
        //------------------------------
        let hasTitle: Bool = title != nil && title != ""
        let hasMessage: Bool = message != nil && message != ""
        let hasTextField: Bool = textFields != nil && textFields!.count > 0
        
        var textAreaPositionY: CGFloat = alertViewPadding
        if (!isAlert()) {textAreaPositionY += alertViewPadding}
        
        // TitleLabel
        if (hasTitle) {
            titleLabel.frame.size = CGSize(width: innerContentWidth, height: 0.0)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center
            titleLabel.font = titleFont
            titleLabel.textColor = titleTextColor
            titleLabel.text = title
            titleLabel.sizeToFit()
            titleLabel.frame = CGRect(x: 0, y: textAreaPositionY, width: innerContentWidth, height: titleLabel.frame.height)
            textContainer.addSubview(titleLabel)
            textAreaPositionY += titleLabel.frame.height + 5.0
        }
        
        // MessageView
        if (hasMessage) {
            messageView.frame.size = CGSize(width: innerContentWidth, height: 0.0)
            messageView.numberOfLines = 0
            messageView.textAlignment = .center
            messageView.font = messageFont
            messageView.textColor = messageTextColor
            messageView.text = message
            messageView.sizeToFit()
            messageView.frame = CGRect(x: 0, y: textAreaPositionY, width: innerContentWidth, height: messageView.frame.height)
            textContainer.addSubview(messageView)
            textAreaPositionY += messageView.frame.height + 5.0
        }
        
        // TextFieldContainerView
        if (hasTextField) {
            if (hasTitle || hasMessage) { textAreaPositionY += 5.0 }
            
            textFieldContainerView.backgroundColor = textFieldBorderColor
            textFieldContainerView.layer.masksToBounds = true
            textFieldContainerView.layer.cornerRadius = textFieldCornerRadius
            textFieldContainerView.layer.borderWidth = 0.5
            textFieldContainerView.layer.borderColor = textFieldBorderColor.cgColor
            textContainer.addSubview(textFieldContainerView)
            
            var textFieldContainerHeight: CGFloat = 0.0
            
            // TextFields
            for (_, obj) in (textFields!).enumerated() {
                let textField = obj as! UITextField
                textField.frame = CGRect(x: 0.0, y: textFieldContainerHeight, width: innerContentWidth, height: textField.frame.height)
                textFieldContainerHeight += textField.frame.height + 0.5
            }
            
            textFieldContainerHeight -= 0.5
            textFieldContainerView.frame = CGRect(x: 0.0, y: textAreaPositionY, width: innerContentWidth, height: textFieldContainerHeight)
            textAreaPositionY += textFieldContainerHeight + 5.0
        }
        
        if (!hasTitle && !hasMessage && !hasTextField) {
            textAreaPositionY = 0.0
        }
        
        // TextAreaScrollView
        textAreaHeight = textAreaPositionY
        textAreaScrollView.contentSize = CGSize(width: alertViewWidth, height: textAreaHeight)
        textContainerHeightConstraint.constant = textAreaHeight
        
        //------------------------------
        // ButtonArea Layout
        //------------------------------
        var buttonAreaPositionY: CGFloat = buttonMargin
        
        // Buttons
        if (isAlert() && buttons.count == 2) {
            let buttonWidth = (innerContentWidth - buttonMargin) / 2
            var buttonPositionX: CGFloat = 0.0
            for button in buttons {
                let action = actions[button.tag - 1] as! DOAlertAction
                button.titleLabel?.font = buttonFont[action.style]!
                button.setTitleColor(buttonTextColor[action.style], for: UIControl.State())
                button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), for: UIControl.State())
                button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .highlighted)
                button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .selected)
                button.frame = CGRect(x: buttonPositionX, y: buttonAreaPositionY, width: buttonWidth, height: buttonHeight)
                buttonPositionX += buttonMargin + buttonWidth
            }
            buttonAreaPositionY += buttonHeight
        } else {
            for button in buttons {
                let action = actions[button.tag - 1] as! DOAlertAction
                if (action.style != DOAlertActionStyle.cancel) {
                    button.titleLabel?.font = buttonFont[action.style]!
                    button.setTitleColor(buttonTextColor[action.style], for: UIControl.State())
                    button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), for: UIControl.State())
                    button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .highlighted)
                    button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .selected)
                    button.frame = CGRect(x: 0, y: buttonAreaPositionY, width: innerContentWidth, height: buttonHeight)
                    buttonAreaPositionY += buttonHeight + buttonMargin
                } else {
                    cancelButtonTag = button.tag
                }
            }
            
            // Cancel Button
            if (cancelButtonTag != 0) {
                if (!isAlert() && buttons.count > 1) {
                    buttonAreaPositionY += buttonMargin
                }
                let button = buttonAreaScrollView.viewWithTag(cancelButtonTag) as! UIButton
                let action = actions[cancelButtonTag - 1] as! DOAlertAction
                button.titleLabel?.font = buttonFont[action.style]!
                button.setTitleColor(buttonTextColor[action.style], for: UIControl.State())
                button.setBackgroundImage(createImageFromUIColor(buttonBgColor[action.style]!), for: UIControl.State())
                button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .highlighted)
                button.setBackgroundImage(createImageFromUIColor(buttonBgColorHighlighted[action.style]!), for: .selected)
                button.frame = CGRect(x: 0, y: buttonAreaPositionY, width: innerContentWidth, height: buttonHeight)
                buttonAreaPositionY += buttonHeight + buttonMargin
            }
            buttonAreaPositionY -= buttonMargin
        }
        buttonAreaPositionY += alertViewPadding
        
        if (buttons.count == 0) {
            buttonAreaPositionY = 0.0
        }
        
        // ButtonAreaScrollView Height
        buttonAreaHeight = buttonAreaPositionY
        buttonAreaScrollView.contentSize = CGSize(width: alertViewWidth, height: buttonAreaHeight)
        buttonContainerHeightConstraint.constant = buttonAreaHeight
        
        //------------------------------
        // AlertView Layout
        //------------------------------
        // AlertView Height
        reloadAlertViewHeight()
        alertView.frame.size = CGSize(width: alertViewWidth, height: alertViewHeightConstraint.constant)
    }
    
    // Reload AlertView Height
    func reloadAlertViewHeight() {
        
        var screenSize = UIScreen.main.bounds.size
        if ((UIDevice.current.systemVersion as NSString).floatValue < 8.0) {
            if (UIApplication.shared.statusBarOrientation.isLandscape) {
                screenSize = CGSize(width: screenSize.height, height: screenSize.width)
            }
        }
        let maxHeight = screenSize.height - keyboardHeight
        
        // for avoiding constraint error
        buttonAreaScrollViewHeightConstraint.constant = 0.0
        
        // AlertView Height Constraint
        var alertViewHeight = textAreaHeight + buttonAreaHeight
        if (alertViewHeight > maxHeight) {
            alertViewHeight = maxHeight
        }
        if (!isAlert()) {
            alertViewHeight += actionSheetBounceHeight
        }
        alertViewHeightConstraint.constant = alertViewHeight
        
        // ButtonAreaScrollView Height Constraint
        var buttonAreaScrollViewHeight = buttonAreaHeight
        if (buttonAreaScrollViewHeight > maxHeight) {
            buttonAreaScrollViewHeight = maxHeight
        }
        buttonAreaScrollViewHeightConstraint.constant = buttonAreaScrollViewHeight
    }
    
    // Button Tapped Action
    @objc func buttonTapped(_ sender: UIButton) {
        sender.isSelected = true
        let action = actions[sender.tag - 1] as! DOAlertAction
        if (action.handler != nil) {
            action.handler(action)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // Handle ContainerView tap gesture
    @objc func handleContainerViewTapGesture(_ sender: AnyObject) {
        // cancel action
        let action = actions[cancelButtonTag] as! DOAlertAction
        if (action.handler != nil) {
            action.handler(action)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    // UIColor -> UIImage
    func createImageFromUIColor(_ color: UIColor) -> UIImage {
        let color = color
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let contextRef: CGContext = UIGraphicsGetCurrentContext()!
        contextRef.setFillColor(color.cgColor)
        contextRef.fill(rect)
        let img: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
    
    // MARK : Handle NSNotification Method
    
    @objc func handleAlertActionEnabledDidChangeNotification(_ notification: Notification) {
        for i in 0..<buttons.count {
            buttons[i].isEnabled = actions[i].isEnabled
        }
    }
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification) {
        if let userInfo = (notification as NSNotification).userInfo as? [String: NSValue] {
            var keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey]!.cgRectValue.size
            if ((UIDevice.current.systemVersion as NSString).floatValue < 8.0) {
                if (UIApplication.shared.statusBarOrientation.isLandscape) {
                    keyboardSize = CGSize(width: keyboardSize.height, height: keyboardSize.width)
                }
            }
            keyboardHeight = keyboardSize.height
            reloadAlertViewHeight()
            containerViewBottomSpaceConstraint.constant = -keyboardHeight
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        keyboardHeight = 0.0
        reloadAlertViewHeight()
        containerViewBottomSpaceConstraint.constant = keyboardHeight
        UIView.animate(withDuration: 0.25, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    // MARK: Public Methods
    
    // Attaches an action object to the alert or action sheet.
    func addAction(_ action: DOAlertAction) {
        // Error
        if (action.style == DOAlertActionStyle.cancel) {
            for ac in actions as! [DOAlertAction] {
                if (ac.style == DOAlertActionStyle.cancel) {
                    let error: NSError?
                    NSException.raise(NSExceptionName(rawValue: "NSInternalInconsistencyException"), format:"DOAlertController can only have one action with a style of DOAlertActionStyleCancel", arguments:getVaList(["" ?? "nil"]))
                    return
                }
            }
        }
        // Add Action
        actions.append(action)
        
        // Add Button
        let button = UIButton()
        button.layer.masksToBounds = true
        button.setTitle(action.title, for: UIControl.State())
        button.isEnabled = action.enabled
        button.layer.cornerRadius = buttonCornerRadius
        button.addTarget(self, action: #selector(DOAlertController.buttonTapped(_:)), for: .touchUpInside)
        button.tag = buttons.count + 1
        button.layer.cornerRadius = 8   // set Up corner radius for ALertVIew
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0.5
        buttons.append(button)
        
        buttonContainer.addSubview(button)
    }
    
    // Adds a text field to an alert.
    func addTextFieldWithConfigurationHandler(_ configurationHandler: ((UITextField?) -> Void)!) {
        
        // You can add a text field only if the preferredStyle property is set to DOAlertControllerStyle.Alert.
        if (!isAlert()) {
            let error: NSError?
            NSException.raise(NSExceptionName(rawValue: "NSInternalInconsistencyException"), format: "Text fields can only be added to an alert controller of style DOAlertControllerStyleAlert", arguments:getVaList(["" ?? "nil"]))
            return
        }
        if (textFields == nil) {
            textFields = []
        }
        
        let textField = UITextField()
        textField.frame.size = CGSize(width: innerContentWidth, height: textFieldHeight)
        textField.borderStyle = UITextField.BorderStyle.none
        textField.backgroundColor = textFieldBgColor
        textField.delegate = self
        
        if ((configurationHandler) != nil) {
            configurationHandler(textField)
        }
        
        textFields!.append(textField)
        textFieldContainerView.addSubview(textField)
    }
    
    func isAlert() -> Bool { return preferredStyle == .alert }
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField.canResignFirstResponder) {
            textField.resignFirstResponder()
            self.dismiss(animated: true, completion: nil)
        }
        return true
    }
    
    // MARK: UIViewControllerTransitioningDelegate Methods
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        layoutView()
        return DOAlertAnimation(isPresenting: true)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DOAlertAnimation(isPresenting: false)
    }
    
}

extension UIViewController{
    func showAlertController(_ title:String,message:String,cancelButton:String,isTextFiled:Bool = false,otherButtons buttonTitles:[String],handler: ((Int?) -> Void)!){
        
        DispatchQueue.main.async { () -> Void in
            
            let alertController = DOAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = DOAlertAction(title: cancelButton, style: .cancel, handler: { (action) -> Void in
                if let _ = handler{
                    handler(0)
                }
            })
            alertController.addAction(cancelAction)
            if isTextFiled{
                alertController.addTextFieldWithConfigurationHandler({ (textField) in textField?.placeholder = "enter email or username"; print("textfieldadded")})
            }
            if buttonTitles.count != 0 {
                for buttonTitle in buttonTitles{
                    if buttonTitle != ""{
                        let okAction = DOAlertAction(title: buttonTitle, style: .default, handler: { (action) -> Void in
                            if let buttonIndex = buttonTitles.firstIndex(of: buttonTitle){
                                if let _ = handler{
                                    handler(buttonIndex+1)
                                }
                            }
                        })
                        alertController.addAction(okAction)
                    }
                }
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    func showAlertControllerWithTextField(_ title:String,message:String,cancelButton:String,otherButtons buttonTitles:[String],handler: ((NSMutableDictionary?) -> Void)!){
        
        DispatchQueue.main.async { () -> Void in
            let alertController = DOAlertController(title: title, message: message, preferredStyle: .alert)
            var commonTextField : UITextField?
                alertController.addTextFieldWithConfigurationHandler({ (textField) in textField?.placeholder = "username";
                    commonTextField = textField
                    print("textfieldadded")})
            
            let cancelAction = DOAlertAction(title: cancelButton, style: .cancel, handler: { (action) -> Void in
                if let _ = handler{
                    
                    let dictValue = NSMutableDictionary()
                    dictValue.setObject(0, forKey: "index" as NSCopying)
                    handler(dictValue)
                }
            })
            alertController.addAction(cancelAction)

            
            if buttonTitles.count != 0 {
                for buttonTitle in buttonTitles{
                    if buttonTitle != ""{
                        let okAction = DOAlertAction(title: buttonTitle, style: .default, handler: { (action) -> Void in
                            if let buttonIndex = buttonTitles.firstIndex(of: buttonTitle){
                                if let _ = handler{
                                    let dictValue = NSMutableDictionary()
                                    dictValue.setObject(buttonIndex+1, forKey: "index" as NSCopying)
                                     dictValue.setObject(commonTextField!, forKey: "textField" as NSCopying)
                                   handler(dictValue)
                                }
                            }
                        })
                        alertController.addAction(okAction)
                    }
                }
            }
            self.present(alertController, animated: true, completion: nil)
        }
    }

}


