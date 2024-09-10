//
//  ModuleCollectionViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 21/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit

class ModuleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var labelModule: UILabel!
    @IBOutlet weak var moduleImageView: UIImageView!
    @IBOutlet weak var labelDataCount: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
