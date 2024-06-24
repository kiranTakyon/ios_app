//
//  WPTableViewCell.swift
//  Ambassador Education
//
//  Created by apple on 24/06/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit

protocol WPTableViewCellDelegate: AnyObject {
    func wPTableViewCell(_ cell: WPTableViewCell, didTapOnArrow button: UIButton, index: Int)
}

class WPTableViewCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonArrow: UIButton!
    @IBOutlet weak var attachmntButtnHeight: NSLayoutConstraint!
    @IBOutlet weak var attachmntButtn: UIButton!
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
    var index: Int = -1
    weak var delegate: WPTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonArrowDidTap(_ sender: UIButton) {
        delegate?.wPTableViewCell(self, didTapOnArrow: sender, index: index)
    }
}
