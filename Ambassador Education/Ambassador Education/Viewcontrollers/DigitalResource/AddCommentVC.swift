//
//  AddCommentVC.swift
//  Ambassador Education
//
//  Created by Jashu Prajapati on 07/12/21.
//  Copyright © 2021 InApp. All rights reserved.
//

import UIKit
import MobileCoreServices

class AddCommentVC: UIViewController,TaykonProtocol,UIDocumentMenuDelegate,UIDocumentPickerDelegate {
    func getBackToTableViewS(value: Any?, tagValueInt: Int) {
        
    }
    
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
        
    }
    
    func moveToComposeController(titleTxt: String, index: Int, tag: Int) {
        
    }
    
    func getSearchWithCommunicate(searchTxt: String, type: Int) {
        
    }
    
    func getUploadedAttachments(isUpload: Bool, isForDraft: Bool) {
        
    }
    
    
    @IBOutlet weak var lblChooseFile: UILabel!
    @IBOutlet weak var txtViewComment: UITextView!
    @IBOutlet weak var lblCommentPH: UILabel!
    
    var delegate : TaykonProtocol?
    var strSubject : String = ""
    var strID : String = ""
    var strDId : String = ""
    var attachmentTypes: [AttachmentType] = []
    var weeklyPlan : WeeklyPlanList?
    var fileUpload = FTPUpload()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getFTPDetails()
        
        // Do any additional setup after loading the view.
    }
    func getUdidOfDevide() -> String {
        return  UIDevice.current.identifierForVendor!.uuidString
    }
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
    func getSendDictionary() -> [String:Any] {
        var dictionary = [String: Any]()
        let userId  = UserDefaultsManager.manager.getUserId()
        let bodyText = self.txtViewComment.text
        dictionary["UserId"] = userId
        dictionary["groups_status"] = "0"
        dictionary["UserName"] = ""
        dictionary["weeklyplanmodule"] = ""
        dictionary["weeklyplansubject"] = self.weeklyPlan?.topic
        dictionary["weeklyplandate"] = self.weeklyPlan?.date
        //        "weeklyplandate":"Tuesday October 27th 2020",
        dictionary["weeklyplandesc"] = ""
        dictionary["AttachIcon"] = attachmentTypes.count > 0 ? 1 : 0
        dictionary["Comments"] = bodyText
        dictionary["divisionId"] = strDId
        dictionary["fdate"] = self.weeklyPlan?.date
        dictionary["weeklyplanID"] = self.weeklyPlan?.id
        dictionary["ParentMsgId"] = 0
        dictionary["IsMobile"] = 1
        dictionary["client_ip"] =  getUdidOfDevide()
        dictionary["Attachments"] = self.getAttachments()
        print(dictionary)
        return dictionary
    }
    func getAttachments() -> [[String : String]] {
        
        var tempattachments = [[String : String]]()
        var tempAttachmnt = [String : String]()
        if attachmentTypes.count > 0 {
            for each in attachmentTypes {
                tempAttachmnt["LinkName"] = returnFileName(file: each.attachmentItem)
                tempAttachmnt["Link"] = each.attachmentItem
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
            addItemIfUnique(type: "iCloud", attachmentItem: each.absoluteString)
        }
        self.lblChooseFile.text = "\(attachmentTypes.count) file is attached"
        //        attachmentTb.reloadData()
    }
    
    func addItemIfUnique(type: String, attachmentItem: String) {
        let newAttachment = AttachmentType(type: type, attachmentItem: attachmentItem)
        
        // Check if the attachmentItem already exists in the array
        if !attachmentTypes.contains(where: { $0.attachmentItem == attachmentItem }) {
            attachmentTypes.append(newAttachment)
        } else {
            print("Attachment item \(attachmentItem) already exists.")
        }
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
    
    @IBAction func btnSelectFile(_ sender: UIButton) {
        self.txtViewComment.resignFirstResponder()
        if attachmentTypes.count > 4 {
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
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        self.txtViewComment.resignFirstResponder()
        if self.txtViewComment.text == "" {
            _ = SweetAlert().showAlert("", subTitle: "Please enter comment", style: .warning)
            return
        }
        var ftpUrls = [String]()
        if attachmentTypes.count > 0 {
            for each in attachmentTypes {
                ftpUrls.append(each.attachmentItem)
            }
        }
        if attachmentTypes.count > 0 {
            connectFtp(list : ftpUrls)
        }
        let sendDict = self.getSendDictionary()
        print("sending dictionary is :-",sendDict)
        let url = APIUrls().weeklyPlanComment
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "",typingCountVal:typingCount, requestParameters: sendDict, completion: { (result) in
            if let statusCode = result["StatusCode"] as? Int {
                DispatchQueue.main.async {
                    if statusCode == 1 {
                        self.view.endEditing(true)
                        self.stopLoadingAnimation()
                        _ = SweetAlert().showAlert("Success", subTitle: "\(result["StatusMessage"]!)", style: .success, buttonTitle: alertOk, action: { (index) in
                            if index {
                                self.dismissPopUpViewController()
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
    func connectFtp(list : [String]){
        if let ftpDetails = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.FTPDetails) as? NSDictionary{
            fileUpload.delegate = self
            fileUpload.upload(attachments: attachmentTypes )
        }
    }
}
extension AddCommentVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let imageURL = info["UIImagePickerControllerImageURL"] as? URL {
            addItemIfUnique(type: "Gallery", attachmentItem: imageURL.absoluteString)
        }
        
        //        attachmentTb.reloadData()
        self.lblChooseFile.text = "\(attachmentTypes.count) file is atteched"
        picker.dismiss(animated: true, completion: nil)
    }
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        self.lblCommentPH.isHidden = newText.count != 0
        return true
    }
}
