//
//  TInboxMessage.swift
//  Ambassador Education
//
//  Created by    Kp on 31/07/17.
//  Copyright © 2017 //. All rights reserved.
//manasin madiyile

import Foundation


class TinboxMessage{
    
    var id : String?
    var subject : String?
    var message : String?
    var date : String?
    var user : String?
    var userBool : Bool?
    var userProfileImage : String?
    var isRead : String?
    var attachIcon : Int?
    var markAsUnReadLabel : String?
    var markAsReadLabel : String?
    var sender : String?
    var senderImage : String?
    var senderId : String?
    var memebers = ""
    var groups = ""
    var persons : [TNPerson]?
    var group : [TNGroup]?
    var attachments : [Attachment]?
    var wholeGroup : String?
    
    init(values:NSDictionary) {
        
        self.id = values["Id"] as? String
        self.markAsUnReadLabel = values["MarkAsUnReadLabel"] as? String

        self.markAsReadLabel = values["MarkAsReadLabel"] as? String

        if let value = values["Sujbect"] as? String{
            self.subject = value
        }else{
             self.subject = values["Sujbect"] as? String
        }
        self.message = values["Message"] as? String
        self.wholeGroup = values["WholeGroup"] as? String

        self.date = values["Date"] as? String
        if let userval = values["User"] as? String{
            self.user = userval
        }else if let userbl =  values["User"] as? Bool {
            self.userBool = userbl
        }
        self.userProfileImage = values["UserProfileImg"] as? String
        self.isRead = values["IsRead"] as? String
        self.attachIcon = values["AttachIcon"] as? Int
        
        self.sender = values["Sender"] as? String
        self.senderImage = values["SenderProfileImg"] as? String
        self.senderId = values["SenderID"] as? String
        
        if let recipients = values["Recipients"] as? NSDictionary{

            if let members = recipients["Members"] as? NSArray{
                
                var membersArray = [String]()
                var groupsArray = [String]()

                for member in members{
                    
                    if let memberObj = member as? NSDictionary{
                        if let name = memberObj["Name"] as? String{
                        membersArray.append(name)
                        }
                        if let name = memberObj["GroupName"] as? String{
                            groupsArray.append(name)
                        }
                    }
                }
                self.groups = groupsArray.joined(separator: ",")
                self.memebers = membersArray.joined(separator: ",")
            }
        }
 
        if let recipients = values["Recipients"] as? NSDictionary{
            if let groupsArray = recipients["Group"] as? NSArray{
                var array = [TNGroup]()
                for groupVal in groupsArray{
                    if let groupDict  = groupVal as? NSDictionary{
                        array.append(TNGroup(values:groupDict))
                    }
                }
                self.group = array
            }
        }
        //0-to,1,cc 2,bcc
        if let recipients = values["Recipients"] as? NSDictionary{
            if let groupsArray = recipients["Members"] as? NSArray{
                var array = [TNPerson]()
                for groupVal in groupsArray{
                    if let groupDict  = groupVal as? NSDictionary{
                        array.append(TNPerson(values:groupDict))
                    }
                }
                self.persons = array
            }
        }
        if let attachmentValues = values["Attachments"] as? NSArray{
            var attachment = [Attachment]()
            if attachmentValues.count > 0{
                for each in attachmentValues{
                    attachment.append(Attachment(values: (each as? NSDictionary)!))
                }
                self.attachments = attachment
                }
            
            }
    }
    
    
}


class MessageModel {

    var addAttachmentLabel : String?
    var cCLabel : String?
    var checkAllLabel : String?
    var checkReadLabel : String?
    var checkUnreadLabel : String?
    var communicateLabel : String?
    var composeHeadLabel : String?
    var composeLabel : String?
    var deleteMailLabel : String?
    var filterLabel : String?
    var forwardLabel : String?
    var groupLabel : String?
    var inboxLabel : String?
    var markAsReadLabel : String?
    var markAsUnReadLabel : String?
   
    var messageListCurrentCount : Int?
    var messageTotalCount : Int?
    var paginationNumber : Int?
    var paginationStartFrom : Int?
    var paginationTotalNumber : Int?
    var replyAllLabel : String?
    var replyLabel : String?
    var sendLabel : String?
    var sentItemsLabel : String?
    var statusCode : Int?
    var statusMessage : String?
    var subjectLabel : String?
    var toLabel : String?
    var trashLabel : String?
    var typingCount : Int?
   

    init(values: NSDictionary?){

        self.addAttachmentLabel =  values?["AddAttachmentLabel"] as? String
        self.cCLabel = values?["CCLabel"] as? String
        self.checkAllLabel = values?["CheckAllLabel"] as? String
        self.checkReadLabel = values?["CheckReadLabel"] as? String
        self.checkUnreadLabel = values?["CheckUnreadLabel"] as? String
        self.communicateLabel = values?["CommunicateLabel"] as? String
        self.composeHeadLabel = values?["ComposeHeadLabel"] as? String
        self.composeLabel = values?["ComposeLabel"] as? String
        
        if let delete = values?["DeleteMailLabel"] as? String{
            self.deleteMailLabel = delete
        }
        else{
            self.deleteMailLabel = values?["DeleteLabel"] as? String
        }
       
        self.filterLabel = values?["FilterLabel"] as? String
        if let forward = values?["ForwardLabel"] as? String{
          self.forwardLabel = forward
        }
        else{
           self.forwardLabel = values?["ForwardMailLabel"] as? String
        }
        
         self.groupLabel = values?["GroupLabel"] as? String
         self.inboxLabel = values?["InboxLabel"] as? String
        self.markAsReadLabel = values?["MarkAsReadLabel"] as? String
        if let text = values?["MarkAsUnReadLabel"] as? String{
            self.markAsUnReadLabel = text
        }
        else{
            self.markAsUnReadLabel = values?["MarkAsUneadLabel"] as? String
        }

        self.messageListCurrentCount = values?["MessageListCurrentCount"] as? Int
        self.messageTotalCount = values?["MessageTotalCount"] as? Int
         self.paginationNumber = values?["PaginationNumber"] as? Int
         self.paginationStartFrom = values?["PaginationStartFrom"] as? Int
         self.paginationTotalNumber = values?["PaginationTotalNumber"] as? Int
         self.replyAllLabel = values?["ReplyAllLabel"] as? String
         self.replyLabel = values?["ReplyLabel"] as? String
         self.sendLabel = values?["SendLabel"] as? String
         self.sentItemsLabel = values?["SentItemsLabel"] as? String
        self.statusCode = values?["StatusCode"] as? Int
         self.statusMessage = values?["StatusMessage"] as? String
         self.subjectLabel = values?["SubjectLabel"] as? String
         self.toLabel = values?["ToLabel"] as? String
         self.trashLabel = values?["TrashLabel"] as? String
         self.typingCount = values?["typingCount"] as? Int
        
    
    }
}
