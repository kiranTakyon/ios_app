//
//  ModelManager.swift
//  Ambassador Education
//
//  Created by    Kp on 30/07/17.
//  Copyright © 2017 //. All rights reserved.
//

import Foundation
import UIKit
import WebKit
enum ModelType:String {

    case TNotification = "TNotification"
    case TNMyProfile = "TNMyProfile"
    case TSibling = "TSibling"
    case TinboxMessage = "TinboxMessage"
    case MessageModel = "MessageModel"
    case TNGroups = "TNGroups"
    case TNGroupCategory = "TNGroupGalleryCategory"
    case TNGallery = "TNGallery"
    case TNPerson = "TNPerson"
    case TNDigitalResource = "TNDigitalResource"
    case TNDigitalResourceSubList = "TNDigitalResourceSubList"
    case TNNoticeboardCategory = "TNNoticeboardCategory"
    case TNMenuItem = "TNMenuItem"
    case TNPayment = "TNPayment"
    case TNWeeklyPlan = "TNWeeklyPlan"
    case WeeklyPlanList = "WeeklyPlanList"
    case TNCalendarEvent = "TNCalendarEvent"
    case TNNoticeBoardDetail = "TNNoticeBoardDetail"
    case TNAwarnessArticleDetail = "TNAwarnessArticleDetail"
    case TNAwarenessDetail = "TNAwarenessDetail"
    case TNSubject = "TNSubject"
    case TModule = "TModule"

}


class ModelClassManager {

    static let sharedManager = ModelClassManager()
    
    func createModelArray(data:NSArray,modelType:ModelType) -> NSArray {
        var results = [AnyObject]()
        if data.count != 0{
            for eachData in data as! [NSDictionary]{
                var object:AnyObject?
                switch modelType {
                case .TNotification: object  = TNotification(values: eachData)
                case .TNMyProfile:object = TMyProfile(values:eachData)
                case .TSibling:object = TSibling(values:eachData)
                case .TinboxMessage:object = TinboxMessage(values:eachData)
                case .MessageModel:object = MessageModel(values:eachData)

                    
                case .TNGroups:object = TNGroup(values:eachData)
                case .TNGroupCategory:object = TNGalleryCategory(values:eachData)
                case .TNGallery:object = TNGallery(values:eachData)
                case .TNPerson:object = TNPerson(values:eachData)
                case .TNDigitalResource:object = TNDigitalResourceCategory(values:eachData)
                case .TNDigitalResourceSubList:object = TNDigitalResourceSubList(values:eachData)
                case .TNNoticeboardCategory:object = TNNoticeboardCategory(values:eachData)
                case .TNMenuItem:object = TNMenuItem(values:eachData)
                case .TNPayment:object = TNPayment(values:eachData)
                case .TNWeeklyPlan:object = TNWeeklyPlan(values:eachData)
                case .WeeklyPlanList:object = WeeklyPlanList(values:eachData)
                case .TNCalendarEvent:object = TNCalendarEvent(values:eachData)
                case .TNNoticeBoardDetail:object = TNNoticeBoardDetail(values:eachData)
                case .TNAwarnessArticleDetail: object = TNAwarnessArticleDetail(values: eachData)
                case .TNAwarenessDetail : object = TNAwarenessDetail(values : eachData)
                case .TNSubject:object = TNSubject(values:eachData)
                case .TModule:object = TModule(values:eachData)
                    
//TNPerson
                default:
                    break
                }
                results.append(object!)
            }
        }
        return results as NSArray
    }

}
