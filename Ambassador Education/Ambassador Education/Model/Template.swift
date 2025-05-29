//
//  Template.swift
//  Ambassador Education
//
//  Created by IE14 on 29/05/25.
//  Copyright © 2025 InApp. All rights reserved.
//


struct TemplateResponse: Codable {
    let statusCode: Int
    let statusMessage: String
    let templates: [Template]
    let paginationNumber, paginationMaxCount, templateCount: Int
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "StatusCode"
        case statusMessage = "StatusMessage"
        case templates = "Templates"
        case paginationNumber = "PaginationNumber"
        case paginationMaxCount = "PaginationMaxCount"
        case templateCount = "TemplateCount"
    }
    
    init(values: NSDictionary) {
        self.statusCode = values["StatusCode"] as? Int ?? 0
        self.statusMessage = values["StatusMessage"] as? String ?? ""
        self.paginationNumber = values["PaginationNumber"] as? Int ?? 0
        self.paginationMaxCount = values["PaginationMaxCount"] as? Int ?? 0
        self.templateCount = values["TemplateCount"] as? Int ?? 0
        
        if let templateArray = values["Templates"] as? [NSDictionary] {
            self.templates = templateArray.map { Template(values: $0) }
        } else {
            self.templates = []
        }
    }
}

// MARK: - Template
struct Template: Codable {
    let templateID, templateName, templateMessage: String
    
    enum CodingKeys: String, CodingKey {
        case templateID = "TemplateId"
        case templateName = "TemplateName"
        case templateMessage = "TemplateMessage"
    }
    
    var dictionary: [String: Any]? {
        return try? JSONSerialization.jsonObject(
            with: JSONEncoder().encode(self),
            options: []
        ) as? [String: Any]
    }
    
    init(values: NSDictionary) {
        self.templateID = values["TemplateId"] as? String ?? ""
        self.templateName = values["TemplateName"] as? String ?? ""
        self.templateMessage = values["TemplateMessage"] as? String ?? ""
    }
}
