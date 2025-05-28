//
//  RegisterPopUpVc.swift
//  Ambassador Education
//
//     on 05/05/17.
//   . All rights reserved.
//

import UIKit

class RegisterPopUpVc: UIViewController {
    
    @IBOutlet weak var countryPicker: Picker!
    @IBOutlet weak var usernameField: SkyFloatingLabelTextFieldWithIcon!
    
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextFieldWithIcon!
    
    let tick = UIImage(named:"Tick")
    let unTick = UIImage(named:"UnTick")

    
    override func viewDidLoad() {
         self.countryPicker.pickerInputItems(["English","عربى"])
    }
    
    @IBAction func remembermeButtonAction(_ sender: AnyObject) {
        
        if tickImage.image == tick{
            
            self.tickImage.image = unTick
            
        }else{
             self.tickImage.image = tick
        }
    }
    
    @IBAction func forgotAction(_ sender: AnyObject) {
        
        
    }
    
    @IBAction func logInAction(_ sender: AnyObject) {
    }
}
