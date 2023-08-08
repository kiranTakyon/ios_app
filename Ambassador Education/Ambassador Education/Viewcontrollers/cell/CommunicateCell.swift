//
//  CommunicateCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 07/08/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation
import UIKit


class CommunicateCell : UITableViewCell{
    
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var cImageView: ImageLoader!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var ReadIcon: UIImageView!
    @IBOutlet weak var ReadStatus: UILabel!
    @IBOutlet weak var attachHeight: NSLayoutConstraint!
    
    var imageUrl : String = ""{
        
        didSet{
            self.setImage()
        }
    }
    
    func setImage(){
        self.cImageView.loadImageWithUrl(imageUrl)
    }
    
}
