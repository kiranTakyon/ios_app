//
//  BusMessageViewController.swift
//  Takyon360Buzz
//
//  Created by Veena on 18/04/18.
//  Copyright © 2018 Sreeshaj Kp. All rights reserved.
//


import UIKit
var typeValue = Int()


enum CommunicationType : String{
    
    case inbox = "INBOX"
    case sent  = "SENT"
}

class BusMessageViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var communicateTable: UITableView!
    var delegate : BussProtocol?
    var type : CommunicationType?
    var msgs : Any?
    
    var inboxMessages : BusMsgModel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewProporties()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getInboxMessages()
    }
    
    
   

    func getInboxMessages(){
        
        self.startLoadingAnimation()
        var url  = APIUrls().busMsgsList
       
        print("communicate send urk :- ",url)
        
        var dictionary = [String: Any]()
        dictionary["UserId"] = UserDefaultsManager.manager.getUserId()
        dictionary["MapId"] = branchId
        dictionary["TripId"] = tripId
        dictionary["StaffId"] = staffId
        
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result,data) in
            
            
            if result["StatusCode"] as? Int == 1{
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()

                    let list = self.setDecoderForParsingDataFromAPIResponse(data: data as Data)
                if list.statusCode == -300{
                        self.communicateTable.reloadData()
                        self.addNoDataFoundLabel()
                }else{
                    self.inboxMessages = list
                    self.removeNoDataLabel()
                    if self.type == CommunicationType.inbox{
                        if let inbox = self.inboxMessages?.inboxMessages{
                        if inbox.count == 0{
                            self.addNoDataFoundLabel()
                        }
                        else{
                            self.removeNoDataLabel()
                            self.communicateTable.reloadData()
                        }
                    }
                    }
                    else{
                        
                        
                        
                        if let send = self.inboxMessages?.sentMessages{
                        if send.count == 0{
                            self.addNoDataFoundLabel()
                        }
                        else{
                            self.removeNoDataLabel()
                            self.communicateTable.reloadData()

                        }
                    }
                    }
                    self.communicateTable.reloadData()
                }
                }
                
            }else{
                DispatchQueue.main.async {
                    self.stopLoadingAnimation()
                    self.addNoDataFoundLabel()
                }
            }
          
        }
    }
    
    
    func setDecoderForParsingDataFromAPIResponse(data : Data) -> BusMsgModel {
        var  responseModel : BusMsgModel?
        do{
            let jsonDecoder = JSONDecoder()
            responseModel = try jsonDecoder.decode(BusMsgModel.self, from: data)
            return responseModel!
        }catch let error as NSError {
            print(error.debugDescription)
        }
        return BusMsgModel(status : -300)
    }
    
  
    func tableViewProporties(){
        
        self.communicateTable.estimatedRowHeight = 160
        self.communicateTable.rowHeight = UITableViewAutomaticDimension
    }
    
    


    func getDecodedString(baseString : String) -> String{
        let decodedData = Data(base64Encoded: baseString, options: [])
        var decodedString: String? = nil
        if let aData = decodedData {
            let newStr = String(data: aData, encoding: .utf8)
            decodedString = newStr?.replacingOccurrences(of: "%20", with: " ")
        }
        return decodedString.safeValue
    }
    //MARK:- TableView Delegates and Datasources
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inboxMessages != nil{
            print(type)
            if type == CommunicationType.inbox{
                if let inbox = inboxMessages?.inboxMessages{
                if inbox.count > 0{
                    msgs = inbox as? [InboxMessages]
                    return inbox.count
                }
                else{
                    return 0
                }
            }
        }
        else{
                if let sent = inboxMessages?.sentMessages{
                if sent.count > 0{
                    msgs = sent as? [SentMessages]

                    return sent.count
                }
                else{
                    return 0
                }
            }
        }
        }
        return 0
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BugMsgCell", for: indexPath) as! BugMsgCell
        if let msgVal = msgs as? [InboxMessages]{
            
            let currentData = msgVal[indexPath.row]
            if let stringEncoded = currentData.inbox_mess{
                cell.firstLabel.text = getDecodedString(baseString: stringEncoded)
            }
            
            
        }
        else  if let msgVal = msgs as? [SentMessages]{
            let currentData = msgVal[indexPath.row]
            if let stringEncoded = currentData.sent_mess{
                cell.firstLabel.text = getDecodedString(baseString: stringEncoded)
            }
            
        }
        cell.selectionStyle = .none
        
        return cell
    }
    

    
    @IBAction func composeAction(_ sender: Any) {
        self.delegate?.getBackToParentView!(value: "compose")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

class BugMsgCell : UITableViewCell{
    
    @IBOutlet weak var firstLabel: UILabel!

    
    var imageUrl : String = ""{
        
        didSet{
            
            self.setImage()
        }
    }
    
    func setImage(){
    }
    
}
