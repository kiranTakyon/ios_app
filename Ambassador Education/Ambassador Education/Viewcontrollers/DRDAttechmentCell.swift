//
//  DRDAttechmentCell.swift
//  Ambassador Education
//
//  Created by Jashu Prajapati on 11/05/21.
//  Copyright © 2021 InApp. All rights reserved.
//

import UIKit
protocol DRDAttechmentCellDelegate {
    func downLoadMylink(index: Int)
}

class DRDAttechmentCell: UITableViewCell {

    var delegate : DRDAttechmentCellDelegate?
    
    @IBOutlet weak var downldLabel: UILabel!
    @IBOutlet weak var btnDownload: UIButton!
    
    @IBAction func dwnloadButtnAction(_ sender: UIButton) {
        self.delegate?.downLoadMylink(index: self.tag)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
