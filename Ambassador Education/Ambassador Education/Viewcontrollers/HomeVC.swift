//
//  HomeVC.swift
//  Ambassador Education
//
//     on 05/05/17.
//   . All rights reserved.
//

import UIKit
import BIZPopupView
import EzPopup

var isFirstTime = true


enum alertType:String{
    
    case gallery        = "GAL"
    case html           = "HTML"
    case communicate    = "INTM"
    case noticeboard    = "NWS"
    case weeklyPlan     = "HMW"
    case bus            = "BUS"
    
    
}

var selectedAlertType : alertType = .gallery
var notificationObject : TNotification = TNotification(values: NSDictionary())


class HomeVC: UIViewController,SWRevealViewControllerDelegate {
    var popUpViewVc : BIZPopupViewController?
    
    @IBOutlet weak var studentImageView: ImageLoader!
    @IBOutlet weak var studentSecondLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var buttonRightArrow: UIButton!
    @IBOutlet weak var classLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var buttonSideArrow: UIButton!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    var notificationList = [TNotification]()
    var moduleList = [TModule]()
    var NoticeBoardItems = [TNNoticeBoardDetail]()
    var buttonOrigin : CGPoint = CGPoint(x: 0, y: 0)
    let dashboardView: DashboardView = DashboardView.fromNib()
    let notificationsView: NotificationsView = NotificationsView.fromNib()
    
    let popUpHeight = UIScreen.main.bounds.height - 150
    let popUpWidth = UIScreen.main.bounds.width - 60
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        setAllTextFieldsEmpty()
        getTokenValueForMobileNotification()
        setSlideMenuProporties()
        addObserverToNotification()
        topHeaderView.delegate = self
        addGestureOnButton()
    }
    
    func setAllTextFieldsEmpty(){
        studentNameLabel.text = ""
        studentSecondLabel.text = ""
        //classLabel.text = "Class"
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setProfileImageToRound()
        
        if isFirstTime {
            self.revealViewController().revealToggle(self)
            isFirstTime = false
            
            let shoudShowBirthdayWish = UserDefaults.standard.bool(forKey: DBKeys.shouldShowBirthdayWish)
            if shoudShowBirthdayWish {
                let storyBoard = UIStoryboard(name: "Main", bundle: nil)
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
    
    func setSlideMenuProporties(){
        if let revealVC = revealViewController() {
            topHeaderView.setMenuOnLeftButton(reveal: revealVC)
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    
    func addGestureOnButton() {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(leftArrowGesture(_ :)))
        gesture.minimumNumberOfTouches = 1
        buttonSideArrow.addGestureRecognizer(gesture)
        
        let rigtGesture = UIPanGestureRecognizer(target: self, action: #selector(rightArrowGesture(_ :)))
        rigtGesture.minimumNumberOfTouches = 1
        buttonRightArrow.addGestureRecognizer(rigtGesture)
    }
    
    
    @objc func leftArrowGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        switch gesture.state {
        case .changed:
            if location.x <= 100 {
                buttonSideArrow.frame.origin = CGPoint(x: location.x, y: buttonSideArrow.frame.origin.y)
                buttonOrigin = CGPoint(x: location.x, y: buttonSideArrow.frame.origin.y)
            } else {
                buttonSideArrow.frame.origin = CGPoint(x: 100, y: buttonSideArrow.frame.origin.y)
                buttonOrigin = CGPoint(x: 100, y: buttonSideArrow.frame.origin.y)
            }
        case .possible:
            break
        case .began:
            break
        case .ended,.cancelled,.failed:
            buttonSideArrow.frame.origin = self.buttonOrigin
            addNotificationsView()
        @unknown default:
            break
        }
    }
    
    @objc func rightArrowGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: view)
        switch gesture.state {
        case .changed:
            if location.x >= view.frame.width - 100 {
                buttonRightArrow.frame.origin = CGPoint(x: location.x, y: buttonSideArrow.frame.origin.y)
                buttonOrigin = CGPoint(x: location.x, y: buttonSideArrow.frame.origin.y)
            } else {
                buttonRightArrow.frame.origin = CGPoint(x: view.frame.width - 100, y: buttonSideArrow.frame.origin.y)
                buttonOrigin = CGPoint(x:view.frame.width - 100, y: buttonSideArrow.frame.origin.y)
            }
        case .possible:
            break
        case .began:
            break
        case .ended,.cancelled,.failed:
            buttonRightArrow.frame.origin = self.buttonOrigin
            addDashboardView()
        @unknown default:
            break
        }
    }
    
    
    func setProfileImageToRound() {
        studentImageView.contentMode = .scaleAspectFill
        studentImageView.layer.cornerRadius = 42
        studentImageView.clipsToBounds = true
        self.studentImageView.layer.borderWidth = 1
        self.studentImageView.layer.borderColor = UIColor.white.cgColor
    }
    
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
            // self.studentImageView.loadImageWithUrl((dict["img"] as? String).safeValue)
            postLogIn(id : (dict["userId"] as? String).safeValue)
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
        
        if UserDefaultsManager.manager.getNotifications() {
            self.addNotificationsView()
        } else {
            self.addDashboardView()
        }
    }
    
    func addDashboardView() {
        UserDefaultsManager.manager.setNotifications(isShow: false)
        buttonOrigin = CGPoint(x: 0, y: 0)
        showRightArrowButton(false)
        topHeaderView.title = "Dashboard"
        notificationsView.removeFromSuperview()
        dashboardView.notificationList = notificationList
        dashboardView.moduleList = moduleList
        dashboardView.NoticeBoardItems = NoticeBoardItems
        dashboardView.delegate = self
        dashboardView.tableView.reloadData()
        dashboardView.frame = containerView.bounds
        containerView.addSubview(dashboardView)
    }
    
    func addNotificationsView() {
        UserDefaultsManager.manager.setNotifications(isShow: true)
        buttonOrigin = CGPoint(x: 0, y: 0)
        showRightArrowButton(true)
        topHeaderView.title = "Notifications"
        dashboardView.removeFromSuperview()
        notificationsView.notificationList = notificationList
        notificationsView.tableView.reloadData()
        notificationsView.delegate = self
        notificationsView.frame = containerView.bounds
        containerView.addSubview(notificationsView)
    }
    
    func showRightArrowButton(_ isShow: Bool) {
        buttonSideArrow.isHidden = isShow
        buttonRightArrow.isHidden = !isShow
    }
    
    //MARK: - TableView Delegates and Datasources -
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        var currentNotification = self.notificationList[indexPath.row]
        if let notificationType = currentNotification.type{
            if let proceddId = currentNotification.id{
                if let typeVal = alertType(rawValue: notificationType){
                    selectedAlertType = typeVal
                    notificationObject = currentNotification
                }
                self.readNotification(notiId: proceddId, type: notificationType,index : indexPath)
            }
        }
    }
    
    func readNotification(notiId:String,type:String,index: IndexPath){
        
        let url = APIUrls().readNotificatoin
        
        var dictionary = [String:Any]()
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        dictionary[UserIdKey().id] = userId
        dictionary["ModuleCode"] = type
        dictionary["ProcessId"] = Int(notiId)
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                if result["StatusCode"] as? Int == 1{
                    print(index.row)
                    self.notificationList.remove(at: index.row)
                    //self.alertTable.deleteRows(at: [index], with: .right)
                    self.navigateToSpecificPage(typeValue: selectedAlertType)
                }
            }
        }
    }
    
    func navigateToSpecificPage(typeValue:alertType){
        selectedAlertType = typeValue
        let selectedDict = ["selected":typeValue]
        NotificationCenter.default.post( name: NSNotification.Name(rawValue: "selecAlert"), object: nil)
    }
    
    
    func getTheViewController(typeValue:alertType){
        
        
        var viewController : UINavigationController?
        if typeValue == .gallery{
            
            self.performSegue(withIdentifier: "toGallery", sender: self)
            //           viewController = mainStoryBoard.instantiateViewController(withIdentifier: "galleryrootVc") as? UINavigationController
            
        }
        else if typeValue == .communicate{
            viewController = mainStoryBoard.instantiateViewController(withIdentifier: "communicateVC") as? UINavigationController
            
        }else if typeValue == .html{
            
            viewController = mainStoryBoard.instantiateViewController(withIdentifier: "communicateVC") as? UINavigationController
            
        }else if typeValue == .noticeboard{
            
            viewController = mainStoryBoard.instantiateViewController(withIdentifier: "communicateVC") as? UINavigationController
            
        }else if typeValue == .weeklyPlan{
            
            viewController = mainStoryBoard.instantiateViewController(withIdentifier: "communicateVC") as? UINavigationController
            
        }
        
        //        guard let _ = viewController else {return}
        
        self.show(viewController!, sender: self)
    }
}

enum msgTypes : String{
    
    case gallery        = "GAL"
    case htmlType       = "HTML"
    case communicate    = "INTM"
    case noticeboard    = "NWS"
    case weeklyPlan     = "HWM"
    case bus = "BUS"
    
}


class HomeListViewCell : UITableViewCell{
    
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertDate: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
}


@IBDesignable
class CardView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 2
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 2
    @IBInspectable var shadowColor: UIColor? = UIColor.darkGray
    @IBInspectable var shadowOpacity: Float = 0.5
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
}

extension HomeVC: TopHeaderDelegate {
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


extension HomeVC: NotificationsViewDelegate {
    func removeNoNotificationdataLabel() {
        self.removeNoDataLabel()
    }

    func notificationsView(_ view: NotificationsView, didTapOnNotification notification: TNotification) {
        didTapOnNotification(notification: notification)
    }

    func notificationsView(_ view: NotificationsView, didTapOnGallery id: String) {
        guard let viewController = mainStoryBoard.instantiateViewController(withIdentifier: "GalleryListController") as? GalleryListController else { return }
        viewController.categoryId = id
        viewController.categoryName = "Gallery"
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    func notificationsView(_ view: NotificationsView, didTapOnStogoImageWith url: String) {
        gotoWeb(str: url)
    }

    func gotoWeb(str : String) {
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.strU = str
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeVC: DashboardViewDelegate {
    func dashboardView(_ view: DashboardView, didTapOnNotification notification: TNotification) {
        didTapOnNotification(notification: notification)
    }
    
    func dashboardView(_ view: DashboardView, didTapOnStogoImageWith url: String) {
        gotoWeb(str: url)
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
            }
        }
    }
    
    func presentCommunicatePopUp(notification: TNotification) {
        let navVC = mainStoryBoard.instantiateViewController(withIdentifier: "MessageDetailsNavigationController") as! UINavigationController
        let vc = navVC.children[0] as! MessageDetailController
        vc.messageId = notification.id
        vc.typeMsg = typeValue
        vc.isPresent = true
        
        let popupVC = PopupViewController(contentController: navVC, popupWidth: popUpWidth, popupHeight: popUpHeight)
        popupVC.cornerRadius = 25
        self.present(popupVC, animated: true)
        
    }
    
    func presentGalleryPopUp(notification: TNotification) {
        let navVC = mainStoryBoard.instantiateViewController(withIdentifier: "ImagPreviewNavigationController") as! UINavigationController
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
        let detailVc = mainStoryBoard.instantiateViewController(withIdentifier: "DigitalResourceDetailController") as! DigitalResourceDetailController
        
        detailVc.isPresent = true
        detailVc.notification = notification
        let popupVC = PopupViewController(contentController: detailVc, popupWidth: popUpWidth, popupHeight: popUpHeight)
        popupVC.cornerRadius = 25
        self.present(popupVC, animated: true)
    }
    
    func presentNoticeboardPopUp(notification: TNotification) {
        let navVC = mainStoryBoard.instantiateViewController(withIdentifier: "NBNavigationController") as! UINavigationController
        let vc = navVC.children[0] as! NoticeboardDetailController
        vc.NbID = notification.processid ?? ""
        vc.isPresent = true
        
        let popupVC = PopupViewController(contentController: navVC, popupWidth: popUpWidth, popupHeight: popUpHeight)
        popupVC.cornerRadius = 25
        self.present(popupVC, animated: true)
    }
    
    func presentWeeklyPopUp(notification: TNotification) {
        let navVC = mainStoryBoard.instantiateViewController(withIdentifier: "WeeklyNavigationController") as! UINavigationController
        let vc = navVC.children[0] as! WeeklyPlanController
        vc.delegate = self
        vc.isPresent = true
        let popupVC = PopupViewController(contentController: navVC, popupWidth: popUpWidth, popupHeight: popUpHeight)
        popupVC.cornerRadius = 25
        self.present(popupVC, animated: true)
    }
}


extension HomeVC: WeeklyPlanControllerDelegate {
    func weeklyPlanController(_ view: UIViewController, didtapOnCellForPopupWith comment: String, divId: String, weeklyPlan: WeeklyPlanList) {
        let detailVc = mainStoryBoard.instantiateViewController(withIdentifier: "DigitalResourceDetailController") as! DigitalResourceDetailController
        detailVc.weeklyPlan = weeklyPlan
        detailVc.divId = divId
        detailVc.comment_needed = comment
        self.navigationController?.pushViewController(detailVc, animated: true)
    }
    
    
}
