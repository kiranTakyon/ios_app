//
//  CommunicationTableViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 07/08/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit

protocol CommunicationTableViewCellDelegate: AnyObject {
    func communicationTableViewCell(_ cell: CommunicationTableViewCell, didTapOnCellWithIndex index: Int)
}

class CommunicationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelMessageType: UILabel!
    @IBOutlet weak var labelHeading: UILabel!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var ReadIcon: UIImageView!
    @IBOutlet weak var ReadStatus: UILabel!
   
    var index: Int = -1
    weak var delegate: CommunicationTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func didTapOnCell(_ sender: Any) {
        delegate?.communicationTableViewCell(self, didTapOnCellWithIndex: index)
    }
}
