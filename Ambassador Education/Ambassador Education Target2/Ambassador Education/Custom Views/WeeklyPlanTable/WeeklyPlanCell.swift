//
//  WeeklyPlanCell.swift
//  Ambassador Education
//
//  Created by Sreeshaj  on 15/01/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit

class WeeklyPlanCell: UITableViewCell {

    @IBOutlet weak var titleImageView: UIImageView!
    
    @IBOutlet weak var attachmntButtnHeight: NSLayoutConstraint!
    @IBOutlet weak var attachmntButtn: UIButton!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
