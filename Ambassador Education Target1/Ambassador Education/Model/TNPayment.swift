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
    
    
    init(values:NSDictionary) {
        
        self.amount = values["Amount"] as? String
        self.date = values["Date"] as? String
        
        if let _ = values["ReceiptNo"] as? String{
            self.receiptNo = values["ReceiptNo"] as? String

        }else{
            self.fee = values["Fee"] as? String
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
