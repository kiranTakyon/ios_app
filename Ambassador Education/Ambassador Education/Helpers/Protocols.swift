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
    func getBackToParentView(value:Any?,titleValue : String?,isForDraft: Bool, message: TinboxMessage)
    func getBackToTableView(value:Any?,tagValueInt : Int)
    func getBackToParentViewS(value:Any?,titleValue : String?)
    func selectedPickerRow(selctedRow:Int)
    func popUpDismiss()
    func moveToComposeController(titleTxt : String,index : Int,tag : Int)
    func getSearchWithCommunicate(searchTxt : String,type: Int)
    func getUploadedAttachments(isUpload : Bool, isForDraft: Bool)
    func didCheckApproveState(isApprove : Bool)

}

extension TaykonProtocol {
    func didCheckApproveState(isApprove : Bool) {
        
    }
    func getBackToParentView(value:Any?,titleValue : String?,isForDraft: Bool, message: TinboxMessage) {
        
    }
    func getBackToParentViewS(value:Any?,titleValue : String?) {
        
    }
}
