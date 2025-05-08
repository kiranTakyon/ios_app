//
//  MenuViewController.swift
//  Ambassador Education
//
//  Created by IE14 on 15/02/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit
import StoreKit

var indexOfSelectedStudent = 0
var studentDetails = [TSibling]()
var gradeBookLink : String?
var selectedHash : String?
var sibling = false
var siblingUserId = ""
var siblingUname = ""
var siblingPwd = ""
var OpenBrowser = false
class MenuViewController: UIViewController {
    
    static var identifier = "MenuViewController"
    
    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var studentNameLabel: UILabel!
    @IBOutlet weak var schoolNameLabel: UILabel!
    @IBOutlet weak var profileImage: ImageLoader!
    @IBOutlet weak var studentPicker: Picker!
    @IBOutlet weak var academicsStackView: UIView!
    @IBOutlet weak var financeStackView: UIView!
    @IBOutlet weak var financeImageView: UIImageView!
    @IBOutlet weak var financeLabel: UILabel!
    @IBOutlet weak var academicsImageView: UIImageView!
    @IBOutlet weak var academicsLabel: UILabel!
    
    var delegate : TaykonProtocol?
    var siblings = [TSibling]()
    
    // MARK: - Variable
    var selectionTitles = [String]()
    var selectionIds = [Int]()
    let acadamicsInnerArray = ["Time Table","Digital Resources","Awareness & Policies","Report Card","Weekly Plan","Absence Report"]
    let academicsImageArray = ["","","","","",""]
    var menuListDetails = ["T0001":["dashboard","toHomeVc"],
                           "T0011":["notice_board","toNoticeboard"],
                           "T0018":["gallery","toGallery"],
                           "T0009":["communicate","toCommunicate"],
                           "T0004":["",""],
                           "T0005":["academicContent","toWeeklyPlan"],
                           "T0012":["gradeBook","toGradeBook"],
                           "T0019":["awarenessAndPolicies","toAwareness"],
                           "T0021":["digitalResources","toDigitalResource"],
                           "T0041":["timeTable","toGradeBook"],
                           "T0039":["controlPanel","toGradeBook"],
                           "T0040":["controlPanel","toGradeBook"],
                           "T0035":["fee_summary","toFeeSummary"],
                           "T0036":["fee_details","toFeeDetails"],
                           "T0037":["paymentHistory","toFeeDetails"],
                           "T0038":["report_card","toFeeDetails"],
                           "T0008":["",""],
                           "T0058":["studentBehaviour","toGradeBook"],
                           "T0059":["daily","toGradeBook"],
                           "T0059_3":["Primary Timetable","toGradeBook"],
                           "T0059_4":["Link1","toGradeBook"],
                           "T0059_5":["chatbot","toGradeBook"],
                           "T0060":["EYFS Timetable","toGradeBook"],
                           "T0002":["calendar","toCalendarView"],
                           "T0010":["Locator&Navigator","Location"],
                           "MyProfileKey":["Profile","toProfileVc"],
                           "T0059_1":["stogo_world_logo","toGradeBook"],
                           "T0059_6":["Stogo-Suite-Logo","toGradeBook"],
    ]
    var menuListItems = [TNMenuItem]()
    var mainItems = [TNMenuItem]()
    var academicsItems = [TNMenuItem]()
    var financeItems = [TNMenuItem]()
    var sectionHeaderItems = [TNMenuItem]()
    var isMenuApperaFirst = false
    
    // MARK: - Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureCollectionViewCell()
        collectionView.dataSource = self
        collectionView.delegate = self
        getMenuDetails()
        setImage()
        getSiblingsDetails()
        let stuDetails = getStudentNameAndSchoolName()
        studentPicker.delegate = self
        self.studentPicker.pickerTextField.textAlignment = .center
        self.studentPicker.pickerTextField.textColor = UIColor.white
        studentNameLabel.text = stuDetails.0
        schoolNameLabel.text = stuDetails.1
        NotificationCenter.default.addObserver(self, selector: #selector(onPostLoaded), name: NSNotification.Name(rawValue: "selecAlert"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getMenuDetails), name: NSNotification.Name(rawValue: "updateSideMenuItems"), object: nil)
        setDataForPicker()
    }
    
    func setDataForPicker(){
        print(studentDetails)
        studentPicker.pickerInputItems(selectionTitles as NSArray)
        studentPicker.pickerInputIDitems(selectionIds)
        schoolNameLabel.numberOfLines = 0
        studentNameLabel.numberOfLines = 0
        let user = UserDefaultsManager.manager.getUserType()
        if user == UserType.parent.rawValue || user == UserType.student.rawValue{
            if selectionTitles.count > indexOfSelectedStudent{
                studentPicker.pickerTextField.text = selectionTitles[indexOfSelectedStudent]
                //studentDetailLabel.text = studentDetails[indexOfSelectedStudent].classValue!
            }
        } else {
            let details =  getTheSchoolName()
            studentPicker.pickerTextField.text = details.0
           // studentDetailLabel.text =  details.1
        }
        let stuDetails = getStudentNameAndSchoolName()
        studentNameLabel.text = stuDetails.0
        schoolNameLabel.text = stuDetails.1
        
        if studentDetails.count > 0 {
            studentPicker.pickerButton.isHidden = false
        } else {
           studentPicker.pickerButton.isHidden = true
        }
        siblings = studentDetails
    }
    
    
    @IBAction func academicsButtonPressed(_ sender: UIButton) {
        let indexPath = IndexPath(item: 0, section: 1)
        moveToSection(indexPath)
       
    }
    
    
    @IBAction func financeButtonPressed(_ sender: UIButton) {
        let indexPath = IndexPath(item: 0, section: 2)
        moveToSection(indexPath)
    }
    
    @IBAction func redirectToProfileScreenPressed(_ sender: Any) {
        navigateToViewController(for: "MyProfileKey", header: "", from: self)
    }
    
    
    func setSideMenuForAcademics(_ selected:Bool){
        if selected{
            academicsStackView.backgroundColor = .clear
            academicsImageView.tintColor = UIColor.white
            academicsLabel.textColor = UIColor.white
        }
        else{
            academicsStackView.backgroundColor = .white
            academicsImageView.tintColor = UIColor(named: "AppColor")
            academicsLabel.textColor = UIColor(named: "AppColor")
        }
    }
    
    func setSideMenuForFinance(_ selected:Bool) {
        if selected {
            financeStackView.backgroundColor = .clear
            financeImageView.tintColor = UIColor.white
            financeLabel.textColor = UIColor.white
        }
        else{
            financeStackView.backgroundColor = .white
            financeImageView.tintColor = UIColor(named: "AppColor")
            financeLabel.textColor = UIColor(named: "AppColor")
        }
    }
    
    func moveToSection(_ indexPath:IndexPath){
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        DispatchQueue.main.async {
            if let attributes = self.collectionView.layoutAttributesForItem(at: indexPath) {
                let offset = CGPoint(x: 0, y: attributes.frame.origin.y - 10)
                self.collectionView.setContentOffset(offset, animated: false)
                if indexPath.section == 1 {
                    self.setSideMenuForAcademics(true)
                    self.setSideMenuForFinance(false)
                } else {
                    self.setSideMenuForFinance(true)
                    self.setSideMenuForAcademics(false)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else { return }
        
        let visibleIndexPaths = collectionView.indexPathsForVisibleItems
        let sortedIndexPaths = visibleIndexPaths.sorted(by: { $0.section < $1.section }) // Get the top-most section
        
        if let topSection = sortedIndexPaths.first?.section {
            switch topSection {
            case 0:
                setSideMenuForAcademics(false)
                setSideMenuForFinance(false)
            case 1:
                setSideMenuForAcademics(true)
                setSideMenuForFinance(false)
            case 2:
                setSideMenuForAcademics(false)
                setSideMenuForFinance(true)
            default:
                break
            }
        }
    }
}

// MARK: - Private functions -
extension MenuViewController{
    
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

    func configureCollectionViewCell() {
        collectionView.register(UINib(nibName: MenuCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MenuCollectionViewCell.identifier)
        collectionView.register(UINib(nibName: MenuHeaderCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: MenuHeaderCollectionViewCell.identifier)
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 500, right: 0)
    }
    
    @objc func getMenuDetails() {
        let logInDetails = logInResponseGloabl
        guard let menuList = logInDetails["MenuList"] as? [[String: Any]] else { return }
        
        let sortedArray = menuList.sorted { Int($0["MenuOrder"] as! String)! < Int($1["MenuOrder"] as! String)! }
        var zeroParentIds = [TNMenuItem]()
        var valueProfile = NSDictionary()
        
        if let lang = logInDetails["Language"] as? String {
            if lang == "1" {
                valueProfile = NSDictionary(objects: ["0", "Profile", "111111111111", "T0013"], forKeys: ["ParentId" as NSCopying, "Label" as NSCopying, "id" as NSCopying, "hashkey" as NSCopying])
            } else {
                valueProfile = NSDictionary(objects: ["0", "الملف الشخصي", "111111111111", "T0013"], forKeys: ["ParentId" as NSCopying, "Label" as NSCopying, "id" as NSCopying, "hashkey" as NSCopying])
            }
        }
        
        let profileItem = TNMenuItem(values: valueProfile)
        let unsortedItems = ModelClassManager.sharedManager.createModelArray(data: sortedArray as NSArray, modelType: ModelType.TNMenuItem) as! [TNMenuItem]
        
        var financemenuid: String = ""
        
        for menu in unsortedItems {
            if menu.label != "" {
                if menu.parentid == "0" {
                    if menu.hashKey.safeValue == "T0008" {
                        sectionHeaderItems.append(menu)
                        financemenuid = menu.id.safeValue
                    } else if menu.hashKey.safeValue == "T0004" {
                        sectionHeaderItems.append(menu)
                    } else {
                        mainItems.append(menu)
                    }
                } else if menu.parentid.safeValue == financemenuid {
                    financeItems.append(menu)
                } else if menu.parentid == "5" {
                    academicsItems.append(menu)
                }
            }
        }
        
        var index = 0
        for each in mainItems {
            zeroParentIds.insert(each, at: index)
            index += 1
        }
        
        var isFirst = false
        if sectionHeaderItems.count > 0 {
            isFirst = true
            for eachSection in sectionHeaderItems {
                if eachSection.hashKey == "T0008" {
                    if isFirst {
                        zeroParentIds.insert(eachSection, at: index)
                    } else {
                        zeroParentIds.insert(eachSection, at: index + 1)
                        index += 1
                    }
                    for eachFinance in financeItems {
                        index += 1
                        zeroParentIds.insert(eachFinance, at: index)
                    }
                    isFirst = false
                } else if eachSection.hashKey == "T0004" {
                    if isFirst {
                        zeroParentIds.insert(eachSection, at: index)
                    } else {
                        zeroParentIds.insert(eachSection, at: index + 1)
                    }
                    for eachFinance in academicsItems {
                        index += 1
                        zeroParentIds.insert(eachFinance, at: index)
                    }
                    isFirst = false
                }
            }
        }
        
        if zeroParentIds.count != 0 {
            zeroParentIds.insert(profileItem, at: 1)
        }
        
        menuListItems = zeroParentIds
        let userType = UserDefaultsManager.manager.getUserType()
        if userType == "admin"{
            if let index = financeItems.firstIndex(where: { $0.hashKey == "T0035" }) {
                financeItems.remove(at: index)
            }
        }
        
        if !isMenuApperaFirst{
            isMenuApperaFirst = true
            if let index = mainItems.firstIndex(where: { $0.hashKey == "T0001" }) {
                let item = mainItems[index]
                navigateToViewController(for: item.hashKey ?? "", header: item.label ?? "", from: self, animated: false)
            }
        }
        
        collectionView.reloadData()
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
    
    func getSiblingsDetails() {
        let details = logInResponseGloabl;
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
    
    func showAlertIfAppIsNotInstalled(appID:Int){
        SweetAlert().showAlert(kAppName, subTitle: "You need to install Bus App", style: AlertStyle.warning, buttonTitle:alertCancel, buttonColor:UIColor.lightGray , otherButtonTitle: alertOk, otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == false {
                let vc = SKStoreProductViewController()
                 vc.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier:NSNumber(value: appID)],completionBlock: nil)
                self.present(vc,animated:true)
               
            }
        }
    }

    func setImage(){
        self.profileImage.contentMode = .scaleAspectFill
        self.profileImage.loadImageWithUrl(getTheProductLogo())
    }
    
    func getTheProductLogo() -> String {
        if let dict = logInResponseGloabl as? NSDictionary{
            if let logo = dict["LogoPath"] as? String{
                return logo
            }
        }
        return ""
    }
}

// MARK: - Navigation functions -
extension MenuViewController{

    func navigateToViewController(for key: String, header:String,from viewController: UIViewController, animated: Bool = true) {
        var destinationVC: UIViewController?
        switch key {
        case "T0001":
            destinationVC = DashboardViewController.instantiate(from: .home)
        case "T0011":
            destinationVC = NoticeboardCategoryController.instantiate(from: .noticeboard)
        case "T0018":
            destinationVC = GalleryCategoryListController.instantiate(from: .gallery)
        case "T0009":
            destinationVC = CommunicateLandController.instantiate(from: .communicateLand)
        case "T0004", "T0008":
            print("No navigation available for this key.")
            return
        case "T0005":
            destinationVC = WeeklyPlanController.instantiate(from: .weeklyPlan)
        case "T0012":
            if OpenBrowser == true {
                if let gradeBookLink = gradeBookLink, let url = URL(string: gradeBookLink) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            } else {
                let gradeVC = GradeViewController.instantiate(from: .grade)
                gradeVC.header = header
                gradeVC.hashkey = selectedHash ?? ""
                destinationVC = gradeVC
            }
        case "T0019":
            destinationVC = AwarenessViewController.instantiate(from: .awareness)
        case "T0021":
            destinationVC = DigitalResourcesListController.instantiate(from: .digitalResource)
        case "T0041", "T0039", "T0040", "T0058", "T0059", "T0059_3", "T0059_4", "T0059_5", "T0060", "T0069", "T0059_6":
            let gradeVC = GradeViewController.instantiate(from: .grade)
            gradeVC.header = header
            destinationVC = gradeVC
        case "T0035":
            destinationVC = PaymentDetailsController.instantiate(from: .paymentDetails)
        case "T0036", "T0037", "T0038":
            destinationVC = PaymentDetailsController.instantiate(from: .paymentDetails)
        case "T0002":
            destinationVC = CalendarController.instantiate(from: .calendar)
        case "T0010":
            openBuzzApp()
        case "MyProfileKey":
            let profile = MyProfileController.instantiate(from: .myProfile)
            profile.shouldShowBackButton = true
            destinationVC = profile
        case "T0059_1":
            if let stringUrl = JWTHelper.shared.getStogoUrl() {
                gotoWeb(str : stringUrl)
            }
           // destinationVC = GradeViewController.instantiate(from: .grade)
        default:
            print("Invalid key provided.")
            return
        }

        if let destination = destinationVC {
            viewController.navigationController?.pushViewController(destination, animated: animated)
        }
    }
    
    func gotoWeb(str : String) {
        let vc = commonStoryBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.strU = str
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func onPostLoaded() {
        guard let navigationController = self.navigationController else { return }
        switch selectedAlertType {
        case .gallery:
            let vc = ImagePreviewController.instantiate(from: .gallery)
            let url = notificationObject.catid ?? ""
            vc.imageUrl = url
            vc.imageArr = [url]
            vc.pageTitle = notificationObject.title
            vc.position = 0
            navigationController.pushViewController(vc, animated: true)

        case .communicate:
            let vc = MessageDetailController.instantiate(from: .communicateLand)
            vc.messageId = notificationObject.id
            vc.typeMsg = typeValue
            navigationController.pushViewController(vc, animated: true)

        case .html:
            let vc = WeeklyPlanController.instantiate(from: .weeklyPlan)
            navigationController.pushViewController(vc, animated: true)

        case .noticeboard:
            let vc = NoticeboardDetailController.instantiate(from: .noticeboard)
            vc.NbID = notificationObject.processid ?? ""
            navigationController.pushViewController(vc, animated: true)

        case .weeklyPlan:
            let vc = WeeklyPlanController.instantiate(from: .weeklyPlan)
            navigationController.pushViewController(vc, animated: true)

        default:
            break
        }
    }
    
    func openBuzzApp(){
        let bundleID = Bundle.main.bundleIdentifier
        var appURLScheme = ""
        var applink = 0
        let details = logInResponseGloabl;
        if ((bundleID?.elementsEqual("com.reportz.habitatv2")) == false)
        {
            appURLScheme = "Takyon360Buzz://"
            applink = 1375203859
        }
        else
        {
            appURLScheme = "touchworldbybpro://"
            applink = 1662188522
        }
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
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(ns!)
            }
            else{
                UIApplication.shared.openURL(ns!)
            }
        }
    }
}

// MARK: - CollectionView Delegate and Datatsources -

extension MenuViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionHeaderItems.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return mainItems.count
        case 1: return academicsItems.count + 1
        case 2: return financeItems.count + 1
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let item = mainItems[indexPath.row ]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionViewCell.identifier, for: indexPath) as! MenuCollectionViewCell
            cell.titleLabel.text = item.label
            if let imageValue = menuListDetails[item.hashKey ?? ""]?[0] {
                if item.label == "parent contract"{
                    cell.setIage(for: "family")
                }
                else{
                    cell.setIage(for: imageValue)
                }
            }
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let item = sectionHeaderItems[0]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuHeaderCollectionViewCell.identifier, for: indexPath) as! MenuHeaderCollectionViewCell
                cell.titleLabel.text = item.label
                return cell
            } else {
                let item = academicsItems[indexPath.row - 1]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionViewCell.identifier, for: indexPath) as! MenuCollectionViewCell
                cell.titleLabel.text = item.label
                if let imageValue = menuListDetails[item.hashKey ?? ""]?[0] {
                    cell.setIage(for: imageValue)
                }
                return cell
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let item = sectionHeaderItems[1]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuHeaderCollectionViewCell.identifier, for: indexPath) as! MenuHeaderCollectionViewCell
                cell.titleLabel.text = item.label
                return cell
            } else {
                let item = financeItems[indexPath.row - 1]
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MenuCollectionViewCell.identifier, for: indexPath) as! MenuCollectionViewCell
                cell.titleLabel.text = item.label
                if let imageValue = menuListDetails[item.hashKey ?? ""]?[0] {
                    cell.setIage(for: imageValue)
                }
                return cell
            }
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        gradeBookLink = ""
        var item = TNMenuItem(values: [:])
        switch indexPath.section {
        case 0:
            item = mainItems[indexPath.row]
        case 1:
            if indexPath.row > 0 {
                item = academicsItems[indexPath.row - 1]
            }
        case 2:
            if indexPath.row > 0 {
                item = financeItems[indexPath.row - 1]
            }
        default:
            break
        }
        getTitleValue(item: item)
        handleCellSelection(at: indexPath, item: item)
    }
    
    private func getTitleValue(item:TNMenuItem)  {
        if let link = item.link, !link.isEmpty {
            gradeBookLink = link
            if item.hashKey == "T0069" || item.hashKey == "T0012" {
                OpenBrowser = true
            }
        }
    }

    private func handleCellSelection(at indexPath: IndexPath,item:TNMenuItem) {
        guard let key = item.hashKey else { return }
        if item.hashKey == "T0010" {
            openBuzzApp()
        } else {
            finance = getFinanceValue(for: key)
            sibling = false
            selectedHash = key
            navigateToViewController(for: key, header: item.label ?? "", from: self)
        }
    }

    private func getFinanceValue(for hashKey: String) -> Int {
        switch hashKey {
        case APIUrls().paymentDetails: return 1
        case APIUrls().feeDetails: return 2
        case APIUrls().feeSummary: return 3
        case APIUrls().absenceReport: return 5
        default: return 0
        }
    }
    
}

// MARK: - CollectionViewDelegateFlowLayout -
extension MenuViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let totalPadding = 13 + 13 + 10 * 2
        let itemWidth = (Int(collectionViewWidth) - totalPadding) / 3
        
        switch indexPath.section {
        case 0:
            return CGSize(width: itemWidth, height: itemWidth)
        case 1:
            return indexPath.row == 0 ? CGSize(width: collectionViewWidth - 40, height: 55) : CGSize(width: itemWidth, height: itemWidth)
        case 2:
            return indexPath.row == 0 ? CGSize(width: collectionViewWidth - 40, height: 55) : CGSize(width: itemWidth, height: itemWidth)
        default:
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 13, bottom: 0, right: 13)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension MenuViewController: TaykonProtocol {
    
    func deleteTheSelectedAttachment(index: Int) {
    
    }
    
    func downloadPdfButtonAction(url: String, fileName: String?) {}
    
    func getUploadedAttachments(isUpload : Bool, isForDraft: Bool) {}
    
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
  
    func getBackToTableView(value: Any?,tagValueInt : Int) {}
    
    func selectedPickerRow(selctedRow: Int) {}
    
    func popUpDismiss() {}
    
    func moveToComposeController(titleTxt: String,index : Int,tag: Int) {}
    
    func getSearchWithCommunicate(searchTxt: String, type: Int) {}
}

fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

extension MenuViewController: PickerDelegate{
    
    func pickerSelector(_ selectedRow: Int) {
        indexOfSelectedStudent = selectedRow
        let selectedSibling = siblings[selectedRow]
        if let userId = selectedSibling.userId as? String{
            UserDefaultsManager.manager.saveUserId(id: userId)
        }
        self.studentNameLabel.text = selectedSibling.studentName.safeValue
       getBackToParentView(value: selectedSibling, titleValue: "", isForDraft: false, message: TinboxMessage(values: [:]))
    }
    
}
