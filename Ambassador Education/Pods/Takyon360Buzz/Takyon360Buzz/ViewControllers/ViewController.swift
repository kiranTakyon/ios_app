//
//  ViewController.swift
//  Ambassador Education
//
//     on 04/05/17.
//   . All rights reserved.
//

import UIKit
import BIZPopupView

let kAlert = "Orison"
let fillFields = "All fields are mandatory"
var showWebUrl : String?
let toHomeSegue = "tohomevc"


class ViewController: UIViewController {
    @IBOutlet weak var countryPicker: Picker!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    
    let tick = UIImage(named:"Tick")
    let unTick = UIImage(named:"UnTick")
    override func viewDidLoad() {
        super.viewDidLoad()
        setCountryPicker()
        setVersion()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getDashboardWhenAlreadyLogin()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(self.getDashboardWhenAlreadyLogin), name: NSNotification.Name(rawValue: "CallPostLoaginApi"), object: nil)
    }
    
    func setCountryPicker(){
        self.countryPicker.pickerInputItems(["English","عربى"])
        self.countryPicker.pickerTextField.textAlignment = .left
    }
    
    func setVersion(){
        
//        if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String {
//            versionLabel.text = "Version no:" + " " + text
//        }
        
    }
    
    @IBAction func LogInAction(_ sender: AnyObject) {
        
        if !isEmptyField(){
            self.startLoadingAnimation()
            postLogIn()
        }else{
            SweetAlert().showAlert(kAppName, subTitle: fillFields, style: AlertStyle.error)
            
        }
        
    }
    
    func showSavedCredentials(){
        
        guard let username = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.username) as? String else {return}
        guard let password = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.password) as? String else {return}
        
        self.usernameField.text = username
        self.passwordField.text = password
        
        
        self.tickImage.image = tick
    }
    
    func saveCredentials(){
        
        if tickImage.image == tick{
            let username = usernameField.text
            let password = passwordField.text
            
            
            useranameGlobal = username!
            passwordGloal = password!
            
            
            UserDefaultsManager.manager.insertUserDefaultValue(value: username ?? "", key: DBKeys.username)
            UserDefaultsManager.manager.insertUserDefaultValue(value:password ?? "", key: DBKeys.password)
            
            
            
            
        }
        
    }
    
    func isEmptyField() -> Bool{
        
        if passwordField.text != "" && usernameField.text != "" && countryPicker.pickerTextField.text != ""{
            return false
        }else{
            return true
        }
        
    }
    
    
    
    
    @IBAction func remembermeButtonAction(_ sender: AnyObject) {
        
        if tickImage.image == tick{
            
            self.tickImage.image = unTick
            
        }else{
            self.tickImage.image = tick
        }
    }
    
    
    func getLanguageCodes(textValue:String) -> String{
        
        if textValue == "English"{
            
            return "1"
        }else{
            return "2"
        }
    }
    
    func getDashboardWhenAlreadyLogin(){
        if let user = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.username) as? String{
            if let pass = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.password) as? String{
                if user != "" && pass != ""{
                    self.startLoadingAnimation()
                    self.showSavedCredentials()
                    self.postLogIn()
                }
            }
        }
        else{
            self.usernameField.placeholder = "User Name"
            self.passwordField.placeholder = "Password"

            self.usernameField.text = ""
            self.passwordField.text = ""
            SweetAlert().showAlert(kAppName, subTitle: "Please login with the credentials or redirect to the Orizon application to login this application", style: AlertStyle.error)
        }
    }
    
    func postLogIn(){
        var dictionary = [String: String]()
        
        
        let md5Data = passwordField.text?.md5()
        
      //  let md5Hex =  md5Data.map {String (format: "%02hhx",$0)}?.byWords.joined()//md5Data.map { String(format: "%02hhx", $0) }!.joined()
     //   let md5Password = md5Hex
//
        dictionary[LogInKeys().username] =  usernameField.text!
        dictionary[LogInKeys().password] = md5Data
        dictionary[LogInKeys().language] = self.getLanguageCodes(textValue:countryPicker.pickerTextField.text! )
        dictionary[LogInKeys().platform] = "ios"
        
        
        let url = APIUrls().logIn
        
        print("sent dict",dictionary)
        
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result,data) in
            DispatchQueue.main.async {

            if let resultDict = result as? NSDictionary{

                if resultDict["StatusCode"] as? Int == 1{
                    
                    // UserDefaultsManager.manager.insertUserDefaultValue(value: resultDict, key: DBKeys.logInDetails)
                    self.saveCredentials()

                    logInResponseGloabl = resultDict
                        self.stopLoadingAnimation()
                        self.setCurrentCredentials(userName: self.usernameField.text!, password: self.passwordField.text!)
                        self.performSegue(withIdentifier: toHomeSegue, sender: nil)
                        
                    
                }else{
                    
                    if let errorMessage = resultDict["StatusMessage"] as? String{
                            self.stopLoadingAnimation()
                            SweetAlert().showAlert(kAppName, subTitle: errorMessage, style: AlertStyle.error)
                    }
                    else{
                            self.stopLoadingAnimation()
                            if let errorMessage = resultDict["MSG"] as? String{
                                SweetAlert().showAlert(kAppName, subTitle: errorMessage, style: AlertStyle.error)
                            }
                    }
                }
            }
            
            print("result value is ",result)
            
        }
        
        }
        
        
    }
 
    
    @IBAction func forgotButtonAction(_ sender: Any) {
       // showPopUpView()
    }
    
    func showPopUpView(){
        
        let MainStoyboard = UIStoryboard(name: "Main", bundle: nil)
        let popvc = MainStoyboard.instantiateViewController(withIdentifier: "forgottPasswordVc") as! ForgotPasswordController
        var popUpViewVc : BIZPopupViewController?
        popUpViewVc = BIZPopupViewController(contentViewController: popvc, contentSize: CGSize(width:300,height: CGFloat(310)))
        self.present(popUpViewVc!, animated: true, completion: nil)
        
    }
    
    
    func setCurrentCredentials(userName:String,password:String){
        
        currentPassword = userName
        currentPassword = password
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

