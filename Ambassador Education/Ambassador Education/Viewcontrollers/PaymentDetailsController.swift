//
//  WeeklyPlanController.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 10/01/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit
/*
 1 = payementHistory
 2 = fee fee History
 3 = fee summary
 */

var finance = 3

class PaymentDetailsController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var StudentDetailTableView: UITableView!
    @IBOutlet weak var paymentDetailTable: UITableView!
    @IBOutlet weak var payTF: UITextField!
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var payViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var paymentDetailTBHeight: NSLayoutConstraint!
    
    @IBOutlet weak var firstSectionNameLabel: UILabel!
    @IBOutlet weak var secondSectionNameLabel: UILabel!
    @IBOutlet weak var thirdSectionNameLabel: UILabel!


    
    @IBOutlet weak var topHeaderView: TopHeaderView!
    
    @IBOutlet weak var PayOptions: UISegmentedControl!
    let feeSummaryKeys = ["TotalFee","TotalPaid","TotalDue","CurrentDue"]
    let feeSummaryTitles = ["Toatal Fee","Total Paid","Total Payable","Current Due"]
    let feeSummarySubTitleKyes = ["TotalFeeLabel","TotalPaidLabel","TotalPayableLabel","CurrentDueFormLabel"]
    var feesummaryDictionary = NSDictionary()
    
    var classValue = ""//Division()
    var payemntDetails = [TNPayment]()
    var absentDetails = [TAbsents]()
    var payLink =  ""
    
    var dayLabel =  ""
    var dateLabel =  ""
    var typeLabel =  ""
    var totalLabel =  ""
    var totalPaidLabel =  ""
    var nameLabel =  ""
    var classLabel =  ""
    var headLabel =  ""
    var receiptLabel =  ""
    var amountLabel =  ""
    var accountDetailsLabel =  ""
    var payLabel =  ""
    var FeeLabel =  ""
    var BalanceLabel = ""
    var PaidLabel = ""
    var FeeDescLabel = ""
    var PrevBalanceLabel=""
    var PrevBalance = ""
    var CDueLabel = ""
    var TDueLabel = ""
    var OtherLabel = ""
    var receiptAmountLabel =  ""

    var CurrentDue = "0.00"
    var TotalDue = "0.00"
    var compid = "0"
    var TotalRecptAmount = "0.00"
    var fee_url_type = UserDefaultsManager.manager.getfeeurltype()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
      //  self.getWeeklyPlan()
        getWeeklyPlanView()
        setSlideMenuProporties()
        topHeaderView.delegate = self
    }
    
    func setUI(){
        payTF.delegate = self
        payTF.keyboardType = .numbersAndPunctuation
        payTF.isUserInteractionEnabled = false
  
        self.paymentDetailTable.estimatedRowHeight = 118.0
        
        self.paymentDetailTable.rowHeight = UITableView.automaticDimension
        if finance == 2 {
//            titleLabel.text = "Fee Details"
            self.secondSectionNameLabel.text = self.headLabel
        }
        else if finance == 1{
//            titleLabel.text = "Payment History"
        }
        else if finance == 3{
//            titleLabel.text = "Fee Summary"
          }
        else {
//            titleLabel.text = "Absence Report"
            self.secondSectionNameLabel.text = self.headLabel
        }
    }


    @IBAction func payTypeChanged(_ sender: UISegmentedControl, forEvent event: UIEvent) {
        payTF.isUserInteractionEnabled = false
        switch sender.selectedSegmentIndex {
        case 0://CurrentDue
            payTF.text = CurrentDue
            break
        case 1://TotalDue
            payTF.text = TotalDue
            break
        case 2://Other
            payTF.text = ""
            payTF.isUserInteractionEnabled = true
            break
       default:
            break
        }
    }
    
    func setSlideMenuProporties(){
        if let revealVC = revealViewController() {
            topHeaderView.setMenuOnLeftButton(reveal: revealVC)
            view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    
    func setSectionHeader() {
        if finance == 1 {
        } else {
            secondSectionNameLabel.text = accountDetailsLabel
        }
    }

    
   /* func getWeeklyPlan(){
        self.startLoadingAnimation()
        var dictionary = [String: String]()
         let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] =  userId
        let url = APIUrls().weeklyPlan
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: MethodType.POST, requestString: "", requestParameters: dictionary) { (result) in
            
            if let divisionArray = result["Divisions"] as? NSArray{
                
                if divisionArray.count > 0{
                    
                    if let division = divisionArray[0] as? NSDictionary{
                        
                        if let divisionId = division["DivId"] as? Int{
                            self.classValue.divId = divisionId
                        }
                        
                        if let divValue = division["Division"] as? String{
                            self.classValue.division = divValue
                        }
                    }
                }
                
            }
                    self.headLabel = result["HeadLabel"] as? String ?? ""
                    self.dayLabel = result["DayLabel"] as? String ?? "Day"
                    self.dateLabel = result["DateLabel"] as? String ?? "Date"
                    self.typeLabel = result["TypeLabel"] as? String ?? "Type"
                    self.totalLabel = result["TotalLabel"] as? String ?? "Total"
                    self.totalPaidLabel = result["PaidLabel"] as? String ?? "Total Paid"
                    self.FeeLabel = result["FeeLabel"] as? String ?? "Fee"

                    self.nameLabel = result["NameLabel"] as? String ?? "Name"
                    self.classLabel = result["ClassLabel"] as? String ?? "Class"
                    self.amountLabel = result["AmountLabel"] as? String ?? "Amount"
                    self.accountDetailsLabel = result["AccountDetailsLabel"] as? String ?? "Payment Details"
                    self.payLabel = result["PayLabel"] as? String ?? "Payment Details"
            
             DispatchQueue.main.async {
                self.titleLabel.text = self.headLabel
                self.stopLoadingAnimation()
                if let message = result["MSG"] as? String{
                    SweetAlert().showAlert(kAppName , subTitle: message, style: AlertStyle.error)
                }
                else{
                    self.StudentDetailTableView.reloadData()
                }
            }
            
            print("weekly plan result is :-",result)
        }
        
    }
*/
    
    func getWeeklyPlanView(){
        var url = ""
        payView.isHidden = true
        PayOptions.isHidden = true
        payViewHeightConstraint.constant = 0
        
        if finance == 1{
             url = APIUrls().paymentDetails
        }else if finance == 2{
             url = APIUrls().feeDetails

        }else  if finance == 3 {
            payView.isHidden = false
            PayOptions.isHidden = false
            
//            payViewHeightConstraint.constant = 70
            payViewHeightConstraint.constant = 138
            url = APIUrls().feeSummary
        }
        else  if finance == 5 {
            url = APIUrls().absenceReport
        }
        
        var dictionary = [String: Any]()
        let userId = UserDefaultsManager.manager.getUserId()
        dictionary[UserIdKey().id] =  userId
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: .POST, requestString: "", requestParameters: dictionary) { (result) in
            
            print("weekly planview result :- ",result)
            self.headLabel = result["HeadLabel"] as? String ?? ""
            self.dayLabel = result["DayLabel"] as? String ?? "Day"
            self.dateLabel = result["DateLabel"] as? String ?? "Date"
            self.typeLabel = result["TypeLabel"] as? String ?? "Type"
            self.totalLabel = result["TotalLabel"] as? String ?? "Total"
            self.totalPaidLabel = result["PaidLabel"] as? String ?? "Total Paid"
            self.FeeLabel = result["FeeLabel"] as? String ?? "Fee"

            self.nameLabel = result["NameLabel"] as? String ?? "Name"
            self.classLabel = result["ClassLabel"] as? String ?? "-"
            self.receiptLabel = result["ReceiptLabel"] as? String ?? "Receipt No"
            self.amountLabel = result["AmountLabel"] as? String ?? "Amount"
            self.accountDetailsLabel = result["AccountDetailsLabel"] as? String ?? "Payment Details"
            self.payLabel = result["PayLabel"] as? String ?? "Pay"
            self.CurrentDue = result["CurrentDue"] as? String ?? "0.00"
            self.TotalDue = result["TotalDue"] as? String ?? "0.00"
            self.classValue = result["Division"] as? String ?? ""
            self.compid = result["comp_id"] as? String ?? "0"
            self.BalanceLabel=result["BalanceLabel"] as? String ?? "Balance"
            self.FeeDescLabel=result["FeeDescriptionLabel"] as? String ?? "Fee Description"
            self.PaidLabel=result["PaidLabel"] as? String ?? "Paid"
            self.PrevBalanceLabel = result["PrevBalanceLabel"] as? String ?? "Prev Balance"
            self.PrevBalance = result["prev_bal"] as? String ?? "0"
            self.CDueLabel = result["CurrentDueLabel"] as? String ?? "Current Due"
            self.TDueLabel = result["DueAmountLabel"] as? String ?? "Total Due"
            self.OtherLabel = result["OtherLabel"] as? String ?? "Other"
            self.receiptAmountLabel = result["ReceiptamountLabel"] as? String ?? "Receipt Amount"

            DispatchQueue.main.async {
                self.topHeaderView.title = self.headLabel
                self.PayOptions.setTitle(self.CDueLabel, forSegmentAt: 0)
                self.PayOptions.setTitle(self.TDueLabel, forSegmentAt: 1)
                self.PayOptions.setTitle(self.OtherLabel, forSegmentAt: 2)
            }
            
            if finance == 3{
                self.feesummaryDictionary = result
                DispatchQueue.main.async {
                    if let link  = self.feesummaryDictionary.value(forKey: "PaymentUrl") as? String{
                        self.payLink = link
                    }
                    self.payTF.text = self.CurrentDue
                    
                    if(self.compid == "216" || self.compid == "262" || self.compid == "96")
                    {
                        
                        self.PayOptions.setEnabled(false, forSegmentAt: 2);
                    }
                    if(self.payLink == "-1")
                    {
                        self.payView.isHidden = true
                        self.PayOptions.isHidden = true
                    }
                    else
                    {
                        self.payView.isHidden = false
                        self.PayOptions.isHidden = false
                    }
                    self.paymentDetailTable.reloadData()
                    self.StudentDetailTableView.reloadData()
                    self.stopLoadingAnimation()
                }

            }
            else if finance == 5{
                if let transaction = result["Transactions"] as? NSArray{
                    for each in transaction{
                        self.absentDetails.append(TAbsents(values: each as! NSDictionary))
                    }
                    DispatchQueue.main.async {
                        self.paymentDetailTable.reloadData()
                        self.StudentDetailTableView.reloadData()
                        self.stopLoadingAnimation()
                    }

                }
                
            }else{
                if let transaction = result["Transactions"] as? NSArray{
                   
                    let transactions = ModelClassManager.sharedManager.createModelArray(data: transaction, modelType: ModelType.TNPayment) as! [TNPayment]
                    
                    self.payemntDetails.append(contentsOf: transactions)
                    DispatchQueue.main.async {
                        self.paymentDetailTable.reloadData()
                        self.StudentDetailTableView.reloadData()
                        self.stopLoadingAnimation()
                    }
                }
            }
        }
    }
    
    //MARK:- UITableView delegate nad datasource
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == StudentDetailTableView{
            return 2
        }else{
            
            if finance == 3{
               return self.feeSummaryTitles.count
            }
            else if finance == 5{
                return self.absentDetails.count //> 0 ? (self.absentDetails.count + 1) : 0

            }
            else{
                if(fee_url_type=="2" && finance==2)
                {
                    return self.payemntDetails.count > 0 ? (self.payemntDetails.count + 3) : 0
                }
                else if(fee_url_type=="1" && finance==2)
                {
                    return self.payemntDetails.count > 0 ? (self.payemntDetails.count + 2) : 0
                }             
                else
                {
                    return self.payemntDetails.count > 0 ? (self.payemntDetails.count + 1) : 0
                }
            }
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var commonCell : UITableViewCell?
        
        if tableView == StudentDetailTableView{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "StudentDetailCell", for: indexPath) as! StudentDetailCell
            
            if indexPath.row == 0{
                
                let username = self.getProfileName()
                cell.titleLabel.text = username
                cell.titlePlaceHolder.text = self.nameLabel
                
            }else{
                //if let titleVal = classValue.division{
                    cell.titleLabel.text = classValue //titleVal
                    cell.titlePlaceHolder.text = self.classLabel
               // }
            }
            commonCell = cell
            
        }else{
            
            if finance == 3{
                
                 let cell = tableView.dequeueReusableCell(withIdentifier: "FeeDetailCell", for: indexPath) as! FeeDetailCell
                
                let holderKey = self.feeSummarySubTitleKyes[indexPath.row]
                
                if let keyValue  = self.feesummaryDictionary[holderKey] as? String{
                    cell.titlePlaceHolder.text = keyValue

                }
                let key = self.feeSummaryKeys[indexPath.row]
                
                if let value  = self.feesummaryDictionary[key] as? String{
                    
                    cell.titleLabel.text = value
                }
                
                 commonCell = cell
            }
                
            else if finance == 5{
                let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentDetailCell", for: indexPath) as! PaymentDetailCell

                    if absentDetails.count > 0{
                        let item = absentDetails[indexPath.row]
                        if(item.day.safeValue == "0")
                        {
                            cell.receiptNumberLabel.text = "No Data to Display"
                            cell.dateLabel.text = " "
                            cell.amount.text = ""
                        }
                        else
                        {
                            cell.receiptNumberLabel.text = "\(self.dayLabel): " + item.day.safeValue
                            cell.dateLabel.text = "\(self.dateLabel): " + item.date.safeValue
                            cell.amount.text = "\(self.typeLabel): " + item.type.safeValue
                        }
                    }
                  
                commonCell = cell
            }
            else{
               if self.payemntDetails.count == indexPath.row{
                    if(fee_url_type=="2" && finance == 2)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalCell
                        cell.totalTitleLabel.text = "\(self.totalLabel)" + " "+"\(self.FeeLabel):" + " " +  String(self.totalEstimateOfFee())
                        cell.totalLabel.text = "\(self.totalLabel)" + " "+"\(self.totalPaidLabel):" + " " +  String(self.totalEstimateOfPaidNew())//
                        //cell.totalLabel.text = "\(self.BalanceLabel):" + " " +  String(self.totalEstimateOfBalance())//
                        commonCell = cell
                    }
                   else
                   {
                      /* let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalCell
                       commonCell = cell
                       commonCell?.contentView.isHidden=true*/
                       let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalCell
                       
                           cell.totalLabel.text = String(self.totalEstimate())//totalEstimateOfPaid
                       
                       commonCell = cell
                   }
                }
                else if self.payemntDetails.count+1 == indexPath.row{
                    if(fee_url_type=="2" && finance == 2)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalCell
                        cell.totalTitleLabel.text = "\(self.BalanceLabel):" + " " +  String(self.totalEstimateOfBalance())
                        cell.totalLabel.text = ""
                        commonCell = cell
                    }
                    else if(fee_url_type=="1" && finance == 2)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalCell
                        cell.totalTitleLabel.text = "\(self.FeeLabel):" + " " +  String(self.totalEstimateOfFee())
                        cell.totalLabel.text = "\(self.totalPaidLabel):" + " " +  String(self.totalEstimateOfPaidNew())//
                        commonCell = cell
                    }
                     else
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalCell
                        if finance == 2{
                            cell.totalTitleLabel.text = "\(self.totalLabel):" + " " +  String(self.totalEstimateOfFee())
                            cell.totalLabel.text = "\(self.totalPaidLabel):" + " " +  String(self.totalEstimateOfPaid())//
                        }
                        else{
                            cell.totalLabel.text = String(self.totalEstimate())//totalEstimateOfPaid
                        }
                        commonCell = cell
                    }
                }
                else if self.payemntDetails.count < indexPath.row{
                    if(fee_url_type=="2" && finance == 2)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalCell
                        cell.totalTitleLabel.text = "\(self.PrevBalanceLabel):"
                        cell.TotalPaidlbl.text=""
                        cell.totalLabel.text = self.PrevBalance
                        commonCell = cell
                    }
                    if(fee_url_type=="1" && finance == 2)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCell", for: indexPath) as! TotalCell
                        cell.totalTitleLabel.text = "\(self.receiptAmountLabel):" + " " +  String(self.totalEstimateOfRecptAmount())
                        //cell.TotalPaidlbl.text = "\(self.totalPaidLabel):" + " " +  String(self.totalEstimateOfPaidNew())//
                        cell.totalLabel.text = "\(self.BalanceLabel):" + " " +  String(self.totalEstimateOfBalance())//
                        commonCell = cell
                      }
                }
                else{
                    if(fee_url_type=="2" && finance == 2)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentDetailCell2", for: indexPath) as! PaymentDetailCell2
                        
                        let paymentDetail = self.payemntDetails[indexPath.row]
                        
                        if let date = paymentDetail.date{
                            cell.DateLabel.text = "\(self.dateLabel) : \(date)"
                        }
                        if let fee = paymentDetail.fee{
                            cell.feeLbl.text = "\(self.FeeLabel) : \(fee)"
                        }
                        if let feeDesc = paymentDetail.Desc{
                            cell.DescLabel.text = "\(self.FeeDescLabel) : \(feeDesc)"
                        }
                        if let paid = paymentDetail.paid{
                            cell.paidLbl.text = "\(self.PaidLabel) : \(paid)"
                        }
                        if let balance = paymentDetail.balance{
                            cell.BalanceLbl.text = "\(self.BalanceLabel) : \(balance)"
                        }
                        cell.RecptLbl.isHidden = true
                        commonCell = cell
                    }
                   else if(fee_url_type=="1" && finance == 2)
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentDetailCell2", for: indexPath) as! PaymentDetailCell2
                        
                        let paymentDetail = self.payemntDetails[indexPath.row]
                        
                        if let date = paymentDetail.date{
                            cell.DateLabel.text = "\(self.dateLabel) : \(date)"
                        }
                        if let fee = paymentDetail.fee{
                            cell.feeLbl.text = "\(self.FeeLabel) : \(fee)"
                        }
                        if let feeDesc = paymentDetail.Desc{
                            cell.DescLabel.text = "\(self.FeeDescLabel) : \(feeDesc)"
                        }
                        if let paid = paymentDetail.paid{
                            cell.paidLbl.text = "\(self.PaidLabel) : \(paid)"
                        }
                        if let balance = paymentDetail.balance{
                            cell.BalanceLbl.text = "\(self.BalanceLabel) : \(balance)"
                        }
                        if let recptamt = paymentDetail.receiptAmount{
                            cell.RecptLbl.text = "\(self.receiptAmountLabel) : \(recptamt)"
                        }
                        commonCell = cell
                    }
                    else
                    {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentDetailCell", for: indexPath) as! PaymentDetailCell
                        
                        let paymentDetail = self.payemntDetails[indexPath.row]
                        
                        if let receiptNo = paymentDetail.receiptNo{
                            cell.receiptNumberLabel.text = "\(self.receiptLabel) : \(receiptNo)"
                        }else if let fee = paymentDetail.fee{
                            cell.receiptNumberLabel.text = "\(self.FeeLabel) : \(fee)"
                        }
                        
                        if let date = paymentDetail.date{
                            if finance == 2{
                                cell.dateLabel.text = "\(self.dateLabel) : \(date)"
                            }
                            else if finance == 1{
                                cell.dateLabel.text = "\(self.dateLabel): \(date)"
                            }
                        }
                        
                        if let amount = paymentDetail.amount{
                            if finance == 2{
                                cell.amount.text = "\(self.amountLabel):  \(amount)"
                            }
                            else if finance == 1{
                                cell.amount.text = "\(amount)"
                            }
                        }
                        commonCell = cell
                    }
                }
            }
            paymentDetailTBHeight.constant = tableView.contentSize.height
        }
        
        commonCell?.selectionStyle = .none
        return commonCell!
        
    }
    
    func getProfileName() -> String{
        
        let details = logInResponseGloabl;// UserDefaultsManager.manager.getUserDefaultValue(key:DBKeys.logInDetails) as? NSDictionary else {return}
        if let values = details["Siblings"] as? NSArray{
            
            let siblings = ModelClassManager.sharedManager.createModelArray(data: values, modelType: ModelType.TSibling) as! [TSibling]
            
            let profileValue = siblings[0]
            
            let profileName = profileValue.studentName
            
            return profileName!
            
        }
    
        return ""
       
    }

    func totalEstimate() -> Double{
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails{
            let doublevalue = Double(value.amount!)
            if doublevalue != nil{
                sum += doublevalue!
            }
        }
        
        return round(sum * 100) / 100.0
        
    }
    
    func totalEstimateOfFee() -> Double{
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails{
            let doublevalue = Double(value.fee!)
            if doublevalue != nil{
            sum += doublevalue!
            }
        }
        
        return round(sum * 100) / 100.0
        
    }
    
    func totalEstimateOfPaid() -> Double{
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails{
            let doublevalue = Double(value.amount!)
            if doublevalue != nil{
                sum += doublevalue!
            }
        }
        
        return round(sum * 100) / 100.0
        
    }
    func totalEstimateOfBalance() -> Double{
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails{
            
            let doublevalue = Double(value.balance!)
            if doublevalue != nil{
                sum += doublevalue!
            }
        }
        
        return round(sum * 100) / 100.0
        
    }
    func totalEstimateOfPaidNew() -> Double{
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails{
            let doublevalue = Double(value.paid!)
            if doublevalue != nil{
                sum += doublevalue!
            }
        }
        
        return round(sum * 100) / 100.0
        
    }
    func totalEstimateOfRecptAmount() -> Double{
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails{
            
            let doublevalue = Double(value.receiptAmount!)
            if doublevalue != nil{
                sum += doublevalue!
            }
        }
        
        return round(sum * 100) / 100.0
        
    }
    func navigateToWebView(){
        let vc = mainStoryBoard.instantiateViewController(withIdentifier: "GradeViewController") as? GradeViewController
        if payLink != "" {
            vc?.header  = "Payment"
            gradeBookLink = payLink
            self.present(vc!, animated: true, completion: nil)
        }
    }
    
    @IBAction func payButtonAction(_ sender: UIButton) {
        payTF.resignFirstResponder()
        if payTF.text != ""{
            if let userId = UserDefaultsManager.manager.getUserId() as? String{
                payLink = payLink + "?m_userid=" + userId + "&amount=" + payTF.text.safeValue
                navigateToWebView()
            }
        }else{
            SweetAlert().showAlert(kAppName , subTitle: "Please enter your amount to pay", style: AlertStyle.error)
    }
    }
    
    @IBAction func logOutButtonAction(_ sender: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            }
            else {
                isFirstTime = true
                gradeBookLink = ""
                showLoginPage()
            }
        }

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

extension PaymentDetailsController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        payTF.resignFirstResponder()
        return true
    }
}

class Division{
    
    var divId : Int?
    var division : String?
    
  
}


class StudentDetailCell:UITableViewCell{
    
    @IBOutlet weak var titlePlaceHolder: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
}

class PaymentDetailCell:UITableViewCell{
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var receiptNumberLabel: UILabel!
   
    @IBOutlet weak var dateLabel: UILabel!
}

class PaymentDetailCell2:UITableViewCell{
    @IBOutlet weak var DescLabel: UILabel!
    @IBOutlet weak var paidLbl: UILabel!
    @IBOutlet weak var DateLabel: UILabel!
    @IBOutlet weak var BalanceLbl: UILabel!
    @IBOutlet weak var feeLbl: UILabel!
    @IBOutlet weak var RecptLbl: UILabel!
}
class TotalCell:UITableViewCell{
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var totalTitleLabel: UILabel!
    
    @IBOutlet weak var TotalPaidlbl: UILabel!
}

class FeeDetailCell:UITableViewCell{
    @IBOutlet weak var titlePlaceHolder: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
}


extension PaymentDetailsController: TopHeaderDelegate {
    func secondRightButtonClicked(_ button: UIButton) {
        print("")
    }
    
    func searchButtonClicked(_ button: UIButton) {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            }
            else {
                isFirstTime = true
                gradeBookLink = ""
                showLoginPage()
            }
        }
    }
    
}
