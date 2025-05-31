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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == startingDateField {
            self.showDatePicker(textField: textField, date: startTime,tag: 2)
        }
        else{
            self.showDatePicker(textField: textField, date: endTime)
        }
        return true
    }
    
    func showDatePicker(textField:UITextField,date:Date = Date(),tag:Int = 0) {
        
        self.datePicker = UIDatePicker(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 216))
        self.datePicker.tag = textField.tag
        self.datePicker.backgroundColor = UIColor.white
        self.datePicker.datePickerMode = UIDatePicker.Mode.date
        self.datePicker.tag = tag
        textField.inputView = self.datePicker
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.isSelected = true
        datePicker.date = date
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
        
        let calendar = NSCalendar.current
        
        let date1 = datePicker.tag == 2 ? datePicker.date : calendar.startOfDay(for: startTime as Date)
        let date2 = datePicker.tag == 0 ?  datePicker.date : calendar.startOfDay(for: endTime as Date)//startOfDayForDate(endTime)
        
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
                if datePicker.tag == 2{
                    startingDateField.text = dateValue
                    startTime = (datePicker.date as NSDate) as Date
                    startTimeString  = dateValue
                    endTimeString = endingDateField.text!
                    endTime = changetoDiffFormatInDate(value:endTimeString,fromFormat: "dd-MM-yyyy",toFormat:"yyyy-MM-dd hh:mm:ss")
                }else{
                    
                    endingDateField.text = "\(dateValue)"
                    endTime = (datePicker.date as NSDate) as Date
                    endTimeString = dateValue
                    startTimeString = startingDateField.text!
                    startTime = changetoDiffFormatInDate(value:startTimeString,fromFormat: "dd-MM-yyyy",toFormat:"yyyy-MM-dd hh:mm:ss")
                }
            }
            
        }
        startingDateField.resignFirstResponder()
        endingDateField.resignFirstResponder()
        
    }
    @objc func cancelClick() {
        startingDateField.resignFirstResponder()
        endingDateField.resignFirstResponder()
        
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
        cell.titleLabel.textColor = isSelected ? UIColor.white : UIColor.black
        cell.titleLabel.text = titles[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if titles.count > 0{
            if let value = self.titles[indexPath.item] as? String{
                mainTitle  = value
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
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



//MARK: - API Calls -
extension WeeklyPlanController {
    
    func getSubjectAPI(){
        startLoadingAnimation()
        let url = APIUrls().subjectList;
        var dictionary = [String: String]()
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] =  userId
        dictionary[WeeklyPlanKeys().Div_Id] = self.divId
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
    
    func callDownLoadWeeklyPlanReport(type:String){
        
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
    
    func getWeeklyPlanDetails(fromDate:String,toDate:String,isSearch : Int,Sub_Id:String,div : String,isCallFrist: Bool = false){
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
                if isCallFrist{
                    self.getSubjectAPI();
                }
                self.setDate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.setUpInitialData()
                    self.stopLoadingAnimation()
                }
            }
        }
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
                    self.setClassDropDown()
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
                            self.getWeeklyPlanDetails(fromDate: self.startTimeString, toDate: self.endTimeString, isSearch: 1, Sub_Id: self.subId, div: self.divId,isCallFrist: true)
                        }
                    }
                    else
                    {
                        if let div = self.weeklyPlan?.divisions{
                            self.classNameString = div[0].division.safeValue
                        }
                        self.getWeeklyPlanDetails(fromDate: self.startTimeString, toDate: self.endTimeString, isSearch: 1, Sub_Id: self.subId, div: "",isCallFrist: true)
                    }
                }
            }
        }
    }
}

//MARK: - TaykonProtocol -
extension WeeklyPlanController: TaykonProtocol{
    
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
    
    func getUploadedAttachments(isUpload : Bool, isForDraft: Bool) {
        
    }
    
}
