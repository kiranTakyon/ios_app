//
//  BusListViewController.swift
//  Takyon360Buzz
//
//  Created by Veena on 17/04/18.
//  Copyright © 2018 Sreeshaj Kp. All rights reserved.
//

import UIKit

var optionMsgs : [Messages]?
class BusListViewController: UIViewController {

    var busValues : BusModel?
    @IBOutlet weak var headLabel: UITextField!
    @IBOutlet weak var busTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
       getBusList()
    }

    
    func getBusList(){
        var dictionary = [String: String]()
        dictionary["UserId"] =  UserDefaultsManager.manager.getUserId()
        let url = APIUrls().busList
        self.startLoadingAnimation()
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result,data) in
            if let resultDict = result as? NSDictionary{
                
                
                DispatchQueue.main.async {
                    
                    if resultDict["StatusCode"] as? Int == 1{
                        let model = self.setDecoderForParsingDataFromAPIResponse(data: data as Data)

                        if model.statusCode == -300{
                            SweetAlert().showAlert(kAppName, subTitle: "Something went wrong", style: .warning)
                            self.busTableView.reloadData()
                            self.addNoDataFoundLabel()
                        }
                        else{
                            self.busValues = model
                            self.getMyMsgOptions()
                            self.busTableView.reloadData()
                            self.removeNoDataLabel()
                        }
                        self.stopLoadingAnimation()
                    }
                    else{
                        SweetAlert().showAlert(kAppName, subTitle: "Something went wrong", style: .warning)
                        self.stopLoadingAnimation()
                        self.addNoDataFoundLabel()
                    }
                  
                }
                
             
            }
        }
        
    }
    func getMyMsgOptions(){
        if busValues != nil{
            self.headLabel.text = busValues?.headLabel.safeValue.replacingHTMLEntities
            if let messages = busValues?.messages as? [Messages]{
                if messages.count > 0{
                    optionMsgs = messages
                }
                else{
                   optionMsgs = nil
                }
            }
        }
    }
    
    func setDecoderForParsingDataFromAPIResponse(data : Data) -> BusModel {
        var  responseModel : BusModel?
        do{
            let jsonDecoder = JSONDecoder()
            responseModel = try jsonDecoder.decode(BusModel.self, from: data)
            return responseModel!
        }catch let error as NSError {
            print(error.debugDescription)
        }
        return BusModel(status : -300)
    }
    
    
    
    @IBAction func backButtonAction(_ sender: UIButton) {
    }
    
    @IBAction func logOutButtonAction(_ sender: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            }
            else {
                showLoginPage()
            }
        }
    }
    
}


extension BusListViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if busValues != nil{
            if let maps = busValues?.map as? [Map]{
                return maps.count
            }
        }
       
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommunicateCell", for: indexPath) as? CommunicateCell
        cell?.selectionStyle = .none
        
        if let maps = busValues?.map as? [Map]{
            cell?.busNameLabel.text = maps[indexPath.row].brach
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = tableView.cellForRow(at: indexPath) as? CommunicateCell
        if let maps = busValues?.map{
        let currentValue = maps[indexPath.row] as? Map
            if busValues?.trip_id == "" || busValues?.staff_id == ""{
                SweetAlert().showAlert(kAppName, subTitle: "No Trip found", style: .warning)
            }
            else{
                if let branc = currentValue?.branchId{
                    navigateToMsgView(branchIdValue: branc,staffIdValue : (busValues?.staff_id).safeValue,header : (currentValue?.brach.safeValue).safeValue)
                }
            }
        }
    }
    func returnPagerTitles() -> [String]{
        var arr = [String]()
        if busValues != nil{
            arr.append("LOCATION")
            arr.append((busValues?.messageFromBusLabel.safeValue).safeValue.uppercased())
            arr.append((busValues?.messageToBusLabel.safeValue).safeValue.uppercased())
        }
        return arr
    }
    
    func navigateToMsgView(branchIdValue : String,staffIdValue : String,header : String){
        if busValues != nil{
        let view = mainStoryBoard.instantiateViewController(withIdentifier: "BusMessageLandViewController") as? BusMessageLandViewController
        if staffIdValue != ""{
            staffId = staffIdValue
        }
        tripId  = (busValues?.trip_id).safeValue
        branchId = branchIdValue
        view?.headerText = header
        if returnPagerTitles().count != 0{
        view?.headers = returnPagerTitles()
        self.navigationController?.pushViewController(view!, animated: true)
        }
        }
    }
}


class CommunicateCell: UITableViewCell{
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var busNameLabel: UILabel!
}





@IBDesignable
class CardView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 2
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 2
    @IBInspectable var shadowColor: UIColor? = UIColor.darkGray
    @IBInspectable var shadowOpacity: Float = 0.5
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.cgPath
    }
    
}

