//
//  NotificationTableViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 24/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit



class NotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var tableView: UITableView!
    
    var notificationList = [TNotification]()
    var selectedIndexes: [Int] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.register(UINib(nibName: "NotificationMailTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationMailTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}


extension NotificationTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return notificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationMailTableViewCell", for: indexPath) as? NotificationMailTableViewCell else { return UITableViewCell()}
        cell.delegate = self
        let notification = notificationList[indexPath.row]
        cell.index = indexPath.row
        if let titel = notification.title {
            cell.alertTitle.numberOfLines = 1
            cell.alertTitle.text = titel
        }
        
        if selectedIndexes.contains(indexPath.row) {
            cell.alertTitle.numberOfLines = 0
            cell.buttonArrow.isSelected = true
        } else {
            cell.buttonArrow.isSelected = false
        }
        
        if let date = notification.date {
            cell.alertDate.text = Date().getDateAgoDisplay(date: date)
            
        }
        
        if let msgType = notification.type {
            switch msgType {
            case msgTypes.communicate.rawValue:
                cell.typeImageView.image = #imageLiteral(resourceName: "email_notification")
                cell.labelTitle.text = "Mail"
            case msgTypes.noticeboard.rawValue,msgTypes.weeklyPlan.rawValue:
                cell.typeImageView.image = #imageLiteral(resourceName: "Notice")
                cell.labelTitle.text = "weekly Plan"
                
            case msgTypes.bus.rawValue:
                cell.typeImageView.image = UIImage(named: "bus_icon")
                cell.labelTitle.text = "Bus fare"
                
            case msgTypes.htmlType.rawValue:
                cell.typeImageView.image =  #imageLiteral(resourceName: "email_notification")
                cell.labelTitle.text = "Mail"
                
            case msgTypes.gallery.rawValue:
                cell.typeImageView.image = #imageLiteral(resourceName: "Gallary")
                cell.labelTitle.text = "Gallery"
                
            default:
                cell.typeImageView.image = #imageLiteral(resourceName: "Notice")
                cell.labelTitle.text = "Notice"
                
            }
        }
        
        print("type value is :- ",notification.type)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}


extension NotificationTableViewCell: NotificationMailTableViewCellDelegate {
    func notificationMailTableViewCell(_ cell: NotificationMailTableViewCell, didTapOnArrow button: UIButton, index: Int) {
        
        if let index = selectedIndexes.firstIndex(of: index) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(index)
        }
        tableView.reloadData()
    }
    
}
