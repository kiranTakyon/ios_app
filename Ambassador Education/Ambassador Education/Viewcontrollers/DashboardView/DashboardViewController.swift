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
    
    private var sideMenuTrailingConstraint: NSLayoutConstraint!
    private var upComingEventViewController: UpComingEventViewController!
    var moduleList = [TModule]()
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
    var apiRoutesArray:[String] = [APIUrls().fUELMETER,APIUrls().jOURNEYPROGRESS,APIUrls().cHALLANGESPROGRESS,APIUrls().qUIZPROGRESS]
    var userType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        configureCollectionViewCell()
        studentImageView.layer.cornerRadius = studentImageView.frame.width / 2
        setAllTextFieldsEmpty()
        updateCollectionViewHeight()
        userType = UserDefaultsManager.manager.getUserType()
        for item in apiRoutesArray {
            callProgressAPI(item)
        }
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
    
    @IBAction func redirectToProfileScreenPressed(_ sender: Any) {
        let profile = MyProfileController.instantiate(from: .myProfile)
        profile.shouldShowBackButton = true
        navigationController?.pushViewController(profile, animated: true)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
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
    
    func callProgressAPI(_ url: String) {
        guard let token = UserDefaultsManager.manager.getSessionToken(),
              let dict = logInResponseGloabl as? [String: Any] else { return }
        let userId = UserDefaultsManager.manager.getUserId()
        let schoolCode = dict["CompanyId"] as? Int ?? 36
        let parameters: [String: Any] = [
            "SchoolCode": schoolCode,
            "user_id": userId,
            "Token": token
        ]

        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: parameters) { [weak self] result in
            DispatchQueue.main.async {
                if let responseDict = result as? NSDictionary,
                   let message = responseDict["StatusMessage"] as? String,
                   message == "Success" {
                    
                    let progress = TProgressTypeModel(values: responseDict)
                    self?.progressViews.append(progress)
                }
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

        if let cachedModules: [TModule] = cacheManager.loadFromCache(key: "modulesCache") {
            self.moduleList = cachedModules
            self.updateUI()
        } else {
            self.startLoadingAnimation()
        }
        self.startLoadingAnimation()
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                var notificationList = [TNotification]()
                var NoticeBoardItems = [TNNoticeBoardDetail]()

                self.stopLoadingAnimation()
                self.moduleList.removeAll()
                guard let nototificationsArray = result["Notification"] as? NSArray else{return}
                let notifications = ModelClassManager.sharedManager.createModelArray(data: nototificationsArray, modelType: ModelType.TNotification) as! [TNotification]
                notificationList.append(contentsOf: notifications)

                if let moduleArray = result["ModuleCount"] as? NSArray {
                    let module = ModelClassManager.sharedManager.createModelArray(data: moduleArray, modelType: ModelType.TModule) as! [TModule]
                    self.moduleList.append(contentsOf: module)
                }

                if let noticeBoardArray = result["NoticeBoardItems"] as? NSArray {
                    let noticeBoard = ModelClassManager.sharedManager.createModelArray(data: noticeBoardArray, modelType: ModelType.TNNoticeBoardDetail) as! [TNNoticeBoardDetail]
                    NoticeBoardItems.append(contentsOf: noticeBoard)
                }
                
                if let feeSummary = result["FeeSummary"] as? NSArray{
                    let feeSummaryM =  ModelClassManager.sharedManager.createModelArray(data: feeSummary, modelType: ModelType.TFeeSummary) as! [FeeSummary]
                    self.feeSummary = feeSummaryM
                }
                
                if let notifications = logInResponseGloabl.value(forKey: "Notification") as? NSArray {
                    logInResponseGloabl.removeObject(forKey: Notification.self)
                    logInResponseGloabl.setValue(nototificationsArray, forKey: "Notification")
                }
                self.collectionView.reloadData()
                self.updateCollectionViewHeight()

                cacheManager.saveToCache(data: notificationList, key: "notificationsCache")
                cacheManager.saveToCache(data: self.moduleList, key: "modulesCache")
                cacheManager.saveToCache(data: NoticeBoardItems, key: "noticeBoardCache")
                self.updateUI()
            }
        }
    }
    
    func updateUI() {
        let completeDict = logInResponseGloabl
        self.setStudentDetailsOnView(studentDetail: completeDict)
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
            if user == UserType.parent.rawValue || user == UserType.student.rawValue {
                if let studentName = studentDetail["StudentName"] as? String{
                    studentNameLabel.text = studentName
                }
                if let name = studentDetail["Name"] as? String{
                    studentSecondLabel.text = name
                }
            } else {
                if let dict = logInResponseGloabl as? NSDictionary {
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
        switch section {
        case 0:
            return moduleList.count
        case 1:
            return feeSummary.isEmpty ? 0 : 1
        case 2:
            return progressViews.isEmpty ? 0 : 4
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardCollectionViewCell.identifier , for: indexPath) as? DashboardCollectionViewCell else { return UICollectionViewCell() }
            let module = moduleList[indexPath.row]
            cell.model = module
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
        } else if indexPath.section == 1 {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DashboardGraphCollectionViewCell.identifier , for: indexPath) as? DashboardGraphCollectionViewCell else { return UICollectionViewCell() }
            if let feeSummary = feeSummary.first {
                cell.feeSummary = feeSummary
                cell.updateChart(with: feeSummary)
            }
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgressCollectionViewCell.identifier , for: indexPath) as? ProgressCollectionViewCell else { return UICollectionViewCell() }
            cell.setProgressData(data: progressViews[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let cell = collectionView.cellForItem(at: indexPath) as? DashboardCollectionViewCell {
                let module = cell.model
                navigateToViewController(for: module.hashKey ?? "", animated: true)
            }
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
            return CGSize(width: itemWidth, height: itemWidth + 20)
        }
        else if indexPath.section == 1{
            if let feeSummary = feeSummary.first{
                return CGSize(width: collectionView.bounds.width - 10, height: 370)
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

extension DashboardViewController {
    
    func navigateToViewController(for key: String, animated: Bool = true) {
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
            let gradeVC = GradeViewController.instantiate(from: .grade)
            gradeVC.hashkey = selectedHash ?? ""
            destinationVC = gradeVC
        case "T0019":
            destinationVC = AwarenessViewController.instantiate(from: .awareness)
        case "T0021":
            destinationVC = DigitalResourcesListController.instantiate(from: .digitalResource)
        case "T0041", "T0039", "T0040", "T0058", "T0059", "T0059_3", "T0059_4", "T0059_5", "T0060", "T0069", "T0059_6":
            let gradeVC = GradeViewController.instantiate(from: .grade)
            destinationVC = gradeVC
        case "T0035":
            destinationVC = PaymentDetailsController.instantiate(from: .paymentDetails)
        case "T0036", "T0037", "T0038":
            destinationVC = PaymentDetailsController.instantiate(from: .paymentDetails)
        case "T0002":
            destinationVC = CalendarController.instantiate(from: .calendar)
        case "MyProfileKey":
            let profile = MyProfileController.instantiate(from: .myProfile)
            profile.shouldShowBackButton = true
            destinationVC = profile
      
        default:
            print("Invalid key provided.")
            return
        }
        guard let destination = destinationVC else { return }
        navigationController?.pushViewController(destination, animated: animated)
    }
}
