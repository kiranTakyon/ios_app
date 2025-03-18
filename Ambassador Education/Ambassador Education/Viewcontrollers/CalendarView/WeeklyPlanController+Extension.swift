//
//  WeeklyPlanController+Extension.swift
//  Ambassador Education
//
//  Created by apple on 24/06/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit
import DropDown

extension WeeklyPlanController: UITextFieldDelegate {
    
    func getSubjectAPI(){
        startLoadingAnimation()
        let url = APIUrls().subjectList;
        
        var dictionary = [String: String]()
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] =  userId
        dictionary[WeeklyPlanKeys().Div_Id]     = self.filterDivId
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                print("result :- ",result)
                if result["StatusCode"] as? Int == 1{
                    if let values = result["subjectlist"] as? NSArray{
                        
                        let subjectmodel = ModelClassManager.sharedManager.createModelArray(data: values, modelType: ModelType.TNSubject) as! [TNSubject]
                        
                        self.subjectsnew = subjectmodel
                        self.setSubjectDropDown()
                    }
                    self.stopLoadingAnimation();
                }
                else {
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
    
    func setSubjectDropDown(){
        savedTime = nil
        subjectDropDown = DropDown()
        DropDown.startListeningToKeyboard()
        subjectDropDown?.direction  = .any
        
        
        // The view to which the drop down will appear on
        subjectDropDown?.anchorView = buttonSubjectDropDown // UIView or UIBarButtonItem
        
        // The list of items to display. Can be changed dynamically
        
        // guard let  _ = subjects else {return}
        let _ = subjectsnew
        var dataSources = [String]()
        for subject in subjectsnew{
            
            dataSources.append(subject.subject_name!)
        }
        
        subjectDropDown?.dataSource = dataSources //["Car", "Motorcycle", "Truck"]
        if dataSources.count > 0{
            self.labelSubject.text = dataSources[0]
            self.subjectID = filterSubIdWrtName(item: dataSources[0], array: self.subjectsnew)
            subjectDropDown?.selectionAction = { (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                self.subjectID = self.filterSubIdWrtName(item: item, array: self.subjectsnew)
                self.labelSubject.text = item
                
            }
        }
        
    }
    
    func setDropDown(){
        savedTime = nil
        dropDown = DropDown()
        DropDown.startListeningToKeyboard()
        dropDown?.direction  = .any
        
        
        // The view to which the drop down will appear on
        //dropDown?.anchorView = selectClassField // UIView or UIBarButtonItem
        
        // The list of items to display. Can be changed dynamically
        
        guard let  _ = weeklyPlan?.divisions else {return}
        
        var dataSources = [String]()
        if let divisions = weeklyPlan?.divisions {
            for division in divisions {
                
                dataSources.append(division.division!)
            }
        }
        dropDown?.dataSource = dataSources//["Car", "Motorcycle", "Truck"]
        if dataSources.count > 0 {
            self.filterDivId = filterDivIdWrtName(item: dataSources[0], array: (self.weeklyPlan?.divisions!)!)
            self.getSubjectAPI();
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
                    return each.divId!
                }
            }
        }
        return ""
    }
    
    @IBAction func didTapOnSubjectDropDown(_ sender: Any) {
        
        subjectDropDown?.show()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        self.showDatePicker(textField: textField)
        return true
        
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
            //            searchButton.isUserInteractionEnabled = false
            //            viewLatestButtton.isUserInteractionEnabled = false
        }
        else{
            if (components.day)! <  0   {
                SweetAlert().showAlert(kAppName, subTitle: "Please select a maximum of 5 days", style: .warning)
                //                searchButton.isUserInteractionEnabled = false
                //                viewLatestButtton.isUserInteractionEnabled = false
            }
            else{
                //                searchButton.isUserInteractionEnabled = true
                //                viewLatestButtton.isUserInteractionEnabled = true
            }
            
        }
        startingDateField.resignFirstResponder()
        endingDateField.resignFirstResponder()
        
    }
    @objc func cancelClick() {
        startingDateField.resignFirstResponder()
        endingDateField.resignFirstResponder()
        
    }
    
    func setDate(){
        
        if let details = self.completeListDetails {
            if let start = details["FromDate"] as? String {
                if start != "" {
                    startTimeString = start
                    startingDateField.text = start
                }
            }
            if let end = details["ToDate"] as? String {
                if end != "" {
                    endTimeString = end
                    endingDateField.text = end
                }
            }
        }
    }
    
    
    @IBAction func searchAction(_ sender: Any) {
        if startingDateField.text != "" && endingDateField.text != ""{
            isSearch = 0
            let fullTime = (startTimeString,endTimeString,isSearch,filterDivId,subjectID )
            self.refreshParentView(value: fullTime, titleValue: nil, isForDraft: false)
        } else {
            SweetAlert().showAlert(kAppName, subTitle: "All fields are required", style: .error)
        }
    }
    
}
