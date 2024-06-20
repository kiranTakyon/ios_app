//
//  CustomTopView.swift
//  Ambassador Education
//
//  Created by apple on 18/06/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit


protocol CustomTopViewDelegate: AnyObject {
    func didTapCloseButton()
}

class CustomTopView: UIView {
    
    weak var delegate: CustomTopViewDelegate?
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "CloseBlack"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor(named: "peachColor")
        
        addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 15)
        ])
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func closeButtonTapped() {
        delegate?.didTapCloseButton()
    }
}
