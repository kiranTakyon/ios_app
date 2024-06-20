//
//  NotificationsTableViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 25/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit

protocol NotificationsTableViewCellDelegate: AnyObject {
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didTapOnArrow button: UIButton, index: Int)
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didTapCell button: UIButton, index: Int)
}

class NotificationsTableViewCell: UITableViewCell {
    
    //MARK: - IBOutlet's -
    
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertDate: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var buttonArrow: UIButton!
    @IBOutlet weak var typeImageV: UIImageView!
    
    
    weak var delegate: NotificationsTableViewCellDelegate?
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
        delegate?.notificationsTableViewCell(self, didTapOnArrow: sender, index: index)
    }
    
    @IBAction func buttonCellDidTap(_ sender: UIButton) {
        delegate?.notificationsTableViewCell(self, didTapCell: sender, index: index)
    }
    
}
