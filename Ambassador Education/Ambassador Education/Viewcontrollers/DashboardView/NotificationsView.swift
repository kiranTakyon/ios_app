//
//  NotificationsView.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 27/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import Foundation
import UIKit
import IQPullToRefresh

protocol NotificationsViewDelegate: AnyObject {
    func notificationsView(_ view: NotificationsView, didTapOnNotification notification: TNotification)
}

class NotificationsView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    var notificationList = [TNotification]()
    var selectedIndexes: [Int] = []
    private lazy var refresher = IQPullToRefresh(scrollView: tableView, refresher: self, moreLoader: self)
    var pageIndex = 0
    weak var delegate: NotificationsViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
        tableView.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        refresher.enableLoadMore = true

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}



//MARK: - UITableViewDelegate,UITableViewDataSource -

extension NotificationsView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTableViewCell", for: indexPath) as? NotificationsTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.index = indexPath.row
        
        let notification = notificationList[indexPath.row]
        
        if let titel = notification.title{
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
            cell.alertDate.text = Date().setDateFormatter(string: date)
            cell.labelTime.text = Date().getTimeFromDate(date: date)
        }
        
        if let msgType = notification.type{
            switch msgType {
            case msgTypes.communicate.rawValue:
                cell.typeImageV.image = UIImage(named: "emailImage")
                cell.typeImageView.image = #imageLiteral(resourceName: "email_notification")
                cell.labelTitle.text = "Mail"
                
            case msgTypes.noticeboard.rawValue,msgTypes.bus.rawValue,msgTypes.weeklyPlan.rawValue:
                cell.typeImageV.image = UIImage(named: "NoticeImage")
                cell.typeImageView.image = #imageLiteral(resourceName: "Notice")
                cell.labelTitle.text = "weekly Plan"
                
            case msgTypes.htmlType.rawValue:
                cell.typeImageV.image = UIImage(named: "emailImage")
                cell.typeImageView.image =  #imageLiteral(resourceName: "email_notification")
                cell.labelTitle.text = "Mail"
                
            case msgTypes.gallery.rawValue:
                cell.typeImageV.image = UIImage(named: "photoGalleryImage")
                cell.typeImageView.image = #imageLiteral(resourceName: "Gallary")
                cell.labelTitle.text = "Gallery"
                
            default:
                cell.typeImageV.image = UIImage(named: "NoticeImage")
                cell.typeImageView.image = #imageLiteral(resourceName: "Notice")
                cell.labelTitle.text = "Notice"
                
            }
        }
        
        print("type value is :- ",notification.type)
        
        cell.selectionStyle = .none
        return cell
    }
    
}


// MARK: - NotificationsTableViewCellDelegate -

extension NotificationsView: NotificationsTableViewCellDelegate {
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didTapCell button: UIButton, index: Int) {
        delegate?.notificationsView(self, didTapOnNotification: notificationList [index])
    }
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didTapOnArrow button: UIButton, index: Int) {
        if let index = selectedIndexes.firstIndex(of: index) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(index)
        }
        delegate?.notificationsView(self, didTapOnNotification: notificationList [index])
        tableView.reloadData()
    }
}


// MARK: - MoreLoadable, Refreshable -

extension NotificationsView: Refreshable, MoreLoadable {
    
    func refreshTriggered(type: IQPullToRefresh.RefreshType, loadingBegin: @escaping (Bool) -> Void, loadingFinished: @escaping (Bool) -> Void) {
        
        print("refresh!!!!!")
    }
    
    func loadMoreTriggered(type: IQPullToRefresh.LoadMoreType, loadingBegin: @escaping (Bool) -> Void, loadingFinished: @escaping (Bool) -> Void) {
        pageIndex += 1
        loadingBegin(true)
        apiForLoadMore(pageNumber: pageIndex) {
            loadingFinished(true)
        }
    }
}


extension NotificationsView {
    func apiForLoadMore(pageNumber: Int, complition: @escaping() -> ()) {
        let url = APIUrls().notification
        var dictionary = [String:Any]()
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] =  userId
        dictionary["paginationNumber"] =  pageNumber
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            print(result)
            DispatchQueue.main.async {
                complition()
                guard let nototificationsArray = result["Notification"] as? NSArray else{return}
                let notifications = ModelClassManager.sharedManager.createModelArray(data: nototificationsArray, modelType: ModelType.TNotification) as! [TNotification]
                self.notificationList.append(contentsOf: notifications)
                self.refresher.enableLoadMore = notifications.count > 0
                self.tableView.reloadData()
            }
        }
    }
}
