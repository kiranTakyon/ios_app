//
//  CommunicationTableViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 07/08/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit

class CommunicationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelMessageType: UILabel!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var ReadIcon: UIImageView!
    @IBOutlet weak var ReadStatus: UILabel!
   

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
