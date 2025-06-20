//
//  ForgotPasswordController.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 25/09/17.
//  Copyright © 2017 InApp. All rights reserved.
//

import UIKit
import DGActivityIndicatorView
import BIZPopupView
import EzPopup

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityView.stopAnimating()
        intialStUp()
        // Do any additional setup after loading the view.
    }
    
    func intialStUp(){
        usernameField.placeholder = "User Name"
        passwordField.placeholder = "Verified Email Address"
        usernameField.delegate = self
        passwordField.delegate = self
    }
    
    func createSendDictionary() ->[String: Any]? {
        var dictionary = [String: Any]()
        if passwordField.text != "" && usernameField.text != "" {
            
            dictionary["UserName"] = usernameField.text
            dictionary["VEmail"] = passwordField.text
            
            return dictionary
            
        }else{return nil}
        
    }
    
    
    @IBAction func resetAction(_ sender: Any) {
        
        
        if usernameField.text != "" && passwordField.text != ""{
            
            if isValidEmail(testStr: passwordField.text!){
                guard let sendDict =  self.createSendDictionary() else {return}
                
                self.activityView.startAnimating();
                
                
                let url = APIUrls().forgotPassword
                
                APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: sendDict) { (result) in
                    DispatchQueue.main.async {
                        self.activityView.stopAnimating();
                        if let code = result["StatusCode"] as? Int{
                            switch code {
                            case 0:
                                
                                SweetAlert().showAlert(kAppName, subTitle: result["StatusMessage"] as? String, style: AlertStyle.error)
                                break
                            case 1:
                                self.showResetPasswordPopUpView()
                                
                            default: break
                            }
                        }
                    }
                }
            }
            else{
                SweetAlert().showAlert(kAppName, subTitle: "Please enter a valid email", style: AlertStyle.error)
                
            }
        }
        else{
            SweetAlert().showAlert(kAppName, subTitle: "All fields are required", style: AlertStyle.error)
        }
    }
    
    func showResetPasswordPopUpView(){
        
        let MainStoyboard = UIStoryboard(name: "Main", bundle: nil)
        let popvc = MainStoyboard.instantiateViewController(withIdentifier: "ResetPasswordVC") as! ResetPasswordVC
        popvc.userEmail = passwordField.text
//        var popUpViewVc : BIZPopupViewController?
//        popUpViewVc = BIZPopupViewController(contentViewController: popvc, contentSize: CGSize(width:300,height: CGFloat(310)))
//        self.present(popUpViewVc!, animated: true, completion: nil)
        
        let popupVC = PopupViewController(contentController: popvc, popupWidth: 300, popupHeight: 300)
        self.present(popupVC, animated: true)
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

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
        {
            passwordField.resignFirstResponder()
            usernameField.resignFirstResponder()
            return true;
        }
}
