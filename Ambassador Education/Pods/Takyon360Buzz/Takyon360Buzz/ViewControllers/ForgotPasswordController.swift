//
//  ForgotPasswordController.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 25/09/17.
//  Copyright © 2017 InApp. All rights reserved.
//

import UIKit
import DGActivityIndicatorView
import SkyFloatingLabelTextField

class ForgotPasswordController: UIViewController {

    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    @IBOutlet weak var usernameField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityView.stopAnimating()
        // Do any additional setup after loading the view.
    }
    
    
    func createSendDictionary() ->[String: Any]? {
        
        var dictionary = [String: Any]()
        
        if passwordField.text != "" && usernameField.text != "" {
            
        
            dictionary["UserName"] = passwordField.text
            dictionary["VEmail"] = usernameField.text

            return dictionary
        
        }else{return nil}
        
        
    }
    
    
    @IBAction func resetAction(_ sender: Any) {
        
        if usernameField.text != "" && passwordField.text != ""{
        guard let sendDict =  self.createSendDictionary() else {return}
        
        self.activityView.startAnimating();
        
        
        let url = APIUrls().forgotPassword
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: sendDict) { (result) in
            DispatchQueue.main.async {
                self.activityView.stopAnimating();
                self.dismiss(animated: true, completion: { 
                    print("ddsmissed")
                })
            }
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
