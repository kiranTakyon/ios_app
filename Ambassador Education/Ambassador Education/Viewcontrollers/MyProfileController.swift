//
//  MyProfileController.swift
//  Ambassador Education
//
//  Created by    Kp on 23/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit
import BIZPopupView
import SCLAlertView
import EzPopup

class MyProfileController: UIViewController,UITableViewDataSource, UITableViewDelegate,UIPopoverPresentationControllerDelegate,TaykonProtocol {
    func getBackToTableViewS(value: Any?, tagValueInt: Int) {
        
    }
    
  

    @IBOutlet weak var changePasswordLabel: UIButton!
    @IBOutlet weak var setMyLocationButton: UIButton!
    @IBOutlet weak var verifyEmailButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var verifyEmailButton: UIButton!
    @IBOutlet weak var verifyEmailButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImageView: ImageLoader!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    var profileImageUrl : String?
    var icons = ["User","User","User","Email","Mobile","LocationGray","Email"]

    var placeHolders:[String] = ["","","","","","",""]
    var titles = ["","","","","","",""]
    @IBOutlet weak var menuButton: UIButton!
    
    var isFromCamera = false
    var profileInfo : TMyProfile?
//    var  popUpViewVc : BIZPopupViewController?
    var isEditClicked : Bool?
    
    @IBOutlet weak var profileTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        setSlideMenuProporties()
        isEditClicked = false
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        profileTable.separatorStyle = .none
        if !isFromCamera{
        getMyProfile()
        }
        isFromCamera = false
    }
    
   
    
    func deleteTheSelectedAttachment(index: Int) {
        
    }
    func setUIUserInteractionDisabledAndAble(cell :ProfileCell,color: UIColor,interactionStatus: Bool){
        if (cell.icon.image == #imageLiteral(resourceName: "User") && cell.titleTextField.placeholder == "User Name") ||   (cell.icon.image ==  #imageLiteral(resourceName: "Email") && cell.titleTextField.placeholder == "Verified Email") || (cell.icon.image == #imageLiteral(resourceName: "User") && cell.titleTextField.placeholder == "Parent Code")  {
            cell.titleTextField.isUserInteractionEnabled = false
            cell.titleTextField.textColor =  UIColor.lightGray
        }
  
        else{
        cell.titleTextField.textColor =  color
        cell.titleTextField.isUserInteractionEnabled = interactionStatus
        }
    }
    
    func setSlideMenuProporties() {
        if let revealVC = revealViewController() {
            topHeaderView.setMenuOnLeftButton(reveal: revealVC)
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    
    func getProfileDetails(){
        
        let details = profileInfoGlobal;//UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.profileInfo) as? NSDictionary else {return}
        
        let profile = ModelClassManager.sharedManager.createModelArray(data: [details], modelType: ModelType.TNMyProfile) as! [TMyProfile]
        
        profileInfo = profile[0]
        
        setUpAllData()
        self.stopLoadingAnimation()
        
    }
    
    func setUpAllData(){
        
        if let url = profileInfo?.profileImage{
            self.profileImageView.loadImageWithUrl(url)
            profileImageUrl = url
        }
        
        
        var name = ""
        var mailVal = ""
        var mobileVal = ""
        var locationVal = ""
        var usrName = ""
        var verifiedEmail = ""
        var userType=""
        var parentCode = ""
        if let nameValue = profileInfo?.name{
            name = nameValue
        }
        
        if let mailValue = profileInfo?.emailID{
            mailVal = mailValue
        }
        
        verifiedEmail = getTheVerifiedEmail()
        
        if let contactValue = profileInfo?.contactNumber{
            mobileVal = contactValue
        }
        
        if let userName = profileInfo?.userName{
          usrName  = userName
        }
        
        if let address = profileInfo?.contact{
             locationVal = address
        }
      //  print(profileInfo?.parentCode ?? "NA")
        if let PCode = profileInfo?.parentCode{
            parentCode = PCode
        }
        let namae = name
        let mail = mailVal
        let verifyMail = verifiedEmail
        let mobile = mobileVal
        let location = locationVal
        let userN = usrName
        let parentCde = parentCode
        
        //var icons = ["User","User","User","Email","Mobile","LocationGray","Email"]

        //var placeHolders:[String] = ["","","","","","",""]
        //var titles = ["","","","","","",""]
        
        userType = getUserType().lowercased()
                
        if(userType=="parent" || userType == "student" || profileInfo?.EnableChangePassword == 1)
        {
            changePasswordLabel.isHidden=false
            titles = [parentCde,namae,userN,mail,mobile,location,verifyMail]
        }
        else
        {
            changePasswordLabel.isHidden=true
            titles = [namae,userN,mail,mobile,location,verifyMail]
        }
       // titles = [parentCde,namae,userN,mail,mobile,location,verifyMail]

        self.profileTable.reloadData()
    }
    
    func setVerifyEmailButtonVisibility(isHide :Bool,constraint: CGFloat,constriantTop: CGFloat){
        verifyEmailButton.isHidden = isHide
        verifyEmailButtonHeight.constant = constraint
        verifyEmailButtonTopConstraint.constant = constriantTop
    }
    
    func filterTheCoreespondingSibling(idValue: String) -> String{
        if let siblings = logInResponseGloabl.value(forKey: "Siblings") as? NSArray{
            if siblings.count > 0{
                for each in siblings{
                    let eachDict = each as? NSDictionary
                    if let userName = eachDict?.value(forKey: "login_username") as? String{
                        if userName == idValue {
                            return userName
                        }
                    }
                }
            }
        }
        return ""
    }
    
    func getMyProfile(){
        self.startLoadingAnimation()
        let url = APIUrls().getProfile
        
        var dictionary = [String: String]()
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        dictionary[UserIdKey().id] = userId
        
        
       // print("params:"+String(dictionary))
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {

            if result["StatusCode"] as? Int == 1{
                profileInfoGlobal.removeAllObjects()
                profileInfoGlobal = NSMutableDictionary(dictionary : result)
                self.topHeaderView.title = result["ProfileLabel"] as? String ?? ""
                    self.verifyEmailButton.setTitle((result["VerifiedEmailLabel"] as? String)?.uppercased(), for: .normal)
                    self.setMyLocationButton.setTitle((result["SetMyLocationLabel"] as? String)?.uppercased(), for: .normal)
                    self.changePasswordLabel.setTitle((result["ChangePasswordLabel"] as? String)?.uppercased(), for: .normal)
                
                guard let NameLabel = result["NameLabel"] as? String else {return}
                guard let UserNameLabel = result["UserNameLabel"] as? String else {return}
                guard let EmailIDLabel = result["EmailIDLabel"] as? String else {return}
                guard let ContactNumberLabel = result["ContactNumberLabel"] as? String else {return}
                guard let ContactLabel = result["ContactLabel"] as? String else {return}
                guard let VerifiedEmailLabel = result["VerifiedEmailLabel"] as? String else {return}
                guard let ParentCodeLabel = result["ParentCodeLabel"] as? String else {return}
                
                let userType = self.getUserType().lowercased()
                
                if(userType=="parent" || userType == "student")
                {
                self.placeHolders = [ParentCodeLabel,NameLabel,UserNameLabel,EmailIDLabel,ContactNumberLabel,ContactLabel,VerifiedEmailLabel]
                }
                else
                {
                    self.icons = ["User","User","Email","Mobile","LocationGray","Email"]
                    self.placeHolders = [NameLabel,UserNameLabel,EmailIDLabel,ContactNumberLabel,ContactLabel,VerifiedEmailLabel]
                }
                    self.getProfileDetails()
                }
            else{
                self.stopLoadingAnimation()

                    }
                }
                }
                
            }
    
    func downloadPdfButtonAction(url: String, fileName: String?) {
        
    }
    
    func getUploadedAttachments(isUpload : Bool, isForDraft: Bool) {
        
    }
    
    func getBackToParentView(value: Any?, titleValue: String?, isForDraft: Bool) {
        
    }
    
    func moveToComposeController(titleTxt: String,index : Int,tag: Int) {
        
    }
    
    
    func getBackToTableView(value: Any?,tagValueInt : Int) {
        
    }
    
    func selectedPickerRow(selctedRow: Int) {
        
    }
    func getSearchWithCommunicate(searchTxt: String, type: Int) {
        
    }
    
   
    
    
    //MARK:- TableView Delegates and Datasources
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat{
        
        return 60;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell
        let iconVal = icons[indexPath.row]
        cell.icon.image = UIImage(named:iconVal)
        cell.titleTextField.placeholder = placeHolders[indexPath.row]
        self.tableHeight.constant = profileTable.contentSize.height
        if !isEditClicked!{
            setUIUserInteractionDisabledAndAble(cell: cell, color: UIColor.lightGray, interactionStatus: false)
             cell.titleTextField.text = titles[indexPath.row]
        }
        else{
            setUIUserInteractionDisabledAndAble(cell: cell, color: UIColor.black, interactionStatus: true)
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func getTheVerifiedEmail() -> String{
        if let globalDict = logInResponseGloabl as? NSDictionary{
                    if let email = globalDict["Verify"] as? String{
                        return email
                }
        }
        return ""
    }
    
    func returnVerifiedUserCode() -> String{
            if let globalDict = logInResponseGloabl as? NSDictionary{
                if let userType = globalDict["VerifiedUser"] as? String{
                    return userType
                }
        }
                return ""
    }
        
    func returnTheStatusOfEmailVerification() {
        let type = returnVerifiedUserCode()
                switch type{
                case "0":
                    SweetAlert().showAlert("", subTitle: "Your email is not verified", style: .warning)
                case "1":
                   popUpVc()
                case "2":
                    SweetAlert().showAlert("", subTitle: "Your email verification is pending", style: .warning)
                default:
                    break
                }
    }
    func getUserType() -> String{
        if let globalDict = logInResponseGloabl as? NSDictionary{
                    if let usertype = globalDict["UserType"] as? String{
                        return usertype
                }
        }
        return ""
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    @IBAction func setMyLocationAction(_ sender: Any) {
        let mapVc = mainStoryBoard.instantiateViewController(withIdentifier: "mapVc") as! MapController
        
        mapVc.latitude = Double(seperateOptionalTextFromString(text: profileInfo!.latitude!))
        mapVc.longitude = Double(seperateOptionalTextFromString(text: profileInfo!.longitude!))
        self.navigationController?.pushViewController(mapVc, animated: true)
    }
    
    func seperateOptionalTextFromString(text : String) ->String{
        var newString = ""
        if text != ""{
            for each in text{
                if let intValue = Int(each.description){
                    newString.append("\(intValue)")
                }
                else{
                    if each.description == "-" || each.description == "+" || each.description == "."{
                        newString.append(each)
                    }
                }
                }
               
            }
        print(newString)
        return newString
    }
    
    @IBAction func changePasswordAction(_ sender: Any) {
        returnTheStatusOfEmailVerification()
//        if let isEmailVerified = profileInfo?.isEmailVerified{
//                self.popUpVc()
//        }
    }
    
    func popUpVc(){
       
        let heightVal = 400
        let popvc = mainStoryBoard.instantiateViewController(withIdentifier: "changePasswordVc") as! ChangePasswordController
        popvc.delegate = self
//        popUpViewVc = BIZPopupViewController(contentViewController: popvc, contentSize: CGSize(width: self.view.frame.size.width - 40,height: CGFloat(heightVal)))
//        self.present(popUpViewVc!, animated: true, completion: nil)
        let popupVC = PopupViewController(contentController: popvc, popupWidth: 300, popupHeight: 300)
        self.present(popupVC, animated: true)
    }
    
    
    func popUpVcToEmailVerification(email: String){
        
        let heightVal = 400
        let popvc = mainStoryBoard.instantiateViewController(withIdentifier: "VerificationEmailView") as! VerificationEmailViewController
        popvc.delegate = self
        if let emailValue = email as? String{
            popvc.email = emailValue
//            popUpViewVc = BIZPopupViewController(contentViewController: popvc, contentSize: CGSize(width: self.view.frame.size.width - 40,height: CGFloat(heightVal)))
//            self.present(popUpViewVc!, animated: true, completion: nil)
            
            let popupVC = PopupViewController(contentController: popvc, popupWidth: 300, popupHeight: 300)
            self.present(popupVC, animated: true)
        }
    }
    
    func saveProfile(){
            self.startLoadingAnimation()
            let url = APIUrls().saveProfile
            
        
            APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: getValuesFromAllVisibleCellsOfTableView()) { (result) in
                
                if result["StatusCode"] as? Int == 1{
                    
                    DispatchQueue.main.async {
                        self.isEditClicked = false
                        self.stopLoadingAnimation()
                        SweetAlert().showAlert(kAppName, subTitle:  "Profile updated successfully", style: AlertStyle.success)
                        self.getMyProfile()
                       // self.profileTable.reloadData()
                    }
                    
                }
            }
    }
    
    func getUdidOfDevide() -> String{
        return  UIDevice.current.identifierForVendor!.uuidString
    }
    
    func getValuesFromAllVisibleCellsOfTableView() -> [String: Any]{
        let userId = UserDefaultsManager.manager.getUserId()
        var dictionary = [String : Any]()
        dictionary["client_ip"] =  getUdidOfDevide()

        dictionary[UserIdKey().id] = userId
        if let imageUser = profileImageView.image{
            let profileDict = NSMutableDictionary()
            profileDict.setValue(convertTheImageToBase64(image: imageUser), forKey: UserIdKey().profileName)
            profileDict.setValue("", forKey: UserIdKey().profileMime)
            profileDict.setValue("", forKey: UserIdKey().profilePostName)
            
            dictionary[UserIdKey().profileImage] = profileDict
        }

        if let visibleCells = profileTable.visibleCells as? [ProfileCell]{
            if visibleCells.count != 0{
                for each in visibleCells{
                    if let image = each.icon.image{
                        
                        switch image {
                        case #imageLiteral(resourceName: "User"):
                            if each.titleTextField.placeholder == "Name"{
                            dictionary[UserIdKey().name] = each.titleTextField.text
                            }

                        case #imageLiteral(resourceName: "Email"):
                            dictionary[UserIdKey().email] = each.titleTextField.text
                            
                        case #imageLiteral(resourceName: "Mobile"):
                            dictionary[UserIdKey().contactNumber] = each.titleTextField.text

                        case #imageLiteral(resourceName: "LocationGray"):
                            dictionary[UserIdKey().contact] = each.titleTextField.text

                        
                        default:
                            break
                        }
                    }
                
                }
            }
        }
        print(dictionary)
        return dictionary
    }
    
    func convertTheImageToBase64(image: UIImage) -> String{
        let convertImage : UIImage = image
        if let base64String = convertImage.base64(format: .jpeg(0.5)){
            return base64String
        }
        else{
            return ""
        }
        
    }
    //MARK:- Taykon protocol
    
    
    func popUpDismiss() {
       // popUpViewVc?.dismiss(animated: true, completion: nil)
    }
    
    func getAllVisibleCellsFromTableView() -> (Bool,String){
        
        if let visibleCells = profileTable.visibleCells as? [ProfileCell]{
            if visibleCells.count != 0{
                for each in visibleCells{
                    if let text = each.titleTextField.text{
                        if text.contains(".com"){
                            
                            return (true,text)
                        }
                    }
                    else{
                        return (false,"")
                    }
                }
            }
            
        }
        return (false,"")
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
    
    

    func verifyEmailAction(msg : String){
        if getAllVisibleCellsFromTableView().0{
            if getAllVisibleCellsFromTableView().1 != ""{
                showAlertController(kAppName, message: "You want to verify this email - \(getAllVisibleCellsFromTableView().1)", cancelButton: alertNo, otherButtons: [alertYes]){ (index) in
                    if index == 1{
                        self.callEmailVerificationApi(email: self.getAllVisibleCellsFromTableView().1)
                    }
                }
                
            }
        }
        else{
            showAlertController(kAppName, message: "Please enter an email", cancelButton: alertOk, otherButtons: [], handler: nil)
            
        }

    }
    
    func checkValidation() -> Bool{
    if let visibleCells = profileTable.visibleCells as? [ProfileCell] {
        if visibleCells.count != 0{
            for each in visibleCells{
                print(each.titleTextField.text)
                if each.titleTextField.placeholder == "Name"{
                    if each.titleTextField.text == "" && each.titleTextField.text?.count == 0{
                    return false
                }
            
            }
        }
    }
        }
        return true
    }
    
    @IBAction func verifyEmailButtonAction(_ sender: UIButton) {
        let appearance = SCLAlertView.SCLAppearance(
            kTextFieldHeight: 60,
            showCloseButton: false
        )
        let alert = SCLAlertView(appearance: appearance)
        let txt = alert.addTextField("Enter your new email id")
        _ = alert.addButton("Yes") {
            if txt.text != ""{
                txt.resignFirstResponder()
                if isValidEmail(testStr: txt.text.safeValue){
                self.callEmailVerificationApi(email: txt.text.safeValue)
                }
                else{
                  alert.hideView()
                    SweetAlert().showAlert("", subTitle: "Please enter a valid email" , style: .warning)
                }
            }
            else{
            alert.hideView()
            SweetAlert().showAlert("", subTitle: "Please enter a valid email" , style: .warning)
            }
        }
        alert.addButton("No") {
            if self.getAllVisibleCellsFromTableView().0{
                  self.callEmailVerificationApi(email: self.getAllVisibleCellsFromTableView().1)
            }
        }
        _ = alert.showEdit("Verify Email", subTitle:"Do you want to change your \(getAllVisibleCellsFromTableView().1) ?")
    
    }
    
    
    
//    @IBAction func profileSaveAction(_ sender: UIButton) {
//        if saveImageView.image == #imageLiteral(resourceName: "Edit"){
//            saveImageView.image = #imageLiteral(resourceName: "Save")
//            isEditClicked = true
//            profileTable.reloadData()
//        }
//        else if saveImageView.image == #imageLiteral(resourceName: "Save"){
//            profileTable.reloadData()
//            isEditClicked = true
//            callProfileEdit()
//        }
//    }
    
    func callProfileEdit(){
        if checkValidation(){
            saveProfile()
        }
        else{
            showAlertController(kAppName, message: "Name is required", cancelButton: alertOk, otherButtons: [], handler: nil)
        }
    }
    
    func navigateToGallery(url:String,title:String,indexPath: Int){
        let galleryDetail = mainStoryBoard.instantiateViewController(withIdentifier: "ImagePreviewController") as! ImagePreviewController
        galleryDetail.imageUrl = url
        galleryDetail.pageTitle  = ""
        galleryDetail.titleValue = title
        //galleryDetail.imageArr = [url]
        let imageInfo = ["imageUrl": url, "imageTitle": title]
        let imageArray = [imageInfo]
        galleryDetail.imageArr = imageArray
        galleryDetail.position = indexPath
        self.navigationController?.pushViewController(galleryDetail, animated: true)
        }
    

    @IBAction func showMyProfileImageLarger(_ sender: UIButton) {
        if !isEditClicked!{
            if let image = profileImageUrl as? String{
                if let nameValue = profileInfo?.name{
                    navigateToGallery(url: image, title: nameValue, indexPath: 0)
                    
                }
            }
        }
        else{
            showAlertOnProfileImageEdit()
        }
}
    func showAlertOnProfileImageEdit(){
        SweetAlert().showAlert("", subTitle: "Choose...", style: AlertStyle.warning, buttonTitle:"Photos", buttonColor:UIColor.lightGray , otherButtonTitle:  "Camera", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
        if isOtherButton == true {
            self.openGallery()
        }
        else {
            self.openCamera()
        }
        }
    }
        
        func openCamera(){
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                setImagePickerWrtType(allowEditing : false,sourceType: .camera)
            }
        }
    
    func openGallery(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            self.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    //MARK:- setImagePickerWrtType
    func setImagePickerWrtType(allowEditing : Bool,sourceType : UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = allowEditing
        self.present(imagePicker, animated: true, completion: nil)
    }
    
}

extension MyProfileController : UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            profileImageView.image = image
        }else{
            print("Something went wrong")
        }
        isFromCamera = true
       dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        isFromCamera = true
       self.dismiss(animated: true, completion: nil)
    }
}

class ProfileCell : UITableViewCell{
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleTextField: SkyFloatingLabelTextField!
    
 
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}


extension MyProfileController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            }
            else {
                isFirstTime = true
                gradeBookLink = ""
                showLoginPage()
            }
        }
    }
    
    func searchButtonClicked(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            isEditClicked = true
            profileTable.reloadData()
            button.setImage(#imageLiteral(resourceName: "Save"), for: .normal)
        } else {
            profileTable.reloadData()
            isEditClicked = true
            button.setImage(#imageLiteral(resourceName: "Edit"), for: .normal)
            callProfileEdit()
        }
    }
}
