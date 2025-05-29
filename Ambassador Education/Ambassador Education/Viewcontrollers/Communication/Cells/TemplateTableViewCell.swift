//
//  TemplateTableViewCell.swift
//  CredenceSchool
//
//  Created by IE14 on 28/05/25.
//  Copyright © 2025 InApp. All rights reserved.
//

import UIKit

protocol TemplateTableViewCellDelegate: AnyObject {
    func templateTableViewCellDidTapEdit(_ cell: TemplateTableViewCell)
    func templateTableViewCellDidTapDelete(_ cell: TemplateTableViewCell)
}

class TemplateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    static let identifier = "TemplateTableViewCell"
    weak var delegate: TemplateTableViewCellDelegate?
    var template: Template?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setData(template: Template) {
        self.template = template
        titleLabel.text = template.templateName
        setHTML(to: messageLabel, html: template.templateMessage)
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        delegate?.templateTableViewCellDidTapEdit(self)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        delegate?.templateTableViewCellDidTapDelete(self)
    }
    
    func setHTML(to label: UILabel, html: String) {
        guard let data = html.data(using: .utf8) else { return }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            label.attributedText = attributedString
            label.numberOfLines = 0
        }
    }
    
}
