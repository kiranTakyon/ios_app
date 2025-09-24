





//
//  RusscompAPIHelper.swift
//  Ruscomp
//
//  Created by Drishya on 30/05/16.
//  Copyright © 2016 //. All rights reserved.
//

import Foundation
import UIKit
import WebKit
var tokenExpire = Bool()
var BaseAuthValue = ""

enum JSONError: String, Error {
    case NoData = "ERROR: no data"
    case ConversionFailed = "ERROR: conversion from JSON failed"
    
}

enum MethodType : String {
    case GET = "GET"
    case POST = "POST"
}

class APIHelper {
    
    static let sharedInstance = APIHelper()
    
    private func prettyJSONString(_ obj: Any) -> String {
        guard JSONSerialization.isValidJSONObject(obj),
              let data = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
              let str = String(data: data, encoding: .utf8) else {
            return String(describing: obj)
        }
        return str
    }

    private func dumpHeaders(_ headers: [AnyHashable: Any]?) -> String {
        guard let headers = headers, !headers.isEmpty else { return "(none)" }
        return headers.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
    }

    private func makeCurl(_ request: URLRequest) -> String {
        var parts = ["curl -i"]
        if let method = request.httpMethod { parts.append("-X \(method)") }
        request.allHTTPHeaderFields?.forEach { k, v in parts.append("-H '\(k): \(v)'") }
        if let body = request.httpBody, let bodyStr = String(data: body, encoding: .utf8) {
            parts.append("--data '\(bodyStr.replacingOccurrences(of: "'", with: "'\\''"))'")
        }
        if let url = request.url?.absoluteString { parts.append("'\(url)'") }
        return parts.joined(separator: " ")
    }
    func apiCallHandler(_ originalUrl: String,
                           requestType: MethodType,
                           requestString: String,
                           typingCountVal: Int = 0,
                           requestParameters: [String : Any],
                           completion: @escaping (_ result: NSDictionary) -> Void) {
           
           guard Reachability.isConnectedToInternet() else {
               completion([JsonKeys().message :"No Internet Connection"])
               return
           }
           
           print("🌐 [API CALL] original url = \(originalUrl)")
           
           let completeUrl = BaseUrl + originalUrl
           guard let url = URL(string: completeUrl.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? "") else {
               print("❌ Error in creating url")
               return
           }
           
           let request = NSMutableURLRequest(url: url)
           request.httpMethod = requestType.rawValue
           
           // --- Auth logic (kept same as your code) ---
           var baseAuth = ""
           if originalUrl.contains("_LOGIN") || originalUrl.contains("LOGIN") {
               baseAuth = self.getBasicAuth(dictionary: requestParameters)
               BaseAuthValue = baseAuth
           } else if originalUrl.contains("T0048") {
               baseAuth = self.getBasicAuthForForgotPassword(dictionary: requestParameters)
               BaseAuthValue = baseAuth
           } else {
               baseAuth = BaseAuthValue
           }
           
           request.setValue("Basic \(baseAuth)", forHTTPHeaderField: "authorization")
           request.setValue("application/json", forHTTPHeaderField: "Content-Type")
           
           // --- Body ---
           if requestParameters.count > 0 {
               request.httpBody = try? JSONSerialization.data(withJSONObject: requestParameters, options: .prettyPrinted)
           }
           if !requestString.isEmpty {
               request.httpBody = requestString.data(using: .utf8)
           }
           
           // --- Log full REQUEST ---
           print("🛰️ [REQUEST] \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")")
           print("🧾 [HEADERS]\n\(dumpHeaders(request.allHTTPHeaderFields))")
           if let body = request.httpBody, let bodyStr = String(data: body, encoding: .utf8) {
               print("📦 [BODY]\n\(bodyStr)")
           } else {
               print("📦 [BODY]\n(none)")
           }
           print("🧪 [cURL]\n\(makeCurl(request as URLRequest))")
           
           // --- URLSession ---
           let session = URLSession.shared
           let dataTask = session.dataTask(with: request as URLRequest) { data, response, error in
               
               // --- Log full RESPONSE ---
               if let httpResponse = response as? HTTPURLResponse {
                   print("📡 [RESPONSE] Status: \(httpResponse.statusCode)")
                   print("🧾 [RESPONSE HEADERS]\n\(self.dumpHeaders(httpResponse.allHeaderFields))")
               } else {
                   print("📡 [RESPONSE] (no HTTPURLResponse)")
               }
               
               if let data = data {
                   if let rawText = String(data: data, encoding: .utf8) {
                       print("📨 [RESPONSE BODY RAW]\n\(rawText)")
                   } else {
                       print("📨 [RESPONSE BODY RAW] (binary or non-utf8, \(data.count) bytes)")
                   }
               } else {
                   print("📨 [RESPONSE BODY RAW] (none)")
               }
               
               // --- Parse JSON as before ---
               do {
                   guard let data = data else {
                       completion([JsonKeys().message : "Some error occured . Please try again"])
                       throw JSONError.NoData
                   }
                   
                   guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                       completion([JsonKeys().message : []])
                       throw JSONError.ConversionFailed
                   }
                   
                   print("🧩 [RESPONSE BODY JSON]\n\(self.prettyJSONString(json))")
                   
                   if originalUrl.contains("authorize.net") {
                       completion(json)
                   } else {
                       let combinedDict = NSMutableDictionary(dictionary: json)
                       combinedDict["typingCount"] = typingCountVal
                       completion(NSDictionary(dictionary: combinedDict))
                   }
                   
               } catch {
                   completion([JsonKeys().message :"Json error occured . Please try again"])
                   print("❌ JSON Parse Error: \(error.localizedDescription)")
               }
           }
           dataTask.resume()
       }
    
    func postmanCall(){
        
        let headers = [
            "content-type": "application/json",
            
            ]
        let parameters = [
            "Password": "e10adc3949ba59abbe56e057f20f883e",
            "UserName": "AKAP4449",
            "Language": "English"
            ] as [String : Any]
        
        var postData : Data?
        
        do{
            postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        }catch{
            
        }
        let request = NSMutableURLRequest(url: NSURL(string: "http://lasagu.net/school/T360Api/LOGIN")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData!
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            
            if (error != nil) {
                print(error ?? "")
                
            } else {
                let httpResponse = response as? HTTPURLResponse
                print(httpResponse ?? 200)
                
                let theJSONText = String(data: data!,
                                         encoding: .ascii)
                print("JSON response string = \(theJSONText!)")
            }
        })
        
        dataTask.resume()
    }
    
    func getBasicAuth(dictionary:[String:Any]) -> String{
        
        
        let username = dictionary[LogInKeys().username] as! String
        let password = dictionary[LogInKeys().password] as! String
        /* let md5Data = MD5(string:username)
         let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
         let md5Password = md5Hex */
        
        
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        return base64LoginString
    }
    
    func getBasicAuthForForgotPassword(dictionary:[String:Any]) -> String{
        
        
         let username = "TakAdmin"//dictionary["UserName"] as! String
       // let email = dictionary["VEmail"] as! String
         let password = "1dfec5f317bf845120dfc030b0b385e8"
        /* let md5Data = MD5(string:password)
         let md5Hex =  md5Data.map { String(format: "%02hhx", $0) }.joined()
         let md5Password = md5Hex*/
        
        
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        return base64LoginString
    }
    
    /*  func goToRoot(){
     DispatchQueue.main.async {
     DataManager().removeAllUserDefaults()
     tokenExpire = true
     let appDelegate = UIApplication.shared.delegate
     let mainStoryboard: UIStoryboard = UIStoryboard(name: mainStoryBoard, bundle: nil)
     let loginVC = mainStoryboard.instantiateViewController(withIdentifier: ViewControllerID().loginRootID) as! RPResidentNavigationController
     appDelegate?.window??.rootViewController = loginVC
     appDelegate?.window??.makeKeyAndVisible()
     }
     } */
    
    
}
