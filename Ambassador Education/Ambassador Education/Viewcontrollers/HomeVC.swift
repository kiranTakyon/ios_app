//
//  HomeVC.swift
//  Ambassador Education
//
//     on 05/05/17.
//   . All rights reserved.
//

import UIKit
import BIZPopupView

var isFirstTime = true


enum alertType:String{
    
    case gallery        = "GAL"
    case html           = "HTML"
    case communicate    = "INTM"
    case noticeboard    = "NWS"
    case weeklyPlan     = "HMW"
    case bus     = "BUS"


}

var selectedAlertType : alertType = .gallery


class HomeVC: UIViewController,UITableViewDataSource, UITableViewDelegate,SWRevealViewControllerDelegate {
    var popUpViewVc : BIZPopupViewController?
    
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var studentImageView: ImageLoader!
    @IBOutlet weak var studentSecondLabel: UILabel!
    @IBOutlet weak var classLabel: UILabel!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var alertTable: UITableView!
    @IBOutlet weak var classLabelHeight: NSLayoutConstraint!
    
    var notificationList = [TNotification]()
    override func viewDidLoad() {
        super.viewDidLoad()
        setAllTextFieldsEmpty()
        self.tableViewProporties()
        getTokenValueForMobileNotification()
        setSlideMenuProporties()
        addObserverToNotification()

    }
    
    func setAllTextFieldsEmpty(){
        studentNameLabel.text = ""
        studentSecondLabel.text = ""
        classLabel.text = ""
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

        if isFirstTime{
            self.revealViewController().revealToggle(self)
            isFirstTime = false
        }

        if sibling{
            postLogIn(id: siblingUserId)
        }
        else{
            let userId = UserDefaultsManager.manager.getUserId()
            setNotitificationList(id : userId)
        }
        
    }
    
    func setSlideMenuProporties(){
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControl.Event.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    
    func setProfileImageToRound(){
        studentImageView.contentMode = .scaleAspectFill
        studentImageView.layer.cornerRadius = 42
        studentImageView.clipsToBounds = true
        self.studentImageView.layer.borderWidth = 1
        self.studentImageView.layer.borderColor = UIColor.white.cgColor
    }
    
    func setStudentDetailsOnView(studentDetail: NSDictionary){
        if studentDetail != nil{
            
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
                classLabel.text = "Class - " + studentClass
                    classLabel.isHidden = false
                    classLabelHeight.constant = 17.5
                }
                else{
                   classLabelHeight.constant = 0.0
                   classLabel.isHidden = true
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
                self.alertTable.reloadData()
                self.setStudentDetailsOnView(studentDetail: logInResponseGloabl)
                    if self.notificationList.count == 0{
                        self.addNoDataFoundLabel(textValue: "Hurray all your notification are attended !!")
                    }
                    else{
                        self.removeNoDataLabel()
                }
                    self.alertTable.reloadData()
            }
    

    
    func setNotitificationList(id :String){

        let url = APIUrls().notification
        var dictionary = [String:Any]()
        
        dictionary[UserIdKey().id] =  id
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                    self.notificationList.removeAll()
                    guard let nototificationsArray = result["Notification"] as? NSArray else{return}
                    let notifications = ModelClassManager.sharedManager.createModelArray(data: nototificationsArray, modelType: ModelType.TNotification) as! [TNotification]
                    self.notificationList.append(contentsOf: notifications)

                    if let notifications = logInResponseGloabl.value(forKey: "Notification") as? NSArray
                    {
                        logInResponseGloabl.removeObject(forKey: Notification.self)
                        logInResponseGloabl.setValue(nototificationsArray, forKey: "Notification")
                    }
                    let completeDict = logInResponseGloabl
                    self.setStudentDetailsOnView(studentDetail: completeDict)

                if self.notificationList.count == 0{
                    self.addNoDataFoundLabel(textValue: "Hurray all your notification are attended !!")
                }
                
                self.alertTable.reloadData()
            }
        }
     
    }
    
        
    func tableViewProporties(){
        self.headLabel.text = "Dashboard"
        self.alertTable.estimatedRowHeight = 60
        self.alertTable.rowHeight = UITableView.automaticDimension
    }
    
    //MARK:- TableView Delegates and Datasources
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        
       let cell = tableView.dequeueReusableCell(withIdentifier: "HomeListViewCell", for: indexPath) as! HomeListViewCell
        
        let notification = notificationList[indexPath.row]
        
        if let titel = notification.title{
            cell.alertTitle.numberOfLines = 0
            cell.alertTitle.text = titel
        }
        
        if let date = notification.date{
            cell.alertDate.text = setDateFormatter(string: date)

        }
        
        if let msgType = notification.type{
            switch msgType {
            case msgTypes.communicate.rawValue:
                cell.typeImageView.image = #imageLiteral(resourceName: "Message")
                
            case msgTypes.noticeboard.rawValue,msgTypes.bus.rawValue,msgTypes.weeklyPlan.rawValue:
                cell.typeImageView.image = #imageLiteral(resourceName: "Notice")
                
            case msgTypes.htmlType.rawValue:
                cell.typeImageView.image =  #imageLiteral(resourceName: "html")
                
            case msgTypes.gallery.rawValue:
                cell.typeImageView.image = #imageLiteral(resourceName: "Gallary")
                
            default:
                cell.typeImageView.image = #imageLiteral(resourceName: "Notice")

            }
        }
        
        print("type value is :- ",notification.type)
        
        cell.selectionStyle = .none

        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        var currentNotification = self.notificationList[indexPath.row]
        if let notificationType = currentNotification.type{
            if let proceddId = currentNotification.id{
                if let typeVal = alertType(rawValue: notificationType){
                    selectedAlertType = typeVal
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
                    self.alertTable.deleteRows(at: [index], with: .right)
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
    
    
    
    @IBAction func logOutAction(_ sender: Any) {
        
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
    
    
   /* func setWebViewProperties(){
        self.automaticallyAdjustsScrollViewInsets = false
        webView.delegate = self
        webView.scrollView.bounces = false
    }

    func loadWebView(){
        
        showWebUrl = "www.apple.com"
        if let webUrl = showWebUrl{
            if let url = URL (string: webUrl){
                let requestObj = URLRequest(url:url)
                self.webView.loadRequest(requestObj)
            }
        }
    }

    
    func showPopUpView(){
        
        let MainStoyboard = UIStoryboard(name: "Main", bundle: nil)
        let heightVal = UIScreen.main.bounds.size.height - 80
        let popvc = MainStoyboard.instantiateViewController(withIdentifier: "registerPopUpVc") as! RegisterPopUpVc
        popUpViewVc = BIZPopupViewController(contentViewController: popvc, contentSize: CGSize(width: self.view.frame.size.width - 40,height: CGFloat(heightVal)))
        self.present(popUpViewVc!, animated: true, completion: nil)
        
    }
    
    //MARK:- 
    
    
    func webViewDidFinishLoad(_ webView: WKWebView) {
        
        print("webview loaded")
        self.stopLoadingAnimation()
    } */


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

