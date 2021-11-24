//
//  Protocols.swift
//  Ambassador Education
//
//  Created by    Kp on 25/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation


 protocol TaykonProtocol {
    
    
    func deleteTheSelectedAttachment(index : Int)
    func downloadPdfButtonAction(url: String,fileName : String?)
    func getBackToParentView(value:Any?,titleValue : String?)
    func getBackToTableView(value:Any?,tagValueInt : Int)
    func selectedPickerRow(selctedRow:Int)
    func popUpDismiss()
    func moveToComposeController(titleTxt : String,index : Int,tag : Int)
    func getSearchWithCommunicate(searchTxt : String,type: Int)
    func getUploadedAttachments(isUpload : Bool)

}
