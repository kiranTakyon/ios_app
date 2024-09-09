//
//  serDefaultManager.swift
//  PosBook
//
//     on 13/07/17.
//   . All rights reserved.
//

import Foundation


//Store valuess


var logInResponseGloabl = NSMutableDictionary()
var profileInfoGlobal = NSMutableDictionary()
var useranameGlobal = ""
var passwordGloal = ""
var languagueGlobal = ""
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

    func saveJwtToken(token: String){
        UserDefaultsManager.manager.insertUserDefaultValue(value: token , key: UserDefaultKeys().jwtToken)
    }

    func getJwtToken() -> String? {
        return UserDefaultsManager.manager.getUserDefaultValue(key: UserDefaultKeys().jwtToken) as? String
    }

    func saveUserId(id: String){
        UserDefaultsManager.manager.insertUserDefaultValue(value: id , key: DBKeys.userIdValue)
    }
    
    func getUserId() -> String{
        return UserDefaultsManager.manager.getUserDefaultValue(key: DBKeys.userIdValue) as! String
    }
    
    func getUserType() -> String{
        
         let details = logInResponseGloabl//self.getUserDefaultValue(key: DBKeys.logInDetails) as? NSDictionary else{return ""}
        
        guard let userType = details["UserType"] as? String else {return ""}
        
        return userType
    }
    func getfeeurltype() -> String{
        
         let details = logInResponseGloabl//self.getUserDefaultValue(key: DBKeys.logInDetails) as? NSDictionary else{return ""}
        
        guard let feeurlType = details["fee_url_type"] as? String else {return "0"}
        
        return feeurlType
    }
    
    func setNotifications(isShow: Bool) {
        UserDefaults.standard.set(isShow, forKey: DBKeys.isNotifications)
    }
    
    func setRemember(isRemember: Bool) {
        UserDefaults.standard.set(isRemember, forKey: DBKeys.isRemember)
    }
    
    func getRemember() -> Bool {
        if let value = UserDefaults.standard.value(forKey: DBKeys.isRemember) as? Bool {
            return value
        } else {
            return false
        }
    }
    
    func getNotifications() -> Bool {
        if let value = UserDefaults.standard.value(forKey: DBKeys.isNotifications) as? Bool {
            return value
        } else {
            return false
        }
    }

    // save refreshable toke and session token

    func saveSessionToken(token: String) {
        UserDefaults.standard.set(token, forKey: DBKeys.session_Token)
    }
    func saveRefreshableToken(token: String) {
        UserDefaults.standard.set(token, forKey: DBKeys.refresh_token)
    }
    func getSessionToken() -> String? {
        return UserDefaults.standard.string(forKey: DBKeys.session_Token)

    }
    func getRefreableToken() -> String? {
        return UserDefaults.standard.string(forKey: DBKeys.refresh_token)

    }

    // Function to save the NSMutableDictionary to UserDefaults
    func saveDictionaryToUserDefaults(dictionary: NSMutableDictionary, forKey key: String) {
        do {
            let data = try PropertyListSerialization.data(fromPropertyList: dictionary, format: .xml, options: 0)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Error saving dictionary to UserDefaults: \(error)")
        }
    }

    // Function to retrieve the NSMutableDictionary from UserDefaults
    func retrieveDictionaryFromUserDefaults(forKey key: String) -> NSMutableDictionary? {
        if let data = UserDefaults.standard.data(forKey: key) {
            do {
                let dictionary = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? NSMutableDictionary
                return dictionary
            } catch {
                print("Error retrieving dictionary from UserDefaults: \(error)")
            }
        }
        return nil
    }


}
