





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
    
    func apiCallHandler(_ originalUrl: String, requestType: MethodType,requestString:String,typingCountVal:Int = 0, requestParameters: [String : Any], isRefreshToken: Bool = false, completion: @escaping (_ result: NSDictionary) -> Void) {
        
        if Reachability.isConnectedToInternet() == true {
            
            print("original url = \(originalUrl)")
            var requestTypeString = String()
            
            requestTypeString = requestType.rawValue
            
            var completeUrl = BaseUrl + originalUrl
            if ["CHALLANGESPROGRESS", "QUIZPROGRESS", "FUELMETER", "JOURNEYPROGRESS"].contains(originalUrl) {
                completeUrl = DashboardBaseUrl + originalUrl
            }
            print("Complete url = \(completeUrl)")

            let inputUrlString = completeUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)
            
            guard let url = URL(string: inputUrlString!) else {
                print("Error in creating url")
                return
            }
            
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = requestTypeString
            
            var baseAuth = ""
            if originalUrl.contains("_LOGIN") {
                baseAuth = self.getBasicAuth(dictionary: requestParameters)
            } else {
                if originalUrl.contains("LOGIN") {
                    baseAuth = self.getBasicAuth(dictionary: requestParameters)
                } else if originalUrl.contains("T0048") {
                    baseAuth = self.getBasicAuthForForgotPassword(dictionary: requestParameters)
                } else {
                    baseAuth = UserDefaultsManager.manager.getSessionToken() ?? "" /// send session token
                }
            }
            
            print("Basic \(baseAuth)")
            if originalUrl.contains("T0048") || originalUrl.contains("LOGIN") {
                request.setValue("Basic \(baseAuth)", forHTTPHeaderField: "authorization")
            } else if ["CHALLANGESPROGRESS", "QUIZPROGRESS", "FUELMETER", "JOURNEYPROGRESS"].contains(originalUrl) {
                baseAuth = self.getBasicAuthForProgressAPI()
                request.setValue("Basic \(baseAuth)", forHTTPHeaderField: "authorization")
            } else {
                request.setValue("Bearer \(baseAuth)", forHTTPHeaderField: "Authorization")
            }

            //  }
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            /*     if let token = UserDefaultsManager.manager.getUserDefaultValue(key: UserDefaultKeys().AccessToken){
             request.setValue(token as! String, forHTTPHeaderField: "Authorization")
             print("access token set")
             } */
            
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
                    completion(["StatusMessage" : []])
                }
            }
            
            if requestString != "" {
                
                let jsonData = requestString.data(using: String.Encoding.utf8, allowLossyConversion: false)
                request.httpBody = jsonData
            }
            
            
            let urlconfig = URLSessionConfiguration.default
            urlconfig.timeoutIntervalForRequest = 300
            urlconfig.timeoutIntervalForResource = 1000
            let session = URLSession.shared
            
            //   request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
            
            
            let dataTask = session.dataTask(with: request as URLRequest) {data,response,error in
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("reposense code", httpResponse.statusCode)

                    if httpResponse.statusCode == 401  && !isRefreshToken { // Unauthorized, token might be expired
                        self.refreshToken { success in
                            if success {
                                // Retry the original request
                                self.apiCallHandler(originalUrl, requestType: requestType, requestString: requestString, typingCountVal: typingCountVal, requestParameters: requestParameters,isRefreshToken: true, completion: completion)
                            } else {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SessionExpired"), object: nil)
                            }
                        }
                    } else {
                        do {
                            
                            if let data = data{
                                if let jsonString = String(data: data, encoding: .utf8) {
                                    print(jsonString)
                                    print("original url = \(originalUrl)")
                                } else {
                                    print("Failed to convert JSON data to string")
                                }
                            }
                            
                            guard let data = data else {
                                completion([JsonKeys().message : "Some error occured . Please try again"])
                                throw JSONError.NoData
                            }
                            // print(response)
                            // let datastring = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                                completion([JsonKeys().message : [],JsonKeys().status : httpResponse.statusCode])
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
                            if let sessionToken = json["session_token" ]{
                                UserDefaultsManager.manager.saveSessionToken(token: sessionToken as! String )
                            }
                            if let refreshToken = json["refresh_token" ]{
                                UserDefaultsManager.manager.saveRefreshableToken(token: refreshToken as! String )
                            }
                            if originalUrl.contains("authorize.net") {
                                completion(json)
                            } else {
                                //   let typingDict = NSDictionary(object: typingCountVal, forKey: "typingCount" as NSCopying)
                                let combinedDict = NSMutableDictionary(dictionary: json)
                                combinedDict["typingCount"] = typingCountVal
                                print("combined dict is :",combinedDict)
                                let staticDict = NSDictionary(dictionary: combinedDict)
                                completion(staticDict)
                            }

                        } catch let error as JSONError {
                            completion([JsonKeys().message : "Json error occured . Please try again",JsonKeys().status : httpResponse.statusCode])
                            print(error.rawValue)
                        } catch let error as NSError {
                            completion([JsonKeys().message :"Json error occured . Please try again"])
                            print("Error = \(error.debugDescription)")
                        }
                    }
                } else {
                    completion([JsonKeys().message :"Some error occured . Please try again"])
                }

            }
            dataTask.resume()
        }
        else{
            completion([JsonKeys().message :"No Internet Connection"])
        }
    }
    // token refresh

    func refreshToken(completion: @escaping (_ success: Bool) -> Void) {
        guard let refreshToken = UserDefaultsManager.manager.getRefreableToken() else {
            print("Refresh token not found")
            completion(false)
            return
        }

        let refreshTokenUrl = BaseUrl + APIUrls().REFRESH_TOKEN
        guard let sessionToken = UserDefaultsManager.manager.getSessionToken() else {
            print("Session token not found")
            completion(false)
            return
        }

        // Prepare the request
        guard let url = URL(string: refreshTokenUrl) else {
            print("Invalid URL")
            completion(false)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(sessionToken)", forHTTPHeaderField: "Authorization")  // Ensure the "Bearer" prefix if required by API

        // Create the JSON body
        let parameters = [
            "refresh_token": refreshToken,
            "session_token": sessionToken
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Error creating JSON body for refresh token request: \(error)")
            completion(false)
            return
        }

        // Perform the request
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error refreshing token: \(error)")
                completion(false)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                completion(false)
                return
            }

            if httpResponse.statusCode != 202 {
                print("Unexpected status code: \(httpResponse.statusCode)")
                completion(false)
                return
            }

            guard let data = data else {
                print("No data received")
                completion(false)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let statusCode = json["StatusCode"] as? Int, statusCode == 1 {
                        if let newSessionToken = json["session_token"] as? String,
                           let newRefreshToken = json["refresh_token"] as? String {
                            // Store new tokens if necessary
                            UserDefaultsManager.manager.saveSessionToken(token: newSessionToken)
                            UserDefaultsManager.manager.saveRefreshableToken(token: newRefreshToken)
                            completion(true)
                        } else {
                            print("Invalid response data")
                            completion(false)
                        }
                    } else {
                        print("Token refresh failed: \(json["StatusMessage"] ?? "Unknown error")")
                        completion(false)
                    }
                }
            } catch {
                print("Error parsing JSON response: \(error)")
                completion(false)
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
    
    func getBasicAuthForProgressAPI() -> String {
        
        let basicHeader = "T360NotifApiUser" + ":" + "*@!T36oN0t!F!@*"
        if let data = basicHeader.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return ""
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
