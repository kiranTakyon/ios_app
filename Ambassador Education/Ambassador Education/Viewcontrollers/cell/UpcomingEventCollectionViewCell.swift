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
    @IBOutlet weak var cellBorderView: UIView!

    var borderColor = ["FF6666","91D0DF"]
    var index: Int = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setupCell(event: TUpcomingEvent) {

        tittleLabel.text = event.title ?? ""

        if let url = event.image {
            eventImageView.loadImageWithUrl(url)
        }
        let index = index % borderColor.count
        let color = borderColor[index]
        cellBorderView.backgroundColor = UIColor(named: color)
    }

}
