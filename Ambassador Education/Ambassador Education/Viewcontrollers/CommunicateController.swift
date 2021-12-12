//
//  CommunicateController.swift
//  Ambassador Education
//
//  Created by    Kp on 23/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit
var typeValue = Int()



enum CommunicationType : String{
    
    case inbox = "INBOX"
    case sent  = "SENT"
    case WP = "WEEKLYPLAN"
}

class CommunicateController: UIViewController,UITableViewDataSource, UITableViewDelegate,TaykonProtocol {


    @IBOutlet weak var communicateTable: UITableView!
    var delegate : TaykonProtocol?
    
    var type : CommunicationType?

    var paginationNumber = 1
    
    var inboxMessages = [TinboxMessage]()
    
    let refreshControl = UIRefreshControl()
    var searchText = ""
    override func viewDidLoad() {
        super.viewDidLoad()
      
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {

        NotificationCenter.default.addObserver(self, selector: #selector(getMsgs(notification:)), name: NSNotification.Name(rawValue: "searchAction"), object: nil)
        tableViewProporties()
        setRefreshControll()
        paginationNumber = 1
        searchText = ""
        paginationNumber = 1
        inboxMessages.removeAll()
        getInboxMessages(txt : searchText, types: typeValue)
    }
    
    @objc func getMsgs(notification : NSNotification){
        if let userInfo = notification.object as? NSDictionary{
        let msg = userInfo["text"] as? String
            paginationNumber = 0
            inboxMessages.removeAll()
            UIApplication.shared.cancelAllLocalNotifications()
            getInboxMessages(txt : msg.safeValue, types: typeValue)
        }
    }
    
    func setRefreshControll(){
        
        
        refreshControl.addTarget(self, action: #selector(CommunicateController.refresh(sender:)), for: UIControl.Event.valueChanged)
        
        communicateTable.bottomRefreshControl = refreshControl// not required when using UITableV
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        self.searchText = ""
        self.paginationNumber += 1
        self.getInboxMessages(txt : searchText, types: typeValue)
    }

    
    func getInboxMessages(txt : String,types: Int){
        
        self.startLoadingAnimation()
        var url  = ""
        
         if type == CommunicationType.inbox{
            typeValue = 2
            url = APIUrls().getInBox
         }
        else if type == CommunicationType.WP{
            typeValue = 3
            url = APIUrls().WPCommentList
        }
        else{
            typeValue = 1
            url = APIUrls().getSentBox
        }

        print("communicate send urk :- ",url)
        
        var dictionary = [String: Any]()
        
        
        dictionary[UserIdKey().id] =  UserDefaultsManager.manager.getUserId()//self.checkSibingsAndGetId()
        dictionary[Communicate().searchText] = txt
        dictionary[Communicate().paginationNumber] = paginationNumber
        if(typeValue == 3)
        {
            dictionary[Communicate().ModuleCode] = "weeklyplan"
        }
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            print("inbox messages",result)
            
    //        if result["StatusCode"] as? Int == 1{
            
                    DispatchQueue.main.async {
                        if let messageList = result["MessageList"] as? NSArray{
                            let list = ModelClassManager.sharedManager.createModelArray(data: messageList, modelType: ModelType.TinboxMessage) as! [TinboxMessage]
                        for each in list{
                        self.inboxMessages.append(each)
                        }
                    
                        self.stopLoadingAnimation()
                        self.communicateTable.reloadData()
                        self.removeNoDataLabel()
                        self.checkAndStopBounce(count: list.count)
                        self.refreshControl.endRefreshing()
                            if self.inboxMessages.count == 0{
                                self.addNoDataFoundLabel()
                            }
                            else{
                                self.removeNoDataLabel()
                            }

                }else{
                         self.stopLoadingAnimation()
                         //   self.addNoDataFoundLabel()
                          self.refreshControl.endRefreshing()
                }
            }

            }
    }
    

    
    func checkAndStopBounce(count:Int){
        
        if count == 0{
            self.communicateTable.bounces = false
        }
        
    }
    func setCharacterColor(cell:CommunicateCell,textColr: UIColor){
        cell.firstLabel.textColor = textColr
        cell.secondLabel.textColor = textColr
    }
    
    func setReadStatus(message : TinboxMessage,cell: CommunicateCell){
        if type == CommunicationType.inbox
        {
            cell.ReadStatus.isHidden = true
            
        }
        else
        {
            cell.ReadStatus.isHidden = false
            //cell.ReadStatus.text = String(describing: message.TotalCount)
            
            let ReadCount = Int(message.ReadCount ?? "0")
            let str = message.ReadCount ?? "0"
            let str2 = message.TotalCount ?? "0"
            cell.ReadStatus.text = str + "/" + str2
            if message.TotalCount == message.ReadCount
            {
                cell.ReadIcon.image = UIImage(named : "check_green")
            }
            else if ReadCount!  > 0
            {
                cell.ReadIcon.image = UIImage(named : "check_grey")
            }
        }
        
        
    }
    func setTheTableCellElementsTextColorWrtIsRead(message : TinboxMessage,cell: CommunicateCell){
         if let isUserRead  = message.isRead{
                 switch isUserRead {
                 case "0":
                    setCharacterColor(cell: cell, textColr: UIColor.black)
                 case "1":
                     setCharacterColor(cell: cell, textColr: UIColor.lightGray)
                     cell.ReadIcon.image = UIImage(named: "check_green")
                 default:
                     break
         }
         }
     }
    func checkSibingsAndGetId() -> String?{
        
        if studentDetails.count > 0{
            
            let studDetails = studentDetails[indexOfSelectedStudent]
            
            return studDetails.userId
            
        }else{
            let userId = UserDefaultsManager.manager.getUserId()

            return userId
        }
    }
    
    func tableViewProporties(){
        self.communicateTable.delegate = self
        self.communicateTable.dataSource = self
        self.communicateTable.estimatedRowHeight = 60
        self.communicateTable.rowHeight = UITableView.automaticDimension
    }
    
    func setHeight(isHide : Bool,const : CGFloat,cell: CommunicateCell){
        cell.attachButton.isHidden = isHide
        cell.attachHeight.constant = const
    }
    
    func setAttachmentsIcon(msg : TinboxMessage,cell: CommunicateCell){
        let attachIcon = msg.attachIcon.safeValueOfInt
        switch attachIcon {
        case 0:
            setHeight(isHide: true, const: 0.0,cell: cell)
        case 1:
            setHeight(isHide: false, const: 30.0,cell: cell)
        default:
            break
        }
    }
    //MARK:- TableView Delegates and Datasources
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inboxMessages.count > 0{
        return self.inboxMessages.count
        }
        else{
            return 0
        }
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunicateCell", for: indexPath) as! CommunicateCell
        if inboxMessages.count > 0{
        let message = inboxMessages[indexPath.row]
        
        setReadStatus(message: message, cell: cell)
        setTheTableCellElementsTextColorWrtIsRead(message: message, cell: cell)
       
        if let userval = message.user{
            cell.firstLabel.text = userval
        }else if let userBol = message.userBool{
            cell.firstLabel.text = String(userBol)

        }
        setAttachmentsIcon(msg: message, cell: cell)
        cell.secondLabel.text = message.subject?.replacingHTMLEntities
        cell.thirdLabel.text = message.date
        cell.imageUrl = message.userProfileImage.safeValue
        
        cell.selectionStyle = .none
        }
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
        if inboxMessages.count > 0{
        let message = self.inboxMessages[indexPath.row]
        let messageSub = message.subject.safeValue
        let messageId = message.id.safeValue

        delegate?.getBackToParentView(value: messageId,titleValue :messageSub)
        }
    }
    
    func deleteTheSelectedAttachment(index: Int) {

    }

    @IBAction func composeAction(_ sender: Any) {
        self.delegate?.getBackToParentView(value: "compose", titleValue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func downloadPdfButtonAction(url: String, fileName: String?) {
        
    }
    
    func getBackToParentView(value: Any?, titleValue: String?) {
        
    }
    
    func getBackToTableView(value: Any?,tagValueInt : Int) {
        
    }
    
    func getUploadedAttachments(isUpload : Bool) {
        
    }
    

    func selectedPickerRow(selctedRow: Int) {
        
    }
    
    func popUpDismiss() {
        
    }
    
    func moveToComposeController(titleTxt: String, index: Int,tag: Int) {
        
    }
    
    func getSearchWithCommunicate(searchTxt: String, type: Int) {
        getInboxMessages(txt : searchTxt, types: type)
    }
    

}

class CommunicateCell : UITableViewCell{
    
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var cImageView: ImageLoader!
    @IBOutlet weak var attachButton: UIButton!
    @IBOutlet weak var ReadIcon: UIImageView!
    @IBOutlet weak var ReadStatus: UILabel!
    @IBOutlet weak var attachHeight: NSLayoutConstraint!
    
    var imageUrl : String = ""{
        
        didSet{
            self.setImage()
        }
    }
    
    func setImage(){
        self.cImageView.loadImageWithUrl(imageUrl)
    }
    
}


