//
//  DashboardCollectionViewCell.swift
//  Ambassador Education
//
//  Created by IE14 on 24/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit

class DashboardCollectionViewCell: UICollectionViewCell {
    
    static var identifier = "DashboardCollectionViewCell"
    
    @IBOutlet weak var imageContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var labelDataCount: UILabel!
    @IBOutlet weak var countContainerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageContainerView.cornerRadius1 = imageContainerView.frame.width / 2
        imageContainerView.layer.shadowColor = UIColor.black.cgColor
        imageContainerView.layer.shadowOpacity = 0.5
        imageContainerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        imageContainerView.layer.shadowRadius = 4
        imageContainerView.layer.masksToBounds = false
        countContainerView.layer.cornerRadius = countContainerView.frame.width / 2
        
    }

}
