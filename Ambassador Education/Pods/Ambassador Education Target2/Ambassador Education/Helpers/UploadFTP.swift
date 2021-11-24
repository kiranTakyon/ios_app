//
//  UploadFTP.swift
//  Ambassador Education
//
//  Created by "" Kp on 14/09/17.
//  Copyright © 2017 "". All rights reserved.
//


import Foundation
import CFNetwork
import  UIKit

var resultPaths = [String]()

class FTPUpload {
    
    var delegate : TaykonProtocol?
    var dataObj = NSMutableDictionary()
    
    func upload(attachments : [String]) {
        resultPaths.removeAll()
        if let ftpDetails = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.FTPDetails) as? NSDictionary {
            if attachments.count > 0 {
                for each in attachments {
                    var fileName = ""
                    let arr = each.components(separatedBy: "Inbox/")
                    if arr.count > 1 {
                        fileName = arr[1]
                    } else {
                        let tmpDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
                        let tempArr = each.components(separatedBy: tmpDirURL.absoluteString)
                        if tempArr.count > 1 {
                            fileName = tempArr[1]
                        }
                    }
                    dataRequest(urlweb: each, str: fileName, detail: ftpDetails, attach: attachments, completion: { (success) in
                        if success {
                            if self.dataObj.count == attachments.count {
                                self.uploadAttachmentsData(detail:  ftpDetails)
                            }
                        }
                        else {
                            
                        }
                    })
                }
            }
        }
        else{
            self.delegate?.getUploadedAttachments(isUpload: false)
        }
    }
    
    func convertDataFromImage(image : UIImage) -> Data{
        if image != nil{
            let data = UIImageJPEGRepresentation(image, 0.1)
            return data!
        }
        return Data()
    }
    
    func dataRequest(urlweb: String, str : String, detail: NSDictionary, attach : [String], completion: @escaping (_ success: Bool) -> Void) {
        
        switch str.lastWord{
        case "jpg","jpeg","png","JPG","JPEG","PNG":
            let url = URL(string : urlweb)
            let data = NSData(contentsOf: url!)
            if let dataValue = data as? Data {
                let image = UIImage(data: dataValue)
                let convertedData = convertDataFromImage(image : image!)
                self.dataObj.setValue(convertedData, forKey: str)
            }
            completion(true)
            
        default:
            let urlStr = URL(string : urlweb)
            let requestURL: URL = urlStr!
            let urlRequest: URLRequest = URLRequest(url: requestURL)
            let session = URLSession.shared
            let task = session.dataTask(with: urlRequest) {
                (data, response, error) -> Void in
                DispatchQueue.main.async {
                    if error == nil {
                        self.dataObj.setValue(data, forKey: str)
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
            task.resume()
        }
        
        
    }
    
    
    
    func uploadAttachmentsData(detail : NSDictionary){
        if  let username = detail["UserName"] as? String{
            let password = detail["Password"] as? String
            let serverHost = detail["Server"] as? String
            let serverPath = detail["ServerPath"] as? String
            
            let pass =  (password?.base64Decoded().safeValue).safeValue
            checkValues(credentials : detail)
        } else {
            self.delegate?.getUploadedAttachments(isUpload: false)
        }
    }
    
    func checkValues(credentials : NSDictionary){
        
        if  let username = credentials["UserName"] as? String{
            let password = credentials["Password"] as? String
            let serverHost = credentials["Server"] as? String
            let serverPath = credentials["ServerPath"] as? String
            
            let pass =  (password?.base64Decoded().safeValue).safeValue
            let uploadManager = FTPUploadHelper(baseUrl: serverHost.safeValue, userName: username, password: pass, directoryPath: "")
            
            if dataObj.count > 0{
                for each in dataObj{
                    uploadManager.send(data: each.value as! Data, with: each.key as! String) { (success) in
                        DispatchQueue.main.async {
                            if success{
                                let path =  serverPath.safeValue + "\(each.key as! String)"
                                print("Successfully uploaded file",each.key)
                                resultPaths.append(path as! String)
                                if resultPaths.count == self.dataObj.count {
                                    self.dataObj.removeAllObjects()
                                    self.delegate?.getUploadedAttachments(isUpload : true)
                                }
                            }
                            else{
                                self.delegate?.getUploadedAttachments(isUpload : false)
                            }
                        }
                        
                    }
                }
            }
                
            else{
                self.delegate?.getUploadedAttachments(isUpload : true)
            }
        }
    }
    
}




