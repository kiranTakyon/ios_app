//
//  NoticeBoardListTableViewCell.swift
//  Ambassador Education
//
//  Created by apple on 20/06/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit

class NoticeBoardListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageUserProfile: ImageLoader!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var cellBackView: CardView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
