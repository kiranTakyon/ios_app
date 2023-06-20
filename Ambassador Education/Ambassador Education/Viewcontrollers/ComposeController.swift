//  ComposeController.swift
//  Ambassador Education
//
//  Created by    Kp on 25/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import UIKit
import RichEditorView
import MobileCoreServices
//import RebekkaTouch


var typingCount = 0


class ComposeController: UIViewController,RichEditorToolbarDelegate,TaykonProtocol,UITextFieldDelegate,UIDocumentMenuDelegate,UIDocumentPickerDelegate ,KSTokenViewDelegate {

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var attachmentTb: UITableView!
    @IBOutlet weak var attachmenyTBHeight: NSLayoutConstraint!
    
    @IBOutlet weak var addPersonWidth: NSLayoutConstraint!
    @IBOutlet weak var addCcHeight: NSLayoutConstraint!
    @IBOutlet weak var groupViewHeight: NSLayoutConstraint!
    @IBOutlet weak var personViewHeight: NSLayoutConstraint!
    

    @IBOutlet weak var groupView: KSTokenView!
    @IBOutlet weak var personView: KSTokenView!
    @IBOutlet weak var bccView: KSTokenView!
    @IBOutlet weak var subjectTextField: UITextField!
    

    @IBOutlet weak var editorView: RichEditorView!
    @IBOutlet weak var toolBar: RichEditorToolbar!
    @IBOutlet weak var topHeaderView: TopHeaderView!
 

    @IBOutlet weak var suggestionConstraint: NSLayoutConstraint!
    
    var forwardMsgIdValue = String()
    //var fileUpload = UploadFTP()
    var fileUpload = FTPUpload()
    var isReplyMail = false
    var attachmentItems = [String]()
    var titleText = String()
    var seletedGroups = ""
    var selectedPersons = ""
    var selectedPersonCC = ""
    var isIncluded = false
    
    var groupItems = [TNGroup]()
    var personItems = [TNPerson]()
    var obj : TinboxMessage?
    var groupIds = [Int]()
    var personsIds = [String]()
    var selectedPersonItems = [TNPerson]()
    var parentMessageId = 0
    var attachments = [String]()
    var currentSelectedTag = 0
    var session: Session!

    override func viewDidLoad() {
        super.viewDidLoad()
        topHeaderView.delegate = self
        setRichToolbarProporties()
        setTableViewProporties()
        getFTPDetails()
        subjectTextField.delegate = self
        getTokenView(tokenView : groupView,placeHolder: "Select Group")
        getTokenView(tokenView : personView,placeHolder:"Select Person")
        getTokenView(tokenView : bccView,placeHolder:"Add Cc")
        subjectTextField.placeholder = "Subject"
        setMessages()
        isIncluded = false
        // Do any additional setup after loading the view.
    }
    
    
    private func stringFromHtml(string: String,method: String)  {
        if method.contains("Forward") ||  method.contains("إلى الأمام") {
            editorView.html =  "<br display: block; margin: 800px; height: 1500;> </br> <br display: block; margin: 800px; height: 1500;> </br> <p>---------Forwarded Message--------- </p> <p> From: \(obj!.sender.safeValue) </p> <p>Date : \(obj!.date.safeValue) </p> <p>Subject : \(obj!.subject.safeValue) </p>  <p>\(string) </p>"
        }
            
        else if titleText == "Reply" || titleText ==  "الرد" || titleText == "Reply All" || titleText == "الرد على الجميع"{
            editorView.html =  "<br display: block; margin: 800px; height: 1500;> </br> <br display: block; margin: 800px; height: 1500;> </br> <p>---------Reply Message--------- </p> <p>\(string) </p>"
        }
        }
    
    
    func getTheIncluded(){
       
    }
    func seperateNameWithCommas(string : String,view:KSTokenView ){
        if string != ""{
            if let arr =  string.components(separatedBy: ",") as? [String]{
                if arr.count > 0{
                    for each in arr{
                        view.addTokenWithTitle(each)
                    }
                }
            }
        }
    }
    
    func setReplyCommonFunctions(){
        forwardMsgIdValue = (obj?.id.safeValue).safeValue
        isReplyMail = true
        subjectTextField.text = "Re: " + (obj?.subject.safeValue).safeValue
        stringFromHtml(string: (obj?.message).safeValue, method: titleText)
        seperateNameWithCommas(string: seletedGroups, view: groupView)
        groupView.searchResultHeight = 0.0
        groupView.minimumCharactersToSearch = 100
        groupView.placeholder = "Select Person"
    }
    
    func setMessages(){
        if titleText == "Reply" || titleText ==  "الرد"{
            setReplyCommonFunctions()
            setConstraints(addPersonWidthValue: 0.0, addCcHeightValue: 0.0, groupViewHeightValue: 0.0, personViewHeightValue: 0.0, hide: true)
            selectedPersonItems.removeAll()
            let dict = NSMutableDictionary()
            dict.setValue(obj?.senderId.safeValue, forKey: "UserId")
            dict.setValue(obj?.sender.safeValue, forKey: "name")
            if groupIds.count > 0{
              dict.setValue("\(groupIds[0])", forKey: "GroupId")
            }
            else{
                dict.setValue("0", forKey: "GroupId")
            }
            dict.setValue("0", forKey: "RecipientType")
            selectedPersonItems = [TNPerson(values : dict)]
        }
           else if titleText == "Reply All" || titleText == "الرد على الجميع"{
             setReplyCommonFunctions()
             setConstraints(addPersonWidthValue: 20.0, addCcHeightValue: 20.0, groupViewHeightValue: 45.0, personViewHeightValue: 45.0, hide: false)
             seperateNameWithCommas(string: selectedPersons, view: personView)
             seperateNameWithCommas(string: selectedPersonCC, view: bccView)
            }
       
      else  if titleText.contains("Forward") ||  titleText.contains("إلى الأمام")  {
            isReplyMail = false
            subjectTextField.text = "Fwd: " + (obj?.subject.safeValue).safeValue
            stringFromHtml(string: (obj?.message).safeValue, method: titleText)

            groupView.placeholder = "Select Group"
            groupView.searchResultHeight = 500
            groupView.minimumCharactersToSearch = 0
            setConstraints(addPersonWidthValue: 20.0, addCcHeightValue: 20.0, groupViewHeightValue: 45.0, personViewHeightValue: 45.0, hide: false)
        }
        else{
            isReplyMail = false
            groupView.placeholder = "Select Group"
            groupView.searchResultHeight = 500
            groupView.minimumCharactersToSearch = 0
            //heightConstraint.constant = 100
            setConstraints(addPersonWidthValue: 20.0, addCcHeightValue: 20.0, groupViewHeightValue: 45.0, personViewHeightValue: 45.0, hide: false)
        }
    }
    
    func setConstraints(addPersonWidthValue: CGFloat,addCcHeightValue: CGFloat,groupViewHeightValue: CGFloat,personViewHeightValue: CGFloat,hide: Bool){
        addPersonWidth.constant = addPersonWidthValue
        addCcHeight.constant =  addCcHeightValue
        groupViewHeight.constant = groupViewHeightValue
        personViewHeight.constant = personViewHeightValue
        personView.isHidden  = hide
        bccView.isHidden  = hide
    }
    
    func getTokenView(tokenView : KSTokenView,placeHolder : String){
                tokenView.delegate = self
                tokenView.placeholder = placeHolder
                tokenView.shouldHideSearchResultsOnSelect = true
                tokenView.shouldSortResultsAlphabatically = false
                tokenView.shouldDisplayAlreadyTokenized = true
                tokenView.shouldDeleteTokenOnBackspace = true
                tokenView.minimumCharactersToSearch = 0
                tokenView.searchResultHeight = 500
                tokenView.activityIndicatorColor = UIColor.lightGray
                tokenView.cursorColor = UIColor.gray
                tokenView.direction = .horizontal
                tokenView.style = .rounded
    }
    

    func setRichToolbarProporties(){
        toolBar.tintColor = UIColor.white
        toolBar.barTintColor = UIColor.black.withAlphaComponent(0.3)
        toolBar.options = RichEditorDefaultOption.all
        toolBar.delegate = self
        toolBar.editor = self.editorView
        editorView.placeholder = "Compose Email"
        
    }
    
    func setTableViewProporties(){
        self.attachmentTb.estimatedRowHeight = 60.00
        self.attachmentTb.rowHeight = UITableView.automaticDimension
        attachmentTb.delegate = self
        attachmentTb.dataSource = self
        attachmentTb.tableFooterView = UIView()
        topHeaderView.title = titleText
        setBorderColor()
    }
    

    //Did selction method of suggestion Table
    
    
    func didSelelectItem(selectedIndex:Int){
        
        if currentSelectedTag == 0{
            if groupItems.count > 0{

            let item = groupItems[selectedIndex]
            if !groupIds.contains((Int(String(describing: item.id.safeValue)).safeValueOfInt)){
                isIncluded = false

                item.setRecipieValues(type: 0)
                seletedGroups.append("\(item.name.safeValue),")
                groupIds.append((Int(String(describing: item.id.safeValue)).safeValueOfInt))
            }
            else{
                isIncluded = true
            }
        }
        }else if currentSelectedTag == 1 {
            if personItems.count > 0{
            if let item = personItems[selectedIndex] as? TNPerson{
            if !personsIds.contains(item.id.safeValue){
                isIncluded = false

            let nameVal = item.name.safeValue
            item.setRecipieValues(type: 0)
        
            selectedPersonItems.append(item)
            
            let word = nameVal
            if let lowerBound = word.range(of: "(")?.lowerBound {
                
                let cutWord = word.substring(to: lowerBound)
                selectedPersons.append("\(cutWord),")
                
            }
            else{
                selectedPersons.append(word + ",")
            }
            
            personsIds.append(item.id.safeValue)
            }
            else{
                isIncluded = true
            }
        }
        }
        }else if currentSelectedTag == 2{
            if personItems.count > 0{

            if let item = personItems[selectedIndex] as? TNPerson{
            
            let nameVal = item.name.safeValue
            if selectedPersonItems.count > 0{
                for each in selectedPersonItems{
                    if each.id == item.id{
                        isIncluded = true
                    }
                    else{
                        isIncluded = false
                        item.setRecipieValues(type: 1)
                        
                        selectedPersonItems.append(item)
                        
                        
                        let word = nameVal
                        if let lowerBound = word.range(of: "(")?.lowerBound {
                            
                            let cutWord = word.substring(to: lowerBound)
                            selectedPersonCC.append("\(cutWord),")
                            
                        }
                    }
                }
            }
            }
        }
        }
            else{
            if personItems.count > 0{

            if let item = personItems[selectedIndex] as? TNPerson{

                isIncluded = false
                item.setRecipieValues(type: 1)
                
                selectedPersonItems.append(item)
                
                let nameVal = item.name.safeValue

                let word = nameVal
                if let lowerBound = word.range(of: "(")?.lowerBound {
                    
                    let cutWord = word.substring(to: lowerBound)
                    selectedPersonCC.append("\(cutWord),")
                    
                }
            }
        }
    }
        }
    
    
    func checkFieldsEmpty() -> (Bool,String,Int){
        
        if groupView.text == ""{
            if groupView.placeholder == "Select Person"{
                groupView.searchResultHeight = 0.0
                groupView.minimumCharactersToSearch = 500

             return (true,"Sorry, Please select a person to reply.",0)
            }
            return (true,"Sorry, Please select a Group to send.",0)
        }
        else if personView.text == ""{
            if !personView.isHidden{
            guard let user = UserDefaultsManager.manager.getUserType() as? String else{
                
            }
            
            if user == UserType.parent.rawValue || user == UserType.student.rawValue{
                return (true,"Sorry, Please select a group or a person",1)
            }
   
        }
        }
   
        return (false,"",0)
    }

    @IBAction func attachmentAction(_ sender: UIButton) {
        if attachmentItems.count > 4 {
            _ = SweetAlert().showAlert("", subTitle: "You can only upload 5 attachments at a time", style: .warning)
        } else {
            let alertController = UIAlertController(title:nil, message: "Add Attachment", preferredStyle: .actionSheet)
            let galleryAction =  UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
                self.getImageFromImagPickerController()
            })
            let iCloudAction = UIAlertAction(title: "iCloud", style: .default, handler: { (action) in
                self.getDocumentsFromiCloud()
            })
            let cancelAction =  UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(galleryAction)
            alertController.addAction(iCloudAction)
            alertController.addAction(cancelAction)
            
            if UI_USER_INTERFACE_IDIOM() == .pad {
                if let currentPopoverPresentationController = alertController.popoverPresentationController {
                    currentPopoverPresentationController.sourceView = sender
                    currentPopoverPresentationController.sourceRect = sender.bounds
                    currentPopoverPresentationController.permittedArrowDirections = .any
                    present(alertController, animated: true, completion: nil)
                }
            } else {
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func getImageFromImagPickerController() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func getDocumentsFromiCloud(){
        let types = [kUTTypeText,
                     kUTTypePlainText,
                     kUTTypeUTF8PlainText,
                     kUTTypeUTF16ExternalPlainText,
                     kUTTypeUTF16PlainText,
                     kUTTypeDelimitedText,
                     kUTTypeCommaSeparatedText,
                     kUTTypeTabSeparatedText,
                     kUTTypeUTF8TabSeparatedText,
                     kUTTypePDF,
                     kUTTypeRTFD,
                     kUTTypeFlatRTFD,
                     kUTTypeTXNTextAndMultimediaData,
                     kUTTypeWebArchive,
                     kUTTypeImage,
                     kUTTypeJPEG,
                     kUTTypeJPEG2000,
                     kUTTypeTIFF,
                     kUTTypePICT,
                     kUTTypeGIF,
                     kUTTypePNG,
                     kUTTypeQuickTimeImage,
                     kUTTypeAppleICNS,
                     kUTTypeBMP,
                     kUTTypeICO,
                     kUTTypeRawImage,
                     kUTTypeScalableVectorGraphics,
                     //kUTTypeLivePhoto,
            kUTTypeAudiovisualContent,
            kUTTypeMovie,
            kUTTypeVideo,
            kUTTypeAudio,
            kUTTypeQuickTimeMovie,
            kUTTypeMPEG,
            kUTTypeMPEG2Video,
            kUTTypeMPEG2TransportStream,
            kUTTypeMP3,
            kUTTypeMPEG4,
            kUTTypeMPEG4Audio,
            kUTTypeAppleProtectedMPEG4Audio,
            kUTTypeAppleProtectedMPEG4Video,
            kUTTypeAVIMovie,
            kUTTypeAudioInterchangeFileFormat,
            kUTTypeWaveformAudio,
            kUTTypeMIDIAudio,
            kUTTypeSpreadsheet,
            kUTTypePresentation,
            kUTTypeDatabase,
            kUTTypeInkText,
            kUTTypeFont,
            kUTTypeBookmark,
            kUTType3DContent,
            kUTTypePKCS12]
        
        let importMenu = UIDocumentMenuViewController(documentTypes: types as [String], in: UIDocumentPickerMode.import)
        importMenu.delegate = self
        present(importMenu, animated: true, completion: nil)
    }
    
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController)
    {
        print("document selected \(documentPicker)")
        
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }

    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for each in urls {
            attachmentItems.append(each.absoluteString)
        }
        let tempArr = attachmentItems
        attachmentItems = removeDuplicates(array: tempArr)
        
        attachmentTb.reloadData()
    }
    
    func removeDuplicates(array: [String]) -> [String] {
        var encountered = Set<String>()
        var result: [String] = []
        for value in array {
            if encountered.contains(value) {
                // Do not add a duplicate element.
            }
            else {
                // Add value to the set.
                encountered.insert(value)
                // ... Append the value.
                result.append(value)
            }
        }
        return result
    }
    
    func showAlert(message : String){
        _ = SweetAlert().showAlert("", subTitle: message, style: .warning)
    }
    
    @IBAction func sendMailAction(_ sender: Any) {
       
        self.view.endEditing(true)
        groupView.resignFirstResponder()
        subjectTextField.resignFirstResponder()
        personView.resignFirstResponder()
        bccView.resignFirstResponder()
        editorView.resignFirstResponder()
        self.resignFirstResponder()
        var ftpUrls = [String]()
        if checkFieldsEmpty().0 != true{

            if attachmentItems.count > 0{
                for each in attachmentItems{
                   ftpUrls.append(each)
                }
            }
         self.checkForStudAndParent(fileUrls : ftpUrls)
        }else{
            SweetAlert().showAlert(kAppName, subTitle: checkFieldsEmpty().1, style: AlertStyle.error)
        }
    }
    
    func getUploadedAttachments(isUpload : Bool){
        
        if !isUpload {
            var msg = "Error in uploading attachments , Please try again later"
            self.stopLoadingAnimation()
            showAlert(message: msg)
        }
        else{
       sendMail()
        }
    }
    
    func sendMail() {
        let sendDict = self.getSendDictionary(isReply: isReplyMail)
        print("sending dictionary is :-",sendDict)
        let url = APIUrls().sendMail
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "",typingCountVal:typingCount, requestParameters: sendDict, completion: { (result) in
            if let statusCode = result["StatusCode"] as? Int {
                DispatchQueue.main.async {
                    if statusCode == 1 {
                        self.attachmentItems.removeAll()
                        self.groupView.text = ""
                        resultPaths.removeAll()
                        self.selectedPersonItems.removeAll()
                        self.view.endEditing(true)
                        self.stopLoadingAnimation()
                        _ = SweetAlert().showAlert("Success", subTitle: "Mail Sent", style: .success, buttonTitle: alertOk, action: { (index) in
                            if index {
                                self.groupIds.removeAll()
                                self.backAction(UIButton())
                            }
                        })
                    } else {
                        //  self.attachmentItems.removeAll()
                        self.stopLoadingAnimation()
                        self.view.endEditing(true)
                    }
                }
            } else {
                //  self.attachmentItems.removeAll()
                self.stopLoadingAnimation()
                self.view.endEditing(true)
            }
            print("sent mail response is \(result)")
            
        })
    }
    
    //MARK:- removeAutoCompleteOptionFromSuperView
    func removeAutoCompleteOptionFromSuperView() {
        let window = UIApplication.shared.keyWindow
        if let subViewArray = window?.subviews {
            for each in subViewArray {
                if each.tag == 1999999 {
                    each.isHidden =  true
                }
            }
        }
        self.resignFirstResponder()
    }
    
    
    func checkForStudAndParent(fileUrls: [String]){
        
        guard (UserDefaultsManager.manager.getUserType() as? String) != nil else { return }
        
       // if user == UserType.parent.rawValue || user == UserType.student.rawValue {
            if self.checkFieldsEmpty().2 == 1 {
            } else {
                self.startLoadingAnimation()
                if attachmentItems.count > 0 {
                    connectFtp(list : fileUrls)
                } else {
                    sendMail()
                }
            }
        }
    
    func checkUserTypeAndDoNeedful(){
        let _ = UserDefaultsManager.manager.getUserType()
    }
    
    
    func getUdidOfDevide() -> String {
        return  UIDevice.current.identifierForVendor!.uuidString
    }
    
    func findMyGroupId(name: String) -> String {
        if name != "" {
            if personItems != nil {
                if let persons = personItems as? [TNPerson] {
                    for each in persons {
                        if name == each.name{
                            return each.groupId.safeValue
                        }
                    }
                }
            }
        }
        return ""
    }
    
    func getSendDictionary(isReply : Bool) -> [String:Any] {
        var dictionary = [String: Any]()
        let userId  = UserDefaultsManager.manager.getUserId()
        let subjectValue = subjectTextField.text
        let bodyText = self.editorView.contentHTML
        dictionary["client_ip"] =  getUdidOfDevide()
        dictionary["UserId"] = userId
      //  if !isReply{
            dictionary["Recipients"] = self.getRecipients()
       // }
//        else{
//            var recipients = [[String: Any]]()
//            var recipient = [String:Any]()
//            recipient["UserId"] = obj?.senderId
//            recipient["Name"] = obj?.sender
//            recipient["RecipientType"] = 0
//            recipient["GroupId"] = findMyGroupId(name: (obj?.senderId.safeValue).safeValue)
//            recipients.append(recipient)
//            dictionary["Recipients"] = recipients
//        }
//         if titleText == "Reply"{
//            dictionary["GroupId"] = [findMyGroupId(name: (obj?.senderId.safeValue).safeValue)]
//        }
       //  else{
            let groups = groupIds
            dictionary["GroupId"] = groups
       // }

        dictionary["Subject"] = subjectValue
        dictionary["Message"] = bodyText.base64Encoded()
        dictionary["AttachIcon"] = attachments.count > 0 ? 1 : 0
        dictionary["Attachments"] = self.getAttachments()
        dictionary["ParentMsgId"] = parentMessageId
        dictionary["IsMobile"] = 1
        dictionary["frwdMsgId"] = forwardMsgIdValue

        print(dictionary)
        
        return dictionary
        
    }
    
    func getRecipients() -> [[String: Any]] {
        
        var recipients = [[String: Any]]()

       // if !isReplyMail{
        for item in selectedPersonItems {
            var recipient = [String:Any]()

            recipient["UserId"] = Int(item.id.safeValue)
            recipient["Name"] = item.name.safeValue
            recipient["RecipientType"] = item.recipieType.safeValueOfInt
            recipient["GroupId"] =  Int(item.groupId.safeValue)
            print("recipient :- ",recipient)
            recipients.append(recipient)

            }
      //  }
        
        return recipients
        
    }
    
    
    func getShortName(nameVal:String) -> String {
        
        let word = nameVal
        if let lowerBound = word.range(of: "(")?.lowerBound {
            
            let cutWord = word.substring(to: lowerBound)
            
            return cutWord
            
        }
        
        return ""
    }
    
    
    func getAttachments() -> [[String : String]] {
        
        var tempattachments = [[String : String]]()
        var tempAttachmnt = [String : String]()
        if resultPaths.count > 0 {
            for each in resultPaths {
                tempAttachmnt["LinkName"] = returnFileName(file: each)
                tempAttachmnt["Link"] = each
                tempattachments.append(tempAttachmnt)
            }
        }
        return tempattachments
    }
    
    func returnFileName(file : String) -> String {
        if file != "" {
            let url = URL(string : file)
            return (url?.lastPathComponent).safeValue
        } else {
            return ""
        }
    }
//        let arr = file.components(separatedBy: "rptzfileup/") as! [String]
//        if arr.count > 0{
//            for eachValue in arr{
//                if eachValue.contains(".pdf") ||  eachValue.contains(".docx") || eachValue.contains(".doc")||eachValue.contains(".jpeg") || eachValue.contains(".png") || eachValue.contains(".jpg") || eachValue.contains(".PDF") ||  eachValue.contains(".DOCX") || eachValue.contains(".DOC")||eachValue.contains(".JPEG") || eachValue.contains(".PNG") || eachValue.contains(".JPG") {
//                    return eachValue
//                }
//            }
//        }
//        }
//        return ""
//    }
    
    
    //GetFtpLocation Credebtilas
    
    func getFTPDetails() {		
        let url = APIUrls().getFTPUrls
        let userId  = UserDefaultsManager.manager.getUserId()
        var dictionary = [String: Any]()
        dictionary[UserIdKey().id] = userId
        dictionary[Communicate().isMobile] = 1
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "",typingCountVal:typingCount, requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                print("FTP location details details",result)
                UserDefaultsManager.manager.insertUserDefaultValue(value: result, key:DBKeys.FTPDetails)
            }
        }
    }
    
    func getGroups(text:String, completion: @escaping (_ result: [TNGroup]) -> Void) {
        
        var groupList = [TNGroup]()
        
        let userId  = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: String]()
        dictionary[UserIdKey().id] = userId
        dictionary[GetGroups().searchtext] = text
        
        let url = APIUrls().getGroups
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "",typingCountVal:typingCount,requestParameters: dictionary) { (result) in
            
            if let countVal = result["typingCount"] as? Int {
                if countVal  != typingCount { return }
            }
            
            print("get groups are :- ",dictionary)
            if let groups = result["Groups"] as? NSArray {
                if groups.count > 0 {
                    groupList = ModelClassManager.sharedManager.createModelArray(data: groups, modelType: ModelType.TNGroups) as! [TNGroup]
                    self.groupItems = groupList
                    DispatchQueue.main.async {
                        self.stopLoadingAnimation()
                        if self.groupItems.count > 0{
                            completion(self.groupItems)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.groupItems.removeAll()
                        self.stopLoadingAnimation()
                        completion(self.groupItems)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.groupItems.removeAll()
                    self.stopLoadingAnimation()
                    completion(self.groupItems)
                }
            }
        }
    }
    
    func getGroupmembers(text:String, completion: @escaping (_ result: [TNPerson]) -> Void) {
        var data: Array<AnyObject> = []

        let userId = UserDefaultsManager.manager.getUserId()
        
        let searchtext = text
        
        let stringWithCommas = (groupIds as NSArray).componentsJoined(by: ",")
        
        var dictionary = [String: Any]()
        dictionary[UserIdKey().id] = userId
        dictionary[Communicate().searchText] = searchtext
        dictionary[Communicate().groupId] = stringWithCommas
        
        let url = APIUrls().getGroupMembers
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "",typingCountVal:typingCount, requestParameters: dictionary) { (result) in
            
            if let countVal = result["typingCount"] as? Int{
                if countVal  != typingCount{return}
                
            }
            
            print("members : -",result)
            
            if let members = result["Members"] as? NSArray{
                
                if members.count > 0{
                let membersValues = ModelClassManager.sharedManager.createModelArray(data: members, modelType: ModelType.TNPerson) as! [TNPerson]
                
                self.personItems = membersValues
                
                DispatchQueue.main.async {
                  
                    if self.personItems.count > 0{
                        completion(self.personItems)
                        }
                    }
                    self.stopLoadingAnimation()
                
                }
                else{
                DispatchQueue.main.async {
                    self.personItems.removeAll()
                    self.stopLoadingAnimation()
                    completion(self.personItems)

                }
                }
            }
            else{
                DispatchQueue.main.async {
                    self.personItems.removeAll()
                    self.stopLoadingAnimation()
                    completion(self.personItems)

                }
            }
      
        }
    }
    
    
    //MARK:- toolbar delegate
    
    fileprivate func randomColor() -> UIColor {
        let colors: [UIColor] = [
            .red,
            .orange,
            .yellow,
            .green,
            .blue,
            .purple
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        // toolbar.editor?.insertImage("https://gravatar.com/avatar/696cf5da599733261059de06c4d1fe22", alt: "Gravatar")
        
        //
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
//        if toolbar.editor?.hasRangeSelection == true {
//            //     toolbar.editor?.insertLink("http://github.com/cjwirth/RichEditorView", title: "Github Link")
//        }
    }
    
    func setBorderColor(){
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    
    func deleteTheUser(tokenValue : KSToken,tokenView :KSTokenView ) -> String{
        var id = String()
        if tokenView == groupView{
            if groupItems.count > 0{
                var filter = groupItems.filter({ (group) -> Bool in
                    if group.name == "\(tokenValue)"{
                        id = group.id.safeValue
                        return true
                    }
                    return false
                })
            }
        }
        else{
            
        }
        return id
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
 
    func tokenView(_ tokenView: KSTokenView, willDeleteToken token: KSToken) {
    
        if token != nil{
          var deletedId =  deleteTheUser(tokenValue: token, tokenView: tokenView)
            if deletedId != ""{
                print(Int(deletedId))
                if groupIds.count > 0{
                    if groupIds.contains(Int(deletedId).safeValueOfInt){
                        var index = groupIds.firstIndex(of: (Int(deletedId)).safeValueOfInt)
                        groupIds.remove(at: index.safeValueOfInt)
                    }
                }
            }
            if seletedGroups.contains("\(token)"){
                var fullArr = seletedGroups.components(separatedBy: ",")
                if fullArr.count > 0{
                    for each in fullArr{
                        if each == "\(token)"{
                            let index = fullArr.firstIndex(of: each)
                            fullArr.remove(at: index.safeValueOfInt)
                        }
                    }
                }
                seletedGroups = fullArr.joined(separator: ",")
            }
        }
    }
    
        func tokenView(_ tokenView: KSTokenView, performSearchWithString string: String, completion: ((Array<AnyObject>) -> Void)?) {
            if tokenView == groupView{
                currentSelectedTag = 0
                getGroups(text: string, completion: { (groups) in
                    DispatchQueue.main.async {
                        var data: Array<String> = []
                        
                        for each in groups{
                            data.append(each.name.safeValue)
                        }
                        if data.count == 0{
                            tokenView.searchResultHeight = 0.0
                        }
                        else{
                            tokenView.searchResultHeight = 300.0
                        }
                        completion!(data as Array<AnyObject>)
                    }
                   
            })
            }
                
            else  if tokenView == personView || tokenView == bccView{
                currentSelectedTag = 1
                if tokenView == bccView{
                    currentSelectedTag = 2
                }
                getGroupmembers(text: string, completion: { (persons) in
                    DispatchQueue.main.async {

                    var data: Array<String> = []

                    for each in persons{
                        data.append(each.name.safeValue)
                    }
                    if data.count == 0{
                        tokenView.searchResultHeight = 0.0
                    }
                    else{
                        tokenView.searchResultHeight = 300.0
                    }
                    completion!(data as Array<AnyObject>)
                    }
                })
            }
         
        }
    
    func tokenView(_ tokenView: KSTokenView, displayTitleForObject object: AnyObject) -> String? {
            if !isIncluded {
                return object as? String
            } else {
              isIncluded  = false
              return nil
            }
        }
    
    func tokenView(_ tokenView: KSTokenView, didSelectRowAtIndexPath indexPath: IndexPath) {
        didSelelectItem(selectedIndex: indexPath.row)
    }
    
    func downloadPdfButtonAction(url: String, fileName: String?) {
        
    }
        
    func getBackToParentView(value: Any?, titleValue: String?) {
        
    }
    
    func deleteTheSelectedAttachment(index: Int) {
        if let item = attachmentItems[index] as? String{
            attachmentItems.remove(at: index)
            attachmentTb.reloadData()
        }
    }
    
    func getBackToTableView(value: Any?,tagValueInt : Int) {
        
    }
    
    func selectedPickerRow(selctedRow: Int) {
        
    }
    
    func popUpDismiss() {
        
    }
    func moveToComposeController(titleTxt: String,index : Int,tag: Int) {
        
    }
    
    func getSearchWithCommunicate(searchTxt: String, type: Int) {
    }
    
}

extension ComposeController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
	
        if let imageURL = info["UIImagePickerControllerImageURL"] as? URL {
            attachmentItems.append(imageURL.absoluteString)
        }
        let tempArr = attachmentItems
        attachmentItems = removeDuplicates(array: tempArr)
        attachmentTb.reloadData()
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ComposeController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if attachmentItems.count > 0{
            return attachmentItems.count
        }
        return 0
    }
    

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AttachCell", for: indexPath) as? AttachCell
        if attachmentItems.count > 0 {
            if let eachAttachmnt = attachmentItems[indexPath.row] as? String {
                let arr = eachAttachmnt.components(separatedBy: "Inbox/")
                if arr.count > 1 {
                    cell?.attachLabel.text = arr[1]
                } else {
                    let tmpDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
                    let tempArr = eachAttachmnt.components(separatedBy: tmpDirURL.absoluteString)
                    if tempArr.count > 1 {
                        cell?.attachLabel.text = tempArr[1]
                    }
                }
            }
        }
        cell?.selectionStyle = .none
        cell?.delegate = self
        cell?.closeButton.tag = indexPath.row
        attachmenyTBHeight.constant = tableView.contentSize.height
        return cell!
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

class AttachCell: UITableViewCell{
    var delegate : TaykonProtocol?
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var attachLabel: UILabel!
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.delegate?.deleteTheSelectedAttachment(index: sender.tag)
    }
    
}

class toEmailCell : UITableViewCell,UITextFieldDelegate{

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var icon: UIImageView!
  //  @IBOutlet weak var textFieldView: KSTokenView!
    
    var delegate : TaykonProtocol?
    var typeString = ""
    var currentText  = ""
    var groupList = [TNGroup]()

    override func awakeFromNib() {
        textField.delegate = self
    }
    
    @IBAction func editingBegin(_ sender: UITextField) {
        currentText  = ""
        typingCount += 1
    }
    

    


    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func editingChangedAction(_ sender: Any) {

    }
    
}

extension ComposeController{
    func connectFtp(list : [String]){
        if let ftpDetails = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.FTPDetails) as? NSDictionary{
            fileUpload.delegate = self
            fileUpload.upload(attachments: list )
    }
    }

    


}
class SuggestionCell: UITableViewCell{
    @IBOutlet weak var ttitleLabel: UILabel!
    
    
}



// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}


extension ComposeController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        self.view.endEditing(true)
        groupView.resignFirstResponder()
        subjectTextField.resignFirstResponder()
        personView.resignFirstResponder()
        bccView.resignFirstResponder()
        editorView.resignFirstResponder()
        self.resignFirstResponder()
        var ftpUrls = [String]()
        if checkFieldsEmpty().0 != true{

            if attachmentItems.count > 0{
                for each in attachmentItems{
                   ftpUrls.append(each)
                }
            }
         self.checkForStudAndParent(fileUrls : ftpUrls)
        }else{
            SweetAlert().showAlert(kAppName, subTitle: checkFieldsEmpty().1, style: AlertStyle.error)
        }
    }
    
    func searchButtonClicked(_ button: UIButton) {
        if attachmentItems.count > 4 {
            _ = SweetAlert().showAlert("", subTitle: "You can only upload 5 attachments at a time", style: .warning)
        } else {
            let alertController = UIAlertController(title:nil, message: "Add Attachment", preferredStyle: .actionSheet)
            let galleryAction =  UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
                self.getImageFromImagPickerController()
            })
            let iCloudAction = UIAlertAction(title: "iCloud", style: .default, handler: { (action) in
                self.getDocumentsFromiCloud()
            })
            let cancelAction =  UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(galleryAction)
            alertController.addAction(iCloudAction)
            alertController.addAction(cancelAction)
            
            if UI_USER_INTERFACE_IDIOM() == .pad {
                if let currentPopoverPresentationController = alertController.popoverPresentationController {
                    currentPopoverPresentationController.sourceView = button
                    currentPopoverPresentationController.sourceRect = button.bounds
                    currentPopoverPresentationController.permittedArrowDirections = .any
                    present(alertController, animated: true, completion: nil)
                }
            } else {
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}
