//
//  NotificationsTableViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 25/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit

protocol NotificationsTableViewCellDelegate: AnyObject {
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didTapOnArrow button: UIButton, index: Int)
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didTapCell button: UIButton, index: Int)
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didSelectEmoji  emoji: String, type: String, index: Int)
}

class NotificationsTableViewCell: UITableViewCell {

    //MARK: - IBOutlet's -

    @IBOutlet weak var reactionViewTop: NSLayoutConstraint!
    @IBOutlet weak var reactionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reactionWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertDate: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var buttonArrow: UIButton!
    @IBOutlet weak var typeImageV: UIImageView!
    @IBOutlet weak var buttonCellDidTap: UIButton!
    @IBOutlet weak var reactionLabel: UILabel!

    weak var delegate: NotificationsTableViewCellDelegate?
    var index: Int = -1
    var emojiCount: Int = 0
    var reactionView: ReactionView?
    let imageToEmoji: [String: String] = [
        "wow": "😮",
        "love": "❤️",
        "like": "👍",
        "clapping hand": "👏",
        "party popper": "🎉"
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        [reactionViewTop,reactionHeightConstraint].forEach({$0?.constant = 0})
        reactionView = ReactionView()

        let reactions: [Reaction] = [Reaction(title: "wow", imageName: "icn_wow"),
                                     Reaction(title: "like", imageName: "icn_like"),
                                     Reaction(title: "party_popper", imageName: "icn_celebrate"),
                                     Reaction(title: "love", imageName: "icn_love"),
                                     Reaction(title: "clapping_hand", imageName: "icn_clap")]

        reactionView?.initialize(delegate: self , reactionsArray: reactions, sourceView: self.contentView, gestureView: buttonCellDidTap)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setUpReaction(reactions: TReaction) {
        reactionViewTop.constant = -25
        reactionHeightConstraint.constant = 30
        reactionWidthConstraint.constant = CGFloat(30 + (reactions.reactionCount * 25))
        emojiCount = 1
        reactionLabel.text = "\(reactions.emojis) \(reactions.totalReactionCount)  "
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reactionLabel.text = nil
    }

    @IBAction func buttonArrowDidTap(_ sender: UIButton) {
        delegate?.notificationsTableViewCell(self, didTapOnArrow: sender, index: index)
    }

    @IBAction func buttonCellDidTap(_ sender: UIButton) {
        delegate?.notificationsTableViewCell(self, didTapCell: sender, index: index)
    }
}


extension NotificationsTableViewCell: FacebookLikeReactionDelegate {
    func selectedReaction(reaction: Reaction) {
        delegate?.notificationsTableViewCell(self, didSelectEmoji: "\(imageToEmoji[reaction.title] ?? "")", type: reaction.title, index: index)
    }
}
