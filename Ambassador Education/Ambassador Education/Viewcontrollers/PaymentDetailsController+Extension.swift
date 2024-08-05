//
//  PaymentDetailsController+Extension.swift
//  Ambassador Education
//
//  Created by IE12 on 05/08/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import UIKit
import DropDown


extension PaymentDetailsController {


    func getStudentsAPI(){
        startLoadingAnimation()
        let url = APIUrls().subjectList;

        var dictionary = [String: String]()
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] =  userId
       // dictionary[WeeklyPlanKeys().Div_Id]     = self.filterDivId
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                print("result :- ",result)
                if result["StatusCode"] as? Int == 1{
                    if let values = result["subjectlist"] as? NSArray{

                        let subjectmodel = ModelClassManager.sharedManager.createModelArray(data: values, modelType: ModelType.TNSubject) as! [TNSubject]

                        self.setStudentDropDown()
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

    func setStudentDropDown(){
        dropDown = DropDown()
        DropDown.startListeningToKeyboard()
        dropDown?.direction  = .any


        // The view to which the drop down will appear on
        dropDown?.anchorView = buttonStudentsDropDown // UIView or UIBarButtonItem

        // The list of items to display. Can be changed dynamically

        // guard let  _ = subjects else {return}
        var dataSources = [String]()
        let details = logInResponseGloabl
        if let values = details["Siblings"] as? NSArray{

            let siblings = ModelClassManager.sharedManager.createModelArray(data: values, modelType: ModelType.TSibling) as! [TSibling]

            for sib in siblings {
                if let studentName = sib.studentName {
                    dataSources.append(studentName)
                }
            }
        }

        dropDown?.dataSource = dataSources //["Car", "Motorcycle", "Truck"]
        if dataSources.count > 0 {
            self.labelName.text = dataSources[0]
            if let studentid = self.getStudentId(studentName: dataSources[0]) {
                self.getpaymentSummery(studentId: studentid)
            }

            dropDown?.selectionAction = { (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                /// Call getpaymentSummery api for selected student.
                let studentName = self.labelName.text
                if studentName != item {
                    if let studentid = self.getStudentId(studentName: item) {
                        self.getpaymentSummery(studentId: studentid)
                        self.labelName.text = item
                    }
                }
            }
        }

    }

    func getStudentId(studentName: String) -> String? {
        let details = logInResponseGloabl
        if let values = details["Siblings"] as? NSArray {

            let siblings = ModelClassManager.sharedManager.createModelArray(data: values, modelType: ModelType.TSibling) as! [TSibling]
            for sib in siblings {
                if sib.studentName == studentName {
                    return sib.userId
                }
            }

        }
        return nil
    }
}
