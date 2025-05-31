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

class WeeklyPlanController: UIViewController {
        
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var viewPager: MXSegmentedPager!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var labelSubject: UILabel!
    @IBOutlet weak var buttonSubjectDropDown: UIButton!
    @IBOutlet weak var viewClassDropDown: UIView!
    @IBOutlet weak var endingDateField: UITextField!
    @IBOutlet weak var startingDateField: UITextField!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var fromDateLabel: UILabel!
    @IBOutlet weak var toDateLabel: UILabel!
    @IBOutlet weak var progressBar: ProgressViewBar!
    @IBOutlet weak var collectionView: UICollectionView!

    private var lastQuery = ""
    private var searchText = ""
    var selectedIndexes: [Int] = []
    var divisions: [WeeklyDivision] = []
    let videoDownload  = VideoDownload()
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()
    var divId = ""
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
    var endTimeString = ""
    var startTime = Date()
    var endTime = Date()
    var isSearch = Int()
    private var debouncedDelegate: DebouncedTextFieldDelegate!
    var classDropDown : DropDown?
    var dataArray : [WeeklyPlanList] = [WeeklyPlanList](){
        didSet {
            self.setDataArray()
        }
    }
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
        debouncedDelegate = DebouncedTextFieldDelegate(handler: self)
        searchTextField.delegate = debouncedDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addBlurEffectToTableView(inputView: self.view, hide: true)
        progressBar.isHidden = true
    }
    
    @IBAction func selectClassDropDown(_ sender: Any) {
        classDropDown?.show()
    }
    
    
    @IBAction func searchButtonAction(_ sender: Any) {
        if searchTextField.text?.isEmpty == false {
            performSearchIfNeeded(query: searchTextField.text ?? "")
        }
    }
    
    @IBAction func viewLatestButtonPressed(_ sender: Any) {
        self.startTimeString = ""
        self.endTimeString = ""
        self.subId = ""
        self.divId = ""
        self.getWeeklyPlanDetails(fromDate: self.startTimeString, toDate: self.endTimeString, isSearch: 1, Sub_Id: self.subId, div: self.divId,isCallFrist: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    
    }

    @IBAction func FromdatePickerAction(_ sender: Any) {
        self.fromDatePickerTapped()
    }
    
    
    @IBAction func TodatePickerAction(_ sender: Any) {
        self.toDatePickerTapped()
    }
    
    @IBAction func didTapOnSubjectDropDown(_ sender: Any) {
        subjectDropDown?.show()
    }
    
    @IBAction func searchAction(_ sender: Any) {
        if startingDateField.text != "" && endingDateField.text != ""{
            isSearch = 0
            let fullTime = (startTimeString,endTimeString,isSearch,divId,subjectID )
            self.refreshParentView(value: fullTime, titleValue: nil, isForDraft: false)
        } else {
            SweetAlert().showAlert(kAppName, subTitle: "All fields are required", style: .error)
        }
    }
}

//MARK: - Functions -
extension WeeklyPlanController {
    
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

    func navigateToDetail(weeklyPlan:WeeklyPlanList){
        let detailVc = DigitalResourceDetailController.instantiate(from: .digitalResource)
        detailVc.weeklyPlan = weeklyPlan
        detailVc.divId = self.divId
        detailVc.comment_needed = self.comment_needed
        self.navigationController?.pushViewController(detailVc, animated: true)
    }

    
    func setPagerView(){
        if completeListDetails !=  nil{
            titles.removeAll()
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

    func loadPDFAndShare(url: String,formatString: String,fileName: String){
        var urlString = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let urls = URL(string: urlString!)
        addBlurEffectToTableView(inputView: self.view, hide: false)
        progressBar.isHidden = false
        progressBar.progressBar.setProgress(1.0, animated: true)
        progressBar.titleText = "Downloading,Please wait"
        videoDownload.startDownloadingUrls(urlToDowload:[urlString!],type:"",fileName: fileName)
        
    }
    
    func setClassName(for className: String) {
        classNameLabel.text = "\(className)"
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
    
    func setSubjectDropDown(){
        savedTime = nil
        subjectDropDown = DropDown()
        DropDown.startListeningToKeyboard()
        subjectDropDown?.direction  = .any
        subjectDropDown?.anchorView = buttonSubjectDropDown
        let _ = subjectsnew
        var dataSources = [String]()
        for subject in subjectsnew{
            
            dataSources.append(subject.subject_name!)
        }
        subjectDropDown?.dataSource = dataSources
        if dataSources.count > 0{
            self.labelSubject.text = dataSources[0]
            self.subjectID = filterSubIdWrtName(item: dataSources[0], array: self.subjectsnew)
            self.subId = self.subjectID
            subjectDropDown?.selectionAction = { (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                self.subjectID = self.filterSubIdWrtName(item: item, array: self.subjectsnew)
                self.labelSubject.text = item
                
            }
        }
    }
    
    func filterSubIdWrtName(item : String,array :[TNSubject]) -> String{
        if array.count > 0{
            for each in array{
                if each.subject_name  == item{
                    return each.subject_id!
                }
            }
        }
        return ""
    }
    
    func filterDivIdWrtName(item : String,array :[WeeklyDivision]) -> String{
        if array.count > 0{
            for each in array{
                if each.division  == item{
                    classNameString = each.division ?? "Class :"
                    return each.divId!
                }
            }
        }
        return ""
    }
}

//MARK: - Date Formattter -

extension WeeklyPlanController {
    
    func setDatesOnPicker(){
        var daycomponents = DateComponents(calendar: Calendar.current,weekday:  Calendar.current.firstWeekday)
        print("hh",Calendar.current.timeZone)
        let startday = Calendar.current.nextDate(after: Date(), matching: daycomponents, matchingPolicy: .nextTimePreservingSmallerComponents)
        daycomponents.day = -8
        var fromdate = Calendar.current.date(byAdding: daycomponents, to: startday ?? today as Date)
        self.fromDateLabel.text = "From : \(dateFormatter1.string(from: fromdate ?? today as Date))"
        self.toDateLabel.text = "To : \(getThe5thDayFromSelectedDate(date: fromdate as! NSDate, value: +1))"
    }
  
    func convertToDate(from dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        return formatter.date(from: dateString)
    }
    
    func convertToDateString(from dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd-MM-yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return nil
    }
    
    func getThe5thDayFromSelectedDate(date : NSDate,value : Int) -> String{
        var dayComponent = DateComponents()
        dayComponent.day = value*(weeklyPlan?.no_days ?? 5)
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: date as Date)
        let dateValue  = dateFormatter1.string(from: nextDate!)
        return dateValue
    }
    
    func getprevSelectedDate(date : NSDate,value : Int) -> String{
        var dayComponent = DateComponents()
        dayComponent.day = value
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: date as Date)
        let dateValue  = dateFormatter1.string(from: nextDate!)
        return dateValue
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
        if fromDateLabel.text != "" {
            if let value = fromDateLabel.text?.components(separatedBy: ": ") {
                for each in value {
                    if each.contains("-") || each.contains("/") {
                        let normalizedDateStr = each.replacingOccurrences(of: "-", with: "/")
                        let newdate = convertToDDMMYYYY(normalizedDateStr)
                        toDateLabel.text = newdate
                        let format = "dd/MM/yyyy"
                        let date = changetoDiffFormatInDate(value: newdate, fromFormat: format, toFormat: "yyyy-MM-dd hh:mm:ss")
                        let nextDate = getThe5thDayFromSelectedDate(date: date as NSDate, value: -1)
                        let formatedStart = nextDate.replacingOccurrences(of: "-", with: "/")
                        let formatedEnd = newdate.replacingOccurrences(of: "-", with: "/")
                        self.fromDateLabel.text = "From : " + formatedStart
                        self.getWeeklyPlanDetails(fromDate: formatedStart, toDate: formatedEnd, isSearch: 0, Sub_Id: subId, div: divId)
                    }
                }
            }
        }
    }

    func convertToDDMMYYYY(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy/MM/dd"
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM/yyyy"
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString
        }
    }

    func toDatePickerTapped() {
        if toDateLabel.text != "" {
            if let value = toDateLabel.text?.components(separatedBy: ": ") {
                for each in value {
                    if each.contains("-") || each.contains("/") {
                        fromDateLabel.text = each
                        let format = "yyyy-MM-dd"
                        let newdate = each
                        let date = changetoDiffFormatInDate(value: newdate, fromFormat: format, toFormat: "yyyy-MM-dd hh:mm:ss")
                        
                        let ndate = getprevSelectedDate(date: date as NSDate, value: +1)
                        let nextDate = getThe5thDayFromSelectedDate(date: date as NSDate, value: +1)

                        self.toDateLabel.text = "To : " + nextDate
                        let formatedStart = ndate.replacingOccurrences(of: "-", with: "/")
                        let formatedEnd = nextDate.replacingOccurrences(of: "-", with: "/")
                        self.getWeeklyPlanDetails(fromDate: formatedStart, toDate: formatedEnd, isSearch: 0, Sub_Id: subId, div: divId)
                    }
                }
            }
        }
    }
    
    func setClassDropDown(){
        savedTime = nil
        classDropDown = DropDown()
        DropDown.startListeningToKeyboard()
        classDropDown?.direction  = .bottom
        classDropDown?.anchorView = viewClassDropDown
        var dataSources = [String]()
        divisions = self.weeklyPlan?.divisions ?? []
        for subject in divisions{
            dataSources.append(subject.division!)
        }
        classDropDown?.dataSource = dataSources
        if dataSources.count > 0{
            self.divId = divisions[0].divId.safeValue
            classDropDown?.selectionAction = {[weak self]  (index: Int, item: String) in
                guard let self = self else { return }
                print("Selected item: \(item) at index: \(index)")
                self.divId = self.filterDivIdWrtName(item: item, array: self.divisions)
                self.classNameLabel.text = item
                if  self.startingDateField.text != "" &&  self.endingDateField.text != ""{
                    self.isSearch = 0
                    let fullTime = (startTimeString,endTimeString,isSearch,divId,subjectID )
                    self.refreshParentView(value: fullTime, titleValue: nil, isForDraft: false)
                }
            }
        }
    }
    
    func setDate(){
        if let details = self.completeListDetails {
            if let start = details["FromDate"] as? String {
                if start != "" {
                    let date = convertToDateString(from: start) ?? ""
                    startTimeString = date
                    startingDateField.text = date
                    if let date = convertToDate(from: date) {
                        startTime = date
                    }
                }
            }
            if let end = details["ToDate"] as? String {
                if end != "" {
                    let date = convertToDateString(from: end) ?? ""
                    endTimeString = date
                    endingDateField.text = date
                    if let date = convertToDate(from: date) {
                        endTime = date
                    }
                }
            }
        }
    }
}

//MARK: - VideoDownloadDelegate -
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

extension WeeklyPlanController: DebouncedSearchHandling {

    func performSearchIfNeeded(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            guard !lastQuery.isEmpty else { return }
            lastQuery = ""
            reloadTableWithCompleteData()
            return
        }

        guard trimmedQuery != lastQuery else {
            print("Skipping API – same query")
            return
        }

        lastQuery = trimmedQuery
        callAPI(with: trimmedQuery)
    }

    private func callAPI(with query: String) {
        let events = fetchEvents()
        dataArray = filterEvents(byTitle: query, in: events)

        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func reloadTableWithCompleteData() {
        let events = fetchEvents()
        dataArray = events

        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func fetchEvents() -> [WeeklyPlanList] {
        let categoryKey = getMappedTitle(from: mainTitle)
        guard let list = completeListDetails?[categoryKey] as? NSArray else {
            return []
        }

        return ModelClassManager.sharedManager
            .createModelArray(data: list, modelType: .WeeklyPlanList) as? [WeeklyPlanList] ?? []
    }

    func filterEvents(byTitle searchText: String, in events: [WeeklyPlanList]) -> [WeeklyPlanList] {
        let trimmedText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return events }

        return events.filter { $0.topic?.localizedCaseInsensitiveContains(trimmedText) ?? false }
    }

    func getMappedTitle(from title: String) -> String {
        switch title.uppercased() {
        case "HOMEWORK":
            return "HomeWork"
        case "ASSESSMENT":
            return "Assessments"
        case "CLASSWORK":
            return "ClassWork"
        case "QUIZES":
            return "Quizes/Project/Research"
        default:
            return "Unknown"
        }
    }
}


