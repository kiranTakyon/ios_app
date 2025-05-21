//
//  WeeklyPlanController.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 14/01/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit
import MXSegmentedPager
import DatePickerDialog
import BIZPopupView
import QuickLook
import DropDown

var mainTitle = ""

protocol WeeklyPlanControllerDelegate: AnyObject {
    func weeklyPlanController(_ view: UIViewController, didtapOnCellForPopupWith comment: String, divId: String, weeklyPlan: WeeklyPlanList)
}

class WeeklyPlanController: UIViewController,TaykonProtocol {
        
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var viewPager: MXSegmentedPager!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var labelSubject: UILabel!
    @IBOutlet weak var buttonSubjectDropDown: UIButton!
    @IBOutlet weak var endingDateField: UITextField!
    @IBOutlet weak var startingDateField: UITextField!
    
    var selectedIndexes: [Int] = []
    
    let videoDownload  = VideoDownload()
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()
    var divId = ""
    var filterDivId = ""
    var dropDown : DropDown?
    var subId = ""
    var comment_needed = "1"
    var viewColors: [String] = ["F1C690","76CECF","EFC8CB","C49BC9"]
    var subjectsnew = [TNSubject]()
    var subjectID:String = ""
    var savedTime : String?
    
    var isPresent: Bool = false
    var completeListDetails : NSDictionary?
    var backgroundSession: URLSession!
    weak var delegate: WeeklyPlanControllerDelegate?
    var subjectDropDown : DropDown?
    var datePicker : UIDatePicker!
    var startTimeString = ""
    var endTimeString = "End Date"
    var startTime = Date()
    var endTime = Date()
    var isSearch = Int()
    
    var dataArray : [WeeklyPlanList] = [WeeklyPlanList](){
        didSet {
            self.setDataArray()
        }
    }
    
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var progressBar: ProgressViewBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var weeklyPlan : TNWeeklyPlan?
    var titles = [String]()
    var titlesnew = [String]()
    let dateFormatter1 = DateFormatter()
    var isEmpty = false
    
    var popUpViewVc : BIZPopupViewController?
    let today = NSDate()
    
    var currentFromDate = "Start Date"
    var currentToDate = "End Date"
    var classNameString = ""{
        didSet {
            self.setClassName(for: classNameString)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEmpty = false
        setDateFormatter()
        setDatesOnPicker()
        videoDownload.delegate = self
        quickLookController.dataSource = self
        quickLookController.delegate = self
        topHeaderView.delegate = self
        topHeaderView.shouldShowThirdRightButtons(true)
        if isPresent {
            topHeaderView.isHidden = true
            topHeaderView.viewHeightConstraint.constant = 40
            addCustomTopView()
        }
        
        collectionView.register(UINib(nibName: "WeeklyPlanCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WeeklyPlanCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        tableView.register(UINib(nibName: "WPTableViewCell", bundle: nil), forCellReuseIdentifier: "WPTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.endingDateField.delegate = self 
        self.startingDateField.delegate = self
        self.endingDateField.text = "End Date"
        self.startingDateField.text = "Start Date"
        getWeeklyPlanAPI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBlurEffectToTableView(inputView: self.view, hide: true)
        progressBar.isHidden = true
    }
    
    func setClassName(for className: String) {
        classNameLabel.text = "Class: \(className)"
    }
    
    func deleteTheSelectedAttachment(index: Int) {
        
    }
    
    func setDateFormatter() {
        dateFormatter1.dateStyle = .long
        dateFormatter1.dateFormat = DateTypes.yyyyMMdd
        let details = logInResponseGloabl;
        if(details["CompanyId"]as! String=="330")//Don't display dates for Al Zuhour #53462
        {
            self.fromDateLabel.isHidden = true
            self.toDateLabel.isHidden = true
        }
    }
    func setDatesOnPicker(){
        var daycomponents = DateComponents(calendar: Calendar.current,weekday:  Calendar.current.firstWeekday)
        print("hh",Calendar.current.timeZone)
        
        let startday = Calendar.current.nextDate(after: Date(), matching: daycomponents, matchingPolicy: .nextTimePreservingSmallerComponents)
        daycomponents.day = -8
        var fromdate = Calendar.current.date(byAdding: daycomponents, to: startday ?? today as Date)
       // self.fromDateLabel.text = "From : \(dateFormatter1.string(from: today as Date))"
        self.fromDateLabel.text = "From : \(dateFormatter1.string(from: fromdate ?? today as Date))"
        
        self.toDateLabel.text = "To : \(getThe5thDayFromSelectedDate(date: fromdate as! NSDate, value: +1))"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // backgroundSession = nil
    }
    

    func getWeeklyPlanAPI(){
        startLoadingAnimation()
        let url = APIUrls().weeklyPlan
        
        var dictionary = [String: String]()
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] =  userId
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
              print("requestParameters :- ",dictionary)
            print("result :- ",result)
            DispatchQueue.main.async{
                
                if result["StatusCode"] as? Int == 1{
                    
                    let weeklyPlanModels = ModelClassManager.sharedManager.createModelArray(data: [result], modelType: ModelType.TNWeeklyPlan) as! [TNWeeklyPlan]
                    
                    self.weeklyPlan = weeklyPlanModels[0]
                    self.topHeaderView.title = self.weeklyPlan?.weelyPlanLabel.safeValue ?? ""
                    self.stopLoadingAnimation()
                }
                else{
                    self.stopLoadingAnimation()
                    
                    if let message = result["MSG"] as? String{
                        SweetAlert().showAlert(kAppName , subTitle: message, style: AlertStyle.error)
                    }
                    else{
                        if let  message = result["StatusMessage"] as? String{
                            SweetAlert().showAlert(kAppName, subTitle: message, style: .success, buttonTitle: alertOk, action: { (index) in
                                if index{
                                    
                                }
                            })
                        }
                    }
                }
                if self.weeklyPlan != nil{
                    if let div = self.weeklyPlan?.divisions,let sub = self.weeklyPlan?.subjects{
                        if div.count > 0{
                            self.divId = div[0].divId.safeValue
                            self.subId = sub[0].subject_id.safeValue
                            self.classNameString = div[0].division.safeValue
                            self.getWeeklyPlanDetails(fromDate: self.startTimeString, toDate: self.endTimeString, isSearch: 1, Sub_Id: self.subId, div: self.divId)
                        }
                    }
                    else
                    {
                        self.getWeeklyPlanDetails(fromDate: self.startTimeString, toDate: self.endTimeString, isSearch: 1, Sub_Id: self.subId, div: self.divId)
                    }
                }
            }
        }
        
        
    }
    
    func downloadPdfButtonAction(url: String, fileName: String?) {
        
    }
    
    func selectedPickerRow(selctedRow: Int) {
        
    }
    
    func popUpDismiss() {
        
    }
    
    func moveToComposeController(titleTxt: String,index : Int,tag: Int) {
        
    }
    func getSearchWithCommunicate(searchTxt: String, type: Int) {
        
    }
    
    
    func getWeeklyPlanDetails(fromDate:String,toDate:String,isSearch : Int,Sub_Id:String,div : String){
        startLoadingAnimation()
        let url = APIUrls().weeklyPlanView
        
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        
        let isLatest  = isSearch
        let offset = 0
        let type = ""
        
        let limit = 50
        
        var dictionary = [String: Any]()
        
        dictionary[UserIdKey().id]              = userId
        dictionary[WeeklyPlanKeys().Div_Id]     = div
        dictionary[WeeklyPlanKeys().Sub_Id]     = Sub_Id
        dictionary[WeeklyPlanKeys().IsLatest]   = isLatest
        dictionary[WeeklyPlanKeys().OffSet]     = offset
        dictionary[WeeklyPlanKeys().type]       = type
        dictionary[WeeklyPlanKeys().FromDate]   = fromDate
        dictionary[WeeklyPlanKeys().ToDate]     = toDate
        dictionary[WeeklyPlanKeys().Limit]      = limit
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            print("WeeklyPlanView result is :- ",result)
            
            self.completeListDetails = result
            
            DispatchQueue.main.async {
                if let details = self.completeListDetails{
                    if let start = details["FromDate"] as? String{
                        self.fromDateLabel.text = "From : " + start
                    }
                    if let end = details["ToDate"] as? String{
                        self.toDateLabel.text = "To : " + end
                    }
                    if let comm_n = details["WPComments"] as? String {
                        self.comment_needed = comm_n
                    }
                }

                self.setPagerView()
                self.collectionView.reloadData()
                self.setDropDown()
                self.setDate()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.setUpInitialData()
                    self.titles.removeAll()
                    self.stopLoadingAnimation()
                }
            }
        }
        
        
    }
    func setPagerView(){
        if completeListDetails !=  nil{
            titlesnew.removeAll();
            for each in completeListDetails!{
                if each.value is NSArray{
                    if let value = each.value as? NSArray{
                        if value.count > 0{
                            self.titlesnew.append((each.key as! String).uppercased())
                            switch (each.key as! String).uppercased() {
                            case "HOMEWORK": self.titles.append(self.weeklyPlan?.homeWorkLabel.safeValue.uppercased() ?? "HOMEWORK")
                            case "CLASSWORK": self.titles.append(self.weeklyPlan?.classWorkLabel.safeValue.uppercased() ?? "CLASSWORK")
                            case "ASSESSMENTS": self.titles.append(self.weeklyPlan?.assessmentLabel.safeValue.uppercased() ?? "ASSESSMENT")
                            case "QUIZES": self.titles.append(self.weeklyPlan?.QuizLabel.safeValue.uppercased() ?? "QUIZES")
                            default:
                                break
                            }
                        }
                    }
                }
            }
            
            if self.titles.count > 0 {
                mainTitle = self.titles[0]
                isEmpty = false
            } else {
                isEmpty = true
                titles.removeAll()
                titles.append("")
            }
            
            self.collectionView.reloadData()
            
        }
    }
    func callDownLoadWeeklyPlanReport(type:String){
        
        // startLoadingAnimation()
        let url = APIUrls().weeklyPlanView
        let userId = UserDefaultsManager.manager.getUserId()
        var dictionary = [String: Any]()
        dictionary["UserId"] = userId
        dictionary["Div_Id"] = divId
        if let date = fromDateLabel.text?.lastWords(3){
            dictionary["FromDate"] = date[0]+"/"+date[1]+"/"+date[2]
            
        }
        if let date = toDateLabel.text?.lastWords(3){
            dictionary["ToDate"] = date[0]+"/"+date[1]+"/"+date[2]
            
        }
        dictionary["isLatest"] = true
        dictionary["Type"] = type
        dictionary["Limit"] = 5
        dictionary["OffSet"] = 0
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                
                if let status = result["StatusCode"] as? Int{
                    
                    self.setDownLoadUrl(result: result, type: type)
                    if let msg = result["StatusMessage"] as? String{
                        //SweetAlert().showAlert(kAppName, subTitle: msg, style: AlertStyle)
                        
                    }
                }
            }
        }
    }
    
    func setDownLoadUrl(result : NSDictionary,type:String){
        if let attachmentLink = result["AttachmentLink"] as? String{
            if type == "P"{
                self.loadPDFAndShare(url: attachmentLink, formatString: "downloadPdf.pdf",fileName: "")
            }
            else if type == "W"{
                self.loadPDFAndShare(url: attachmentLink, formatString: "downloadDoc.doc",fileName: "")
                
            }
        }
    }
    
    
    func convertToSlash(date : String)-> String{
        var letter = ""
        if date != ""{
            
            for each in date{
                if each == "-"{
                    letter.append("/")
                }
                else{
                    letter.append(each)
                }
            }
            return letter
        }
        return ""
    }
    
    
    func fromDatePickerTapped() {
        
        if fromDateLabel.text != ""{
            if let value = fromDateLabel.text?.components(separatedBy: ": ") as? [String]{
                
                for each in value{
                    if each.contains("-") || each.contains("/"){
                        toDateLabel.text = each
                        
                        if let dt = toDateLabel.text {
                            
                            if  let dates = dt.components(separatedBy: "-") as? [String]{
                                var newdate = ""
                                var format = ""
                                if each.contains("-"){
                                    if dates.count > 0{
                                        newdate = each //dates[2] + "/" + dates[1] + "/" + dates[0]
                                        format = "yyyy-MM-dd"
                                        
                                    }
                                }else{
                                    newdate = each
                                    format = "yyyy-MM-dd"
                                }
                                let date =  changetoDiffFormatInDate(value:newdate,fromFormat:format ,toFormat:"yyyy-MM-dd hh:mm:ss")
                                let nextDate = getThe5thDayFromSelectedDate(date: date as NSDate, value: -1)
                                self.fromDateLabel.text = "From : " + nextDate//+ convertToSlash(date: nextDate)
                                
                                self.getWeeklyPlanDetails(fromDate: nextDate, toDate: newdate, isSearch: 0, Sub_Id: subId, div: divId)
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    
    func toDatePickerTapped() {

        if toDateLabel.text != ""{
            if let  value = toDateLabel.text?.components(separatedBy: ": ") as? [String]{
                for each in value{
                    if each.contains("-") || each.contains("/"){
                        fromDateLabel.text = each
                        if let dt = fromDateLabel.text {
                            if  let dates = dt.components(separatedBy: "-") as? [String]{
                                var newdate = ""
                                var format = ""
                                if each.contains("-"){
                                    if dates.count > 0{
                                        newdate = each
                                        format = "yyyy-MM-dd"
                                    }
                                    }else{
                                        newdate = each
                                        format = "yyyy-MM-dd"
                                    }
                                    let date =  changetoDiffFormatInDate(value:newdate,fromFormat:format ,toFormat:"yyyy-MM-dd hh:mm:ss")
                                print("hh",date)
                                let ndate = getprevSelectedDate(date : date as NSDate,value: +1)
                                let nextDate = getThe5thDayFromSelectedDate(date: date as NSDate, value: +1)
                                print("hh3",nextDate)
                                print("hh3",ndate)
                                    self.toDateLabel.text = "To : " + nextDate
                                    self.getWeeklyPlanDetails(fromDate: ndate, toDate: nextDate, isSearch: 0, Sub_Id: subId, div: divId)
                            }
                        }
                    }
                }
            }
        }
                    
    }
        
        
    
    
    
    func loadPDFAndShare(url: String,formatString: String,fileName: String){
        var urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let urls = URL(string: urlString!)
        addBlurEffectToTableView(inputView: self.view, hide: false)
        progressBar.isHidden = false
        progressBar.progressBar.setProgress(1.0, animated: true)
        progressBar.titleText = "Downloading,Please wait"
        videoDownload.startDownloadingUrls(urlToDowload:[urlString!],type:"",fileName: fileName)
        
    }
    
    @IBAction func FromdatePickerAction(_ sender: Any) {
 //       datePicker.date = startTime
        self.fromDatePickerTapped()
    }
    
    
    @IBAction func TodatePickerAction(_ sender: Any) {
    //    datePicker.date = endTime
        self.toDatePickerTapped()
    }
    

    
    func getUploadedAttachments(isUpload : Bool, isForDraft: Bool) {
        
    }
    
    
    
    func showPopUpView(){
        let MainStoyboard = UIStoryboard(name: "Main", bundle: nil)
        let popvc = commonStoryBoard.instantiateViewController(withIdentifier: "WeeklyPlanFilterController") as! WeeklyPlanFilterController
        popvc.delegate = self
        if let _ = weeklyPlan?.divisions {
            popvc.divisions = weeklyPlan?.divisions
        }
        if let details = self.completeListDetails{
            
            if let start = details["FromDate"] as? String{
                popvc.startTimeString = start
            }
            if let end = details["ToDate"] as? String{
                popvc.endTimeString = end
            }
        }
        
//        popUpViewVc = BIZPopupViewController(contentViewController: popvc, contentSize: CGSize(width:300,height: CGFloat(520)))
//        self.present(popUpViewVc!, animated: true, completion: nil)
        popvc.view.frame = CGRect(x: 0, y: 0, width: 300, height: CGFloat(520))
         popUpEffectType = .flipDown
         presentPopUpViewController(popvc)
    }
    
    func getBackToParentView(value: Any?, titleValue: String?, isForDraft: Bool) {
        if let values = value as? (String,String,Int,String,String){
            
            let formatedStart = values.0.replacingOccurrences(of: "-", with: "/")
            let formatedEnd = values.1.replacingOccurrences(of: "-", with: "/")
            divId = values.3
            subId = values.4
            self.getWeeklyPlanDetails(fromDate:formatedStart, toDate: formatedEnd,isSearch: values.2, Sub_Id: subId, div: divId )
        }
        
        self.popUpViewVc?.dismiss(animated: true, completion: nil)
        
    }
    
    func refreshParentView(value: Any?, titleValue: String?, isForDraft: Bool) {
        if let values = value as? (String,String,Int,String,String){
            let formatedStart = values.0.replacingOccurrences(of: "-", with: "/")
            let formatedEnd = values.1.replacingOccurrences(of: "-", with: "/")
            divId = values.3
            subId = values.4
            self.getWeeklyPlanDetails(fromDate:formatedStart, toDate: formatedEnd,isSearch: values.2, Sub_Id: subId, div: divId )
        }
    }
    
    func getBackToTableView(value: Any?,tagValueInt : Int) {
        
        
        if let values = value as? WeeklyPlanList{
            
            if isPresent {
                self.dismiss(animated: true)
                delegate?.weeklyPlanController(self, didtapOnCellForPopupWith: comment_needed, divId: divId, weeklyPlan: values)
            } else {
                self.navigateToDetail(weeklyPlan:values)
            }
            
        }
        
        
    }
    
    func getThe5thDayFromSelectedDate(date : NSDate,value : Int) -> String{
        var dayComponent = DateComponents()
        dayComponent.day = value*(weeklyPlan?.no_days ?? 5)
        
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: date as Date)
        print("nextDate: \(nextDate) ...")
        
        let dateValue  = dateFormatter1.string(from: nextDate!)
        print("nextDate1: \(dateValue) ...")
        return dateValue
        
    }
    
    func getprevSelectedDate(date : NSDate,value : Int) -> String{
        var dayComponent = DateComponents()
        dayComponent.day = value
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: date as Date)
        print("nextDate: \(nextDate) ...")
        let dateValue  = dateFormatter1.string(from: nextDate!)
        return dateValue
        
    }
    
    func navigateToDetail(weeklyPlan:WeeklyPlanList){
        
        let detailVc = DigitalResourceDetailController.instantiate(from: .digitalResource)
        detailVc.weeklyPlan = weeklyPlan
        detailVc.divId = self.divId
        detailVc.comment_needed = self.comment_needed
        self.navigationController?.pushViewController(detailVc, animated: true)
        
    }

    
}


extension WeeklyPlanController:VideoDownloadDelegate{
    
    func loadingStarted(){
        //self.startLoadingAnimation()
    }
    
    func loadingEnded(){
        addBlurEffectToTableView(inputView: self.view, hide: true)
        progressBar.isHidden = true
    }
    
    func filesDownloadComplete(filePath:String,fileToDelT:String) {
        fileURLs = []
        let file = NSURL(string: filePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        fileURLs.append(file!)
        quickLookController.dataSource = nil
        quickLookController.delegate = nil
        
        quickLookController.dataSource = self
        quickLookController.delegate = self
        
        if QLPreviewController.canPreview(file!) {
            quickLookController.currentPreviewItemIndex = 0
            present(quickLookController, animated: true, completion: nil)
        }
    }
    
}

extension WeeklyPlanController : QLPreviewControllerDataSource ,QLPreviewControllerDelegate{
    
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        //
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        self.stopLoadingAnimation()
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return fileURLs.count
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURLs[index]
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}


extension WeeklyPlanController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        showPopUpView()
    }
    
    func searchButtonClicked(_ button: UIButton) {
        self.showAlertController(kAppName, message: "Please choose the file type you want to download.", cancelButton:alertCancel, otherButtons: [wordDownLoadType,pdfDownLoadType]) { (index) in
            if index == 0{
                self.dismiss(animated: true, completion: nil)
                
            }else if index == 1{
                self.callDownLoadWeeklyPlanReport(type: "W")
            }
            else if index == 2{
                self.callDownLoadWeeklyPlanReport(type: "P")
            }
        }
    }
    
    func thirdRightButtonClicked(_ button: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            }
            else {
                isFirstTime = true
                showLoginPage()
                gradeBookLink = ""
            }
        }
    }
    
}


//MARK: - UICollectionViewDelegate,UICollectionViewDataSource -

extension WeeklyPlanController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if !isEmpty {
            titles = titles.filter { $0 != "" }
        }
        if titles.count > 0 {
            return titles.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeeklyPlanCollectionViewCell", for: indexPath) as? WeeklyPlanCollectionViewCell else { return UICollectionViewCell() }
        let colorIndex = indexPath.row % viewColors.count
        let title = titles[indexPath.row]
        let isSelected = mainTitle.lowercased() == title.lowercased()
        cell.bgView.backgroundColor = isSelected ? UIColor(named: "AppColor") : UIColor(named: "9CDAE7")
        cell.titleLabel.text = titles[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if titles.count > 0{
            if let value = self.titles[indexPath.item] as? String{
                mainTitle  = value
            }
        }
        self.startLoadingAnimation()
        var titleType = String()
        if indexPath.item < titlesnew.count{
            var titless = self.titlesnew[indexPath.item]
            if titless.contains("ASSESSMENT") ||  titless.contains("ASSESSMENTS"){
                titless = "ASSESSMENT"
            }
            else if titless.contains("CLASSWORK") ||  titless.contains("CLASSWORKS"){
                titless = "CLASSWORK"
            }
            switch titless {
            case "HOMEWORK":
                titleType = "HomeWork"
            case "ASSESSMENT":
                titleType = "Assessments"
            case "CLASSWORK":
                titleType = "ClassWork"
            case "QUIZES":
                titleType = "Quizes/Project/Research"
                
            default:
                break
            }
            
            if  let list = self.completeListDetails?[titleType] as? NSArray {
                
                
                let arrayObjs = ModelClassManager.sharedManager.createModelArray(data: list, modelType: ModelType.WeeklyPlanList) as! [WeeklyPlanList]
                
                
                
                dataArray = arrayObjs
            } else {
                dataArray = [WeeklyPlanList]()
            }
            self.stopLoadingAnimation()
        }
        
        
    }
    
}

extension WeeklyPlanController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 85, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
       return 10
    }
}


extension WeeklyPlanController: UITableViewDelegate, UITableViewDataSource, WPTableViewCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "WPTableViewCell", for: indexPath) as? WPTableViewCell else { return UITableViewCell() }
        cell.index = indexPath.row
        cell.delegate = self
        if selectedIndexes.contains(indexPath.row) {
            cell.labelDescription.numberOfLines = 0
            cell.buttonArrow.isSelected = true
        } else {
            cell.buttonArrow.isSelected = false
        }
        
        let weeklyplan = self.dataArray[indexPath.row]
        if let count = weeklyplan.attachIconCount as? Int {
            cell.attachmntButtn.isHidden = !(count > 0)
        }
        if let topic = weeklyplan.topic {
            cell.labelTitle.text = topic
        }
        
        if let desc = weeklyplan.description {
            let htmlDecode = desc.replacingHTMLEntities
            cell.labelDescription.attributedText = htmlDecode?.htmlToAttributedString
        }
        
        if let date = weeklyplan.date {
            cell.labelDate.text = date
        }
        
        
        cell.selectionStyle = .none
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let values = self.dataArray[indexPath.row]
        self.navigateToDetail(weeklyPlan:values)
    }
    
    func wPTableViewCell(_ cell: WPTableViewCell, didTapOnArrow button: UIButton, index: Int) {
        if let index = selectedIndexes.firstIndex(of: index) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(index)
        }
        tableView.reloadData()
    }
    
    func setDataArray() {
        
        if dataArray.count == 0 {
            noDataLabel.isHidden = false
            tableView.isHidden = true
        } else {
            noDataLabel.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    func setUpInitialData() {
        dataArray.removeAll()
        var titleType = String()
        if 0 < titlesnew.count{
            var titless = self.titlesnew[0]
            if titless.contains("ASSESSMENT") ||  titless.contains("ASSESSMENTS"){
                titless = "ASSESSMENT"
            }
            else if titless.contains("CLASSWORK") ||  titless.contains("CLASSWORKS"){
                titless = "CLASSWORK"
            }
            switch titless {
            case "HOMEWORK":
                titleType = "HomeWork"
            case "ASSESSMENT":
                titleType = "Assessments"
            case "CLASSWORK":
                titleType = "ClassWork"
            case "QUIZES":
                titleType = "Quizes/Project/Research"
                
            default:
                break
            }
            if  let list = self.completeListDetails?[titleType] as? NSArray {
                let arrayObjs = ModelClassManager.sharedManager.createModelArray(data: list, modelType: ModelType.WeeklyPlanList) as! [WeeklyPlanList]
                dataArray = arrayObjs
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                dataArray = [WeeklyPlanList]()
            }
        }
    }
    
}
