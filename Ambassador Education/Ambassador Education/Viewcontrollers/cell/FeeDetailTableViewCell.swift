//
//  FeeDetailTableViewCell.swift
//  Ambassador Education
//
//  Created by apple on 26/06/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit

class FeeDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelFee: UILabel!
    @IBOutlet weak var labelMonth: UILabel!
    @IBOutlet weak var labelPaid: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell() {
        labelFee.text = "Fee: 0.00"
        labelMonth.text = "Month: opening"
        labelPaid.text = "Paid: 0.00"
    }
    
}
