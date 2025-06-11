//
//  ReadSelectViewController.swift
//  Ambassador Education
//
//  Created by Veena on 10/03/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import UIKit

class ReadSelectViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var typeval = Int()
    var tag = Int()
    var msgObj : TinboxMessage?
    var options = [String]()
    var msgId = [String]()
    var delegate : TaykonProtocol?
    var isApproved: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.automaticallyAdjustsScrollViewInsets = false
        checkApprove()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadCell", for: indexPath) as? ReadCell
        if options.count > 0{
        cell?.titleLabel.text = options[indexPath.row]
        }
        cell?.selectionStyle = .none
        
        if isApproved && options[indexPath.row] == "Approve" {
            cell?.titleLabel.textColor = .gray
        } else {
            cell?.titleLabel.textColor = .black
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        switch options[indexPath.row] {
        case "Forward Email":
            moveToComposeView(type: indexPath.row,tag : tag)
        case "Reply All":
            moveToComposeView(type: indexPath.row,tag : tag)
        case "Delete":
            deleteMyMail()
        case "Mark As Read":
            callApi(markType: 1)
        case "Mark As UnRead":
            callApi(markType: 0)
        case "Approve":
            getApprove()
        case "Cancel":
            self.dismiss(animated: true, completion: nil)
        default:
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    func moveToComposeView(type: Int,tag : Int){
        self.dismiss(animated: true, completion: nil)
        self.delegate?.moveToComposeController(titleTxt :options[type],index : type ,tag: tag)
    }
    
    func callApi(markType : Int){
        self.startLoadingAnimation()
        
        let url = APIUrls().mailReadOrUnRead
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
     
        
        dictionary[UserIdKey().id] = userId
        dictionary[UserIdKey().markType] = markType
        dictionary[UserIdKey().msgId] = msgId[tag]
        dictionary[UserIdKey().msgType] = typeval
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                
                if result != nil{
                    self.stopLoadingAnimation()
                    if let status = result["StatusCode"] as? Int{
                        self.dismiss(animated: true, completion: nil)
                        if status == 1{
                            SweetAlert().showAlert(kAppName, subTitle: "Success", style: .success)
                        }
                        else{
                            SweetAlert().showAlert(kAppName, subTitle: result["StatusMessage"] as? String, style: .success)
                            
                        }
                        self.dismiss(animated: true, completion: nil)

                    }
                }
                else{
                    self.stopLoadingAnimation()
                    
                }
                
            }
        }
    }
    
    func deleteMyMail(){
        self.startLoadingAnimation()
        
        let url = APIUrls().deleteMail
        
        let userId = UserDefaultsManager.manager.getUserId()
        
        var dictionary = [String: Any]()
        
        
        dictionary[UserIdKey().id] = userId
        dictionary[UserIdKey().msgId] = msgId
        dictionary[UserIdKey().msgType] = typeval
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                if result != nil{
                    self.stopLoadingAnimation()
                    if let status = result["StatusCode"] as? Int{
                        self.dismiss(animated: true, completion: nil)
                        if status == 1{
                            SweetAlert().showAlert(kAppName, subTitle: "Your mail deleted Successfully", style: .success, buttonTitle: alertOk, action: { (success) in
                                if success{
                                    self.delegate?.getBackToTableView(value: nil,tagValueInt : -1)
                                }
                            })
                        }
                        else{
                            SweetAlert().showAlert(kAppName, subTitle: result["StatusMessage"] as? String, style: .success)
                            
                        }
                        self.dismiss(animated: true, completion: nil)
                        
                    }
                }
                else{
                    self.stopLoadingAnimation()
                    
                }
            }
            
    }
    }
    
    func checkApprove() {
        if !(msgObj?.ApprovedStatus ?? false) {
            if let index = options.firstIndex(of: "Approve") {
                options.remove(at: index)
            }
        }
    }
    
    func getApprove() {
        
        guard !isApproved else { return }
        self.startLoadingAnimation()
        
        var dictionary = [String: Any]()
        
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] = userId
        dictionary[Communicate().messageId] = msgId[tag]
        dictionary[Communicate().isMobile] = 0
        dictionary["client_ip"] =  getUdid()
        
        let url = APIUrls().messageApprove
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { [self] (result) in
            DispatchQueue.main.async {
            if let StatusMessage = result["StatusMessage"] as? String {
                if StatusMessage == "Success" {
                    self.delegate?.didCheckApproveState(isApprove: true)
                    SweetAlert().showAlert(kAppName, subTitle: "Approve", style: .success)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.delegate?.didCheckApproveState(isApprove: false)
                    SweetAlert().showAlert(kAppName, subTitle: result["StatusMessage"] as? String, style: .success)
                    self.dismiss(animated: true, completion: nil)
                }
            }
                self.dismiss(animated: true, completion: nil)
                self.stopLoadingAnimation()
            }
        }
        
    }
    
}

class ReadCell : UITableViewCell{
    @IBOutlet weak var titleLabel: UILabel!
    
}
