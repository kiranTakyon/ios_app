//
//  serDefaultManager.swift
//  PosBook
//
//     on 13/07/17.
//   . All rights reserved.
//

import Foundation


//Store valuess


var logInResponseGloabl = NSDictionary()
var profileInfoGlobal = NSDictionary()
var useranameGlobal = ""
var passwordGloal = ""

class UserDefaultsManager {
    
    static let manager = UserDefaultsManager()
    
    
    func insertUserDefaultValue(value:Any, key:String){
        
        
        var insertValue : Any?
        if let dictionary = value as? NSDictionary{
            insertValue = NSMutableDictionary(dictionary: dictionary) //cleanDictionary(dict: dictionary )
            
            let storeDic = cleanDictionaryValues(dict: insertValue as! NSMutableDictionary)//removeNullsFromDictionary(origin: dictionary)// checkDictionary(dict: dictionary)
            
            print("insert value is : ",storeDic)
            
        }else{
            insertValue = value
        }
        
        UserDefaults.standard.set(insertValue, forKey: key)
        UserDefaults.standard.synchronize()
        
        if key == UserDefaultKeys().userDetails{
            
        }
    }
    
    func getUserDefaultValue(key:String) -> Any?{
        
        let value = UserDefaults.standard.value(forKey: key)
        return value
    }
    
    func insertAccessToken(details:NSDictionary){
        
        if let data = details["data"] as? NSDictionary{
            if let token = data["token"] as? String{
                self.insertUserDefaultValue(value: token, key: UserDefaultKeys().AccessToken)
            }
        }
    }
    
    func removeFromUserDefault(key : String){
        UserDefaults.standard.removeObject(forKey: key)
         UserDefaults.standard.synchronize()
    }
    
    func getUserId() -> String{
        
         let details = logInResponseGloabl;//self.getUserDefaultValue(key: DBKeys.logInDetails) as? NSDictionary else{return ""}
        guard let userId = details["UserId"] as? String else {return ""}
        
        return userId
    }
    
    func getUserType() -> String{
        
         let details = logInResponseGloabl//self.getUserDefaultValue(key: DBKeys.logInDetails) as? NSDictionary else{return ""}
        
        
        
        guard let userType = details["UserType"] as? String else {return ""}
        
        return userType
    }

    
}
