//
//  SendMessageViewController.swift
//  Takyon360Buzz
//
//  Created by Veena on 18/04/18.
//  Copyright © 2018 Sreeshaj Kp. All rights reserved.
//

import UIKit
import DropDown

class SendMessageViewController: UIViewController ,UITextFieldDelegate{
    var delegate : BussProtocol?
    var dropDown : DropDown?
    var dataSources = [String]()

    @IBOutlet weak var msgTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settextFieldProporties()
        setDropDown()
        // Do any additional setup after loading the view.
    }

    func settextFieldProporties(){
        self.msgTextField.delegate = self
    }
    
    func setDropDown(){
        dropDown = DropDown()
        DropDown.startListeningToKeyboard()
        dropDown?.direction  = .any
        
        
        dropDown?.anchorView = msgTextField // UIView or UIBarButtonItem
        
        
        
        if optionMsgs != nil{
            for each in optionMsgs!{
                    dataSources.append(each.name!)
            }
        }
        
        dropDown?.dataSource = dataSources//["Car", "Motorcycle", "Truck"]
        if dataSources.count > 0{
            self.msgTextField.text = dataSources[0]
            dropDown?.selectionAction = { (index: Int, item: String) in
                print("Selected item: \(item) at index: \(index)")
                self.msgTextField.text = item
                
            }
        }
        
    }
    
    func getMsgId(name: String) -> String{
        if name != ""{
            if optionMsgs != nil{
                for each in optionMsgs!{
                        if each.name == name{
                            return each.id!
                        }
                    }
            }
        }
      return ""
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if dataSources.count > 0{
            self.dropDown?.show()
        }
        else{
            SweetAlert().showAlert(kAppName, subTitle: "There is no options to send messages", style: .warning)
        }
            return false
    }

    
    func setDecoderForParsingDataFromAPIResponse(data : Data) -> MsgOptionModel {
        var  responseModel : MsgOptionModel?
        do{
            let jsonDecoder = JSONDecoder()
            responseModel = try jsonDecoder.decode(MsgOptionModel.self, from: data)
            return responseModel!
        }catch let error as NSError {
            print(error.debugDescription)
        }
        return MsgOptionModel(status : -300)
    }
    
    
   
    func sendMessages(){
        
        self.startLoadingAnimation()
        var url  = APIUrls().sendMsg
        
        print("communicate send urk :- ",url)
        

        var dictionary = [String: Any]()
        dictionary["UserId"] = UserDefaultsManager.manager.getUserId()
        if getMsgId(name: msgTextField.text!) != ""{
            dictionary["MsgId"] = getMsgId(name:  msgTextField.text!)
        }
        
        dictionary["TripId"] = tripId
        dictionary["StaffId"] = staffId
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result,data) in
            
            DispatchQueue.main.async {

            if result["StatusCode"] as? Int == 1{
                    self.stopLoadingAnimation()
                
                    if let status = result.value(forKey: "StatusCode") as? Int{
                        self.removeNoDataLabel()
                        if status == 1{
                            SweetAlert().showAlert(kAppName, subTitle: "Success", style: .success)
                        }
                        else{
                            SweetAlert().showAlert(kAppName, subTitle: "Something went worng,Please try again later", style: .warning)
                        }
                        self.dismiss(animated: true, completion: nil)

                    }
                
            }else{
                DispatchQueue.main.async {
                    SweetAlert().showAlert(kAppName, subTitle: "Something went worng,Please try again later", style: .warning)

                    self.dismiss(animated: true, completion: nil)
                }
            }
            }
        }
    }
    @IBAction func sendButtonAction(_ sender: UIButton) {
        if msgTextField.text != ""{
            sendMessages()
        }
        else{
            SweetAlert().showAlert(kAppName, subTitle: "Please enter your message", style: .warning)
        }
    }
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
