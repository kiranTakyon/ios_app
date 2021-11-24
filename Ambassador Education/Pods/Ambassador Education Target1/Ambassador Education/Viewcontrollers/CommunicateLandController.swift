//
//  CommunicateController.swift
//  Ambassador Education
//
//  Created by    Kp on 23/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit

class CommunicateLandController: PagerController,PagerDataSource,TaykonProtocol ,UITextFieldDelegate,PagerDelegate{
   
 
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var searchIcon: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var inBoxVC = CommunicateController()
    var sentBoxVC = CommunicateController()
    var searchText = ""
    var delegates : TaykonProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        self.customizeTab()
        setUi()
        self.getInboxMessages(searchTextValue : "")
        setSlideMenuProporties()
        // Do any additional setup after loading the view.
    }

    func setUi(){
        searchTextField.returnKeyType = .search
        searchTextField.delegate = self
        searchTextField.isHidden = true
        searchTextField.textColor = UIColor.white
        headLabel.isHidden = false
        searchIcon.image = #imageLiteral(resourceName: "Search")
    }
    
    func setSlideMenuProporties(){
        if self.revealViewController() != nil {
            menuButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControlEvents.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    func didChangeTabToIndex(_ pager: PagerController, index: Int) {
        searchTextField.isHidden = true
        searchTextField.text = ""
        headLabel.isHidden = false
        searchIcon.image = #imageLiteral(resourceName: "Search")
    }
    
    func customizeTab() {
        indicatorColor = UIColor.white
        tabsViewBackgroundColor = UIColor.appOrangeColor()
        contentViewBackgroundColor = UIColor.gray.withAlphaComponent(0.32)
        startFromSecondTab = false
        centerCurrentTab = true
        fixFormerTabsPositions = true
        tabLocation = PagerTabLocation.top
        tabHeight = 49
        tabOffset = 36
        tabWidth = self.view.frame.size.width/2
        fixFormerTabsPositions = false
        fixLaterTabsPosition = false
        animation = PagerAnimation.during
        selectedTabTextColor = .white
    }
    
    func setUpPager(list : MessageModel?){
        
        inBoxVC = mainStoryBoard.instantiateViewController(withIdentifier: "communicateVC") as! CommunicateController
        inBoxVC.type = CommunicationType.inbox
        inBoxVC.delegate = self
         sentBoxVC = mainStoryBoard.instantiateViewController(withIdentifier: "communicateVC") as! CommunicateController
        sentBoxVC.type = CommunicationType.sent
        sentBoxVC.delegate = self
        self.setupPager(tabNames: [(list?.inboxLabel.safeValue.uppercased()).safeValue,(list?.sentItemsLabel.safeValue.uppercased()).safeValue], tabControllers: [self.inBoxVC,self.sentBoxVC])
        self.reloadData()

    }
    
    

    func getInboxMessages(searchTextValue : String){
        
        self.startLoadingAnimation()
        var url  = APIUrls().getInBox
            typeValue = 2
        
        
        var dictionary = [String: Any]()
        
        dictionary[UserIdKey().id] = UserDefaultsManager.manager.getUserId()
        dictionary[Communicate().searchText] = searchText
        dictionary[Communicate().paginationNumber] = 0
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            print("inbox messages",result)
            
            DispatchQueue.main.async {

         //  if result["StatusCode"] as? Int == 1{
                if let messageList = result["MessageList"] as? NSArray{
                    
                    let list = MessageModel(values: result)
                    
                        self.removeNoDataLabel()
                        self.headLabel.text = list.communicateLabel.safeValue
                        self.setUpPager(list: list)
                        self.stopLoadingAnimation()
                }else{
                        self.stopLoadingAnimation()
                        self.removeNoDataLabel()
                        SweetAlert().showAlert(kAppName, subTitle: "Some error occured,Please try again later", style: .error)
                }
            }
//            }else{
//                DispatchQueue.main.async {
//                    self.stopLoadingAnimation()
//                    self.removeNoDataLabel()
//                    SweetAlert().showAlert(kAppName, subTitle: "Some error occured,Please try again later", style: .error)
//                }
            }
        }
    
    func deleteTheSelectedAttachment(index: Int) {
        
    }
    func getBackToParentView(value: Any?,titleValue : String?) {
        
        let valueReal = value as? String
        
        if  valueReal != "compose" {
        
            let detailVc = mainStoryBoard.instantiateViewController(withIdentifier: "MessageDetailController") as! MessageDetailController
            detailVc.messageId = valueReal
            detailVc.typeMsg  = typeValue
            detailVc.text = titleValue
            self.navigationController?.pushViewController(detailVc, animated: true)

        
        } else{
        
            let composeViewC = mainStoryBoard.instantiateViewController(withIdentifier: "composeVc") as! ComposeController
            composeViewC.titleText = "Compose New Mail"
            self.navigationController?.pushViewController(composeViewC, animated: true)

        }
           }
    @IBAction func logoutButtonAction(_ sender: UIButton) {
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
    
    @IBAction func serachButtonAction(_ sender: UIButton) {
        if searchIcon.image == #imageLiteral(resourceName: "Search"){
            setBorderAtBottom()
            searchTextField.isHidden = false
            headLabel.isHidden = true
            searchIcon.image = #imageLiteral(resourceName: "Close")
         
        }
        else if searchIcon.image == #imageLiteral(resourceName: "Close"){
            searchTextField.isHidden = true
            searchTextField.text = ""
            headLabel.isHidden = false
            searchIcon.image = #imageLiteral(resourceName: "Search")
            let obj = ["text" : searchTextField.text.safeValue,"type": typeValue] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "searchAction"), object: obj)
          //  self.delegates?.getSearchWithCommunicate(searchTxt : searchTextField.text.safeValue,type: typeValue)
        }
    }
    
    
    func setBorderAtBottom(){
        let border = CALayer()
        let width = CGFloat(2.0)
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: searchTextField.frame.size.height - width, width:  searchTextField.frame.size.width ,  height: searchTextField.frame.size.height)
        
        border.borderWidth = width
        searchTextField.layer.addSublayer(border)
        searchTextField.layer.masksToBounds = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if searchTextField.text != ""{
            searchText = searchTextField.text!
            searchTextField.resignFirstResponder()
            if searchText != ""{
            let obj = ["text" : searchTextField.text.safeValue,"type": typeValue] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "searchAction"), object: obj)
            }
        }
        return true
    }
    
    func downloadPdfButtonAction(url: String) {
        
    }
    

    func getBackToTableView(value: Any?,tagValueInt : Int) {
        
    }
    
    func selectedPickerRow(selctedRow: Int) {
        
    }
    func getUploadedAttachments(isUpload : Bool) {
        
    }
    
    
    func moveToComposeController(titleTxt: String,index : Int,tag: Int) {
        
    }
    
    func getSearchWithCommunicate(searchTxt: String, type: Int) {
        
    }
    
    
    func popUpDismiss() {
        
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
