//
//  ChangePasswordController.swift
//  Ambassador Education
//
//  Created by    Kp on 02/08/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit


class ChangePasswordController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var confirmPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var newPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var currentPassword: SkyFloatingLabelTextField!
    
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
        currentPassword.isSecureTextEntry = true
        confirmPassword.delegate = self
        newPassword.delegate = self
        currentPassword.delegate = self
    }
    
    func getUdidOfDevide() -> String{
    return  UIDevice.current.identifierForVendor!.uuidString
    }
    
    func postAPI(){
        var result = checkFieldIsnonEmpty()
        if result.0{
            self.startLoadingAnimation()
            let url = APIUrls().changePassword
            
            var dictionary = [String: String]()
            let userId = UserDefaultsManager.manager.getUserId()
            let current = currentPassword.text
            let new = newPassword.text
            let confirm = confirmPassword.text
            
             dictionary[UserIdKey().id] = userId
            dictionary[PasswordChange.currentPassword] = current
            dictionary[PasswordChange.newPassword] = new
            dictionary[PasswordChange.repeatPassword] = confirm
            dictionary[PasswordChange.client_ip] = getUdidOfDevide()

            
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
        
        
        
        if confirmPassword.text != "" && newPassword.text != "" && currentPassword.text != ""{
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ChangePasswordController:UITextViewDelegate {
 func textFieldShouldReturn(_ textField: UITextField) -> Bool
 {
     currentPassword.resignFirstResponder()
     newPassword.resignFirstResponder()
     confirmPassword.resignFirstResponder()
     return true
 }
 }
