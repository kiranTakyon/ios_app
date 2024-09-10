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
import SwiftJWT

protocol NotificationsViewDelegate: AnyObject {
    func notificationsView(_ view: NotificationsView, didTapOnNotification notification: TNotification)
    func notificationsView(_ view: NotificationsView, didTapOnStogoImageWith url: String)
    func removeNoNotificationdataLabel()
    func didTapOnUpcomingEventView()
}

class NotificationsView: UIView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageViewStogoLogo: UIImageView!
    @IBOutlet weak var upcomingEventView: UIView!

    var notificationList = [TNotification]()
    var selectedIndexes: [Int] = []
    private lazy var refresher = IQPullToRefresh(scrollView: tableView, refresher: self, moreLoader: self)
    var pageIndex = 0
    private var communicateImages:[String] = ["communicate1","communicate2","communicate3"]
    private var noticeboardImages:[String] = ["noticeboard1","noticeboard2","noticeboard3"]
    private var weeklyPlanImages:[String] = ["awarnessand1","awarnessand2","awarnessand3"]
    private var busImages:[String] = ["bus1","bus2","bus3"]
    private var htmlTypeImages:[String] = ["digitalresourse1","digitalresourse2","digitalresourse3"]
    private var galleryImages:[String] = ["gallery1","gallery2","gallery3"]
    private var currentlyPlayingCell: NotificationsTableViewCell?

    weak var delegate: NotificationsViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
        tableView.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationsTableViewCell")
        upcomingEventView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        tableView.delegate = self
        tableView.dataSource = self
        refresher.enableLoadMore = true

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBAction func didTapOnStogoImage(_ sender: UIButton) {
        if let stringUrl = JWTHelper.shared.getStogoUrl() {
            delegate?.notificationsView(self, didTapOnStogoImageWith: stringUrl)
        }
    }

    @IBAction func didTapOnUpcomingEventView(_ sender: UIButton) {
        delegate?.didTapOnUpcomingEventView()
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
        let imageToEmoji: [String: String] = [
            "wow": "😮",
            "love": "❤️",
            "like": "👍",
            "clapping_hand": "👏",
            "party_popper": "💡"
        ]

        let notification = notificationList[indexPath.row]

        cell.playIcon.isHidden = true
        cell.videoPlayerView.isHidden = !isVideoURL(notification.url ?? "")
        cell.typeImageV.isHidden = isVideoURL(notification.url ?? "")

        if let titel = notification.title{
            cell.alertTitle.numberOfLines = 1
            cell.alertTitle.text = titel
        }

//        if selectedIndexes.contains(indexPath.row) {
//            cell.alertTitle.numberOfLines = 0
//            cell.buttonArrow.isSelected = true
//        } else {
//            cell.buttonArrow.isSelected = false
//        }

        if let date = notification.date {
            cell.alertDate.text = Date().setDateFormatter(string: date)
            cell.labelTime.text = Date().getTimeFromDate(date: date)
        }

        if let msgType = notification.type {
            switch msgType {
            case msgTypes.communicate.rawValue:
                let index = indexPath.row % communicateImages.count
                let image = communicateImages[index]
                if let url = notification.url, !url.isEmpty  {
                    cell.typeImageV.loadImageWithUrl(url)
                } else {
                    cell.typeImageV.image = UIImage(named: image)
                }
                cell.typeImageView.image = #imageLiteral(resourceName: "email_notification")
                cell.labelTitle.text = "Mail"

            case msgTypes.weeklyPlan.rawValue:
                let index = indexPath.row % weeklyPlanImages.count
                let image = weeklyPlanImages[index]
                if let url = notification.url, !url.isEmpty  {
                    cell.typeImageV.loadImageWithUrl(url)
                } else {
                    cell.typeImageV.image = UIImage(named: image)
                }
                cell.typeImageView.image = #imageLiteral(resourceName: "Notice")
                cell.labelTitle.text = "weekly Plan"

            case msgTypes.noticeboard.rawValue:
                let index = indexPath.row % noticeboardImages.count
                let image = noticeboardImages[index]
                if let url = notification.url, !url.isEmpty  {
                    cell.typeImageV.loadImageWithUrl(url)
                } else {
                    cell.typeImageV.image = UIImage(named: image)
                }
                cell.typeImageView.image = #imageLiteral(resourceName: "Notice")
                cell.labelTitle.text = "Noticeboard"

            case msgTypes.bus.rawValue:
                let index = indexPath.row % busImages.count
                let image = busImages[index]
                if let url = notification.url, !url.isEmpty  {
                    cell.typeImageV.loadImageWithUrl(url)
                } else {
                    cell.typeImageV.image = UIImage(named: image)
                }
                cell.typeImageView.image = #imageLiteral(resourceName: "bus_icon")
                cell.labelTitle.text = "Bus fare"

            case msgTypes.htmlType.rawValue:
                let index = indexPath.row % htmlTypeImages.count
                let image = htmlTypeImages[index]
                if let url = notification.url, !url.isEmpty {
                    cell.typeImageV.loadImageWithUrl(url)
                } else {
                    cell.typeImageV.image = UIImage(named: image)
                }
                cell.typeImageView.image =  #imageLiteral(resourceName: "email_notification")
                cell.labelTitle.text = "Digital Resources"

            case msgTypes.gallery.rawValue:
                let index = indexPath.row % galleryImages.count
                let image = galleryImages[index]
                if let url = notification.url, !url.isEmpty  {
                    cell.typeImageV.loadImageWithUrl(url)
                } else {
                    cell.typeImageV.image = UIImage(named: image)
                }
                cell.typeImageView.image = #imageLiteral(resourceName: "Gallary")
                cell.labelTitle.text = "Gallery"
                
            case msgTypes.feeds.rawValue:
                if let url = notification.url, !url.isEmpty,!isVideoURL(url) {
                    cell.typeImageV.loadImageWithUrl(url)
                } else {
                    cell.typeImageV.image = UIImage(named: "NoticeImage")
                }
                cell.typeImageView.image = #imageLiteral(resourceName: "Notice")
                cell.labelTitle.text = "Feed"

            default:
                if let url = notification.url, !url.isEmpty,!isVideoURL(url) {
                    cell.typeImageV.loadImageWithUrl(url)
                } else {
                    cell.typeImageV.image = UIImage(named: "NoticeImage")
                }
                cell.typeImageView.image = #imageLiteral(resourceName: "Notice")
                cell.labelTitle.text = "Notice"

            }
        }

        if let cellReactions = notification.reactions {

            if cellReactions.totalReactionCount > 0 {
                cell.setUpReaction(reactions: cellReactions)
            } else {
                cell.reactionHeightConstraint.constant = 0
            }
        }

        if let url = notification.url, isVideoURL(url) {
            cell.setUpVideoView(url: url)
            if indexPath.row == 0 {
                cell.playVideo()
            }
        }
        print("type value is :- ",notification.type)

        cell.selectionStyle = .none
        print("usrReactionType is :",notification.usrReactionType)
        //cell.buttonEmojiDidTap.setTitle("\(imageToEmoji[notification.usrReactionType ?? "😀"] ?? "")", for: .normal)
        if let reactionType = notification.usrReactionType {
            cell.buttonEmojiDidTap.setTitle("\(imageToEmoji[reactionType] ?? "")", for: .normal)
        } else {
            cell.buttonEmojiDidTap.setTitle("😀", for: .normal)
        }

        return cell
    }

}


extension NotificationsView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        playVisibleVideo()
    }

    func playVisibleVideo() {
        let visibleCells = tableView.visibleCells.compactMap { $0 as? NotificationsTableViewCell }

        for cell in visibleCells {
            if isCellFullyVisible(cell) {
                cell.playVideo()
            } else {
                cell.pauseVideo()
            }
        }
    }

    func isCellFullyVisible(_ cell: UITableViewCell) -> Bool {
        guard let indexPath = tableView.indexPath(for: cell) else { return false }
        let cellRect = tableView.rectForRow(at: indexPath)
        let completelyVisible = tableView.bounds.contains(cellRect)
        return completelyVisible
    }
}


// MARK: - NotificationsTableViewCellDelegate -

extension NotificationsView: NotificationsTableViewCellDelegate {

    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didSelectEmoji emoji: String, type: String, index: Int) {
        apiPostSocialMedia(action: "like", type: type, emoji: emoji,index: index)
    }

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
    
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didProfileTapped button: UIButton, index: Int) {
        if let stringUrl = JWTHelper.shared.getStogoUrlWithProfil() {
            print(stringUrl)
            gotoWeb(str: stringUrl)
        }
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
    // open stego url
    func gotoWeb(str : String) {
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.strU = str
        parentViewController?.navigationController?.isNavigationBarHidden = true
        parentViewController?.navigationController?.pushViewController(vc, animated: true)
    }
}


extension NotificationsView {
    func apiForLoadMore(pageNumber: Int, complition: @escaping() -> ()) {
        let url = APIUrls().notification
        var dictionary = [String:Any]()
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] =  userId
        dictionary["paginationNumber"] =  pageNumber + 1

        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            print(result)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                complition()
                guard let nototificationsArray = result["Notification"] as? NSArray else{return}
                let notifications = ModelClassManager.sharedManager.createModelArray(data: nototificationsArray, modelType: ModelType.TNotification) as! [TNotification]
                self.notificationList.append(contentsOf: notifications)
                self.refresher.enableLoadMore = notifications.count > 0
                if self.notificationList.count > 0 {
                    self.delegate?.removeNoNotificationdataLabel()
                }
                self.notificationList = self.notificationList.unique()
                self.tableView.reloadData()
            }
        }
    }

    func apiPostSocialMedia(action: String, type: String, emoji: String = "", index: Int = -1) {
        let url = APIUrls().postSocialMedia
        var dictionary = [String:Any]()
        let notification = notificationList[index]
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] =  userId
        dictionary["AlertId"] =  notification.alertId ?? 0
        dictionary["Action"] =  action
        dictionary["Type"] =  type

        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            print(result)

            DispatchQueue.main.async {
                notification.changeUserReactionType(type: type)
                self.tableView.reloadData()
            }
        }
    }

    func isVideoURL(_ urlString: String) -> Bool {
        let videoExtensions = Set(["mp4", "m4v", "mov", "avi", "mkv", "flv", "wmv", "webm"])
        guard let url = URL(string: urlString) else {
            return false
        }
        let pathExtension = url.pathExtension.lowercased()
        return videoExtensions.contains(pathExtension)
    }
}

