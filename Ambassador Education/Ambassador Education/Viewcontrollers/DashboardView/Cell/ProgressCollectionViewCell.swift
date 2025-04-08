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
        if let data = data {
            updateUILabels(with: data)
        }
        circularProgressHome.progress = 0.75
    }
    
    func setProgressData(data: TProgressTypeModel) {
        self.data = data
        updateUILabels(with: data)
    }
    
    func updateUILabels(with model: TProgressTypeModel) {
        var progressValue: Double = 0.0
        var headingLabelText: String = "0"
        var percentage = 0
        
        if let quiz = model.quizPercentage {
            percentage = quiz
            headingLabelText = "Quiz: \(quiz)%"
            progressValue = Double(quiz) / 100.0
        } else if let challenges = model.challengesPercentage {
            percentage = challenges
            headingLabelText = "Challenges: \(challenges)%"
            progressValue = Double(challenges) / 100.0
        } else if let journey = model.journeyPercentage {
            percentage = journey
            headingLabelText = "Journey: \(journey)%"
            progressValue = Double(journey) / 100.0
        } else if let fuel = model.fuelPercentage {
            percentage = fuel
            headingLabelText = "Fuel: \(fuel)%"
            progressValue = Double(fuel) / 100.0
        }
        
        headingLable.text = headingLabelText
        persentageLabel.text = "\(percentage)%"
        circularProgressHome.progress = CGFloat(progressValue)
    }

}
