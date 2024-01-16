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

var mainTitle = ""

class WeeklyPlanController: UIViewController,MXSegmentedPagerDelegate,MXSegmentedPagerDataSource,TaykonProtocol {
        
    @IBOutlet weak var viewPager: MXSegmentedPager!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    let videoDownload  = VideoDownload()
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()
    var divId = ""
    var subId = ""
    var comment_needed = "1"
    
    var completeListDetails : NSDictionary?
    var backgroundSession: URLSession!
    
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var progressBar: ProgressViewBar!
    
    var weeklyPlan : TNWeeklyPlan?
    var titles = [String]()
    var titlesnew = [String]()
    let dateFormatter1 = DateFormatter()
    var isEmpty = false
    
    var popUpViewVc : BIZPopupViewController?
    let today = NSDate()
    
    var currentFromDate = ""
    var currentToDate = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isEmpty = false
//        self.showPopUpView()
        setPagerProporties()
        setDateFormatter()
        setSlideMenuProporties()
        setDatesOnPicker()
        videoDownload.delegate = self
        quickLookController.dataSource = self
        quickLookController.delegate = self
        topHeaderView.delegate = self
        topHeaderView.shouldShowThirdRightButtons(true)
        
        //self.getWeeklyPlanDetails(fromDate: dateFormatter1.string(from: today as Date), toDate: getThe5thDayFromSelectedDate(date: today, value: 4), isSearch: 0, div: "")
        getWeeklyPlanAPI()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBlurEffectToTableView(inputView: self.view, hide: true)
        progressBar.isHidden = true
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
                            self.getWeeklyPlanDetails(fromDate: "", toDate: "", isSearch: 1, Sub_Id: self.subId, div: self.divId)
                        }
                    }
                    else
                    {
                        self.getWeeklyPlanDetails(fromDate: "", toDate: "", isSearch: 1, Sub_Id: self.subId, div: self.divId)
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
                
                self.viewPager.segmentedControl.selectedSegmentIndex = 0
               // self.viewPager.segmentedControl.select(index: 0, animated: true)
                self.setPagerView()
                self.stopLoadingAnimation()
               // self.titles.removeAll()
                //self.titlesnew.removeAll()
                self.viewPager.reloadData()
                self.titles.removeAll()
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
            
            if self.titles.count > 0{
                mainTitle = self.titles[0]
                isEmpty = false
                
               // self.viewPager.isHidden = false
            }
            else{
                isEmpty = true
                titles.removeAll()
                titles.append("")
            }
            self.viewPager.reloadData()
            
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
        
        
    
    func setPagerProporties(){
        
        viewPager.delegate = self
        viewPager.dataSource = self
        viewPager.segmentedControl.selectionIndicatorLocation =  HMSegmentedControlSelectionIndicatorLocation.down//HMSegmentedControlSelectionIndicatorLocationDown
        viewPager.segmentedControl.selectionIndicatorColor = UIColor.white
        //viewPager.segmentedControl.indicatorColor = UIColor.white
        viewPager.segmentedControl.backgroundColor = UIColor.appOrangeColor()
                viewPager.segmentedControl.tintColor = UIColor.white
        
        let attributeFontSaySomething : [String : Any] = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor) : UIColor.white,convertFromNSAttributedStringKey(NSAttributedString.Key.font) : UIFont.boldSystemFont(ofSize: 14.0)]
        //
       viewPager.segmentedControl.titleTextAttributes = attributeFontSaySomething
        
        
        
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
    
    func setSlideMenuProporties(){
        if let revealVC = revealViewController() {
            topHeaderView.setMenuOnLeftButton(reveal: revealVC)
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    
    //MARK:- MXPagerViewDelegate & MXPagerViewDataSource
    
    func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        if !isEmpty{
            titles = titles.filter { $0 != "" }
        }
        if titles.count > 0{
            return titles.count
        }
        return 1
    }
    
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        if titles.count > 0{
            return titles[index]
        }
        return ""
    }
    
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelectViewWith index: Int) {
        
        print("index value :- ",index)
        if titles.count > 0{
            if let value = self.titles[index] as? String{
                mainTitle  = value
            }
        }
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        
        let tableView = WeeklyPlanTable(frame: CGRect(x: 0, y: 0, width: segmentedPager.frame.size.width, height: segmentedPager.frame.size.height))
        
        tableView.delegate = self
        var titleType = String()
        if index < titlesnew.count{
            var titless = self.titlesnew[index]
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
            
            if  let list = self.completeListDetails?[titleType] as? NSArray{
                
                
                let arrayObjs = ModelClassManager.sharedManager.createModelArray(data: list, modelType: ModelType.WeeklyPlanList) as! [WeeklyPlanList]
                
                
                
                tableView.dataArray = arrayObjs
            }
            else{
                tableView.dataArray = [WeeklyPlanList]()
            }
        }
        
        return tableView
        
    }
    
    @IBAction func FromdatePickerAction(_ sender: Any) {
        self.fromDatePickerTapped()
    }
    
    
    @IBAction func TodatePickerAction(_ sender: Any) {
        
        self.toDatePickerTapped()
        
    }
    

    
    func getUploadedAttachments(isUpload : Bool, isForDraft: Bool) {
        
    }
    
    
    
    func showPopUpView(){
        let MainStoyboard = UIStoryboard(name: "Main", bundle: nil)
        let popvc = MainStoyboard.instantiateViewController(withIdentifier: "WeeklyPlanFilterController") as! WeeklyPlanFilterController
        popvc.delegate = self
        if let _ = weeklyPlan?.divisions{
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
    
    
    func getBackToTableView(value: Any?,tagValueInt : Int) {
        
        
        if let values = value as? WeeklyPlanList{
            
            self.navigateToDetail(weeklyPlan:values)
            
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
        
        let detailVc = mainStoryBoard.instantiateViewController(withIdentifier: "DigitalResourceDetailController") as! DigitalResourceDetailController
        detailVc.weeklyPlan = weeklyPlan
        detailVc.divId = self.divId
        detailVc.comment_needed = self.comment_needed
        self.navigationController?.pushViewController(detailVc, animated: true)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
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
