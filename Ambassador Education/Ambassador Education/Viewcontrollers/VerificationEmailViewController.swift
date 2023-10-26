//
//  VerificationEmailViewController.swift
//  Ambassador Education
//
//  Created by Veena on 18/02/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit

class VerificationEmailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var verificationNotificationLabel: UILabel!
    @IBOutlet weak var verificationCodeTextField: UITextField!
    
    var delegate : TaykonProtocol?
    var email = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        setEmailNotificationMsgInLabel()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func setEmailNotificationMsgInLabel(){
        verificationNotificationLabel.text = "Thank you for verifying your email id.A message with a confirmation code was sent to \(email).To complete the verification process,enter the verification code above."
        verificationCodeTextField.delegate = self
    }
    
    func setEmailVerification(key : String){
            self.startLoadingAnimation()
            let url = APIUrls().emailVerificationCode
            var dictionary = [String: String]()
            
            dictionary[EmailVerifications().getEmailVCode] = email
            dictionary[EmailVerifications().verificationKey] = key
            APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
                
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    
                    if result["StatusCode"] as? Int == 1{
                        if let  message = result["StatusMessage"] as? String{
                            SweetAlert().showAlert(kAppName, subTitle: message, style: .success, buttonTitle: alertOk, action: { (index) in
                                if index{
                                    self.delegate?.popUpDismiss()
                                    self.dismiss(animated: true, completion: nil)
                                    self.setVerifiedUser()                                }
                            })
                       }
                    }
                    else{
                        if let mesaage = result["StatusMessage"] as? String{
                            SweetAlert().showAlert(kAppName, subTitle: mesaage, style: .error, buttonTitle: alertOk, action: { (index) in
                                if index{
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })

                            
                        }
                        
                    }
                    
                }
            }
            
        }

    
    @IBAction func saveButtonAction(_ sender: UIButton) {
        if verificationCodeTextField.text != ""{
            setEmailVerification(key: verificationCodeTextField.text!)
        }
        else{
            showAlertController(kAppName, message: "All fields are required", cancelButton: alertOk, otherButtons: [], handler: nil)
        }
    }
    func setVerifiedUser(){
        if let globalDict = logInResponseGloabl as? NSMutableDictionary{
            globalDict["VerifiedUser"]="1"
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
extension VerificationEmailViewController:UITextViewDelegate {
 func textFieldShouldReturn(_ textField: UITextField) -> Bool
 {
     verificationCodeTextField.resignFirstResponder()
     return true
 }
 }
