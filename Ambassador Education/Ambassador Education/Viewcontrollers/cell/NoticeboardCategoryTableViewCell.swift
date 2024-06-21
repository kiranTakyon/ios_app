//
//  NoticeboardCategoryTableViewCell.swift
//  Ambassador Education
//
//  Created by apple on 20/06/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit

protocol NoticeboardCategoryTableViewCellDelegate: AnyObject {
    func noticeboardCategoryTableViewCell(_ cell: NoticeboardCategoryTableViewCell, didTapOnArrowButton button: UIButton, withIndex index: Int)
    
    func noticeboardCategoryTableViewCell(_ cell: NoticeboardCategoryTableViewCell, didSelectCellwithIndex index: Int, item: TNNoticeBoardDetail)
}

class NoticeboardCategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateView: UIView!
    @IBOutlet weak var imageUserProfile: ImageLoader!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var imageIndi: UIImageView!
    @IBOutlet weak var heightDateView: NSLayoutConstraint!
    @IBOutlet weak var labelDateTime: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var arrowButton: UIButton!
    
    var listValues : [TNNoticeBoardDetail]?
    var tempValue : [TNNoticeBoardDetail]?
    var sideViewColors: [String] = ["5CB0D7","685AEB","E47763"]
    var itemCellColors: [String] = ["CCCCFD","D7FBD1","F4CDCF"]
    
    weak var delegate: NoticeboardCategoryTableViewCellDelegate?
    var index: Int = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        sideView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
        tableView.delegate = self
        tableView.dataSource = self
        tableViewHeight.constant = 0
        tableView.isHidden = true
        labelDate.isHidden = true
        moreButton.isHidden = true
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setUpCell(category : TNNoticeboardCategory)  {
        tableView.register(UINib(nibName: "NoticeBoardListTableViewCell", bundle: nil), forCellReuseIdentifier: "NoticeBoardListTableViewCell")
        if let title = category.category {
            labelTitle.text = title
        }
        if let item = category.Items as? [TNNoticeBoardDetail] {
            if item.count > 0 {
                if let img  = item[0].image {
                    imageUserProfile.loadImageWithUrl(img)
                }
                
                if let date = item[0].date {
                    labelDate.text = date
                    labelDateTime.text = date
                }
            }
            
            let colorIndex = index % sideViewColors.count
            let hexString = sideViewColors[colorIndex]
            
            sideView.backgroundColor = UIColor(named: hexString)
            listValues = item
            tableView.reloadData()
        }
    }
    
    
    @IBAction func didTapOnArrowButton(_ sender: UIButton) {
        delegate?.noticeboardCategoryTableViewCell(self, didTapOnArrowButton: sender, withIndex: index)
    }
    
    @IBAction func didTapOnMoreButton(_ sender: Any) {
        
    }
}


extension NoticeboardCategoryTableViewCell: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let values = listValues {
            return values.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBoardListTableViewCell", for: indexPath) as? NoticeBoardListTableViewCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        let item = listValues?[indexPath.row]
        cell.labelTitle.text = item?.title
        if let _ = item?.thumbnail{
            cell.imageUserProfile.loadImageWithUrl(item!.thumbnail!)
        }
        
        let colorIndex = indexPath.row % itemCellColors.count
        let hexString = itemCellColors[colorIndex]
        
        cell.cellBackView.backgroundColor = UIColor(named: hexString)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if let item = self.listValues?[indexPath.row]{
            delegate?.noticeboardCategoryTableViewCell(self, didSelectCellwithIndex: index, item: item)
        }
    }
}
