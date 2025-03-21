//
//  ProgressCollectionViewCell.swift
//  Ambassador Education
//
//  Created by IE14 on 25/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit

class ProgressCollectionViewCell: UICollectionViewCell {
    
    static var identifier = "ProgressCollectionViewCell"

    @IBOutlet weak var containView: UIView!
    @IBOutlet private var circularProgressHome: CircularProgressView!
    @IBOutlet private var headingLable: UILabel!
    @IBOutlet private var persentageLabel: UILabel!
    
    var data: TProgressTypeModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        circularProgressHome.progress = 0.75
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }

}
