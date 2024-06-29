//
//  CalendarTableViewCell.swift
//  Ambassador Education
//
//  Created by apple on 29/06/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit
import MBCalendarKit

class CalendarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageUserProfile: ImageLoader!
    @IBOutlet weak var labelDiscription: UILabel!
    @IBOutlet weak var labelDateTime: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var sideView: UIView!
    
    var sideViewColors: [String] = ["5CB0D7","685AEB","E47763"]
    var index: Int = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sideView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(event: CalendarEvent) {
        let colorIndex = index % sideViewColors.count
        let hexString = sideViewColors[colorIndex]
        
        sideView.backgroundColor = UIColor(named: hexString)
        labelTitle.textColor = UIColor(named: hexString)
        labelTitle.text = event.title
        labelDiscription.text = ""
        labelDateTime.text = formatDateToString(date: event.date)
        imageUserProfile.loadImageWithUrl("")
    }
    
    func formatDateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: date)
    }
    
}
