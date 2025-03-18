//
//  MenuCollectionViewCell.swift
//  CredenceSchool
//
//  Created by IE14 on 14/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit

class MenuCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    static var identifier = "MenuCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 10
    }

}

extension MenuCollectionViewCell {
    func setIage(for image: String) {
      imageView.image = UIImage(named: image)
    }
}
