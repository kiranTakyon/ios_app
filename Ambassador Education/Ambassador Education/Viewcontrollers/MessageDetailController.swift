
//
//  MessageDetailController.swift
//  Ambassador Education
//
//  Created by    Kp on 25/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit
import BIZPopupView
import QuickLook
import EzPopup

let html =   NSAttributedString.DocumentType.self


class MessageDetailController: UIViewController,UITableViewDelegate,UITableViewDataSource,TaykonProtocol {
    
    @IBOutlet weak var progressBar: ProgressViewBar!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTable: UITableView!
    @IBOutlet weak var topHeaderView: TopHeaderView!
   
    var text : String?
    var messageId : String?
    var typeMsg = Int()
    var downloadLink = String()
    var resultValue  : MessageModel?

    var messageList = [TinboxMessage]()
//    var popUpViewVc = BIZPopupViewController()
    let videoDownload  = VideoDownload()
    var fileURLs = [NSURL]()
    let quickLookController = QLPreviewController()
    
    var itemId : String?
    var id: String = ""
    var isApprove: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        topHeaderView.delegate = self
        getMessageDetails()
        videoDownload.delegate = self
        quickLookController.dataSource = self
        quickLookController.delegate = self
        quickLookController.navigationItem.rightBarButtonItems?[0] = UIBarButtonItem()
        messageTable.tableFooterView = UIView()
     
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        messageTable.estimatedRowHeight = 250.0
        messageTable.rowHeight = UITableView.automaticDimension
        progressBar.isHidden = true
        addBlurEffectToTableView(inputView: self.view, hide: true)
    }
    override func viewDidAppear(_ animated: Bool) {
//        self.performSegue(withIdentifier: "toMessageDetail", sender: self)
    }
    
    func getMessageDetails() {
        topHeaderView.title = text.safeValue
        self.startLoadingAnimation()
        
        var dictionary = [String: Any]()
        
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] = userId
        dictionary[Communicate().messageId] = messageId
        
        let url = APIUrls().messageDetails
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { [self] (result) in
        
            if result["StatusCode"] as? Int == 1{
                self.resultValue = MessageModel(values: result)//ModelClassManager.sharedManager.createModelArray(data: [result], modelType: ModelType.MessageModel) as! MessageModel
            
                if let messages = result["MessageList"] as? NSArray{
                    let list = ModelClassManager.sharedManager.createModelArray(data: messages, modelType: ModelType.TinboxMessage) as! [TinboxMessage]
                    
                    self.messageList.append(contentsOf: list)
                    DispatchQueue.main.async {
                        if self.text.safeValue == "" && !list.isEmpty {
                            self.topHeaderView.title = "\(list.first!.subject!)"
                        }
                        self.messageTable.reloadData()
                        self.stopLoadingAnimation()
                            if self.messageList.count == 0{
                                self.addNoDataFoundLabel()
                        }
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    SweetAlert().showAlert(kAppName, subTitle: "Not able to get the message details", style: .warning)
                }
            }
        }
    }
    
    
    func showPicker(tag : Int){
        if let colorVC = mainStoryBoard.instantiateViewController(withIdentifier: "ReadSelectViewController") as? ReadSelectViewController {
            if messageList.count > 0{

                var msgId = [String]()
                
                for each in messageList{
                    msgId.append(each.id.safeValue)
                }
                colorVC.msgId = msgId

                guard let user = UserDefaultsManager.manager.getUserType() as? String else{
                    
                }
                
                if user == UserType.parent.rawValue || user == UserType.student.rawValue{

                    colorVC.options = [(resultValue?.forwardLabel.safeValue).safeValue,(resultValue?.deleteMailLabel.safeValue).safeValue,(resultValue?.markAsReadLabel.safeValue).safeValue,(resultValue?.markAsUnReadLabel.safeValue).safeValue,(resultValue?.ApproveLabel.safeValue).safeValue,"Cancel"]

                }
                else{

                    colorVC.options = [(resultValue?.forwardLabel.safeValue).safeValue,(resultValue?.replyAllLabel.safeValue).safeValue,(resultValue?.deleteMailLabel.safeValue).safeValue,(resultValue?.markAsReadLabel.safeValue).safeValue,(resultValue?.markAsUnReadLabel.safeValue).safeValue,(resultValue?.ApproveLabel.safeValue).safeValue,"Cancel"]

                }
        }
            colorVC.isApproved = isApprove
            colorVC.msgObj = messageList[tag]
            colorVC.delegate = self
            colorVC.typeval = typeMsg
            colorVC.tag = tag
//            colorVC.tableView.reloadData()
//            popUpViewVc = BIZPopupViewController(contentViewController: colorVC, contentSize: CGSize(width: 300, height: 300))
//            self.present(popUpViewVc, animated: true, completion: nil)
            let popupVC = PopupViewController(contentController: colorVC, popupWidth: 300, popupHeight: 300)
            self.present(popupVC, animated: true)
        }}
    
    func didCheckApproveState(isApprove : Bool) {
        self.isApprove = isApprove
    }
    
    
    func moveToComposeController(titleTxt : String,index : Int,tag: Int){
        let composeViewC = mainStoryBoard.instantiateViewController(withIdentifier: "composeVc") as! ComposeController
        composeViewC.titleText = titleTxt
        
        let currentMessage = self.messageList[tag]
        composeViewC.obj = currentMessage
        var  values =   seperateMailWithType(msg: currentMessage,text : titleTxt)
        composeViewC.parentMessageId = Int(currentMessage.id.safeValue).safeValueOfInt
        if index == 1{
            if titleTxt == "Reply All" ||  titleTxt == "الرد على الجميع"{
                composeViewC.selectedPersonCC = values.1
                composeViewC.selectedPersons = values.0
                var dict = NSMutableDictionary()
                dict["UserId"] = currentMessage.senderId
                dict["name"] = currentMessage.sender
                dict["RecipientType"] = 0
                composeViewC.selectedPersonItems.append(TNPerson(values: dict as NSDictionary))

            }
            else{
                composeViewC.selectedPersonCC = currentMessage.memebers
                composeViewC.selectedPersons = currentMessage.sender.safeValue
            }
        composeViewC.groupIds = self.groupIdsAndNames(message: currentMessage).0
            if let persons = currentMessage.persons{
                if persons.count > 0{
                    for each in persons{
                    composeViewC.selectedPersonItems.append(each)
                    }
                }
            }
            if let groups = currentMessage.group{
                if groups.count > 0{
                    var names = ""
                    for each in groups{
                       names.append(each.name.safeValue + ",")
                
                    }
                    composeViewC.seletedGroups = names
                }
            }
        
      //(self.personNames(message: currentMessage) as NSArray).componentsJoined(by: ",")
        
        print("groupIdsAndNames : ", composeViewC.groupIds)
        print("seletedGroups : ", composeViewC.seletedGroups)
        print("selectedPersons : ",composeViewC.selectedPersons)
        }
        self.navigationController?.pushViewController(composeViewC, animated: true)
    }
    
    func deleteTheSelectedAttachment(index: Int) {
        
    }
    

    func formatDate(date: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd MMM"
        
        if let date = dateFormatterGet.date(from: date){
            var convered =  dateFormatterPrint.string(from: date)
            return convered
        }
        else {
            print("There was an error decoding the string")
        }
        return ""
    }
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if messageList.count > 0{
            return messageList.count
        }else{
            return 0
        }
    }
    
    func removeDuplicates(value : [String]) -> [String] {
        var temp = value
        for each in temp{
            if each == ""{
                var index = value.firstIndex(of: each)
                temp.remove(at: index.safeValueOfInt)
            }
        }
        let nums = Set(temp).sorted()
        return nums
    }
    
    func seperateGroupWithType(msg : TinboxMessage) -> (String,String,String){
        var toStr = String()
        var ccStr = String()
        var bccStr = String()
        var toArray = [String]()
        var ccArray = [String]()
        var bccArray = [String]()
        
        
        if let persons = msg.persons as? [TNPerson]{
            if persons.count > 0{
            for each in persons{
                if each.recipieType == 0{
                    toArray.append(each.groupName.safeValue)
                }
                else if each.recipieType == 1{
                    ccArray.append(each.groupName.safeValue)
                }
                else if each.recipieType == 2{
                    bccArray.append(each.groupName.safeValue)
                }
            }
            }
            else  if let groups = msg.group as? [TNGroup]{
                if groups.count > 0{
                    for each in groups{
                        toArray.append(each.name.safeValue)
                    }
                }
            }
        }
        
       toArray =  removeDuplicates(value: toArray)
        ccArray =  removeDuplicates(value: ccArray)
        bccArray =  removeDuplicates(value: bccArray)

        toStr = toArray.joined(separator: ",")
        ccStr = ccArray.joined(separator: ",")
        bccStr = bccArray.joined(separator: ",")
        
        return (toStr,ccStr,bccStr)
    }
    
    func seperateMailWithType(msg : TinboxMessage,text : String) -> (String,String,String){
        var toStr = String()
        var ccStr = String()
        var bccStr = String()
        var toArray = [String]()
        var ccArray = [String]()
        var bccArray = [String]()

        let loginUserId = UserDefaultsManager.manager.getUserId()
        
        if let persons = msg.persons as? [TNPerson]{
            for each in persons{
                
                if loginUserId != each.id{
                if each.recipieType == 0{
                    toArray.append(each.name.safeValue)
                }
                else if each.recipieType == 1{
                    ccArray.append(each.name.safeValue)
                }
                else if each.recipieType == 2{
                    bccArray.append(each.name.safeValue)
                }
                }
            }
        }
        if  text == "Reply All" ||  text == "الرد على الجميع"{
          toArray.append(msg.sender.safeValue)
        }
        
        toArray =  removeDuplicates(value: toArray)
        ccArray =  removeDuplicates(value: ccArray)
        bccArray =  removeDuplicates(value: bccArray)
        
        toStr = toArray.joined(separator: ",")
        ccStr = ccArray.joined(separator: ",")
        bccStr = bccArray.joined(separator: ",")

        return (toStr,ccStr,bccStr)
    }
    
    func returnHyphoneOnEmptyValues(value : String) -> String{
        let str = "-"
        if value == ""{
            return str
        }
        else{
            /*let start = value.startIndex
            let end = value.index(value.endIndex, offsetBy: -4)
            let substring = value[start..<end]
            return String(substring)*/
            if value.count>80
            {
                return String(value.prefix(80))+"..."
            }
            else
            {
                return String(value.prefix(80))
            }
        }
    }
    
    func getValues(values : (String,String,String),cell: messageDetailSecondCell){
        if !returnIfArrayIsEmpty(str: values.0){
            if !returnIfArrayIsEmpty(str: values.1){
                if !returnIfArrayIsEmpty(str: values.2){
                    cell.messageLabel.text = "to :- \(returnHyphoneOnEmptyValues(value: values.0))" + "\n\n" + "Cc :- \(returnHyphoneOnEmptyValues(value: values.1))" + "\n\n" + "Bcc :- \(returnHyphoneOnEmptyValues(value: values.2))"
                }
                else{
                    cell.messageLabel.text = "to :- \(returnHyphoneOnEmptyValues(value: values.0))" + "\n\n" + "Cc :- \(returnHyphoneOnEmptyValues(value: values.1))"
                }
            }
            else{
                if !returnIfArrayIsEmpty(str: values.2){
                    cell.messageLabel.text =  "to :- \(returnHyphoneOnEmptyValues(value: values.0))" + "\n\n" + "Bcc :- \(returnHyphoneOnEmptyValues(value: values.2))"
                }
                else{
                    cell.messageLabel.text =  "to :- \(returnHyphoneOnEmptyValues(value: values.0))"
                }
            }
        }
        else{
            if !returnIfArrayIsEmpty(str: values.1){
                if !returnIfArrayIsEmpty(str: values.2){
                    cell.messageLabel.text = "Bcc :- \(returnHyphoneOnEmptyValues(value: values.2))"
                }
                else{
                    cell.messageLabel.text =  "Cc :- \(returnHyphoneOnEmptyValues(value: values.1))"
                }
            }
            else{
                if !returnIfArrayIsEmpty(str: values.2){
                    cell.messageLabel.text =  "Bcc :- \(returnHyphoneOnEmptyValues(value: values.2))"
                }
                else{
                    cell.messageLabel.isHidden = true
                }
            }
        }
    }
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageDetailSecondCell", for: indexPath) as! messageDetailSecondCell
            cell.navigationcontroller = self.navigationController
            let message = self.messageList[indexPath.row]
            cell.delegate = self
            cell.personLabel.text = message.sender
            cell.messageLabel.numberOfLines = 0
            cell.replyButton.tag = indexPath.row
            cell.dropDownButton.titleLabel?.tag = indexPath.row
            cell.messageLabel.isHidden = false
            //print(message.wholeGroup)
            if let count = message.wholeGroup{
                    if count == "0"{
                        let values = seperateMailWithType(msg: message, text: "")
                        getValues(values : values , cell: cell)
               
                }
            else{
                        let values = seperateGroupWithType(msg: message)
                        getValues(values : values , cell: cell)

                       // cell.messageLabel.text = "to :- \(returnHyphoneOnEmptyValues(value: values.0))" + "\n" + "Cc :- \(returnHyphoneOnEmptyValues(value: values.1))" + "\n" + "Bcc :- \(returnHyphoneOnEmptyValues(value: values.2))"
                }
        }
        
            if let dateValue = message.date{
                cell.dateLabel.text = formatDate(date: dateValue)
                
            }
            stringFromHtml(string: message.message!,cell:cell)
//        stringFromHtml(string: "message.messag",cell:cell)
            cell.imageUrl = message.senderImage!
            cell.tag = indexPath.row
            cell.delegate = self
            setAttachmentsToCell(message: [message], cell: cell)
        cell.selectionStyle = .none
        return cell
    }
    
    func returnIfArrayIsEmpty(str : String) -> Bool{
        if str  == ""{
            return true
        }
        else{
            return false
        }
    }

    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     /*   print("You tapped cell number \(indexPath.row).")
       
        let message = self.messageList[indexPath.row]
       
        if message.message != "" {
            let strU : String = self.getLinkFormHtml(strV: message.message!)
            if ((message.message?.contains("weeklyplan?cat_id=")) != false || (message.message?.contains("weeklyplan/?cat_id=")) != false)
                {
                self.itemId = message.message?.components(separatedBy: "&message_id=")[1]
                self.itemId = self.itemId?.components(separatedBy: "\">click here")[0]
                if(itemId != "")
                {
                    showComments(itemid: itemId ?? "")
                }
               }
            else if strU != "" {
              //  UIApplication.shared.open(URL(string:strU)!)
            }
        
                
        }*/
    }
    
    func getLinkFormHtml(strV : String)-> String {
        let types: NSTextCheckingResult.CheckingType = .link
        let detector = try? NSDataDetector(types: types.rawValue)

        guard let detect = detector else {
            return ""
        }
        let matches = detect.matches(in: strV, options: .reportCompletion, range: NSMakeRange(0,strV.count))
        for match in matches {
            print(match.url!)
        }
        return matches.count != 0 ? "\(matches.first!.url!)" : ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setAttachmentsToCell(message : [TinboxMessage],cell :messageDetailSecondCell){
        if let attachments = message[0].attachments{
            if attachments.count > 0{
                cell.data = attachments
            }
            cell.tableViewAttachments.isHidden = false
        }
        else{
            cell.tableViewHeight.constant = 0
            cell.tableViewAttachments.isHidden = true
        }
        
    }
    func downloadPdfButtonAction(url: String, fileName: String?) {
       // self.startLoadingAnimation()
        downloadPdf(attachmentUrl: url,fileName: fileName ?? "")
    }
    
    func getSearchWithCommunicate(searchTxt: String, type: Int) {
        
    }
    
    func getUploadedAttachments(isUpload : Bool, isForDraft: Bool){
        
    }
    
    
    func downloadPdf(attachmentUrl : String,fileName : String){
        _ = URL(string: attachmentUrl)//URL(fileURLWithPath: attachmentUrl)
                self.loadPDFAndShare(url: attachmentUrl, fileName: fileName)
    }
    
    func getBackToTableView(value: Any?,tagValueInt : Int) {
        guard let tagValue = value as? Int else {
           self.navigationController?.popViewController(animated: true)
            return
            
        }
        if tagValue != 9000000{

          
        let composeViewC = mainStoryBoard.instantiateViewController(withIdentifier: "composeVc") as! ComposeController
            composeViewC.titleText = (resultValue?.replyLabel.safeValue).safeValue

            composeViewC.selectedPersonItems.removeAll()
            composeViewC.groupIds.removeAll()
            composeViewC.seletedGroups = ""
            composeViewC.selectedPersons = ""

            
        let currentMessage = self.messageList[tagValue]
        composeViewC.obj = currentMessage
        composeViewC.selectedPersonItems = currentMessage.persons!
        composeViewC.parentMessageId = Int(currentMessage.id.safeValue).safeValueOfInt

        composeViewC.groupIds = self.groupIdsAndNames(message: currentMessage).0
        
        composeViewC.seletedGroups = currentMessage.sender.safeValue////(self.groupIdsAndNames(message: currentMessage).1 as NSArray).componentsJoined(by: ",")
        
        composeViewC.selectedPersons = currentMessage.memebers//(self.personNames(message: currentMessage) as NSArray).componentsJoined(by: ",")
        
/*        print("groupIdsAndNames : ", composeViewC.groupIds)
          print("seletedGroups : ", composeViewC.seletedGroups)
          print("selectedPersons : ",composeViewC.selectedPersons)
       */
        self.navigationController?.pushViewController(composeViewC, animated: true)
        }
        else{
            showPicker(tag : tagValueInt)
        }
    }
    
      func loadPDFAndShare(url: String, fileName: String){
     
        addBlurEffectToTableView(inputView: self.view, hide: false)
        progressBar.isHidden = false
        progressBar.progressBar.setProgress(1.0, animated: true)
        progressBar.titleText = "Downloading,Please wait"

        videoDownload.startDownloadingUrls(urlToDowload:[url],type:"", fileName:fileName)

       }

    

    func groupIdsAndNames(message:TinboxMessage) -> ([Int],[String]){
        
        var ids = [Int]()
        var names = [String]()
        
        for groupValue in message.group!{
            
            ids.append(Int(String(describing: groupValue.id!))!)
            names.append(groupValue.name!)
        }
        
        return (ids,names)
    }
    
    
    func personNames(message:TinboxMessage) -> [String]{
        
        var names = [String]()
        
         for groupValue in message.persons!{
            
            names.append(groupValue.name!)
        }
        
        return names
        
        
    }
    
    func getBackToParentView(value: Any?, titleValue: String?, isForDraft: Bool) {
        
    }
    
    
    func selectedPickerRow(selctedRow: Int) {
        
    }
    
    func popUpDismiss() {
        
    }
    
    
    @IBOutlet var bkimg: [UIImageView]!
    @IBAction func backAction(_ sender: Any) {
        if self.navigationController?.viewControllers.count == 1 {
            let vc = mainStoryBoard.instantiateViewController(withIdentifier: "CommunicateLandController") as! CommunicateLandController
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            self.navigationController!.popViewController(animated: true)
        }
    }
    
    func getHeightOfRichEditorView(cell: messageDetailSecondCell,text : String){
        cell.richEditorHeight.constant =  text.height(withConstrainedWidth: cell.richEditorView.frame.width, font: UIFont.systemFont(ofSize: 18.0, weight: .black)) + 50
    }
    
    private func stringFromHtml(string: String,cell: messageDetailSecondCell)  {
   //     let htmlDecode = string.replacingHTMLEntities
        cell.richEditorView.isScrollEnabled = true
       // cell.richEditorView.setFontSize(30)
        
      
        //cell.richEditorView.html  = string  //"Message Content";  //string
        getHeightOfRichEditorView(cell: cell, text: string.html2String )
        cell.richEditorView.isUserInteractionEnabled = true
        cell.richEditorView.editingEnabled = false
        
        if string != "" {
        if ((string.contains("weeklyplan?cat_id=")) != false || (string.contains("weeklyplan/?cat_id=")) != false){
            cell.WPButton.frame = CGRect( x: 300, y: cell.richEditorHeight.constant+50, width: 100, height: 35 );
            cell.WPButton.isHidden = false
            self.itemId = string.components(separatedBy: "&message_id=")[1]
            self.itemId = self.itemId?.components(separatedBy: "\">click here")[0]
            let ID:Int? = Int(self.itemId ?? "0")
            cell.WPButton.tag = ID ?? 0
            let newString = string.replacingOccurrences(of: "<a[^>]*>(.*?)</a>", with: "Click on <strong>View</strong> button", options: .regularExpression, range: nil)
            cell.richEditorView.html  = newString
        }
            else{
                cell.richEditorView.html  = string
            }
        }
       
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toBackFromMessageDetail"{
            let destinationVC = segue.destination as! UINavigationController
//            let vc = destinationVC.children[0] as! CommunicateLandController
        }

    }

}


import RichEditorView

class messageDetailSecondCell : UITableViewCell,UITableViewDataSource,UITableViewDelegate,MessageDownLoadDelegate{
    
    var delegate : TaykonProtocol?
    @IBOutlet weak var profileImage: ImageLoader!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var personLabel: UILabel!
  //  @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var tableViewAttachments: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var richEditorHeight: NSLayoutConstraint!
    @IBOutlet weak var richEditorRight: NSLayoutConstraint!
    @IBOutlet weak var richEditorView: RichEditorView!
    @IBOutlet weak var dropDownButton: UIButton!
    
    @IBOutlet weak var WPButton: UIButton!
    var navigationcontroller : UINavigationController! = nil
    var imageUrl : String = ""{
        
        didSet{
            self.setImage()
        }
    }
    
    
    var data : [Attachment]?{
        didSet{
            setTableViewHeight()
            tableViewAttachments.reloadData()
        }
    }
    
    func setTableViewHeight(){
        if let count = data?.count {
            tableViewHeight.constant = CGFloat(50.0 * Double(count))
        }
        else{
            tableViewHeight.constant = 0.0
        }
    }
    
    override func awakeFromNib() {
        self.tableViewAttachments.delegate = self
        self.tableViewAttachments.dataSource = self
        self.tableViewAttachments.separatorStyle = .none
        self.tableViewAttachments.tableFooterView = UIView()
        self.tableViewAttachments.estimatedRowHeight = 150.0
        self.tableViewAttachments.rowHeight = UITableView.automaticDimension
        
    }
    func gotoWeb(str : String) {
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
        vc.strU = str
        self.navigationcontroller?.pushViewController(vc, animated: true)
    }
    @IBAction func replyAction(_ sender: UIButton) {
        print("reply tapped0")
        delegate?.getBackToTableView(value: sender.tag,tagValueInt : -1)
        
    }
    
    @IBAction func wpAction(_ sender: UIButton) {
        print("WP tapped0")
        if(sender.tag != 0)
        {
                showComments(itemid: String(sender.tag))
        }
    }
    func showComments(itemid : String)
    {
        let detailVc = mainStoryBoard.instantiateViewController(withIdentifier: "DigitalResourceDetailController") as! DigitalResourceDetailController
        //detailVc.weeklyPlan = weeklyPlan
        detailVc.WpID = itemid
        self.navigationcontroller?.pushViewController(detailVc, animated: true)
        
    }
    func setImage(){
        self.profileImage.layer.cornerRadius = 30.0
        self.profileImage.loadImageWithUrl(imageUrl)
    }
    
    func seperateLinkAndGetCorrectLink(link : String){
        var correctLink = ""
        if link != ""{
            if link.contains("_COMMN_1_"){
                if let arr = link.components(separatedBy: "_COMMN_1_") as? [String]{
                    if arr.count > 0{
                        correctLink = arr[1]
                    }
                }
            }
            else{
                
            }
        }
        
    }
    
    func downLoadMylink(sender: UIButton, index: Int) {
        if let myData = data{
            if let value = myData[index] as? Attachment{
                if let downLink = value.linkAddress{
                    let downname = value.linkName
                    if sender.accessibilityHint == nil {
                        self.gotoWeb(str: "\(downLink)")
                    }
                    else {
                        delegate?.downloadPdfButtonAction(url:downLink, fileName: downname) }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if data != nil {
            if let count = data?.count{
                return count
            }
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = tableView.dequeueReusableCell(withIdentifier: "MessageDownLoadCell", for: indexPath) as? MessageDownLoadCell
        cell?.downldLabel.text  = data![indexPath.row].linkName
        cell?.btnDownload.accessibilityHint = "Download"
        cell?.tag = indexPath.row
        cell?.selectionStyle = .none
        cell?.delegate = self
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
   
    @IBAction func dropDowwnButtonAction(_ sender: UIButton) {
        delegate?.getBackToTableView(value: sender.tag,tagValueInt : (sender.titleLabel?.tag).safeValueOfInt)
    }
    
}




extension String {
    
    var htmlToAttributedString: NSAttributedString? {
      
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            
            return try NSAttributedString(data: data, options: convertToNSAttributedStringDocumentReadingOptionKeyDictionary([convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.documentType): convertFromNSAttributedStringDocumentType(NSAttributedString.DocumentType.html), convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.characterEncoding): String.Encoding.utf8.rawValue]), documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    // extension String {
    var replacingHTMLEntities: String? {
        do {
            return try NSAttributedString(data: Data(utf8), options: convertToNSAttributedStringDocumentReadingOptionKeyDictionary([
                convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.documentType): convertFromNSAttributedStringDocumentType(NSAttributedString.DocumentType.html),
                convertFromNSAttributedStringDocumentAttributeKey(NSAttributedString.DocumentAttributeKey.characterEncoding): String.Encoding.utf8.rawValue
                ]), documentAttributes: nil).string
        } catch {
            return nil
        }
    }
}

protocol MessageDownLoadDelegate {
    func downLoadMylink(sender: UIButton, index: Int)
}

class MessageDownLoadCell: UITableViewCell{
    
    var delegate : MessageDownLoadDelegate?
    
    @IBOutlet weak var downldLabel: UILabel!
    @IBOutlet weak var btnDownload: UIButton!
    
    @IBAction func dwnloadButtnAction(_ sender: UIButton) {
        self.delegate?.downLoadMylink(sender: sender, index: self.tag)
    }
    
}

extension MessageDetailController:VideoDownloadDelegate{
    func loadingStarted(){
       // self.startLoadingAnimation()
    }
    
    func loadingEnded(){
        addBlurEffectToTableView(inputView: self.view, hide: true)
        progressBar.isHidden = true
    }
    
    func filesDownloadComplete(filePath:String,fileToDelT:String) {
        fileURLs = []
         let file = NSURL(string: filePath.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        fileURLs.append(file!)
        quickLookController.dataSource = nil
        quickLookController.delegate = nil
        
        quickLookController.dataSource = self
        quickLookController.delegate = self
        
        if QLPreviewController.canPreview(file!) {
            quickLookController.currentPreviewItemIndex = 0
            present(quickLookController, animated: true, completion: nil)
        }
    }
    
}

extension MessageDetailController : QLPreviewControllerDataSource ,QLPreviewControllerDelegate{
    
    func previewControllerWillDismiss(_ controller: QLPreviewController) {
        //
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        self.stopLoadingAnimation()
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return fileURLs.count
    }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURLs[index]
    }
}


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): font]), context: nil)
        if ceil(boundingBox.height) < 30.0 &&  ceil(boundingBox.height) !=  0.0{
            return ceil(boundingBox.height) + 20
        }
        return ceil(boundingBox.height)
}
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringDocumentReadingOptionKeyDictionary(_ input: [String: Any]) -> [NSAttributedString.DocumentReadingOptionKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.DocumentReadingOptionKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentAttributeKey(_ input: NSAttributedString.DocumentAttributeKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringDocumentType(_ input: NSAttributedString.DocumentType) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}


extension MessageDetailController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        print("")
    }
    
    func searchButtonClicked(_ button: UIButton) {
        print("")
    }
    
}
