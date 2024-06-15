//
//  NotificationMailTableViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 24/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit

protocol NotificationMailTableViewCellDelegate: AnyObject {
    func notificationMailTableViewCell(_ cell: NotificationMailTableViewCell, didTapOnArrow button: UIButton, index: Int)
    func notificationMailTableViewCell(_ cell: NotificationMailTableViewCell, didTapCell button: UIButton, index: Int)
}

class NotificationMailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertDate: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var buttonArrow: UIButton!
    
    weak var delegate: NotificationMailTableViewCellDelegate?
    var index: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonArrowDidTap(_ sender: UIButton) {
        delegate?.notificationMailTableViewCell(self, didTapOnArrow: sender, index: index)
    }
    
    @IBAction func buttonCellDidTap(_ sender: UIButton) {
        delegate?.notificationMailTableViewCell(self, didTapCell: sender, index: index)
    }
}
