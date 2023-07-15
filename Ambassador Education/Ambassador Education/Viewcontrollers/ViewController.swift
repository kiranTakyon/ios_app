//
//  ViewController.swift
//  Ambassador Education
//
//     on 04/05/17.
//   . All rights reserved.
//

import UIKit
import BIZPopupView
import SCLAlertView
import EzPopup

let kAlert = "Orison"
let fillFields = "All fields are mandatory"
var showWebUrl : String?
let toHomeSegue = "toHome"


var currentUserName = ""
var currentPassword = ""
var currentLanguage = ""
var UMobile = ""
class ViewController: UIViewController {
    @IBOutlet weak var countryPicker: Picker!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var appLbael: UILabel!
    
    let tick = UIImage(named:"Tick")
    let unTick = UIImage(named:"UnTick")
//    var  popUpViewVc : BIZPopupViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        setCountryPicker()
        setVersion()
        getDashboardWhenAlreadyLogin()
        // Do any additional setup after loading the view, typically from a nib.
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
    }
    func setCountryPicker(){
        
        self.countryPicker.pickerInputItems(["English","عربى"])
        self.countryPicker.pickerTextField.textAlignment = .left
    }
    
    func setVersion(){
       appLbael.text =  Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? ""

        if let text = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String {
            versionLabel.text = "Version no:" + " " + text
        }
       
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
        guard let language = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.language) as? String else {return}
      
        self.usernameField.text = username
        self.passwordField.text = password
        self.countryPicker.pickerTextField.text = language
        
        
        self.tickImage.image = tick
    }
    
    func saveCredentials(){
        
        if tickImage.image == tick{
            let username = usernameField.text
            let password = passwordField.text
            let language = countryPicker.pickerTextField.text
            
            useranameGlobal = username!
            passwordGloal = password!
            languagueGlobal = language!

            
            UserDefaultsManager.manager.insertUserDefaultValue(value: username ?? "", key: DBKeys.username)
            UserDefaultsManager.manager.insertUserDefaultValue(value:password ?? "", key: DBKeys.password)
            UserDefaultsManager.manager.insertUserDefaultValue(value:language ?? "", key: DBKeys.language)
        }
        else{
            UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.username)
            UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.password)
            UserDefaultsManager.manager.removeFromUserDefault(key: DBKeys.language)
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

    func postLogIn(){
        var dictionary = [String: String]()
        
        
        let md5Data = MD5(string:passwordField.text!)
        let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
        let md5Password = md5Hex
        
        dictionary[LogInKeys().username] =  usernameField.text!
        dictionary[LogInKeys().password] = md5Password
        dictionary[LogInKeys().language] = self.getLanguageCodes(textValue:countryPicker.pickerTextField.text! )
        currentLanguage = self.getLanguageCodes(textValue:countryPicker.pickerTextField.text! )
        dictionary[LogInKeys().platform] = "ios"
        dictionary[LogInKeys().Package] = Bundle.main.bundleIdentifier
        
        let url = APIUrls().logIn
        
        print("sent dict",dictionary)
        
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            if let resultDict = result as? NSDictionary{
                
                if resultDict["StatusCode"] as? Int == 1{
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateLast : Date = dateFormatter.date(from: "\(resultDict["last_pswd_updt"]!)") ?? Date()
                    let dateNext : Date = Calendar.current.date(byAdding: .day, value: Int(resultDict["pass_updt_period"]as! String)!, to: dateLast) ?? Date()
                    let datec1 : String = dateFormatter.string(from: Date())
                    let dateToday : Date = dateFormatter.date(from: datec1) ?? Date()
                    
                    let VUser : Int = Int(resultDict["VerifiedUser"] as! String)!
                    let Vemail : String = resultDict["Email"] as! String
                    //(resultDict["Verify"] as! String) ?? resultDict["Email"] as! String
                    let pass_updt_period : Int = Int(resultDict["pass_updt_period"]as! String)!
                   // let pass_updt_period : Int = 1
                    DispatchQueue.main.async {
                        self.saveCredentials()
                        UserDefaultsManager.manager.saveUserId(id:  (resultDict.value(forKey: "UserId") as? String).safeValue)
                        if (dateNext < dateToday && pass_updt_period != 0) {
                           
                            if(VUser==1)
                            {
                                self.popUpVc()
                            }
                            else
                            {
                                self.popVerify(email: Vemail)
                            }
                            return
                        }
                        logInResponseGloabl.removeAllObjects()
                        logInResponseGloabl = NSMutableDictionary(dictionary: resultDict)
                        sibling = false
                        self.stopLoadingAnimation()
                        self.setCurrentCredentials(userName: self.usernameField.text!, password: self.passwordField.text!)
                        self.performSegue(withIdentifier: toHomeSegue, sender: nil)

                    }

                }else{
                    
                    if let errorMessage = resultDict["StatusMessage"] as? String{
                        DispatchQueue.main.async {
                            self.stopLoadingAnimation()
                            let msg = "Please check your credentials"
                            SweetAlert().showAlert(kAppName, subTitle: msg, style: AlertStyle.error)

                        }
                    }
                    else{
                        DispatchQueue.main.async {
                            self.stopLoadingAnimation()
                             if let errorMessage = resultDict["MSG"] as? String{
                                SweetAlert().showAlert(kAppName, subTitle: errorMessage, style: AlertStyle.error)
                            }
                            
                        }
                    }
                }
            }
            
            print("result value is ",result)
            
        }
    }
    func popVerify(email : String)
    {
        let appearance = SCLAlertView.SCLAppearance(
            kTextFieldHeight: 60,
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
      
        let txt = alert.addTextField("Enter your new email id")
        if(email != ""){
            txt.text = email
        }
        _ = alert.addButton("Send OTP") {
            if txt.text != ""{
                txt.resignFirstResponder()
                if isValidEmail(testStr: txt.text.safeValue){
                self.callEmailVerificationApi(email: txt.text.safeValue)
                }
                else{
                    alert.hideView()
                    self.errormsg(email: txt.text.safeValue,msg: "Please enter a valid email",isconfirm: false)
                }
            }
            else{
            alert.hideView()
                self.errormsg(email: txt.text.safeValue, msg: "Please enter a valid email", isconfirm: false)
            }
        }
        _ = alert.showEdit("Verify Email", subTitle:"Your password has expired. Please verify your email and change password to proceed.")
    }
    func errormsg(email : String,msg : String, isconfirm : Bool)
    {
          SweetAlert().showAlert("", subTitle:  msg, style: .warning,buttonTitle:"OK"){(isOtherButton) -> Void in
              if isOtherButton == true {
                  print(isconfirm)
                  if(isconfirm == true)
                  {
                      self.popUpVcToEmailVerification(email: email)
                  }
                  else{
                      self.popVerify(email: email)
                  }
              }
          }
    }
    func callEmailVerificationApi(email: String){
        self.startLoadingAnimation()
        let url = APIUrls().emailVerificationCode
        var dictionary = [String: String]()
        
        dictionary[EmailVerifications().getEmailVCode] = email
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            DispatchQueue.main.async {
                self.stopLoadingAnimation()
                if result["StatusCode"] as? Int == 1{
                    self.popUpVcToEmailVerification(email: email)
                }
                else{
                    if let mesaage = result["StatusMessage"] as? String{
                        SweetAlert().showAlert(kAppName, subTitle:  mesaage, style: AlertStyle.error)
                    }
                }
                
            }
        }
        
    }
    func popUpVcToEmailVerification(email: String){
        
        let appearance = SCLAlertView.SCLAppearance(
            kTextFieldHeight: 60,
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("Enter OTP")
        _ = alert.addButton("Verify OTP") {
            if txt.text != ""{
                txt.resignFirstResponder()
                self.setEmailVerification(key: txt.text.safeValue, email: email)
            }
            else{
                alert.hideView()
                self.errormsg(email: email, msg: "Please enter a valid OTP", isconfirm: true)
            }
        }
        _ = alert.showEdit("Verify Email", subTitle:"Thank you for verifying your email id.A message with a verification code was sent to \(email).To complete the verification process,enter the verification code below.")
    }
    func setEmailVerification(key : String, email : String){
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
                                   // self.delegate?.popUpDismiss()
                                    self.popUpVc()

                                }
                            })
                       }
                    }
                    else{
                        if let mesaage = result["StatusMessage"] as? String{
                            
                            
                            //SweetAlert().showAlert(kAppName, subTitle: mesaage, style: .error, buttonTitle: alertOk, action: { (index) in
                                //if index{
                                    self.dismiss(animated: true, completion: nil)
                                    self.errormsg(email: email, msg: mesaage, isconfirm: true)
                                   // self.popVerify(email: email)
                                    
                                //}
                           // })

                            
                        }
                        
                    }
                    
                }
            }
            
        }

    func popUpVc(){
        DispatchQueue.main.async {
            let heightVal = 375
            let popvc = mainStoryBoard.instantiateViewController(withIdentifier: "changePasswordVc") as! ChangePasswordController
            popvc.delegate = self
            popvc.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width - 50, height: CGFloat(heightVal))
            self.accessibilityHint = "ForceFully"
            self.popUpEffectType = .flipDown
            self.presentPopUpViewController(popvc)
        }
    }
    @IBAction func forgotButtonAction(_ sender: Any) {
        showPopUpView()
    }
    
    func showPopUpView(){
        
        let MainStoyboard = UIStoryboard(name: "Main", bundle: nil)
        let popvc = MainStoyboard.instantiateViewController(withIdentifier: "forgottPasswordVc") as! ForgotPasswordController
//         var popUpViewVc : BIZPopupViewController?
//        popUpViewVc = BIZPopupViewController(contentViewController: popvc, contentSize: CGSize(width:300,height: CGFloat(310)))
//        self.present(popUpViewVc!, animated: true, completion: nil)
        
        let popupVC = PopupViewController(contentController: popvc, popupWidth: 300, popupHeight: 300)
        self.present(popupVC, animated: true)

    }

    
    func setCurrentCredentials(userName:String,password:String){
        let details = logInResponseGloabl;
        if let userId = details["UserId"] as? String{
        UserDefaultsManager.manager.saveUserId(id: userId)
        }
        currentUserName = userName
        currentPassword = password
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController : TaykonProtocol {
    
    func deleteTheSelectedAttachment(index: Int) {
        
    }
    
    func downloadPdfButtonAction(url: String, fileName: String?) {
        
    }
    
    func getBackToParentView(value: Any?, titleValue: String?, isForDraft: Bool) {
        
    }
    
    func getBackToTableView(value: Any?, tagValueInt: Int) {
        
    }
    
    func selectedPickerRow(selctedRow: Int) {
        
    }
    
    func popUpDismiss() {
       // popUpViewVc?.dismiss(animated: true, completion: nil)

    }
    
    func moveToComposeController(titleTxt: String, index: Int, tag: Int) {
        
    }
    
    func getSearchWithCommunicate(searchTxt: String, type: Int) {
        
    }
    
    func getUploadedAttachments(isUpload: Bool, isForDraft: Bool) {
        
    }
    
    
}
