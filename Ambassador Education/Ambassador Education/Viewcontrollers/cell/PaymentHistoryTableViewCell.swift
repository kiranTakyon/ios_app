//
//  PaymentHistoryTableViewCell.swift
//  Ambassador Education
//
//  Created by apple on 25/06/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit

class PaymentHistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelRecipt: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelAmount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(payment: TNPayment) {
        labelRecipt.text = "Receipt No \(payment.receiptNo ?? "")"
        labelDate.text = "Date \(payment.date ?? "")"
        labelAmount.text = "Amount \(payment.amount ?? "")"
    }
    
}
