//
//  WeeklyPlanController.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 10/01/18.
//  Copyright © 2018 . All rights reserved.
//

import UIKit
import DropDown
/*
 1 = payementHistory
 2 = fee fee History
 3 = fee summary
 */

var finance = 3

class PaymentDetailsController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelClass: UILabel!
    @IBOutlet weak var labelDueAmount: UILabel!
    @IBOutlet weak var labelTotalPaid: UILabel!
    @IBOutlet weak var labelTotalFeeConcession: UILabel!
    @IBOutlet weak var labelTotalPayable: UILabel!
    @IBOutlet weak var labelCurrentDue: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var buttonStudentsDropDown: UIButton!

    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet weak var historyTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var detailTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topHeaderView: TopHeaderView!
    
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
    var dropDown : DropDown?

    override func viewDidLoad() {
        super.viewDidLoad()
        setSlideMenuProporties()
        SetupTableView()
        topHeaderView.delegate = self
        setStudentDropDown()
    }
    
    
    func SetupTableView() {
        historyTableView.register(UINib(nibName: "PaymentHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentHistoryTableViewCell")
        historyTableView.register(UINib(nibName: "PaymentTotalTableViewCell", bundle: nil), forCellReuseIdentifier: "PaymentTotalTableViewCell")
        detailTableView.register(UINib(nibName: "FeeDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "FeeDetailTableViewCell")
    }
    
    @IBAction func payTypeChanged(_ sender: UIButton) {
        labelAmount.isUserInteractionEnabled = false
        switch sender.tag {
        case 0://CurrentDue
            labelAmount.text = CurrentDue
            break
        case 1://TotalDue
            labelAmount.text = TotalDue
            break
        case 2://Other
            labelAmount.text = ""
            labelAmount.isUserInteractionEnabled = true
            break
        default:
            break
        }
    }

    @IBAction func buttonStudentDropDownDidTap(_ sender: UIButton) {
        dropDown?.show()
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
            // secondSectionNameLabel.text = accountDetailsLabel
        }
    }
    
    
    //MARK: - UITableView delegate nad datasource
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if  tableView == historyTableView {
            return payemntDetails.count + 1
        } else {
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if  tableView == historyTableView {
            
            if indexPath.row == (payemntDetails.count) {
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentTotalTableViewCell", for: indexPath) as? PaymentTotalTableViewCell else { return UITableViewCell() }
                cell.labelTotalAmount.text = "\(totalEstimateOfPaid())"
                cell.selectionStyle = .none
                historyTableViewHeightConstraint.constant = historyTableView.contentSize.height
                return cell
            } else {
                
                guard let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentHistoryTableViewCell", for: indexPath) as? PaymentHistoryTableViewCell else { return UITableViewCell() }
                cell.setUpCell(payment: payemntDetails[indexPath.row])
                cell.selectionStyle = .none
                
                return cell
            }
            
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeeDetailTableViewCell", for: indexPath) as? FeeDetailTableViewCell else { return UITableViewCell() }
            cell.setUpCell()
            detailTableViewHeightConstraint.constant = detailTableView.contentSize.height
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  tableView == historyTableView {
            historyTableViewHeightConstraint.constant = historyTableView.contentSize.height
            if indexPath.row == payemntDetails.count  {
                return 40
            } else {
                return 90
            }
            
        } else {
            detailTableViewHeightConstraint.constant = detailTableView.contentSize.height
            return 90
        }
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
        
        return sum
        
    }
    
    func totalEstimateOfFee() -> Double{
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails{
            
            let doublevalue = Double(value.fee!)
            if doublevalue != nil{
                sum += doublevalue!
            }
        }
        
        return sum
        
    }
    
    func totalEstimateOfPaid() -> Double{
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails {
            if let amount = value.amount {
                let doublevalue = Double(amount)
                if doublevalue != nil{
                    sum += doublevalue!
                }
            }
        }
        
        return sum
        
    }
    
    func totalEstimateOfBalance() -> Double{
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails {
            
            let doublevalue = Double(value.balance!)
            if doublevalue != nil{
                sum += doublevalue!
            }
        }
        
        return sum
        
    }
    func totalEstimateOfPaidNew() -> Double {
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails {
            
            let doublevalue = Double(value.paid!)
            if doublevalue != nil{
                sum += doublevalue!
            }
        }
        
        return sum
        
    }
    func totalEstimateOfRecptAmount() -> Double{
        
        var sum : Double = 0.0
        
        for value in self.payemntDetails {
            
            let doublevalue = Double(value.receiptAmount!)
            if doublevalue != nil {
                sum += doublevalue!
            }
        }
        
        return sum
        
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
        labelAmount.resignFirstResponder()
        if labelAmount.text != ""{
            if let userId = UserDefaultsManager.manager.getUserId() as? String{
                payLink = payLink + "?m_userid=" + userId + "&amount=" + labelAmount.text.safeValue
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
    
}

extension PaymentDetailsController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //payTF.resignFirstResponder()
        return true
    }
}

class Division{
    
    var divId : Int?
    var division : String?
    
    
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


extension PaymentDetailsController {
    
    func getpaymentSummery(studentId: String = "" ) {
        startLoadingAnimation()
        let url = APIUrls().feeConsolidated
        var dictionary = [String: Any]()
        if !studentId.isEmpty {
            dictionary[UserIdKey().id] =  studentId
        } else {
            let userId = UserDefaultsManager.manager.getUserId()
            dictionary[UserIdKey().id] =  userId
        }

        APIHelper.sharedInstance.apiCallHandler(url, requestType: .POST, requestString: "", requestParameters: dictionary) { [weak self] (result) in
            
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let getFeeDetailReport = result["GetFeeDetailReport"] as? [String: Any] {
                    self.topHeaderView.title = getFeeDetailReport["HeadLabel"] as? String ?? ""
                    self.labelClass.text = getFeeDetailReport["Division"] as? String ?? ""
                    self.labelDueAmount.text = getFeeDetailReport["TotalDue"] as? String ?? "0.00"
                    self.labelTotalPaid.text = getFeeDetailReport["TotalPaid"] as? String ?? "0.00"
                    self.labelTotalFeeConcession.text = getFeeDetailReport["FeeConcession"] as? String ?? "0.00"
                    self.labelTotalPayable.text = getFeeDetailReport["TotalFee"] as? String ?? ""
                    self.labelCurrentDue.text = getFeeDetailReport["CurrentDue"] as? String ?? ""
                    self.labelAmount.text = getFeeDetailReport["TotalDue"] as? String ?? ""
                    
                    self.CurrentDue = getFeeDetailReport["CurrentDue"] as? String ?? "0.00"
                    self.TotalDue = getFeeDetailReport["TotalDue"] as? String ?? "0.00"
                    self.payLink = getFeeDetailReport["PaymentUrl"] as? String ?? ""
                }
                
                if let paymentHistoryReport = result["PaymentHistoryReport"] as? [String: Any] {
                    if let transaction = paymentHistoryReport["Transactions"] as? NSArray{
                        
                        let transactions = ModelClassManager.sharedManager.createModelArray(data: transaction, modelType: ModelType.TNPayment) as! [TNPayment]
                        
                        self.payemntDetails.append(contentsOf: transactions)
                        self.historyTableView.reloadData()
                        
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.historyTableViewHeightConstraint.constant = self.historyTableView.contentSize.height
                    self.detailTableViewHeightConstraint.constant = self.detailTableView.contentSize.height
                    self.stopLoadingAnimation()
                }
            }
        }
    }
}
