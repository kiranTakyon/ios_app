

class TUpcomingEvent: Codable {

    var startDate : String?
    var title : String?
    var type : String?
    var endDate : String?
    var ageTo : String?
    var ageFrom : String?
    var image: String?


    init(values:NSDictionary) {
        self.startDate = values["StartDate"] as? String
        self.title = values["Title"] as? String
        self.type = values["Type"] as? String
        self.endDate = values["EndDate"] as? String
        self.ageTo = values["AgeTo"] as? String
        self.ageFrom = values["AgeFrom"] as? String
        self.image = values["Img_url"] as? String
    }

}
