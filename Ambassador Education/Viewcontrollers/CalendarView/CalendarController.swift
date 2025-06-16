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
    let takyonRed = UIColor(red: 233/255, green: 80/255, blue: 59/255, alpha: 1)

    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MMMM" // "dd/MM"
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
        super.viewWillAppear(animated)
        setNavigationBar() // Set navigation bar when the view appears
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the entire view's background color to red (including the Safe Area)
        self.view.backgroundColor = takyonRed

        // Set the calendar properties or other configurations
        setCalender()
        getCalendarEvents()
    }
    
    func setNavigationBar() {
        // Set the background color of the navigation bar to system red
        self.navigationController?.navigationBar.barTintColor = takyonRed

        // Set the title color to white
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]

        // Set the left bar button item to have a white tint color
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "Menu2"),
            style: .plain,
            target: self.revealViewController(),
            action: #selector(SWRevealViewController.revealToggle(_:))
        )
        navigationItem.leftBarButtonItem?.tintColor = .white

        // Set the right bar button item to have a white tint color
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "LogOut2"),
            style: .plain,
            target: self,
            action: #selector(logOutAction)
        )
        navigationItem.rightBarButtonItem?.tintColor = .white

        // Set the status bar to light content (white text on red background)
        if #available(iOS 13.0, *) {
            self.setNeedsStatusBarAppearanceUpdate()
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
        }
    }

    // Override the status bar style for iOS 13 and later
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent  // White status bar text for red background
    }
    
    @objc func logOutAction() {
        SweetAlert().showAlert("Confirm please", subTitle: "Are you sure, you want to logout?", style: AlertStyle.warning, buttonTitle: "Want to stay", buttonColor: UIColor.lightGray, otherButtonTitle: "Yes, Please!", otherButtonColor: UIColor.red) { (isOtherButton) -> Void in
            if isOtherButton == true {
                // Handle "Stay" button click
            } else {
                isFirstTime = true
                gradeBookLink = ""
                showLoginPage() // Call function to show the login page
            }
        }
    }

    func setCalender() {
        self.delegate = self
        self.dataSource = self
    }
    
    deinit {
        print("\(#function)")
    }
    
    func getCalendarEvents() {
        self.data = [:]
        startLoadingAnimation()
        let url = APIUrls().getCalendarEvents
        
        var dictionary = [String: Any]()
        let userId = UserDefaultsManager.manager.getUserId()
        
        dictionary[UserIdKey().id] = userId
        
        APIHelper.sharedInstance.apiCallHandler(url, requestType: .POST, requestString: "", requestParameters: dictionary) { (result) in
            DispatchQueue.main.async {
                guard let title = result["CalendarLabel"] as? String else { return }
                self.title = title
                
                guard let events = result["Events"] as? NSArray else {
                    self.stopLoadingAnimation()
                    SweetAlert().showAlert(kAppName, subTitle: "Something went wrong", style: .success)
                    return
                }
                
                if events.count == 0 {
                    self.stopLoadingAnimation()
                    SweetAlert().showAlert(kAppName, subTitle: "No Events", style: .success)
                } else {
                    if let eventObjs = ModelClassManager.sharedManager.createModelArray(data: events, modelType: .TNCalendarEvent) as? [TNCalendarEvent] {
                        self.completeDates = self.createCalendarSections(eventData: eventObjs)
                        self.eventData = eventObjs
                        self.adEventsToCalendar()
                        self.stopLoadingAnimation()
                    } else {
                        self.stopLoadingAnimation()
                    }
                }
            }
        }
    }
    
    func getAllStartDates() -> [String] {
        var startDateArr = [String]()
        if eventData.count != 0 {
            for each in eventData {
                startDateArr.append(each.startDate.safeValue)
            }
        }
        return startDateArr
    }
    
    func convertNextDate(dateString: String, incrtemnt: Int) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd,yyyy")
        if let myDate = dateFormatter.date(from: dateString) {
            if let tomorrow = Calendar.current.date(byAdding: .day, value: incrtemnt, to: myDate) {
                return tomorrow
            }
        }
        return Date()
    }
    
    func createCalendarSections(eventData: [TNCalendarEvent]) -> [String:[TNCalendarEvent]] {
        var dict = [String:[TNCalendarEvent]]()
        if eventData.count != 0 {
            for event in eventData {
                let objStartDate = temp(str: event.startDate.safeValue)
                let objEndDate = temp(str: event.endDate.safeValue)
                
                let calendar = NSCalendar.current
                let date1 = calendar.startOfDay(for: objStartDate as Date)
                let date2 = calendar.startOfDay(for: objEndDate as Date)
                let components = calendar.dateComponents([.day], from: date1, to: date2)
                if let dayDiff = components.day {
                    for i in 0..<dayDiff + 1 {
                        let checkDate = convertNextDate(dateString: "\(objStartDate)", incrtemnt: i)
                        if dict["\(checkDate)"] == nil {
                            var insertArray = [TNCalendarEvent]()
                            insertArray.append(event)
                            dict["\(checkDate)"] = insertArray
                        } else {
                            var allValues = dict["\(checkDate)"]
                            allValues?.append(event)
                            dict.removeValue(forKey: "\(checkDate)")
                            dict["\(checkDate)"] = allValues
                        }
                    }
                }
            }
        }
        return dict
    }

    func findSections(eventData: [TNCalendarEvent]) {
        var sectionValues = [String]()
        
        if eventData.count != 0 {
            for each in eventData {
                if let date = each.startDate {
                    if let newDate = setDateFormatter(string: date) {
                        sectionValues.append(newDate)
                    }
                }
                if let text = each.text {
                    var array = [String]()
                    array.append(text)
                    items.append(array)
                }
            }
        }
        
        sections = sectionValues.uniqueElements
    }

    func setDateFormatter(string: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        guard let date = dateFormatter.date(from: string) else { return nil }
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd,yyyy")
        return dateFormatter.string(from: date)
    }

    func setDate(str: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd,yyyy")
        if let date = dateFormatter.date(from: str) {
            return date
        }
        return Date()
    }
    
    func adEventsToCalendar() {
        for each in completeDates {
            let date = each.key
            let dated = setDate(str: date)
            let day = self.getFormattedDate(date: dated).0
            let month = self.getFormattedDate(date: dated).1
            let year = self.getFormattedDate(date: dated).2
            if let dateval: Date = NSDate(day: UInt(day), month: UInt(month), year: UInt(year)) as Date? {
                
                if let events = each.value as? [TNCalendarEvent] {
                    if events.count > 0 {
                        var eventArray = [CalendarEvent]()
                        for event in events {
                            let cleanedText = event.text.safeValue.replacingOccurrences(of: "•", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                            let events: CalendarEvent = CalendarEvent(title: cleanedText, andDate: dateval, andInfo: ["event": event])
                            events.color = UIColor.appTransparantColor()
                            eventArray.append(events)
                        }
                        self.data[dateval] = eventArray
                    }
                }
            }
        }
    }
    
    func getFormattedDate(date: Date) -> (Int, Int, Int) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return (day, month, year)
    }
    
    override func calendarView(_ calendarView: CalendarView, eventsFor date: Date) -> [CalendarEvent] {
        return self.data[date] ?? []
    }
    
    // MARK: - CKCalendarDelegate
    
    override func calendarView(_ calendarView: CalendarView, didSelect date: Date) {
        super.calendarView(calendarView, didSelect: date) // Call super to ensure it
    }
    
    override func calendarView(_ calendarView: CalendarView, willSelect date: Date) {
        // Handle selection if needed
    }
    
    override func calendarView(_ calendarView: CalendarView, didSelect event: CalendarEvent) {
        showEventDetails(value: event)
    }

    func showEventDetails(value: CalendarEvent) {
        if let infoDict = value.info as NSDictionary? {
            if let value = infoDict["event"] as? TNCalendarEvent {
                let showTxt = "Name : \(value.text.safeValue)\n Start Date : \(value.startDate.safeValue) \n End Date : \(value.endDate.safeValue) \n Notes : \(value.details.safeValue)"
                let alertController = UIAlertController(title: "View Events", message: showTxt, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
