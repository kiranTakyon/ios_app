//
//  UploadFTP.swift
//  Ambassador Education
//
//  Created by "" Kp on 14/09/17.
//  Copyright © 2017 "". All rights reserved.
//


import Foundation
import CFNetwork
import UIKit
import WebKit
import Zip

var resultPaths = [String]()

class FTPUpload {
    
    var delegate : TaykonProtocol?
    var dataObj = NSMutableDictionary()
    
    func upload(attachments : [AttachmentType], isForDraft: Bool = false) {
        resultPaths.removeAll()
        if let ftpDetails = UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.FTPDetails) as? NSDictionary {
            if attachments.count > 0 {
                for each in attachments {
                    var fileName = ""
                    let arr = each.attachmentItem.components(separatedBy: "Inbox/")
                    if arr.count > 1 {
                        fileName = arr[1]
                    } else {
                        let tmpDirURL = URL(fileURLWithPath: NSTemporaryDirectory())
                        let tempArr = each.attachmentItem.components(separatedBy: tmpDirURL.absoluteString)
                        if tempArr.count > 1 {
                            fileName = tempArr[1]
                        }
                    }
                    
                    if each.type == "Gallery" {
                        dataRequest(urlweb: each.attachmentItem, str: fileName, detail: ftpDetails, completion: { (success) in
                            if success {
                                if self.dataObj.count == attachments.count {
                                    self.uploadAttachmentsData(detail:  ftpDetails, isForDraft: isForDraft)
                                }
                            } else {
                                
                            }
                        })
                    } else {
                        convertIcloudImageIntoData(url: each.attachmentItem, key: fileName) { [weak self] (success) in
                            
                            if success {
                                if self?.dataObj.count == attachments.count {
                                    self?.uploadAttachmentsData(detail:  ftpDetails, isForDraft: isForDraft)
                                }
                            }
                        }
                    }
                }
            }
        } else {
            self.delegate?.getUploadedAttachments(isUpload: false, isForDraft: isForDraft)
        }
    }
    
    func convertDataFromImage(image : UIImage) -> Data {
        if let data = image.jpegData(compressionQuality: 0.1) {
            return data
        }
        return Data()
    }
    
    func dataRequest(urlweb: String, str : String, detail: NSDictionary, completion: @escaping (_ success: Bool) -> Void) {
        
        switch str.lastWord {
        case "jpg","jpeg","png","JPG","JPEG","PNG":
            let url = URL(string : urlweb)
            let data = NSData(contentsOf: url!)
            if let dataValue = data as Data? {
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
    
    func uploadAttachmentsData(detail : NSDictionary, isForDraft: Bool = false){
        if  let username = detail["UserName"] as? String{
            let password = detail["Password"] as? String
            let serverHost = detail["Server"] as? String
            let serverPath = detail["ServerPath"] as? String
            
            let pass =  (password?.base64Decoded().safeValue).safeValue
            checkValues(credentials : detail,isForDraft: isForDraft)
        } else {
            self.delegate?.getUploadedAttachments(isUpload: false, isForDraft: isForDraft)
        }
    }
    
    func checkValues(credentials : NSDictionary, isForDraft: Bool = false){
        
        if  let username = credentials["UserName"] as? String {
            let password = credentials["Password"] as? String
            let serverHost = credentials["Server"] as? String
            let serverPath = credentials["ServerPath"] as? String
            
            let pass =  (password?.base64Decoded().safeValue).safeValue
            let uploadManager = FTPUploadHelper(baseUrl: serverHost.safeValue, userName: username, password: pass, directoryPath: "")
            
            if dataObj.count > 0 {
                for each in dataObj {
                    uploadManager.send(data: each.value as! Data, with: each.key as! String) { (success) in
                        DispatchQueue.main.async {
                            if success{
                                let path =  serverPath.safeValue + "\(each.key as! String)"
                                print("Successfully uploaded file",each.key)
                                resultPaths.append(path )
                                if resultPaths.count == self.dataObj.count {
                                    self.dataObj.removeAllObjects()
                                    self.delegate?.getUploadedAttachments(isUpload : true, isForDraft: isForDraft)
                                }
                            } else {
                                self.delegate?.getUploadedAttachments(isUpload : false, isForDraft: isForDraft)
                            }
                        }
                        
                    }
                }
            } else {
                self.delegate?.getUploadedAttachments(isUpload : true, isForDraft: isForDraft)
            }
        }
    }
    
}


extension FTPUpload {
    
    func fetchIcloudData(from url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to fetch image:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }
    
    func compressImage(from image: UIImage, completion: @escaping (Data?) -> Void) {
        
        guard let compressedData = image.jpegData(compressionQuality: 0.1) else {
            completion(nil)
            return
        }
        completion(compressedData)
        
    }
    
    func convertIcloudImageIntoData(url: String, key: String, completion: @escaping (_ success: Bool) -> Void) {
        
        if let imageUrl = URL(string: url) {
            
            
            
            switch imageUrl.pathExtension.lowercased() {
                
            case "jpg", "jpeg", "png", "gif", "JPG", "JPEG", "PNG":
                DispatchQueue.global().async { [weak self] in
                    self?.fetchIcloudData(from: imageUrl) { [weak self] data in
                        guard let data = data else {
                            completion(false)
                            return
                        }
                        DispatchQueue.main.async {
                            if let image = UIImage(data: data) {
                                self?.compressImage(from: image) { [weak self] data in
                                    if let imageData = data {
                                        self?.dataObj.setValue(imageData, forKey: key)
                                        completion(true)
                                    } else {
                                        completion(false)
                                    }
                                }
                            } else {
                                completion(false)
                            }
                        }
                    }
                }
            default:
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                
                let destinationURL = documentsDirectory.appendingPathComponent(key.firstWord + ".zip")
                
                // Compress the picked document
                //                let success = SSZipArchive.createZipFile(atPath: destinationURL.path, withFilesAtPaths: [imageUrl.path])
                
                let success = createZipArchive(urls: [imageUrl], destinationURL: destinationURL)
                
                if success {
                    DispatchQueue.global().async { [weak self] in
                        self?.fetchIcloudData(from: destinationURL) { [weak self] data in
                            guard let data = data else {
                                completion(false)
                                return
                            }
                            self?.dataObj.setValue(data, forKey: key)
                            completion(true)
                        }
                    }
                } else {
                    completion(false)
                }
                
            }
        }
    }
    
    func createZipArchive(urls: [URL], destinationURL: URL) -> Bool {
        do {
            // Remove existing zip file if exists
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            // Create a new zip file
            try Zip.zipFiles(paths: urls, zipFilePath: destinationURL, password: nil, progress: nil)
            
            return true
        } catch {
            print("Error creating zip archive: \(error)")
            return false
        }
    }
    
}
