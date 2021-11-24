//
//  CalendarController.swift
//  Ambassador Education
//
//  Created by    Kp on 26/08/17.
//  Copyright © 2017  . All rights reserved.
//

import UIKit
import MBCalendarKit

class CalendarController: CalendarViewController {
    
    var dictionary = [String:[TNCalendarEvent]]()
    var data : [Date:[CalendarEvent]] = [:]
    var sections = [String]()
    var items = [[String]]()
    let calendar = CalendarViewController()
    var calendarEvent  : NSObject?
    
    var completeEvents = [CalendarEvent]()
    
    var eventData = [TNCalendarEvent]()
    
    var completeDates = [String:[TNCalendarEvent]]()
    
    
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MMMM"//"dd/MM"
        return formatter
    }()
    
    required init?(coder aDecoder: NSCoder) {
        
        self.data = [:]
        
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        self.data = [:]
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCalender()
        getCalendarEvents()
    }
    
    func setNavigationBar(){
        self.navigationController?.navigationBar.backgroundColor = UIColor.red
        navigationItem.leftBarButtonItem   = UIBarButtonItem(image: #imageLiteral(resourceName: "Menu2"), style: .plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
        navigationItem.rightBarButtonItem   = UIBarButtonItem(image: #imageLiteral(resourceName: "LogOut2"), style: .plain, target: self, action: #selector(logOutAction))
    }
    
    @objc func logOutAction(){
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle:"Want to stay", buttonColor:UIColor.lightGray , otherButtonTitle:  "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
            } else {
                isFirstTime = true
                gradeBookLink = ""
                showLoginPage()
            }
        }
    }
    
    
    func setCalender(){
        self.delegate = self
        self.dataSource = self
    }
    
    deinit {
        print("\(#function)")
    }
    
    // MARK:- UIGestureRecognizerDelegate
    
    //    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    //        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
    //        if shouldBegin {
    //            let velocity = self.scopeGesture.velocity(in: self.view)
    //            switch self.calendar.scope {
    //            case .month:
    //                return velocity.y < 0
    //            case .week:
    //                return velocity.y > 0
    //            }
    //        }
    //        return shouldBegin
    //    }
    
    //    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
    //        self.calenderHeight.constant = bounds.height
    //        self.view.layoutIfNeeded()
    //    }
    
    //    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
    //        print("did select date \(self.dateFormatter.string(from: date))")
    //        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
    //        print("selected dates is \(selectedDates)")
    //        if monthPosition == .next || monthPosition == .previous {
    //            calendar.setCurrentPage(date, animated: true)
    //        }
    //    }
    //
    //    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    //        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    //    }
    
    
    
    func getCalendarEvents(){
        self.data = [:]
        startLoadingAnimation()
        let url = APIUrls().getCalendarEvents
        
        var dictionary = [String:Any]()
        let userId = UserDefaultsManager.manager.getUserId()
        
        dictionary[UserIdKey().id] =  userId
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: .POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                guard let title = result["CalendarLabel"] as? String else {return}
                self.title = title

                guard let events = result["Events"] as? NSArray else{
                    self.stopLoadingAnimation()
                    SweetAlert().showAlert(kAppName, subTitle: "Something went wrong", style: .success)
                    return
                }
                if   events.count == 0{
                    self.stopLoadingAnimation()
                    SweetAlert().showAlert(kAppName, subTitle: "No Events", style: .success)
                }
                else{
                    if  let eventObjs = ModelClassManager.sharedManager.createModelArray(data: events, modelType: .TNCalendarEvent) as?  [TNCalendarEvent]{
                        self.completeDates = self.createCalendarSections(eventData: eventObjs)
                        
                        self.eventData = eventObjs
                        self.adEventsToCalendar()
                        self.stopLoadingAnimation()
                    }
                    else{
                        self.stopLoadingAnimation()
                    }
                }
            }
        }
    }
    
    func getAllStartDates() -> [String]{
        var startDateArr = [String]()
        if eventData.count != 0{
            for each in eventData{
                startDateArr.append(each.startDate.safeValue)
            }
        }
        return startDateArr
    }
    
    
    func convertNextDate(dateString : String,incrtemnt: Int) -> Date{
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = "MMM dd,yyyy"
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd,yyyy")
        if let myDate = dateFormatter.date(from: dateString){
            if let tomorrow = Calendar.current.date(byAdding: .day, value: incrtemnt, to: myDate){
                print("your next Date is \(tomorrow)")
                return tomorrow
            }
        }
        return Date()
    }
    
    
    func createCalendarSections(eventData : [TNCalendarEvent]) -> [String:[TNCalendarEvent]]{
        var dict = [String:[TNCalendarEvent]]()
        if eventData.count != 0{
            for event in eventData{
                let objStartDate =  temp(str :event.startDate.safeValue)
                let objEndDate =  temp(str :event.endDate.safeValue)
                
                
                
                let calendar = NSCalendar.current
                let date1 = calendar.startOfDay(for: objStartDate as Date)
                let date2 = calendar.startOfDay(for: objEndDate as Date)
                let components = calendar.dateComponents([.day], from: date1, to: date2)
                if let dayDiff = components.day{
                    for i in 0..<dayDiff + 1 {
                        let checkDate = convertNextDate(dateString: "\(objStartDate)",incrtemnt: i)
                        if dict["\(checkDate)"] == nil{
                            var insertArray = [TNCalendarEvent]()
                            
                            insertArray.append(event)
                            dict["\(checkDate)"] =  insertArray
                        }
                        else{
                            var allValues = dict["\(checkDate)"]
                            allValues?.append(event)
                            dict.removeValue(forKey: "\(checkDate)")
                            dict["\(checkDate)"] =  allValues
                        }
                        
                        
                    }
                }
            }
        }
        return dict
    }
    
    
    
    func findSections(eventData : [TNCalendarEvent]){
        
        var sectionValues = [String]()
        
        if eventData.count != 0{
            for each in eventData{
                if let date = each.startDate{
                    if let newDate = setDateFormatter(string: date){
                        sectionValues.append(newDate)
                    }
                }
                if let text = each.text{
                    var array = [String]()
                    array.append(text)
                    items.append(array)
                }
            }
        }
        
        sections = sectionValues.uniqueElements
    }
    
    func setDateFormatter(string : String) -> String?{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        guard let date = dateFormatter.date(from: string) else {return nil}
        //dateFormatter.dateFormat = "dd MMM yyyy"
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd,yyyy")
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func setDate(str : String) -> Date{
        let dateFormatter = DateFormatter()
       // dateFormatter.dateFormat = "MMM dd,yyyy"
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd,yyyy")
        if  let date = dateFormatter.date(from: str){
            print(date)
            return date
        }
        return Date()
    }
    
    
    
    
    func adEventsToCalendar() {
        for each in completeDates{
            let date = each.key
            let dated =   setDate(str: date)
            let day = self.getFormattedDate(date: dated).0
            let month = self.getFormattedDate(date: dated).1
            let year = self.getFormattedDate(date: dated).2
            if let dateval : Date = NSDate(day: UInt(day), month:UInt(month), year: UInt(year)) as Date?{
                
                if let events = each.value as? [TNCalendarEvent]{
                    if events.count > 0{
                        var eventArray = [CalendarEvent]()
                        for event in events{
                            let text = event.text.safeValue
                            
                            let events : CalendarEvent = CalendarEvent(title: text, andDate: dateval, andInfo: ["event": event])
                            events.color = UIColor.appOrangeColor()
                            eventArray.append(events)
                        }
                        self.data[dateval] = eventArray
                    }
                }
            }
        }
        
        
    }
    
    func getFormattedDate(date:Date) -> (Int,Int,Int){
        
        let date = date
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        
        return (day,month,year)
    }
    
    
    override func calendarView(_ calendarView: CalendarView, eventsFor date: Date) -> [CalendarEvent] {
        
        let eventsForDate = self.data[date] ?? []
        
        return eventsForDate
    }
    
    
    // MARK: - CKCalendarDelegate
    
    // Called before the selected date changes.
    override func calendarView(_ calendarView: CalendarView, didSelect date: Date) {
        super.calendarView(calendarView, didSelect: date) // Call super to ensure it
    }
    
    // Called after the selected date changes.
    override func calendarView(_ calendarView: CalendarView, willSelect date: Date) {
        
    }
    
    // A row was selected in the events table. (Use this to push a details view or whatever.)
    override func calendarView(_ calendarView: CalendarView, didSelect event: CalendarEvent) {
        showEventDetails(value: event)
    }
    
    func showEventDetails(value : CalendarEvent) {
        if let infoDict = value.info as NSDictionary? {
            if let value = infoDict["event"] as? TNCalendarEvent {
                let showTxt = "Name : \(value.text.safeValue)\n Start Date : \(value.startDate.safeValue) \n End Date : \(value.endDate.safeValue) \n Notes : \(value.details.safeValue)"
                let alertController = UIAlertController(title: "View Events", message:
                    showTxt, preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default,handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}



class EventCell : UITableViewCell{
    @IBOutlet weak var eventTextLabel: UILabel!
    
}



