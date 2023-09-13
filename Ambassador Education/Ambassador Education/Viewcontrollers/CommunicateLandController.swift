//
//  CommunicateController.swift
//  Ambassador Education
//
//  Created by    Kp on 23/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit

class CommunicateLandController: PagerController,PagerDataSource,TaykonProtocol ,UITextFieldDelegate,PagerDelegate{
    
    
  
    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    var inBoxVC = CommunicateController()
    var sentBoxVC = CommunicateController()
    var WPBoxVC = CommunicateController()
    var draftVC = CommunicateController()
    var searchText = ""
    var delegates : TaykonProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        topHeaderView.setMenuOnLeftButton()
        topHeaderView.searchTextField.delegate = self
        self.dataSource = self
        self.delegate = self
        self.customizeTab()
        self.getInboxMessages(searchTextValue : "")
        setSlideMenuProporties()
        self.topHeaderView.delegate = self
        // Do any additional setup after loading the view.
    }
    
    
    func setSlideMenuProporties(){
        if self.revealViewController() != nil {
            topHeaderView.backButton.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: UIControl.Event.touchUpInside)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }
    
    func didChangeTabToIndex(_ pager: PagerController, index: Int) {
        topHeaderView.titleLabel.isHidden = false
        topHeaderView.searchTextField.isHidden = true
        topHeaderView.setFirstRightButtonImage = #imageLiteral(resourceName: "Search")
        topHeaderView.searchTextField.text = ""
        topHeaderView.shouldShowSecondRightButton(true)
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
        tabTopOffset = topHeaderView.height - topBarHeight()
        tabWidth = self.view.frame.size.width/2
        fixFormerTabsPositions = false
        fixLaterTabsPosition = false
        animation = PagerAnimation.during
        selectedTabTextColor = .white
    }
    
    func setUpPager(list : MessageModel?) {
        
        inBoxVC = mainStoryBoard.instantiateViewController(withIdentifier: "communicateVC") as! CommunicateController
        inBoxVC.type = CommunicationType.inbox
        inBoxVC.delegate = self
        sentBoxVC = mainStoryBoard.instantiateViewController(withIdentifier: "communicateVC") as! CommunicateController
        sentBoxVC.type = CommunicationType.sent
        sentBoxVC.delegate = self
        
        WPBoxVC = mainStoryBoard.instantiateViewController(withIdentifier: "communicateVC") as! CommunicateController
        WPBoxVC.type = CommunicationType.WP
        WPBoxVC.delegate = self
        
        draftVC = mainStoryBoard.instantiateViewController(withIdentifier: "communicateVC") as! CommunicateController
        draftVC.type = CommunicationType.draft
        draftVC.delegate = self
        
        self.setupPager(tabNames: [(list?.inboxLabel.safeValue.uppercased()).safeValue,(list?.sentItemsLabel.safeValue.uppercased()).safeValue,(list?.WPItemsLabel.safeValue.uppercased()).safeValue,(list?.DraftItemsLabel.safeValue.uppercased()).safeValue], tabControllers: [self.inBoxVC,self.sentBoxVC,self.WPBoxVC, self.draftVC])
        self.reloadData()
        
    }
    
    
    
    func getInboxMessages(searchTextValue : String) {
        
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
                    self.topHeaderView.title = list.communicateLabel.safeValue
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
    
    func getBackToParentView(value: Any?,titleValue : String?, isForDraft: Bool,message: TinboxMessage) {
        
        let valueReal = value as? String
        
        if isForDraft {
            let composeViewC = mainStoryBoard.instantiateViewController(withIdentifier: "composeVc") as! ComposeController
            composeViewC.titleText = "Draft"
            composeViewC.obj = message
            composeViewC.parentMessageId = Int(message.id.safeValue).safeValueOfInt
            composeViewC.commDraftId = Int(message.id.safeValue).safeValueOfInt
            self.navigationController?.pushViewController(composeViewC, animated: true)
        } else if  valueReal != "compose" {
            let detailVc = mainStoryBoard.instantiateViewController(withIdentifier: "MessageDetailController") as! MessageDetailController
            detailVc.messageId = valueReal
            detailVc.typeMsg  = typeValue
            detailVc.text = titleValue
            self.navigationController?.pushViewController(detailVc, animated: true)
        } else {
            let composeViewC = mainStoryBoard.instantiateViewController(withIdentifier: "composeVc") as! ComposeController
            composeViewC.titleText = "Compose New Mail"
            self.navigationController?.pushViewController(composeViewC, animated: true)
        }
    }
        
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if topHeaderView.searchTextField.text != ""{
            searchText = topHeaderView.searchTextField.text!
            topHeaderView.searchTextField.resignFirstResponder()
            if searchText != ""{
                let obj = ["text" : topHeaderView.searchTextField.text.safeValue,"type": typeValue] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "searchAction"), object: obj)
            }
        }
        return true
    }
    
    func downloadPdfButtonAction(url: String, fileName: String?) {
        
    }
    
    
    func getBackToTableView(value: Any?,tagValueInt : Int) {
        
    }
    
    func selectedPickerRow(selctedRow: Int) {
        
    }
    func getUploadedAttachments(isUpload : Bool, isForDraft: Bool) {
        
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

extension CommunicateLandController: TopHeaderDelegate {
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
            topHeaderView.titleLabel.isHidden = true
            topHeaderView.searchTextField.isHidden = false
            topHeaderView.shouldShowSecondRightButton(false)
            button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        } else {
            topHeaderView.titleLabel.isHidden = false
            topHeaderView.searchTextField.isHidden = true
            button.setImage(#imageLiteral(resourceName: "Search"), for: .normal)
            topHeaderView.searchTextField.text = ""
            topHeaderView.shouldShowSecondRightButton(true)
            let obj = ["text" : topHeaderView.searchTextField.text.safeValue,"type": typeValue] as [String : Any]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "searchAction"), object: obj)
        }
    }
    
}
