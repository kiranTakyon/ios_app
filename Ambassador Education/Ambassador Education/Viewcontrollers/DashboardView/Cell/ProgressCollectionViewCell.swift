//
//  ProgressCollectionViewCell.swift
//  Ambassador Education
//
//  Created by IE14 on 25/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit

class ProgressCollectionViewCell: UICollectionViewCell {
    
    static var identifier = "ProgressCollectionViewCell"

    @IBOutlet weak var containView: UIView!
    @IBOutlet private var circularProgressHome: CircularProgressView!
    @IBOutlet private var headingLable: UILabel!
    @IBOutlet private var persentageLabel: UILabel!
    
    var data: TProgressTypeModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let data = data{
            updateUILabels(with: data)
        }
        circularProgressHome.progress = 0.75
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func updateUILabels(with model: TProgressTypeModel) {
        var progressValue: Double = 0.0
        var labelText: String = "0"
        
        if let quiz = model.quizPercentage {
            labelText = "Quiz: \(quiz)%"
            progressValue = Double(quiz) / 100.0
        } else if let challenges = model.challengesPercentage {
            labelText = "Challenges: \(challenges)%"
            progressValue = Double(challenges) / 100.0
        } else if let journey = model.journeyPercentage {
            labelText = "Journey: \(journey)%"
            progressValue = Double(journey) / 100.0
        } else if let fuel = model.fuelPercentage {
            labelText = "Fuel: \(fuel)%"
            progressValue = Double(fuel) / 100.0
        }
        
        persentageLabel.text = labelText
        circularProgressHome.progress = CGFloat(progressValue)
    }

}
