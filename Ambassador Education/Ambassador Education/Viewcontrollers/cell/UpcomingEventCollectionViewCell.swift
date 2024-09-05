//
//  UpcomingEventCollectionViewCell.swift
//  Ambassador Education
//
//  Created by Mayur Shrivas on 05/09/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit

class UpcomingEventCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var tittleLabel: UILabel!
    @IBOutlet weak var eventImageView: ImageLoader!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(event: TUpcomingEvent) {

        tittleLabel.text = event.title ?? ""

        if let url = event.image {
            eventImageView.loadImageWithUrl(url)
        }
    }

}
