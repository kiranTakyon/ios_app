//
//  ReactionView.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 29/07/24.
//  Copyright © 2023 InApp. All rights reserved.
//

public protocol FacebookLikeReactionDelegate {
    func selectedReaction(reaction: Reaction)
}

public class ReactionView: UIView {

    var delegate: FacebookLikeReactionDelegate!
    var sourceView: UIView!
    var gestureView: UIView!
    var reactions: [Reaction]!
    private var isViewVisible = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 5)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func initialize(delegate: Any, reactionsArray: [Reaction], sourceView: UIView, gestureView: UIView) {
        let iconHeight: CGFloat = 35
        let padding: CGFloat = 8
        self.reactions = reactionsArray
        self.sourceView = sourceView
        self.gestureView = gestureView
        self.delegate = delegate as? FacebookLikeReactionDelegate

        var imgs: [UIImage] = []

        var arrangedSubviews: [UIView] = []

        for (index, reaction) in reactions.enumerated() {
            imgs.append(UIImage(named: reaction.imageName!)!)

            let imgView = UIImageView(image: UIImage(named: reaction.imageName!)!)
            imgView.isUserInteractionEnabled = true
            imgView.frame = CGRect(x: 0, y: 0, width: iconHeight, height: iconHeight)
            imgView.layer.cornerRadius = (imgView.frame.height) / 2
            imgView.layer.masksToBounds = true
            imgView.layer.borderColor = UIColor.clear.cgColor
            imgView.layer.borderWidth = 0
            imgView.contentMode = .scaleAspectFit
            imgView.tag = index
            reactions[index].tag = index

            // Add tap gesture to each image
            let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
            imgView.addGestureRecognizer(imageTapGesture)

            arrangedSubviews.append(imgView)
        }

        let stackView = UIStackView(arrangedSubviews: arrangedSubviews)
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        stackView.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        stackView.isLayoutMarginsRelativeArrangement = true

        let width = (CGFloat(imgs.count) * iconHeight) + (CGFloat(imgs.count+1) * padding)
        self.frame = CGRect(x: 50, y: 0, width: width, height: iconHeight + 2 * padding)
        layer.cornerRadius = frame.height / 2
        addSubview(stackView)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: iconHeight + 2 * padding)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if !isViewVisible {
            isViewVisible = true
            let location = gesture.location(in: sourceView)
            sourceView.addSubview(self)
            showViewWithAnimation(at: location, in: sourceView)
        } else {
            removeViewWithAnimation(at: gesture.location(in: self))
        }
    }

    @objc func handleImageTap(_ gesture: UITapGestureRecognizer) {
        if let imgView = gesture.view as? UIImageView {
            delegate.selectedReaction(reaction: reactions[imgView.tag])
            removeViewWithAnimation(at: gesture.location(in: self))
        }
    }

    public func showViewWithAnimation(at point: CGPoint, in view: UIView) {
        alpha = 0
        let centerX = view.frame.minX // Align from the leading edge
        transform = CGAffineTransform(translationX: centerX, y: point.y)

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 1
            self.transform = CGAffineTransform(translationX: centerX, y: point.y - 80)
        }) { (_) in
            let lbl = UILabel()
            lbl.frame = CGRect(x: 7.5, y: 3, width: lbl.frame.width + 10, height: 23)
            lbl.textColor = .white
            lbl.text = "Camera"
            let bgView = UIView(frame: CGRect(x: 120, y: -55, width: lbl.frame.width + 15, height: lbl.frame.height + 5))
            bgView.alpha = 0
            bgView.addSubview(lbl)
            bgView.backgroundColor = UIColor.lightGray
            bgView.layer.cornerRadius = bgView.frame.height / 2
            self.addSubview(bgView)
        }
    }

    public func performHittestOnView(at point: CGPoint) {
        let fixedYlocation = CGPoint(x: point.x, y: point.y > 15 ? (self.frame.height / 2) : point.y)
        let hitTestview = hitTest(fixedYlocation, with: nil)

        if hitTestview is UIImageView {
            UIView.animate(withDuration: 0.3) {
                let stackView = self.subviews.first
                stackView?.subviews.forEach({ (imgView) in
                    if imgView != hitTestview {
                        imgView.transform = .identity
                    } else {
                        hitTestview?.transform = CGAffineTransform(scaleX: 1.55, y: 1.55).translatedBy(x: -0.25, y: -10)
                    }
                })

                let titles = self.reactions.map { (reaction) -> String in
                    return reaction.title!
                }

                /// Uncomment if shows the title above the reaction
                // Change position of title
                // for allViews in self.subviews {
                //     for label in allViews.subviews {
                //         if let lbl = label as? UILabel {
                //             lbl.tag = (hitTestview?.tag)!
                //             lbl.text = titles[(hitTestview?.tag)!]
                //             allViews.frame.size.width = label.frame.width + 15
                //             allViews.center.x = (point.x)
                //             allViews.alpha = 1
                //             lbl.sizeToFit()
                //         }
                //     }
                // }
            }
            // Dismiss the view after a reaction is selected
            if let imgView = hitTestview as? UIImageView {
                delegate.selectedReaction(reaction: reactions[imgView.tag])
                removeViewWithAnimation(at: point)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                let stackView = self.subviews.first
                stackView?.subviews.forEach({ (imgView) in
                    imgView.transform = .identity
                })
            }
            for vw in self.subviews {
                for lblView in vw.subviews {
                    if lblView is UILabel {
                        vw.alpha = 0
                        break
                    }
                }
            }
        }
    }

    public func removeViewWithAnimation(at point: CGPoint) {
        isViewVisible = false
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            let stackView = self.subviews.first
            stackView?.subviews.forEach({ (imgView) in
                imgView.transform = .identity
                self.transform = self.transform.translatedBy(x: 0, y: 20)
                self.alpha = 0
            })
        })  { (_) in
            for vw in self.subviews {
                for lblView in vw.subviews {
                    if lblView is UILabel {
                        vw.removeFromSuperview()
                        break
                    }
                }
            }
            self.removeFromSuperview()
        }
    }
}
