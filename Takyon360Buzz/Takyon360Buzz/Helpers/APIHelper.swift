





//
//  RusscompAPIHelper.swift
//  Ruscomp
//
//  Created by Drishya on 30/05/16.
//  Copyright © 2016 //. All rights reserved.
//

import Foundation
import UIKit

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
    
    func apiCallHandler(_ originalUrl: String, requestType: MethodType,requestString:String,typingCountVal:Int = 0, requestParameters: [String : Any], completion: @escaping (_ result: NSDictionary,_ data: NSData) -> Void) {
        
        if Reachability.isConnectedToInternet() == true {
            
            print("original url = \(originalUrl)")
            var requestTypeString = String()
            
            requestTypeString = requestType.rawValue
            
            let completeUrl = BaseUrl + originalUrl
            
            let inputUrlString = completeUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
            
            guard let url = URL(string: inputUrlString!) else{
                print("Error in creating url")
                return
            }
            
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = requestTypeString
            
            var baseAuth = ""
            
            if originalUrl.contains("LOGIN"){
            
             baseAuth = self.getBasicAuth(dictionary: requestParameters)
                BaseAuthValue = baseAuth
                
            }else{
                
                baseAuth = BaseAuthValue
            }
            
                request.setValue("Basic \(baseAuth)", forHTTPHeaderField: "authorization")
          //  }
            
            
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            

       
            if let theJSONData = try? JSONSerialization.data(
                withJSONObject: requestParameters,
                options: []) {
                let theJSONText = String(data: theJSONData,
                                         encoding: .ascii)
                print("JSON string = \(theJSONText!)")
            }

            
            if requestParameters.count > 0 {
                do {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: requestParameters, options: JSONSerialization.WritingOptions.prettyPrinted) as Data
                    request.httpBody = jsonData
                }
                catch _ {
                    completion(["StatusMessage" : []], NSData())
                }
            }
            
            if requestString != "" {

                let jsonData = requestString.data(using: String.Encoding.utf8, allowLossyConversion: false)
                request.httpBody = jsonData 
            }
            
            
            let urlconfig = URLSessionConfiguration.default
            urlconfig.timeoutIntervalForRequest = 05
            urlconfig.timeoutIntervalForResource = 10
            let session = URLSession.shared

         //   request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
            
            
            let dataTask = session.dataTask(with: request as URLRequest) {data,response,error in
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("reposense code",httpResponse.statusCode)
                    

                    do {
                        guard let data = data else {
                            completion([JsonKeys().message : "Some error occured . Please try again"], NSData())
                            throw JSONError.NoData
                        }
                        // print(response)
                        // let datastring = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                            completion([JsonKeys().message : []], NSData())
                            throw JSONError.ConversionFailed
                        }
                        if let theJSONData = try? JSONSerialization.data(
                            withJSONObject: json,
                            options: []) {
                            let theJSONText = String(data: theJSONData,
                                                     encoding: .ascii)
                            print("JSON response string = \(theJSONText!)")
                        }

                        print(json)
                        if originalUrl.contains("authorize.net"){
                            completion(json, data as NSData)
                        }
                        else{
                            
                           
                     //   let typingDict = NSDictionary(object: typingCountVal, forKey: "typingCount" as NSCopying)
                            
                            let combinedDict = NSMutableDictionary(dictionary: json)
                            combinedDict["typingCount"] = typingCountVal
                            
                            print("combined dict is :",combinedDict)
                            
                            let staticDict = NSDictionary(dictionary: combinedDict)
                            
                            
                            completion(staticDict,convertedToDataFromDict(dict: staticDict) as! NSData)
                            }
                        
                    } catch let error as JSONError {
                        completion([JsonKeys().message : "Json error occured . Please try again"], NSData())
                        print(error.rawValue)
                    } catch let error as NSError {
                        completion([JsonKeys().message :"Json error occured . Please try again"], NSData())
                        print("Error = \(error.debugDescription)")
                    }

               // }
                
            }
            else{
                    completion([JsonKeys().message :"Some error occured . Please try again"], NSData())
             }
            
            }
            dataTask.resume()
        }
        else{
            completion([JsonKeys().message :"No Internet Connection"], NSData())
        }
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
