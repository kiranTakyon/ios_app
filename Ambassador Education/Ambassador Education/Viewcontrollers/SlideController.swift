///
//  SlideController.swift
//  Ambassador Education
//
//  Created by    Kp on 23/07/17.
//  Copyright © 2017 //. All rights reserved.
//
import StoreKit
import UIKit

var indexOfSelectedStudent = 0
var studentDetails = [TSibling]()
var gradeBookLink : String?
var selectedHash : String?
var sibling = false
var siblingUserId = ""
var siblingUname = ""
var siblingPwd = ""
var OpenBrowser = false
class SlideController: UITableViewController,TaykonProtocol {

    var titles = ["","Home","My Profile","Locator & Navigator","Gallery","Communication","Notice Board","Calendar","Finance","Payment History","Fee Details","Fee Summary","Academics","Gardebook","Digital Resources","Awareness & policies","Absebce Report","Weekly Plan"]
    var images = ["Home","Home","Profile","Location","Gallary","Communication","Noticeboard","Calender","","","","","","","","","","","","","","","","","","","",""]
    let segueIdentifiers = ["","toHomeVc","toProfileVc","","toGallery","toCommunicate","toNoticeboard","toCalendarView","","","toFeeDetails","","","","toDigitalReource","toMessageDetail","toImagePreview","toImagePreview"]
    
    var selectionTitles = [String]()
    var selectionIds = [Int]()
    
    var menuListItems = [TNMenuItem]()
    
    let acadamicsInnerArray = ["Time Table","Digital Resources","Awareness & Policies","Report Card","Weekly Plan","Absence Report"]
    let academicsImageArray = ["","","","","",""]
    
    var menuListDetails = ["T0001":["Home","toHomeVc"],
                           "T0011":["Noticeboard","toNoticeboard"],
                           "T0018":["Gallary","toGallery"],
                           "T0009":["Communication","toCommunicate"],
                           "T0004":["",""],
                           "T0005":["Weekly Plan","toWeeklyPlan"],
                           "T0012":["Grade Book","toGradeBook"],
                           "T0019":["AwarenessPolicies","toAwareness"],
                           "T0021":["DigitalResource","toDigitalReource"],
                           "T0041":["Time Table","toGradeBook"],
                           "T0039":["Control Panel 1","toGradeBook"],
                           "T0040":["Control Panel 2","toGradeBook"],//need to change
                           "T0035":["Fee Summary","toFeeSummary"],
                           "T0036":["Fee Details","toFeeDetails"],
                           "T0037":["Payment History","toFeeDetails"],
                           "T0038":["Absence Report","toFeeDetails"],
                           "T0008":["",""],
                           "T0058":["Student Behaviour","toGradeBook"],
                           "T0059":["Primary Timetable","toGradeBook"],
                           "T0059_3":["Primary Timetable","toGradeBook"],
                           "T0059_4":["Link1","toGradeBook"],
                           "T0059_5":["Link2","toGradeBook"],
                           "T0060":["EYFS Timetable","toGradeBook"],
                           "T0002":["Calender","toCalendarView"],
                           "T0010":["Locator & Navigator","Location"],
                           "MyProlfeKey":["Profile","toProfileVc"],
                           "T0069":["Language","toGradeBook"],//Open in browser
       // "MyProlfeKey":["الملف الشخصي","toProfileVc"]

                           ]
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewProporties()
        getSiblingsDetails()
        getMenuDetails()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SlideController.onPostLoaded), name: NSNotification.Name(rawValue: "selecAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SlideController.getMenuDetails), name: NSNotification.Name(rawValue: "updateSideMenuItems"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - NAvigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if segue.identifier == "toGradeBook"{
           if(OpenBrowser==true)
           {
           let ns = URL(string : gradeBookLink!)
               if #available(iOS 10.0, *) {
                   UIApplication.shared.open(ns!)
               }
               else{
                   UIApplication.shared.openURL(ns!)
               }
           }
           else
           {
               let destinationVC = segue.destination as! UINavigationController
               let vc = destinationVC.children[0] as? GradeViewController
               if gradeBookLink != "" {
                   vc?.header  = (sender as? String)!
                   vc?.hashkey =  selectedHash ?? ""
               }
           }
        }
        else if segue.identifier == "toMessageDetail"{
            let destinationVC = segue.destination as! UINavigationController
            let vc = destinationVC.children[0] as! MessageDetailController
            vc.messageId = notificationObject.id
            vc.typeMsg = typeValue
//            vc.text = notificationObject.title
        }
        else if segue.identifier == "toImagePreview"{
            let destinationVC = segue.destination as! UINavigationController
            let vc = destinationVC.children[0] as! ImagePreviewController
            var url = notificationObject.catid ?? ""
            vc.imageUrl = url
            vc.imageArr = Array([url])
            vc.pageTitle = notificationObject.title
            vc.position = 0
        }
        else if segue.identifier == "toNBDetails"{
            let destinationVC = segue.destination as! UINavigationController
            let vc = destinationVC.children[0] as! NoticeboardDetailController
            vc.NbID = notificationObject.processid ?? ""
        }
    }

    //MARK: - Other Helpers

    @objc func onPostLoaded() {

            if selectedAlertType == .gallery{
                self.performSegue(withIdentifier: "toImagePreview", sender: nil)
            }else if selectedAlertType == .communicate{
//                self.performSegue(withIdentifier: "toCommunicate", sender: nil)
                self.performSegue(withIdentifier: "toMessageDetail", sender: self)
            }else if selectedAlertType == .html{
                self.performSegue(withIdentifier: "toDigitalReource", sender: nil)
                
            }else if selectedAlertType == .noticeboard{
                self.performSegue(withIdentifier: "toNBDetails", sender: nil)
            }else if selectedAlertType == .weeklyPlan{
                self.performSegue(withIdentifier: "toWeeklyPlan", sender: nil)

            }
        
    }
    
    func tableViewProporties(){
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    func deleteTheSelectedAttachment(index: Int) {
        
    }
    
    func getSiblingsDetails() {
        let details = logInResponseGloabl;// UserDefaultsManager.manager.getUserDefaultValue(key:DBKeys.logInDetails) as? NSDictionary else {return}
        
        if let values = details["Siblings"] as? NSArray{
            
            let siblings = ModelClassManager.sharedManager.createModelArray(data: values, modelType: ModelType.TSibling) as! [TSibling]
            
            for sib in siblings{
                
                if let studname = sib.studentName{
                    selectionTitles.append(studname)
                }
                
                if let studId = sib.userId{
                    if let intValue = Int(studId){
                        selectionIds.append(intValue)

                    }
                    
                }
                
            }
            
            studentDetails = siblings
        }
        
    }
    
    
    @objc func getMenuDetails() {
        
        let logInDetails = logInResponseGloabl;//UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.logInDetails) as? NSDictionary else {return}
        
        guard let menuList = logInDetails["MenuList"] as? [[String:Any]] else {return}
        
        let sortedArray = menuList.sorted {Int($0["MenuOrder"] as! String)! < Int($1["MenuOrder"] as! String)! }
        
        var zeroParentIds = [TNMenuItem]()
        var valueProfile = NSDictionary()
        
        if let lang = logInDetails["Language"] as? String{
            if lang == "1"{
                valueProfile = NSDictionary(objects: ["0","Profile","111111111111","T0013"], forKeys: ["ParentId" as NSCopying,"Label" as NSCopying,"id" as NSCopying,"hashkey" as NSCopying])
            } else {
                valueProfile = NSDictionary(objects: ["0","الملف الشخصي"
                    ,"111111111111","T0013"], forKeys: ["ParentId" as NSCopying,"Label" as NSCopying,"id" as NSCopying,"hashkey" as NSCopying])
            }
        }
        let profileItem = TNMenuItem(values: valueProfile)
        
        let unsortedItems = ModelClassManager.sharedManager.createModelArray(data: sortedArray as NSArray, modelType: ModelType.TNMenuItem) as! [TNMenuItem]
        
        var mainItems           = [TNMenuItem]()
        var academicsItems      = [TNMenuItem]()
        var financeItems        = [TNMenuItem]()
        var sectionHeaderItems  = [TNMenuItem]()
        var financemenuid:String = ""
        
        for menu in unsortedItems{
           // print("menu",menu.label)
            if menu.label != ""{
                if menu.parentid == "0"{
                    if menu.hashKey.safeValue == "T0008"
                    {
                        sectionHeaderItems.append(menu)
                        financemenuid=menu.id.safeValue
                    }
                    else if menu.hashKey.safeValue == "T0004"
                    {
                        sectionHeaderItems.append(menu)
                        //academicsmenuid=menu.id.safeValue
                    }
                    else{
                        // if menu.id != "1697"{
                        mainItems.append(menu)
                        //}
                    }
                }
                else if menu.parentid.safeValue == financemenuid{
               // else if menu.hashKey.safeValue == "T0035" || menu.hashKey.safeValue == "T0036" || menu.hashKey.safeValue == "T0037"{
                    financeItems.append(menu)
                }
                else if menu.parentid == "5"{
                    if menu.hashKey.safeValue == "T0021" || menu.hashKey.safeValue == "T0019" || menu.hashKey.safeValue == "T0005" || menu.hashKey.safeValue == "T0012"{
                        academicsItems.append(menu)
                    }
                    else{
                        academicsItems.append(menu)
                    }
                }
            }
        }
        
        
        var totalCount = mainItems.count + sectionHeaderItems.count + academicsItems.count + financeItems.count
        var index = 0
        
        for each in mainItems{
            zeroParentIds.insert(each, at: index)
            index = index + 1
            
        }
        
        // zeroParentIds.insert(profileItem, at: 1)
        var isFirst  = false
        if sectionHeaderItems.count > 0{
            isFirst = true
            
            for eachSection in sectionHeaderItems{
                // sectionHeaderItems.remove(at: 0)
                if eachSection.hashKey == "T0008"{
                    
                    if isFirst{
                        zeroParentIds.insert(eachSection, at: index)
                    }
                    else{
                        zeroParentIds.insert(eachSection, at: index + 1)
                        index = index + 1
                        
                    }
                    
                    for eachFinance in financeItems{
                        
                        index = index + 1
                        
                        zeroParentIds.insert(eachFinance, at: index)
                        
                    }
                    isFirst = false
                    
                }
                else if eachSection.hashKey == "T0004"{
                    if isFirst{
                        zeroParentIds.insert(eachSection, at: index)
                    }
                    else {
                        zeroParentIds.insert(eachSection, at: index + 1)
                    }
                    
                    for eachFinance in academicsItems {
                        index = index + 1
                        zeroParentIds.insert(eachFinance, at: index)
                    }
                    isFirst = false
                }
            }
        }
        if zeroParentIds.count != 0{
            zeroParentIds.insert(profileItem, at: 1)
        }
        menuListItems = zeroParentIds
        self.tableView.reloadData()
        print("sorted items : ",sortedArray)
    }
    
    func getStudentNameAndSchoolName() -> (String,String){
        var stuName = String()
        var schName = String()
        if let loginResponse = logInResponseGloabl as? NSDictionary{
            if let studentName = loginResponse["Name"] as? String{
                stuName = studentName
            }
            if let scholName = loginResponse["SchoolName"] as? String{
               schName = scholName
            }
        }
        return(stuName,schName)
    }
    
    func getTheProductLogo() -> String {
        if let dict = logInResponseGloabl as? NSDictionary{
            if let logo = dict["LogoPath"] as? String{
                return logo
            }
        }
        return ""
    }
    
    func getTheSchoolName() -> (String,String){
        if let dict = logInResponseGloabl as? NSDictionary{
            if let logo = dict["Name"] as? String{
                if let schoolName = dict["SchoolName"] as? String{
                    return (logo,schoolName)
                }
                
            }
        }
        return ("","")
    }
    
    //MARK:- TaykonProtocol Delagtes
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(menuListItems.count + 1)
        return menuListItems.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        
        if indexPath.row == 8 || indexPath.row == 12{
            return 40
        }else if indexPath.row == 0{
            return 170
        }else{
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            guard let tempCell = tableView.dequeueReusableCell(withIdentifier: "slideMenuFirstCell", for: indexPath) as? slideMenuFirstCell  else {
                return UITableViewCell()
            }
            print(studentDetails)
            tempCell.imageUrl = getTheProductLogo()
            tempCell.studentPicker.pickerInputItems(selectionTitles as NSArray)
            tempCell.studentPicker.pickerInputIDitems(selectionIds)
            guard let user = UserDefaultsManager.manager.getUserType() as? String else {
            }
            tempCell.schoolNameLabel.numberOfLines = 0
            tempCell.studentNameLabel.numberOfLines = 0
            
            if user == UserType.parent.rawValue || user == UserType.student.rawValue{
                
                if selectionTitles.count > indexOfSelectedStudent{
                    tempCell.studentPicker.pickerTextField.text = selectionTitles[indexOfSelectedStudent]
                    tempCell.studentDetailLabel.text = "Class - " + studentDetails[indexOfSelectedStudent].classValue!
                }
            } else {
                let details =  getTheSchoolName()
                tempCell.studentPicker.pickerTextField.text = details.0
                tempCell.studentDetailLabel.text =  details.1
            }
            let stuDetails = getStudentNameAndSchoolName()
            tempCell.studentNameLabel.text = stuDetails.1
            tempCell.schoolNameLabel.text = ""
            
            if studentDetails.count > 0 {
                tempCell.studentPicker.pickerButton.isHidden = false
            } else {
                tempCell.studentPicker.pickerButton.isHidden = true
            }
         
            tempCell.siblings = studentDetails
            tempCell.delegate = self
            tempCell.selectionStyle = .none
            return tempCell
        } else {
            guard let tempCell = tableView.dequeueReusableCell(withIdentifier: "slidemenuCell", for: indexPath) as? slidemenuCell else {
                return UITableViewCell()
            }
            
            let item = menuListItems[indexPath.row - 1]
            print(item.label ?? "")
            if let link = item.link {
                if link != ""{
                    gradeBookLink = link
                    if item.hashKey=="T0069" || item.hashKey=="T0012"
                    {
                        OpenBrowser = true
                    }
                }
            }
            if let hashValue = item.hashKey{
                
                tempCell.hashKey = hashValue
                
                if let imageValue = menuListDetails[hashValue]?[0] {
                    tempCell.iconImage.image = UIImage(named:imageValue)
                }
                
            }
            if let itemLabel = item.label {
                if tempCell.hashKey == "" {
                    if let imageValue = menuListDetails[""]?[0] {
                        tempCell.iconImage.image = UIImage(named:imageValue)
                    }
                }
                tempCell.titleLabel.text = itemLabel //== "Dashboard" ? "Home" : itemLabel  //titles[indexPath.row]
            }
            
            if indexPath.row == 2 {
             tempCell.hashKey = "MyProlfeKey"
                tempCell.iconImage.image = #imageLiteral(resourceName: "toProfileVc")
            }
            
            tempCell.selectionStyle = .default
            
            setTableCellColor(indexPath: indexPath, cell: tempCell)
            
            return tempCell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        gradeBookLink = ""
        var titleValue = String()
        if indexPath.row != 0{
        let item = menuListItems[indexPath.row - 1]
        if let link = item.link {
            if link != ""{
                titleValue = item.label!
                gradeBookLink = link
                if item.hashKey=="T0069" || item.hashKey=="T0012"
                {
                    OpenBrowser = true
                }
            }
           }
        }
        
        if indexPath.row == 0 {
        } else if indexPath.row == 20 {
            
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! slidemenuCell
           
            if cell.hashKey == "T0010" {
                self.openBuzzApp()
            }
            else
            {
                if cell.hashKey == APIUrls().paymentDetails {
                    finance = 1
                } else if cell.hashKey == APIUrls().feeDetails {
                    finance = 2
                } else if cell.hashKey == APIUrls().feeSummary {
                    finance = 3
                } else if cell.hashKey == APIUrls().absenceReport {
                    finance = 5
                }
                
                let segueVal = self.getSegueIdentifier(title: cell.hashKey)
                sibling = false
                selectedHash=cell.hashKey
                if segueVal != ""{
                    if titleValue == ""{
                        self.performSegue(withIdentifier: segueVal, sender: nil)
                    }
                    else{
                        self.performSegue(withIdentifier: segueVal, sender: titleValue)
                    }
                }
            }
        }
    }
    
    func getSegueIdentifier(title:String) -> String{
        
        let identifier = menuListDetails[title]?[1]
        
        return identifier!
        
    }
     func setTableCellColor(indexPath:IndexPath,cell:slidemenuCell){
        
        if cell.hashKey == "T0004" ||  cell.hashKey == "T0008" {
            cell.isSection = true
        }else{
            cell.isSection = false
        }
        
    }
    
    
    func openBuzzApp(){
        let bundleID = Bundle.main.bundleIdentifier
        var appURLScheme = ""
        var applink = 0
       // print(bundleID)
        let details = logInResponseGloabl;
        
        //print(details["UMobile"])
        if ((bundleID?.elementsEqual("com.reportz.habitatv2")) == false)
        {
            appURLScheme = "Takyon360Buzz://"
            applink = 1375203859
        }
        else
        {
           // if(details["CompanyId"]as! String=="94")
            //{
                appURLScheme = "touchworldbybpro://"
                applink = 1662188522

          /*  }
            else
            {
                appURLScheme = "touchworldbyb://"
                applink = 1642865230
            }*/
        }
        //Takyon360Buzz://www.example.com/screen1?key1=value1&key2=value2
        guard let appURL = URL(string: appURLScheme) else {
            return
        }
        
        if !UIApplication.shared.canOpenURL(appURL){
            self.showAlertIfAppIsNotInstalled(appID:applink)
        }
       else{
            var dict  = [String : Any]()
            let md5Data = MD5(string:currentPassword)
            let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
            let md5Password = md5Hex
            dict[LogInKeys().username] = currentUserName
            dict[LogInKeys().password] = md5Password
            dict[LogInKeys().language] = currentLanguage
            dict[LogInKeys().platform] = "ios"
            dict[LogInKeys().Package] = Bundle.main.bundleIdentifier
            var url = "\(appURL)"
            if ((bundleID?.elementsEqual("com.reportz.habitatv2")) == false)
            {
                url = url + "key1=" + currentUserName + "&key2=" + currentPassword
            }
            else
            {
                UMobile = details["UMobile"] as! String
                url = url + "?un=" + UMobile + "&pass=" + UMobile
            }
            let ns = URL(string : url)
          //  SweetAlert().showAlert(kAppName, subTitle: "You need" + url, style:AlertStyle.warning)
  
           /* if #available(iOS 10.0, *) {
                UIApplication.shared.open(ns!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary(dict), completionHandler: nil)
            }
            else{
                UIApplication.shared.open(ns!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary(dict), completionHandler: nil)
            }
            */
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(ns!)
        }
        else{
            UIApplication.shared.openURL(ns!)
        }
        }
    }
    
    func showAlertIfAppIsNotInstalled(appID:Int){
        
        SweetAlert().showAlert(kAppName, subTitle: "You need to install Bus App", style: AlertStyle.warning, buttonTitle:alertCancel, buttonColor:UIColor.lightGray , otherButtonTitle: alertOk, otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == false {
               /* if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string:appUrl)!)
                }
                else{
                    UIApplication.shared.openURL(URL(string:appUrl)!)
                }*/
                let vc = SKStoreProductViewController()
                 vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier:NSNumber(value: appID)],completionBlock: nil)
                self.present(vc,animated:true)
               
            }
        }
    }
    
    func insertRemoveRowsAcademics(indexPath:IndexPath){
        
        
        if !titles.contains(acadamicsInnerArray[0]) {
            
            titles.insert(contentsOf: acadamicsInnerArray, at: 7)//append(contentsOf: acadamicsInnerArray)
            images.insert(contentsOf: academicsImageArray, at: 7)//append(contentsOf: academicsImageArray)
            
            print("titles :- ",titles)
            
            
            self.tableView.reloadData()
            
        }else{
            
            for element in acadamicsInnerArray{
                
                if titles.contains(element){
                    
                    guard  let index = titles.firstIndex(of: element) else {return}
                    
                    titles.remove(at: index)
                    images.remove(at: index)
                    
                }
            }
            
            tableView.reloadData()
            
            //            tableView.beginUpdates()
            //            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
            //            tableView.endUpdates()
        }
        
    }
    
    func downloadPdfButtonAction(url: String, fileName: String?) {
        
    }
    
    func getUploadedAttachments(isUpload : Bool, isForDraft: Bool) {
        
    }
    
    func postNotification(userId : String,student: String, classValue : String,img : String,name : String){
        NotificationCenter.default.post(name: Notification.Name("HomeChnageWithSiblings"), object:  ["userId" : userId])//, "studentName" : student,"classValue" : classValue,"img": img, "name" : name])
    }
    
    
    func getBackToParentView(value: Any?, titleValue: String?, isForDraft: Bool) {
        if let siblings = value as? TSibling{
        let imageUrlVal = siblings.proileImage
            sibling = true
            siblingUserId = siblings.userId.safeValue
            siblingUname = siblings.logInUserName.safeValue
            siblingPwd = siblings.logInPasword.safeValue
            self.performSegue(withIdentifier: "toHomeVc", sender: nil)
        }
    }
  
    func getBackToTableView(value: Any?,tagValueInt : Int) {
        
    }
    
    func selectedPickerRow(selctedRow: Int) {
        
    }
    
    func popUpDismiss() {
        
    }
    
    func moveToComposeController(titleTxt: String,index : Int,tag: Int) {
        
    }
    
    func getSearchWithCommunicate(searchTxt: String, type: Int) {
        
    }
}

class slideMenuFirstCell : UITableViewCell,PickerDelegate{
    
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var profileImage: ImageLoader!
    @IBOutlet weak var studentPicker: Picker!
    var delegate : TaykonProtocol?
    var siblings = [TSibling]()
    var imageUrl : String = "" {
        didSet{
            setImage()
        }
    }
    
    @IBOutlet weak var studentDetailLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        self.studentPicker.delegate = self
        
        self.studentPicker.backgroundColor = UIColor.clear
        self.profileImage.layer.cornerRadius = 30.00
        self.profileImage.clipsToBounds = true
        self.profileImage.layer.borderWidth = 1
        self.profileImage.layer.borderColor = UIColor.red.cgColor
        self.studentPicker.pickerTextField.textAlignment = .left
        self.studentPicker.pickerTextField.textColor = UIColor.white
    }
    
    func setImage(){
        setProfileImageToRound()
        self.profileImage.contentMode = .scaleAspectFill
        self.profileImage.loadImageWithUrl(imageUrl)
    }
    
    func setProfileImageToRound(){
        profileImage.layer.cornerRadius = 30
        profileImage.clipsToBounds = true
        self.profileImage.layer.borderWidth = 1
        self.profileImage.layer.borderColor = UIColor.red.cgColor
    }
    func pickerSelector(_ selectedRow: Int) {
        
        indexOfSelectedStudent = selectedRow
        
        let selectedSibling = siblings[selectedRow]
        if let userId = selectedSibling.userId as? String{
            UserDefaultsManager.manager.saveUserId(id: userId)
        }
        self.studentDetailLabel.text = "Class Name - " + selectedSibling.classValue.safeValue
        self.delegate?.getBackToParentView(value: selectedSibling, titleValue: "", isForDraft: false, message: TinboxMessage(values: [:]))
       
    }
    

}

class slidemenuCell : UITableViewCell{
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLabelContainerLeading: NSLayoutConstraint!
    @IBOutlet weak var titleToImageView: NSLayoutConstraint!
    var hashKey = String()
    @IBOutlet weak var topSeperationView: UIView!
    var isSection : Bool = false{
        didSet{
            setSectionHeader()
        }
    }
    
    
    func setSectionHeader(){
        
        if isSection{
            self.titleLabelContainerLeading.priority = UILayoutPriority(rawValue: 999)
            self.titleToImageView.priority = UILayoutPriority(rawValue: 500)
            self.titleLabel.textColor = UIColor.lightGray
            self.topSeperationView.isHidden = false
        }else{
            self.titleLabelContainerLeading.priority = UILayoutPriority(rawValue: 500)
            self.titleToImageView.priority = UILayoutPriority(rawValue: 999)
            self.titleLabel.textColor = UIColor.darkText
            self.topSeperationView.isHidden = true
            
            
        }
        
        self.layoutIfNeeded()
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
