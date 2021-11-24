//
//  LoadMoreControl.swift
//  Ruby Jubile
//
//  Created by Anil on 9/22/19.
//  Copyright © 2019 InApp. All rights reserved.
//

import Foundation
import UIKit

protocol LoadMoreControlDelegate: class {
    func loadMoreControl(didStartAnimating loadMoreControl: LoadMoreControl)
    func loadMoreControl(didStopAnimating loadMoreControl: LoadMoreControl)
}

class LoadMoreControl {
    
    private let spacingFromLastCell: CGFloat
    private let indicatorHeight: CGFloat
    private weak var activityIndicatorView: UIActivityIndicatorView?
    private weak var scrollView: UIScrollView?
    weak var delegate: LoadMoreControlDelegate?
    
    private var defaultY: CGFloat {
        guard let height = scrollView?.contentSize.height else { return 0.0 }
        return height + spacingFromLastCell
    }
    
    init (scrollView: UIScrollView, spacingFromLastCell: CGFloat, indicatorHeight: CGFloat) {
        self.scrollView = scrollView
        self.spacingFromLastCell = spacingFromLastCell
        self.indicatorHeight = indicatorHeight
        
        let size:CGFloat = 40
        let frame = CGRect(x: (scrollView.frame.width-size)/2, y: scrollView.contentSize.height + spacingFromLastCell, width: size, height: size)
        let activityIndicatorView = UIActivityIndicatorView(frame: frame)
        activityIndicatorView.color = .black
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
        scrollView.addSubview(activityIndicatorView)
        activityIndicatorView.isHidden = isHidden
        self.activityIndicatorView = activityIndicatorView
    }

private var isHidden: Bool {
    guard let scrollView = scrollView else { return true }
    return scrollView.contentSize.height < scrollView.frame.size.height
}

func didScroll() {
    guard let scrollView = scrollView, let activityIndicatorView = activityIndicatorView else { return }
    let offsetY = scrollView.contentOffset.y
    activityIndicatorView.isHidden = isHidden
    if !activityIndicatorView.isHidden && offsetY >= 0 {
        let contentDelta = scrollView.contentSize.height - scrollView.frame.size.height
        let offsetDelta = offsetY - contentDelta
        
        let newY = defaultY-offsetDelta
        if newY < scrollView.frame.height {
            activityIndicatorView.frame.origin.y = newY
        } else {
            if activityIndicatorView.frame.origin.y != defaultY {
                activityIndicatorView.frame.origin.y = defaultY
            }
        }
        
        if !activityIndicatorView.isAnimating {
            if offsetY > contentDelta && offsetDelta >= indicatorHeight && !activityIndicatorView.isAnimating {
                activityIndicatorView.startAnimating()
                delegate?.loadMoreControl(didStartAnimating: self)
            }
        }
        
        if scrollView.isDecelerating {
            if activityIndicatorView.isAnimating && scrollView.contentInset.bottom == 0 {
                UIView.animate(withDuration: 0.3) { [weak self, weak scrollView] in
                    if let bottom = self?.indicatorHeight {
                        scrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottom, right: 0)
                    }
                }
            }
        }
    }
}

func stop() {
    guard let scrollView = scrollView else { return }
    let contentDelta = scrollView.contentSize.height - scrollView.frame.size.height
    let offsetDelta = scrollView.contentOffset.y - contentDelta
    if offsetDelta >= 0 {
        UIView.animate(withDuration: 0.3, animations: { [weak scrollView] in
            scrollView?.contentInset = .zero
        }) { [weak self] result in
            if result { self?.endAnimating() }
        }
    } else {
        scrollView.contentInset = .zero
        endAnimating()
    }
}

private func endAnimating() {
    activityIndicatorView?.stopAnimating()
    delegate?.loadMoreControl(didStopAnimating: self)
}
}
