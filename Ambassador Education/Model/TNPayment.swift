//
//  TNPayment.swift
//  Ambassador Education
//
//  Created by Sreeshaj Kp on 11/01/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import Foundation


class TNPayment{
    
    var amount : String?
    var date : String?
    var receiptNo : String?
    var fee : String?
    var balance : String?
    var paid : String?
    var Desc : String?
    var receiptAmount : String?
    
    init(values:NSDictionary) {
        
        self.amount = values["Amount"] as? String
        self.date = values["Date"] as? String
        
        if let _ = values["ReceiptNo"] as? String{
            self.receiptNo = values["ReceiptNo"] as? String

        }else{
            self.fee = values["Fee"] as? String
        }
        if let _ = values["Balance"] as? String{
            self.balance = values["Balance"] as? String

        }else{
            self.balance = ""
        }
        if let _ = values["Fee"] as? String{
            self.fee = values["Fee"] as? String

        }else{
            self.fee = "0"
        }
        if let _ = values["FeeDescription"] as? String{
            self.Desc = values["FeeDescription"] as? String

        }else{
            self.Desc = ""
        }
        if let _ = values["Paid"] as? String{
            self.paid = values["Paid"] as? String

        }else{
            self.paid = ""
        }
        if let _ = values["receipt_amt"] as? String{
            self.receiptAmount = values["receipt_amt"] as? String

        }else{
            self.receiptAmount = "0"
        }
    }
}


class TAbsents{
    
    var date : String?
    var day : String?
    var type : String?
    
    
    init(values:NSDictionary) {
        
        self.date = values["Date"] as? String
        self.day = values["Day"] as? String
        if let typeVal = values["Type"] as? String{
            self.type = typeVal
        }
    }
}
