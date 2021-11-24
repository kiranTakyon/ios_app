//
//  TNWeeklyPlan.swift
//  Ambassador Education
//
//  Created by Sreeshaj  on 15/01/18.
//  Copyright © 2018 InApp. All rights reserved.
//

import Foundation

class TNWeeklyPlan{
    
    var endingDateLabel : String?
    var weelyPlanLabel : String?
    var homeWorkLabel : String?
    var assessmentLabel : String?
    var weeklyPlanSetting : String?
    var classWorkLabel : String?
    
    var divisions : [WeeklyDivision]?

    
    init(values:NSDictionary) {
        
        self.endingDateLabel = values["EndingDateLabel"] as? String
        self.weelyPlanLabel = values["WeelyPlanLabel"] as? String
        self.homeWorkLabel = values["HomeWorkLabel"] as? String
        self.assessmentLabel = values["AssessmentLabel"] as? String
        self.weeklyPlanSetting = values["WeeklyPlanSetting"] as? String
        self.classWorkLabel = values["ClassWorkLabel"] as? String
        
        if let divisionsValues = values["Divisions"] as? NSArray{
            
            var divsionObjectArray = [WeeklyDivision]()
            
            if divisionsValues.count > 0{
                
                for div in divisionsValues{
                    
                    if let divDict = div as? NSDictionary{
                        let divObj = WeeklyDivision(values: divDict)
                        divsionObjectArray.append(divObj)
                    }
                    
                }
            }
            self.divisions = divsionObjectArray
        }
    }
}


class WeeklyDivision{
    
    var divId : String?
    var division : String?
    
    
    init(values:NSDictionary) {
        
        self.divId = values["DivId"] as? String
        self.division = values["Division"] as? String

    }
    
}

class WeeklyPlanList{
    
    var id : String?
    var date : String?
    var description : String?
    var topic : String?
    var attachIconCount : Int?
    
    var attachments : [Attachment]?
    
    
    init(values:NSDictionary) {
        
        self.date = values["Date"] as? String
        self.description = values["Description"] as? String
        if let topics = values["topic"] as? String{
            self.topic = topics
        }
        else if let topics = values["Topic"] as? String{
            self.topic = topics
        }
        self.attachIconCount = values["AttachIcon"] as? Int
        self.id = values["Id"] as? String
        
        
        
        if let divisionsValues = values["Attachments"] as? NSArray{
            
            var divsionObjectArray = [Attachment]()
            
            if divisionsValues.count > 0{
                
                for div in divisionsValues{
                    
                    if let divDict = div as? NSDictionary{
                        let divObj = Attachment(values: divDict)
                        divsionObjectArray.append(divObj)
                    }
                    
                }
            }
            self.attachments = divsionObjectArray
        }

        
    }
    
    
    
    
    

}

class Attachment{
    
    var linkName : String?
    var linkAddress:String?
    var fileName : String?
    var fileLink:String?

    init(values:NSDictionary) {
        self.linkName = values["LinkName"] as? String
        self.linkAddress = values["Link"] as? String
        self.fileName = values["FileName"] as? String
        self.fileLink = values["Filelink"] as? String
        
    }
}

