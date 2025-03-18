//
//  NotificationsTableViewCell.swift
//  Ambassador Education
//
//  Created by IE Mac 05 on 25/07/23.
//  Copyright © 2023 InApp. All rights reserved.
//

import UIKit
import AVFoundation

protocol NotificationsTableViewCellDelegate: AnyObject {
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didTapOnArrow button: UIButton, index: Int)
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didTapCell button: UIButton, index: Int)
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didSelectEmoji  emoji: String, type: String, index: Int)
    func notificationsTableViewCell(_ cell: NotificationsTableViewCell, didProfileTapped button: UIButton, index: Int)

}

class NotificationsTableViewCell: UITableViewCell {

    //MARK: - IBOutlet's -

    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertDate: UILabel!
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var buttonArrow: UIButton!
    @IBOutlet weak var typeImageV: ImageLoader!
    @IBOutlet weak var buttonCellDidTap: UIButton!
    @IBOutlet weak var reactionLabel: UILabel!
    @IBOutlet weak var buttonEmojiDidTap: UIButton!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var videoPlayerView: UIView!

    weak var delegate: NotificationsTableViewCellDelegate?
    var index: Int = -1
    var emojiCount: Int = 0
    var reactionView: ReactionView?
    let imageToEmoji: [String: String] = [
        "wow": "😮",
        "love": "❤️",
        "like": "👍",
        "clapping_hand": "👏",
        "party_popper": "💡"
    ]

    var avPlayer: AVPlayer?
    var playerLayer: AVPlayerLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        reactionView = ReactionView()

        let reactions: [Reaction] = [Reaction(title: "wow", imageName: "icn_wow"),
                                     Reaction(title: "like", imageName: "icn_like"),
                                     Reaction(title: "party_popper", imageName: "icn_celebrate"),
                                     Reaction(title: "love", imageName: "icn_love"),
                                     Reaction(title: "clapping_hand", imageName: "icn_clap")]

        reactionView?.initialize(delegate: self , reactionsArray: reactions, sourceView: self.contentView, gestureView: buttonEmojiDidTap)
        buttonEmojiDidTap.setTitle("☺", for: .normal)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.videoGravity = .resize
        playerLayer?.frame = videoPlayerView.bounds
    }

    func setUpVideoView(url: String) {
        if let url = URL(string: url) {
            avPlayer = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: avPlayer)
            playerLayer?.frame = videoPlayerView.bounds
            videoPlayerView.layer.addSublayer(playerLayer!)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: avPlayer?.currentItem)
        }
    }

    func playVideo() {
        avPlayer?.play()
    }

    func pauseVideo() {
        avPlayer?.pause()
    }

    @objc private func playerDidFinishPlaying() {
        avPlayer?.seek(to: .zero)
       // avPlayer?.play()
    }

    func setUpReaction(reactions: TReaction) {
        emojiCount = 1
        reactionLabel.text = "\(reactions.emojis) \(reactions.totalReactionCount)  "
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        reactionLabel.text = nil
        typeImageV.image = nil
        playIcon.isHidden = true
        playerLayer?.removeFromSuperlayer()
        avPlayer?.pause()
        avPlayer = nil
        playerLayer = nil
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func buttonArrowDidTap(_ sender: UIButton) {
        delegate?.notificationsTableViewCell(self, didTapOnArrow: sender, index: index)
    }

    @IBAction func buttonCellDidTap(_ sender: UIButton) {
        delegate?.notificationsTableViewCell(self, didTapCell: sender, index: index)
    }
    
    @IBAction func profileButtonTapped(_ sender: UIButton){
        delegate?.notificationsTableViewCell(self, didProfileTapped: sender, index: index)
    }
}

extension NotificationsTableViewCell: FacebookLikeReactionDelegate {
    func selectedReaction(reaction: Reaction) {
        delegate?.notificationsTableViewCell(self, didSelectEmoji: "\(imageToEmoji[reaction.title] ?? "")", type: reaction.title, index: index)
    }
}

