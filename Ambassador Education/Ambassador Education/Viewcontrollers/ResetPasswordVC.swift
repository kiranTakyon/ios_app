//
//  ResetPasswordVC.swift
//  Ambassador Education
//
//  Created by Anil on 8/31/19.
//  Copyright © 2019 InApp. All rights reserved.
//

import UIKit

class ResetPasswordVC: UIViewController {
    
    @IBOutlet weak var confirmPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var newPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var key: SkyFloatingLabelTextField!
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    var userEmail:String?
    var delegate : TaykonProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSecureEntry()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setSecureEntry(){
        confirmPassword.isSecureTextEntry = true
        newPassword.isSecureTextEntry = true
    }
    
    func getUdidOfDevide() -> String{
        return  UIDevice.current.identifierForVendor!.uuidString
    }
    
    func postAPI(){
        var result = checkFieldIsnonEmpty()
        if result.0{
            self.startLoadingAnimation()
            let url = APIUrls().resetPassword
            
            var dictionary = [String: String]()
//            let userId = UserDefaultsManager.manager.getUserId()
            let new = newPassword.text
            let confirm = confirmPassword.text
            let passwordKey = key.text
            guard let mail = userEmail else {SweetAlert().showAlert("Email is missing")
                return }
            dictionary[PasswordReset.newPassword] = new
            dictionary[PasswordReset.email] = mail
            dictionary[PasswordReset.key] = passwordKey
            
            
            APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary, completion: { (result) in
                
                print("change password result is ",result)
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    if let mesaage = result["StatusMessage"] as? String{
                        let msgToStr = mesaage.replacingHTMLEntities
                        if result["StatusCode"] as? Int == 1{
                            SweetAlert().showAlert(kAppName, subTitle: msgToStr, style: .success, buttonTitle: alertOk, action: { (index) in
                                if index{
                                    isFirstTime = true
                                    gradeBookLink = ""
                                    showLoginPage()
                                }
                            })
                        }
                            
                        else{
                            SweetAlert().showAlert(kAppName, subTitle: mesaage, style: .warning, buttonTitle: alertOk, action: { (index) in
                                if index{
                                    self.delegate?.popUpDismiss()
                                }
                            })
                        }
                    }
                }
                
                
            })
        }
        else{
            showAlertController(kAppName, message: result.1, cancelButton: alertOk, otherButtons: [], handler: nil)
        }
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.postAPI()
        
    }
    
    func checkFieldIsnonEmpty() -> (Bool,String){
        
        
        
        if confirmPassword.text != "" && newPassword.text != "" && key.text != ""{
            if (newPassword.text) == (confirmPassword.text){
                return (true,"")
            }
            else{
                return (false,"New password and confirm password does not match")
            }
            
        }else{
            
            return (false,"All fields are required")
            
        }
    }
    
    

    
}
