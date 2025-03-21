//
//  DashboardViewControllerControllerControllerController.swift
//  Ambassador Education
//
//  Created by IE14 on 19/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit
import EzPopup
import AVFoundation
import AVKit

extension DashboardViewController: TopHeaderDelegate {
    
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

class DashboardViewController: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var studentImageView: ImageLoader!
    @IBOutlet weak var studentSecondLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var classLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    private var upComingEventViewController: UpComingEventViewController!
    var notificationList = [TNotification]()
    var moduleList = [TModule]()
    var NoticeBoardItems = [TNNoticeBoardDetail]()
    var upcomingEvents = [TUpcomingEvent]()
    var feeSummary = [FeeSummary]()
    var progressViews = [TProgressTypeModel]()
    
    private var isExpanded: Bool = false
    private var revealSideMenuOnTop: Bool = true
    private var upcomingShadowView: UIView!
    private var upcomingRevealWidth: CGFloat = 300
    private let paddingForRotation: CGFloat = 150
    private var draggingIsEnabled: Bool = false
    private var panBaseLocation: CGFloat = 0.0
    let popUpHeight = UIScreen.main.bounds.height - 150
    let popUpWidth = UIScreen.main.bounds.width - 60
    var moduleBgColor = ["FF6666","99CB98","91D0DF","F1BB4E","DDAF84","669ACC"]
    var progressModel = [TProgressTypeModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        configureCollectionViewCell()
       // setUITableView()
        studentImageView.layer.cornerRadius = studentImageView.frame.width / 2
        setAllTextFieldsEmpty()
        updateCollectionViewHeight()
        callAPI()
    }
    
    func setAllTextFieldsEmpty(){
        studentNameLabel.text = ""
        studentSecondLabel.text = ""
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let userId = UserDefaultsManager.manager.getUserId()
        setNotitificationList(id : userId)
    }
    
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


extension DashboardViewController: NotificationTableViewCellDelegate {
    func notificationTableViewCell(_ cell: UITableViewCell, didTapOnNotification notification: TNotification) {
        didTapOnNotification(notification:notification)
    }
    func notificationTableViewCell(_ view: UITableViewCell, didTapOnStogoImageWith url: String) {
        gotoWeb(str : url)
    }

    func didTapOnUpcomingEventView() {
        openUpComingEvent()
    }
}

extension DashboardViewController{
    
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
    
    func gotoWeb(str : String) {
        let vc = commonStoryBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.strU = str
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
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
        let navVC = commonStoryBoard.instantiateViewController(withIdentifier: "WeeklyNavigationController") as! UINavigationController
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

extension DashboardViewController: WeeklyPlanControllerDelegate {
    func weeklyPlanController(_ view: UIViewController, didtapOnCellForPopupWith comment: String, divId: String, weeklyPlan: WeeklyPlanList) {
        let detailVc = DigitalResourceDetailController.instantiate(from: .digitalResource)
        detailVc.weeklyPlan = weeklyPlan
        detailVc.divId = divId
        detailVc.comment_needed = comment
        self.navigationController?.pushViewController(detailVc, animated: true)
    }
}

extension DashboardViewController{
    
    func callAPI(){
        let dict = logInResponseGloabl
        let url = APIUrls().jOURNEYPROGRESS
        if let token = UserDefaultsManager.manager.getSessionToken(){
            let userId = UserDefaultsManager.manager.getUserId()
            let SchoolCode = dict["CompanyId"] ?? 36
            let dictionary: [String:Any] =
            [
                "SchoolCode": SchoolCode,
                "user_id": userId,
                "token" : token
            ]
            APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
                print(result)
            }
        }
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
        self.startLoadingAnimation()
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
                
                if let feeSummary = result["FeeSummary"] as? NSArray{
                    let feeSummaryM =  ModelClassManager.sharedManager.createModelArray(data: feeSummary, modelType: ModelType.TFeeSummary) as! [FeeSummary]
                    self.feeSummary = feeSummaryM
                    print(feeSummary)
                }
                
            //    self.upComingEventViewController.upcomingEvents = self.upcomingEvents
                if let notifications = logInResponseGloabl.value(forKey: "Notification") as? NSArray
                {
                    logInResponseGloabl.removeObject(forKey: Notification.self)
                    logInResponseGloabl.setValue(nototificationsArray, forKey: "Notification")
                }
                self.collectionView.reloadData()
                self.updateCollectionViewHeight()

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
       // tableView.reloadData()
    }
    
    func configureCollectionViewCell() {
        collectionView.register(UINib(nibName: DashboardCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DashboardCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: ProgressCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: ProgressCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: DashboardGraphCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: DashboardGraphCollectionViewCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension DashboardViewController{
    
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
}

// MARK: - CollectionView Delegate and Datatsources -

extension DashboardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            return moduleList.count

        }
        else if section == 1{
            return 1
        }
        else{
            if progressViews.count > 0{
                return 4
            }
            else{
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCollectionViewCell.identifier , for: indexPath) as? DashboardCollectionViewCell else { return UICollectionViewCell() }
            let module = moduleList[indexPath.row]
            cell.nameLabel.text = module.module
            cell.labelDataCount.text = module.data_count != nil ? String(module.data_count!) : nil
            let index = indexPath.item % moduleBgColor.count
            let color = moduleBgColor[index]
            switch module.module {
            case "Notice Board":
                cell.imageView.image = UIImage(named: "module_noticeBoard")
                break
            case "Articles":
                break
            case "Digital Resources":
                break
            case "Gallery":
                cell.imageView.image = UIImage(named: "module_gallery")
                break
            case "Communicate":
                cell.imageView.image = UIImage(named: "module_message")
                break
            case "Weekly Plan":
                cell.imageView.image = UIImage(named: "module_weekly")
                break
            case "Online Payment":
                break
            case "Awareness & Policies":
                cell.imageView.image = UIImage(named: "awarenessAndPolicies")
                break
            case "Add Gallery":
                cell.imageView.image = UIImage(named: "module_gallery")
                break
            case "Exam Schedule":
                cell.imageView.image = UIImage(named: "examination")
                break
            case "Communicate and Collaborate":
                cell.imageView.image = UIImage(named: "communicate")
                break
            case .none:
                break
            case .some(_):
                break
            }
            return cell
        }
        else if indexPath.section == 1{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardGraphCollectionViewCell.identifier , for: indexPath) as? DashboardGraphCollectionViewCell else { return UICollectionViewCell() }
            if let feeSummary = feeSummary.first{
                cell.feeSummary = feeSummary
                cell.updateChart(with: feeSummary)
            }
            return cell
        }
        else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgressCollectionViewCell.identifier , for: indexPath) as? ProgressCollectionViewCell else { return UICollectionViewCell() }
            return cell
        }
    }

}

// MARK: - CollectionViewDelegateFlowLayout -
extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let totalPadding = 5 + 5 + 10 * 2
        if indexPath.section == 0{
            let itemWidth = (Int(collectionViewWidth) - totalPadding) / 3
            return CGSize(width: itemWidth, height: itemWidth + 15)
        }
        else if indexPath.section == 1{
            if let feeSummary = feeSummary.first{
                return CGSize(width: collectionView.bounds.width - 10, height: 350)
            }
            else{
                return CGSize(width: collectionView.bounds.width - 10, height: 0)

            }
        }
        else{
            let itemWidth = (Int(collectionViewWidth) - totalPadding) / 2
            return CGSize(width: itemWidth, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 5, bottom: 0, right: 5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    private func updateCollectionViewHeight() {
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
    }
}
