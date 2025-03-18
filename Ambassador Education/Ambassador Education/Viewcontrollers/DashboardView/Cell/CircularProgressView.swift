//
//  CircularProgressView.swift
//  Ambassador Education
//
//  Created by IE14 on 25/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit
import Foundation
import QuartzCore

@IBDesignable
class CircularProgressView: UIView {
    
    private let shapeLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()

    @IBInspectable var progress: CGFloat = 0 {
        didSet {
            setProgress(progress)
        }
    }
    
    @IBInspectable var lineWidth: CGFloat = 4 {
        didSet {
            updateLayers()
        }
    }
    
    @IBInspectable var progressColor: UIColor = .blue {
        didSet {
            shapeLayer.strokeColor = progressColor.cgColor
        }
    }
    
    @IBInspectable var trackColor: UIColor = .lightGray {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        layer.addSublayer(trackLayer)
        layer.addSublayer(shapeLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayers()
    }
    
    private func updateLayers() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                                        radius: bounds.width / 2.5,
                                        startAngle: -CGFloat.pi / 2,
                                        endAngle: 1.5 * CGFloat.pi,
                                        clockwise: true)
        
        // Track Layer
        trackLayer.path = circularPath.cgPath
        trackLayer.lineWidth = lineWidth
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        
        // Shape Layer
        shapeLayer.path = circularPath.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.strokeEnd = 0
    }
    
    func setProgress(_ progress: CGFloat) {
        let clampedProgress = min(max(progress, 0), 1)
        shapeLayer.strokeEnd = clampedProgress

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = clampedProgress
        animation.duration = 1.0
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        shapeLayer.add(animation, forKey: "progressAnim")
    }
}
