//
//  WeeklyPlanFilterController.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 15/01/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit
import DropDown

class WeeklyPlanFilterController: UIViewController,UITextFieldDelegate{
    
    @IBOutlet weak var endingDateField: UITextField!
    @IBOutlet weak var startingDateField: UITextField!
    @IBOutlet weak var selectClassField: UITextField!
    @IBOutlet weak var selectSubject: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var viewLatestButtton: UIButton!
    
    var savedTime : String?
    var startTime = Date()
    var endTime = Date()
    var startTimeString = ""
    var endTimeString = ""
    var classValue = ""
    let dateFormatter1 = DateFormatter()
    var isSearch = Int()
    var divId = String()
    var subjectID:String = ""
    var delegate : TaykonProtocol?
    var datePicker : UIDatePicker!

    var divisions :[WeeklyDivision]?
    var subjectsnew = [TNSubject]()
    var dropDown : DropDown?
    var subjectDropDown : DropDown?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDropDown()
        setDateFormatter()
        //setSubjectDropDown()
        settextFieldProporties()
        setDate()
        // Do any additional setup after loading the view.
    }
    
    func setDate(){
        if startTimeString != ""{
            startingDateField.text = startTimeString
        }
        if endTimeString != ""{
            endingDateField.text = endTimeString
        }
        if classValue != ""{
            selectClassField.text = classValue
        }
        
    }
    func settextFieldProporties(){
        
        startingDateField.tag = 2
        endingDateField.tag  = 3
        self.endingDateField.delegate = self
        self.startingDateField.delegate = self
        self.selectClassField.delegate = self
        self.selectSubject.delegate = self
        
    }
    
    func setDateFormatter(){
        dateFormatter1.dateStyle = .long
        dateFormatter1.dateFormat = DateTypes.mmddyyyy
    }
    
    func setDropDown(){
        savedTime = nil
        dropDown = DropDown()
        DropDown.startListeningToKeyboard()
        dropDown?.direction  = .any
        
        
        // The view to which the drop down will appear on
        dropDown?.anchorView = selectClassField // UIView or UIBarButtonItem
        
        // The list of items to display. Can be changed dynamically
        
        guard let  _ = divisions else {return}
        
        var dataSources = [String]()
        for division in divisions!{
            
            dataSources.append(division.division!)
        }
        
        dropDown?.dataSource = dataSources//["Car", "Motorcycle", "Truck"]
        if dataSources.count > 0{
            self.selectClassField.text = dataSources[0]
            self .divId = filterDivIdWrtName(item: dataSources[0], array: self.divisions!)
            self.getSubjectAPI();
            dropDown?.selectionAction = { (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                self.divId = self.filterDivIdWrtName(item: item, array: self.divisions!)
                self.selectClassField.text = item
                self.getSubjectAPI();
            }
        }
        
    }
    
    func setSubjectDropDown(){
       // getSubjectAPI();
        savedTime = nil
        subjectDropDown = DropDown()
        DropDown.startListeningToKeyboard()
        subjectDropDown?.direction  = .any
        
        
        // The view to which the drop down will appear on
        subjectDropDown?.anchorView = selectSubject // UIView or UIBarButtonItem
        
        // The list of items to display. Can be changed dynamically
        
       // guard let  _ = subjects else {return}
        let _ = subjectsnew
        var dataSources = [String]()
        for subject in subjectsnew{
            
            dataSources.append(subject.subject_name!)
        }
        
        subjectDropDown?.dataSource = dataSources //["Car", "Motorcycle", "Truck"]
        if dataSources.count > 0{
            self.selectSubject.text = dataSources[0]
            self.subjectID = filterSubIdWrtName(item: dataSources[0], array: self.subjectsnew)
            subjectDropDown?.selectionAction = { (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                self.subjectID = self.filterSubIdWrtName(item: item, array: self.subjectsnew)
                self.selectSubject.text = item
                
            }
        }
        
    }
    
    func filterDivIdWrtName(item : String,array :[WeeklyDivision]) -> String{
        if array.count > 0{
            for each in array{
                if each.division  == item{
                    return each.divId!
                }
            }
        }
        return ""
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        
        //print("editing");
        //        if textField.tag == 1{
        
        //        }
    }
    
    
    func getSubjectAPI(){
        startLoadingAnimation()
        let url = APIUrls().subjectList;
        
        var dictionary = [String: String]()
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] =  userId
        dictionary[WeeklyPlanKeys().Div_Id]     = self.divId
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async{
                print("result :- ",result)
                if result["StatusCode"] as? Int == 1{
                if let values = result["subjectlist"] as? NSArray{
                    
                    let subjectmodel = ModelClassManager.sharedManager.createModelArray(data: values, modelType: ModelType.TNSubject) as! [TNSubject]
                    
                    self.subjectsnew = subjectmodel
                    self.setSubjectDropDown()
                    }
                    self.stopLoadingAnimation();
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
            }
        }
        
        
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 1{
            self.dropDown?.show()
            return false
            
        }else if textField.tag == 4 {
            self.subjectDropDown?.show()
            return false
        }else{
            self.showDatePicker(textField: textField)
            return true
        }
    }
    
    func showDatePicker(textField:UITextField){
        
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.tag = textField.tag
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePicker.Mode.date
        textField.inputView = self.datePicker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.isSelected = true
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick(sender:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
    }
    
    
    @objc func doneClick(sender : UIDatePicker) {
        let dateFormatter1 = DateFormatter()
        print(datePicker.date)
        dateFormatter1.dateFormat = DateTypes.mmddyyyy
        print(datePicker.date)
        let dateValue  = dateFormatter1.string(from: datePicker.date)
        print("nn",datePicker.tag)
        
        if datePicker.tag == 2{
            
            startingDateField.text = dateValue
            print("nn",dateValue)
            print("nn",startingDateField.text)
            startTime = (datePicker.date as NSDate) as Date
            startTimeString  = dateValue
            endingDateField.text =  getThe5thDayFromSelectedDate(date: datePicker.date as NSDate, value: 4)
            endTimeString = endingDateField.text!
            endTime = changetoDiffFormatInDate(value:endTimeString,fromFormat: "dd-MM-yyyy",toFormat:"yyyy-MM-dd hh:mm:ss")
            
            //  endTime = convertToDate(dateVal: endTimeString)
            
            //            let dateFormatZeros = "yyyy-MM-dd hh:mm:ss +0000"
            //            let dateFormatMonthText = "dd MMM yyyy"
            //            let dateFormatDateTimeText = "d MMMM y hh:mm a"
        }else{
            
            endingDateField.text = "\(dateValue)"
            endTime = (datePicker.date as NSDate) as Date
            endTimeString = dateValue
            //  startingDateField.text =
            // getThe5thDayFromSelectedDate(date: datePicker.date as NSDate, value: -4)
            startTimeString = startingDateField.text!
            
        }
        
        let calendar = NSCalendar.current
        
        let date1 = calendar.startOfDay(for: startTime as Date)
        let date2 = calendar.startOfDay(for: endTime as Date)//startOfDayForDate(endTime)
        
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        print(components.day)
        if (components.day)! >= 5   {
            SweetAlert().showAlert(kAppName, subTitle: "Please select a maximum of 5 days", style: .warning)
            searchButton.isUserInteractionEnabled = false
            viewLatestButtton.isUserInteractionEnabled = false
        }
        else{
            if (components.day)! <  0   {
                SweetAlert().showAlert(kAppName, subTitle: "Please select a maximum of 5 days", style: .warning)
                searchButton.isUserInteractionEnabled = false
                viewLatestButtton.isUserInteractionEnabled = false
            }
            else{
                searchButton.isUserInteractionEnabled = true
                viewLatestButtton.isUserInteractionEnabled = true
            }
            
        }
        startingDateField.resignFirstResponder()
        endingDateField.resignFirstResponder()
        
    }
    @objc func cancelClick() {
        startingDateField.resignFirstResponder()
        endingDateField.resignFirstResponder()
        
    }
    
    func getThe5thDayFromSelectedDate(date : NSDate,value : Int) -> String{
        
        
        var dayComponent = DateComponents()
        dayComponent.day = value
        var theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: date as Date)
        let diff = nextDate?.interval(ofComponent: .day, fromDate: date as Date)
        let dateValue  = dateFormatter1.string(from: nextDate!)
        
        return dateValue
        
    }
    
    @IBAction func searchAction(_ sender: Any) {
        if selectClassField.text != "" && selectSubject.text != "" && startingDateField.text != "" && endingDateField.text != ""{
            isSearch = 0
            let fullTime = (startTimeString,endTimeString,isSearch,divId,subjectID )
            delegate?.getBackToParentView(value: fullTime, titleValue: nil, isForDraft: false, message: TinboxMessage(values: [:]))
            dismissPopUpViewController()
        }
        else{
            SweetAlert().showAlert(kAppName, subTitle: "All fields are required", style: .error)
        }
    }
    
    @IBAction func viewLatestAction(_ sender: Any) {
        isSearch = 1
        let fullTime = (startTimeString,endTimeString,isSearch,divId,subjectID)
        delegate?.getBackToParentView(value: fullTime, titleValue: nil, isForDraft: false, message: TinboxMessage(values: [:]))
        dismissPopUpViewController()
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

extension Date {
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
}
