//
//  ForgotPasswordController.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 25/09/17.
//  Copyright © 2017 InApp. All rights reserved.
//

import UIKit
import DGActivityIndicatorView

class ForgotPasswordController: UIViewController {

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
                        break
                    case 1:
                        self.dismiss(animated: true, completion: {
                            print("ddsmissed")
                        })
                    default: break
                    }
                    SweetAlert().showAlert(kAppName, subTitle: result["StatusMessage"] as? String, style: AlertStyle.error)
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
