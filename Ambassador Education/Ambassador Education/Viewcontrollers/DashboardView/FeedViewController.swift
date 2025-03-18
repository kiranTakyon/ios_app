//
//  FeedViewController.swift
//  Ambassador Education
//
//  Created by IE14 on 21/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit
import IQPullToRefresh
import EzPopup
import AVFoundation
import AVKit

var isFirstTime = true
enum alertType:String{
    case gallery        = "GAL"
    case html           = "HTML"
    case communicate    = "INTM"
    case noticeboard    = "NWS"
    case weeklyPlan     = "HMW"
    case bus            = "BUS"
    case feeds        =  "SWFeeds"
}

enum msgTypes : String{

    case gallery        = "GAL"
    case htmlType       = "HTML"
    case communicate    = "INTM"
    case noticeboard    = "NWS"
    case weeklyPlan     = "HWM"
    case bus           = "BUS"
    case feeds         = "SWFeeds"

}


var selectedAlertType : alertType = .gallery
var notificationObject : TNotification = TNotification(values: NSDictionary())

class FeedViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageViewStogoLogo: UIImageView!
    @IBOutlet weak var upcomingEventView: UIView!
    @IBOutlet weak var studentImageView: ImageLoader!
    @IBOutlet weak var studentSecondLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var classLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    @IBOutlet weak var bellContainerView: UIView!
    
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    var notificationList = [TNotification]()
    var moduleList = [TModule]()
    var NoticeBoardItems = [TNNoticeBoardDetail]()
    var upcomingEvents = [TUpcomingEvent]()
    var buttonOrigin : CGPoint = CGPoint(x: 0, y: 0)
    var selectedIndexes: [Int] = []
    var pageIndex = 0
    private var communicateImages:[String] = ["communicate1","communicate2","communicate3"]
    private var noticeboardImages:[String] = ["noticeboard1","noticeboard2","noticeboard3"]
    private var weeklyPlanImages:[String] = ["awarnessand1","awarnessand2","awarnessand3"]
    private var busImages:[String] = ["bus1","bus2","bus3"]
    private var htmlTypeImages:[String] = ["digitalresourse1","digitalresourse2","digitalresourse3"]
    private var galleryImages:[String] = ["gallery1","gallery2","gallery3"]
    private var currentlyPlayingCell: NotificationsTableViewCell?
    private lazy var refresher = IQPullToRefresh(scrollView: tableView, refresher: self, moreLoader: self)
    private var upcomingShadowView: UIView!
    private var upcomingRevealWidth: CGFloat = 300
    private let paddingForRotation: CGFloat = 150
    private var isExpanded: Bool = false
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0
    private var upComingEventViewController: UpComingEventViewController!
    private var revealSideMenuOnTop: Bool = true

    let popUpHeight = UIScreen.main.bounds.height - 150
    let popUpWidth = UIScreen.main.bounds.width - 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bellContainerView.layer.cornerRadius = 15
        bellContainerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner] 
        self.navigationController?.navigationBar.isHidden = true
        setTableView()
        showUpComingEventView()
        setAllTextFieldsEmpty()
        getTokenValueForMobileNotification()
        addObserverToNotification()
        topHeaderView.delegate = self        
    }
    
    func setAllTextFieldsEmpty(){
        studentNameLabel.text = ""
        studentSecondLabel.text = ""
    }
    
    func setTableView(){
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
        tableView.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: "NotificationsTableViewCell")
        upcomingEventView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        tableView.delegate = self
        tableView.dataSource = self
        refresher.enableLoadMore = true
    }
    
    func getTokenValueForMobileNotification(){
        let url = APIUrls().mobileNotification
        var dictionary = [String:Any]()
        if let token = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.gcmToken) as? String{
            let userId = UserDefaultsManager.manager.getUserId()
            dictionary[UserIdKey().id] = userId
            dictionary["RegId"] = token
            dictionary["PhoneType"] = 1
            APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                }
            }
        }
    }
    
    func addObserverToNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(notified(notification:)), name: Notification.Name(rawValue: "HomeChnageWithSiblings"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionExpired), name: Notification.Name(rawValue: "SessionExpired"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setProfileImageToRound()
        if isFirstTime {
            isFirstTime = false
            let shoudShowBirthdayWish = UserDefaults.standard.bool(forKey: DBKeys.shouldShowBirthdayWish)
            if shoudShowBirthdayWish {
                let storyBoard = UIStoryboard(name: "Common", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "BirthdayViewController") as! BirthdayViewController

                let popupVC = PopupViewController(contentController: vc, popupWidth: 300, popupHeight: 500)
                self.present(popupVC, animated: true)
            } else {
                print("condition false")
            }
        }

        if sibling {
            postLogIn(id: siblingUserId)
        } else {
            let userId = UserDefaultsManager.manager.getUserId()
            setNotitificationList(id : userId)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    @IBAction func didTapOnStogoImage(_ sender: UIButton) {
        if let stringUrl = JWTHelper.shared.getStogoUrl() {
            gotoWeb(str : stringUrl)
        }
    }

    @IBAction func didTapOnUpcomingEventView(_ sender: UIButton) {
        openUpComingEvent()
    }
    
    func gotoWeb(str : String) {
        let vc = commonStoryBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.strU = str
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapOnUpcomingEventView() {
        openUpComingEvent()
    }
    
    func openUpComingEvent() {
        sideMenuState(expanded: self.isExpanded ? false : true)
    }
    
    func setProfileImageToRound() {
        studentImageView.contentMode = .scaleAspectFill
        studentImageView.layer.cornerRadius = 42
        studentImageView.clipsToBounds = true
        self.studentImageView.layer.borderWidth = 1
        self.studentImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    func sideMenuState(expanded: Bool) {
        if expanded {
            self.upComingEventViewController.upcomingEvents = upcomingEvents

            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                self?.upComingEventViewController.collectionView.reloadData()
            }
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? 0 : -self.upcomingRevealWidth) { _ in
                self.isExpanded = true
            }
            UIView.animate(withDuration: 0.5) { self.upcomingShadowView.alpha = 0.6 }
        }
        else {
            self.animateSideMenu(targetPosition: self.revealSideMenuOnTop ? self.upcomingRevealWidth : 0) { _ in
                self.isExpanded = false
            }
            UIView.animate(withDuration: 0.5) { self.upcomingShadowView.alpha = 0.0 }
        }
    }
    
    func animateSideMenu(targetPosition: CGFloat, completion: @escaping (Bool) -> ()) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .layoutSubviews, animations: {
            if self.revealSideMenuOnTop {
                self.sideMenuTrailingConstraint.constant = targetPosition
                self.view.layoutIfNeeded()
            } else {
                self.view.subviews[1].frame.origin.x = targetPosition
            }
        }, completion: completion)
    }

}



//MARK: - UITableViewDelegate,UITableViewDataSource -

extension FeedViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationsTableViewCell", for: indexPath) as? NotificationsTableViewCell else { return UITableViewCell() }
        cell.delegate = self
        cell.index = indexPath.row
        let imageToEmoji: [String: String] = [
            "wow": "😮 ",
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
               // cell.reactionHeightConstraint.constant = 0
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


extension FeedViewController: UIScrollViewDelegate {
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

extension FeedViewController: NotificationsTableViewCellDelegate {

    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didSelectEmoji emoji: String, type: String, index: Int) {
        apiPostSocialMedia(action: "like", type: type, emoji: emoji,index: index)
    }

    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didTapCell button: UIButton, index: Int) {
        //delegate?.notificationsView(self, didTapOnNotification: notificationList [index])
        didTapOnNotification(notification:notificationList [index])
    }
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didTapOnArrow button: UIButton, index: Int) {
        if let index = selectedIndexes.firstIndex(of: index) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(index)
        }
        didTapOnNotification(notification:notificationList [index])
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

extension FeedViewController: Refreshable, MoreLoadable {

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


extension FeedViewController {
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
                    self.removeNoDataLabel()
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
}

extension FeedViewController{
    
    func setStudentDetailsOnView(studentDetail: NSDictionary){
        if studentDetail != nil {
            guard let user = UserDefaultsManager.manager.getUserType() as? String else{

            }
            if user == UserType.parent.rawValue || user == UserType.student.rawValue{
                if let studentName = studentDetail["StudentName"] as? String{
                    studentNameLabel.text = studentName
                }
                if let name = studentDetail["Name"] as? String{
                    studentSecondLabel.text = name
                }
            }
            else{
                if let dict = logInResponseGloabl as? NSDictionary{
                    if let schoolName = dict["SchoolName"] as? String{
                        studentSecondLabel.text = schoolName
                    }
                    if let name = studentDetail["Name"] as? String{
                        studentNameLabel.text = name
                    }
                }
            }
            if let studentClass = studentDetail["Class"] as? String{
                if studentClass != ""{
                    classLabel.text =  studentClass
                }
            }
            if let proImage = studentDetail["ProfileImage"] as? String{
                self.studentImageView.loadImageWithUrl(proImage)

            }
        }
    }
    
    func showUpComingEventView() {

        // Shadow Background View
        self.upcomingShadowView = UIView(frame: self.view.bounds)
        self.upcomingShadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.upcomingShadowView.backgroundColor = .black
        self.upcomingShadowView.alpha = 0.0
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TapGestureRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        self.upcomingShadowView.addGestureRecognizer(tapGestureRecognizer)
        if self.revealSideMenuOnTop {
            view.insertSubview(self.upcomingShadowView, at: 6)
        }

        guard let upComingEventViewController = upcomingEvent.instantiateViewController(withIdentifier: "UpComingEventViewController") as? UpComingEventViewController else { return }
        upComingEventViewController.delegate = self
        self.upComingEventViewController = upComingEventViewController
        view.insertSubview(upComingEventViewController.view, at: self.revealSideMenuOnTop ? 6 : 0)
        addChild(upComingEventViewController)
        upComingEventViewController.didMove(toParent: self)

        // UpComingEvent AutoLayout

        upComingEventViewController.view.translatesAutoresizingMaskIntoConstraints = false

        if self.revealSideMenuOnTop {
            self.sideMenuTrailingConstraint = upComingEventViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: self.upcomingRevealWidth)
            sideMenuTrailingConstraint.isActive = true
        }
        self.upComingEventViewController.upcomingEvents = upcomingEvents
        NSLayoutConstraint.activate([
            upComingEventViewController.view.widthAnchor.constraint(equalToConstant: self.upcomingRevealWidth),
            upComingEventViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            upComingEventViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
        ])
    }
    
    @objc func TapGestureRecognizer(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if self.isExpanded {
                self.sideMenuState(expanded: false)
            }
        }
    }
    
    func postLogIn(id: String){
        var dictionary = [String: String]()

        dictionary["UserId"] =  id
        dictionary[LogInKeys().platform] = "ios"
        dictionary[LogInKeys().Package] = Bundle.main.bundleIdentifier
        dictionary[LogInKeys().username] =  siblingUname
        dictionary[LogInKeys().password] = siblingPwd

        let url = APIUrls().siblingLogin

        print("sent dict",dictionary)

        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {

                if let resultDict = result as? NSDictionary {

                    if resultDict["StatusCode"] as? Int == 1 {

                        logInResponseGloabl = NSMutableDictionary(dictionary: resultDict)//resultDict as NSMutableDictionary
                        UserDefaultsManager.manager.saveDictionaryToUserDefaults(dictionary: logInResponseGloabl, forKey: DBKeys.logInResponse)
                        // Post Notification so that Side Menu updates its items on Sibling Login...
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateSideMenuItems"), object: nil)
                        UserDefaultsManager.manager.saveUserId(id:  (logInResponseGloabl.value(forKey: "UserId") as? String).safeValue)
                        self.setNotitificationList(id : id)
                        self.stopLoadingAnimation()

                    } else {
                        self.stopLoadingAnimation()
                        self.notificationList.removeAll()
                    }
                }

                else{
                    self.stopLoadingAnimation()
                }

                if self.notificationList.count == 0{
                    //  self.addNoDataFoundLabel()
                }
                else{
                    //   self.removeNoDataLabel()
                }
            }
        }
    }


    func getNotification(user: String){//user : String,student : String ,classVal : String){
        notificationList.removeAll()
        guard let nototificationsArray = logInResponseGloabl["Notification"] as? NSArray else{return}
        let notifications = ModelClassManager.sharedManager.createModelArray(data: nototificationsArray, modelType: ModelType.TNotification) as! [TNotification]
        self.notificationList.append(contentsOf: notifications)
        self.setStudentDetailsOnView(studentDetail: logInResponseGloabl)
        if self.notificationList.count == 0{
            self.addNoDataFoundLabel(textValue: "Hurray all your notification are attended !!")
        }
        else{
            self.removeNoDataLabel()
        }
    }
    
    func setDateFormatter(string : String) -> String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy' 'HH:mm:ssss"
        guard let date = dateFormatter.date(from: string) else {return nil}
        dateFormatter.dateFormat = "dd MMM yyyy"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }

    @objc func notified(notification: Notification) {
        if let dict = notification.object as? NSDictionary {
            postLogIn(id : (dict["userId"] as? String).safeValue)
        }
    }
    
    @objc func sessionExpired() {
        let topVc = UIApplication.getTopViewController()
        let alertController = UIAlertController(title: "Alert", message: "Your session has expired. Please log in again.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            isFirstTime = true
            gradeBookLink = ""
            showLoginPage()
        }
        alertController.addAction(okAction)
        topVc?.present(alertController, animated: true, completion: nil)
    }
    
    func setNotitificationList(id :String){

        let url = APIUrls().getDashboard
        var dictionary = [String:Any]()

        dictionary[UserIdKey().id] =  id
        dictionary["DashBoardType"] = 0
        dictionary["Platform"] = "ios"

        // Load from cache
        let cacheManager = CacheManager()

        if let cachedNotifications: [TNotification] = cacheManager.loadFromCache(key: "notificationsCache"),
           let cachedModules: [TModule] = cacheManager.loadFromCache(key: "modulesCache"),
           let cachedNoticeBoardItems: [TNNoticeBoardDetail] = cacheManager.loadFromCache(key: "noticeBoardCache") {

            self.notificationList = cachedNotifications
            self.moduleList = cachedModules
            self.NoticeBoardItems = cachedNoticeBoardItems

            self.updateUI()
        } else {
            self.startLoadingAnimation()
        }

        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                self.notificationList.removeAll()
                self.moduleList.removeAll()
                self.NoticeBoardItems.removeAll()
                guard let nototificationsArray = result["Notification"] as? NSArray else{return}
                let notifications = ModelClassManager.sharedManager.createModelArray(data: nototificationsArray, modelType: ModelType.TNotification) as! [TNotification]
                self.notificationList.append(contentsOf: notifications)

                if let moduleArray = result["ModuleCount"] as? NSArray {
                    let module = ModelClassManager.sharedManager.createModelArray(data: moduleArray, modelType: ModelType.TModule) as! [TModule]
                    self.moduleList.append(contentsOf: module)
                }

                if let noticeBoardArray = result["NoticeBoardItems"] as? NSArray {
                    let noticeBoard = ModelClassManager.sharedManager.createModelArray(data: noticeBoardArray, modelType: ModelType.TNNoticeBoardDetail) as! [TNNoticeBoardDetail]
                    self.NoticeBoardItems.append(contentsOf: noticeBoard)
                }

                if let upcomingEvents = result["upcoming_events"] as? NSArray {
                    let upcomingEvent = ModelClassManager.sharedManager.createModelArray(data: upcomingEvents, modelType: ModelType.TUpcomingEvent) as! [TUpcomingEvent]
                    self.upcomingEvents.append(contentsOf: upcomingEvent)
                }
                self.upComingEventViewController.upcomingEvents = self.upcomingEvents
                if let notifications = logInResponseGloabl.value(forKey: "Notification") as? NSArray
                {
                    logInResponseGloabl.removeObject(forKey: Notification.self)
                    logInResponseGloabl.setValue(nototificationsArray, forKey: "Notification")
                }


                cacheManager.saveToCache(data: self.notificationList, key: "notificationsCache")
                cacheManager.saveToCache(data: self.moduleList, key: "modulesCache")
                cacheManager.saveToCache(data: self.NoticeBoardItems, key: "noticeBoardCache")
                self.updateUI()
            }
        }
    }
    
    func updateUI() {
        let completeDict = logInResponseGloabl
        self.setStudentDetailsOnView(studentDetail: completeDict)
        if self.notificationList.count == 0 {
            self.addNoDataFoundLabel(textValue: "Hurray all your notifications are attended!!")
        }
        topHeaderView.title = "Notifications"
        topHeaderView.shouldShowBackButton = false
        tableView.reloadData()
    }
}


extension FeedViewController: TopHeaderDelegate {
    
    func secondRightButtonClicked(_ button: UIButton) {
        print("")
    }

    func searchButtonClicked(_ button: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {

            }
            else {
                isFirstTime = true
                gradeBookLink = ""
                showLoginPage()
            }
        }
    }
}

extension FeedViewController: UpComingEventViewControllerDelegate {
    
    func upComingEventViewController(_ view: UpComingEventViewController, didTapOnEvent event: TUpcomingEvent) {
        if let eventViewController = upcomingEvent.instantiateViewController(withIdentifier: "EventViewController") as? EventViewController {
            eventViewController.upcomingEvent = event
            if let stringUrl = JWTHelper.shared.getStogoUrl() {
                eventViewController.url = stringUrl
            }
            let popupVC = PopupViewController(contentController: eventViewController, popupWidth: popUpWidth, popupHeight: popUpHeight)
            popupVC.cornerRadius = 25
            self.present(popupVC, animated: true)
        }
    }

    func didTapOnIconButton() {
        //sideMenuState(expanded: self.isExpanded ? false : true)
    }

}


extension FeedViewController{
    
    func didTapOnNotification(notification: TNotification)  {
        if let typeVal = alertType(rawValue: notification.type ?? ""){
            switch typeVal {
            case .gallery:
                presentGalleryPopUp(notification: notification)
                break
            case .html:
                presentHtmlPopUp(notification: notification)
                break
            case .communicate:
                presentCommunicatePopUp(notification: notification)
            case .noticeboard:
                presentNoticeboardPopUp(notification: notification)
                break
            case .weeklyPlan:
                presentWeeklyPopUp(notification: notification)
                break
            case .bus:
                break
            case .feeds:
                presentFeedPopUp(notification: notification)
                break
            }
        }
    }

    func presentCommunicatePopUp(notification: TNotification) {
        let navVC = communicateLand.instantiateViewController(withIdentifier: "MessageDetailsNavigationController") as! UINavigationController
        let vc = navVC.children[0] as! MessageDetailController
        vc.messageId = notification.id
        vc.typeMsg = typeValue
        vc.isPresent = true
        let popupVC = PopupViewController(contentController: navVC, popupWidth: popUpWidth, popupHeight: popUpHeight)
        popupVC.cornerRadius = 25
        self.present(popupVC, animated: true)

    }

    func presentGalleryPopUp(notification: TNotification) {
        let navVC = gallery.instantiateViewController(withIdentifier: "ImagPreviewNavigationController") as! UINavigationController
        let vc = navVC.children[0] as! ImagePreviewController
        let url = notification.catid ?? ""
        vc.imageUrl = url
        vc.imageArr = Array([url])
        vc.pageTitle = notification.title
        vc.position = 0
        vc.isPresent = true

        let popupVC = PopupViewController(contentController: navVC, popupWidth: popUpWidth, popupHeight: popUpHeight)
        popupVC.cornerRadius = 25
        self.present(popupVC, animated: true)
    }

    func presentHtmlPopUp(notification: TNotification) {
        let detailVc = DigitalResourceDetailController.instantiate(from: .digitalResource)
        detailVc.isPresent = true
        detailVc.notification = notification
        let popupVC = PopupViewController(contentController: detailVc, popupWidth: popUpWidth, popupHeight: popUpHeight)
        popupVC.cornerRadius = 25
        self.present(popupVC, animated: true)
    }

    func presentFeedPopUp(notification: TNotification) {
        if let detailVc = videoStoryBoard.instantiateViewController(withIdentifier: "NotificationVideoViewController") as? NotificationVideoViewController {
            detailVc.notification = notification
            let popupVC = PopupViewController(contentController: detailVc, popupWidth: popUpWidth, popupHeight: popUpHeight)
            popupVC.cornerRadius = 25
            self.present(popupVC, animated: true)
        } else {
            print("Failed to instantiate view controller with identifier 'NotificationVideoViewController'")
        }

    }

    func presentNoticeboardPopUp(notification: TNotification) {
        let navVC = noticeboard.instantiateViewController(withIdentifier: "NBNavigationController") as! UINavigationController
        let vc = navVC.children[0] as! NoticeboardDetailController
        vc.NbID = notification.processid ?? ""
        vc.isPresent = true
        let popupVC = PopupViewController(contentController: navVC, popupWidth: popUpWidth, popupHeight: popUpHeight)
        popupVC.cornerRadius = 25
        self.present(popupVC, animated: true)
    }

    func presentWeeklyPopUp(notification: TNotification) {
        let navVC = weeklyPlan.instantiateViewController(withIdentifier: "WeeklyNavigationController") as! UINavigationController
        let vc = navVC.children[0] as! WeeklyPlanController
        vc.delegate = self
        vc.isPresent = true
        let popupVC = PopupViewController(contentController: navVC, popupWidth: popUpWidth, popupHeight: popUpHeight)
        popupVC.cornerRadius = 25
        self.present(popupVC, animated: true)
    }

    func isVideoURL(_ urlString: String) -> Bool {
        let videoExtensions = Set(["mp4", "m4v", "mov", "avi", "mkv", "flv", "wmv", "webm"])
        guard let url = URL(string: urlString) else {
            return false
        }
        let pathExtension = url.pathExtension.lowercased()
        return videoExtensions.contains(pathExtension)
    }

    func presentVideoViewController(url: String)  {
        if let videoURL = URL(string: url) {
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            present(playerViewController, animated: true) {
                player.play()
            }
        }
    }
}


extension FeedViewController: WeeklyPlanControllerDelegate {
    func weeklyPlanController(_ view: UIViewController, didtapOnCellForPopupWith comment: String, divId: String, weeklyPlan: WeeklyPlanList) {
        let detailVc = DigitalResourceDetailController.instantiate(from: .digitalResource)
        detailVc.weeklyPlan = weeklyPlan
        detailVc.divId = divId
        detailVc.comment_needed = comment
        self.navigationController?.pushViewController(detailVc, animated: true)
    }
}
