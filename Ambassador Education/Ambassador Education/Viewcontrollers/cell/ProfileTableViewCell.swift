//
//  ProfileTableViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 31/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headingImageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var labelHeading: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        //textField.text = nil
    }
    
}
