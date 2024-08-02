//
//  TReaction.swift
//  Ambassador Education
//
//  Created by IE12 on 30/07/24.
//  Copyright © 2024 InApp. All rights reserved.
//

import Foundation

enum ReactionType: String {
    case like = "like"
    case love = "love"
    case partyPopper = "party_popper"
    case wow = "wow"
    case clappingHand = "clapping_hand"
}

class TReaction: Codable {
    var like : Int?
    var love : Int?
    var partyPopper: Int?
    var wow: Int?
    var clappingHand: Int?

    init(values: NSDictionary) {
        self.like = values["like"] as? Int
        self.love = values["love"] as? Int
        self.partyPopper = values["party_popper"] as? Int
        self.wow = values["wow"] as? Int
        self.clappingHand = values["clapping_hand"] as? Int
    }

    var totalReactionCount: Int {
        return (like ?? 0) + (love ?? 0) + (partyPopper ?? 0) + (wow ?? 0) + (clappingHand ?? 0)
    }

    var emojis: String {
        var text = ""

        let reactions: [(Int?, String)] = [
            (like, "👍"),
            (love, "❤️"),
            (wow, "😮"),
            (partyPopper, "💡"),
            (clappingHand, "👏")
        ]

        for (count, emoji) in reactions {
            if (count ?? 0) > 0 {
                text += emoji
            }
        }

        return text
    }

    var reactionCount: Int {
        var count: Int = 0
        let reactions = [like, love, wow, partyPopper, clappingHand]
        for reaction in reactions {
            if (reaction ?? 0) > 0 {
                count += 1
            }
        }
        return count
    }

    func updateReactionCount(type: String, increase: Bool) {
        guard let reaction = ReactionType(rawValue: type) else { return }

        let increment = increase ? 1 : -1

        switch reaction {
        case .like:
            self.like = (self.like ?? 0) + increment
        case .love:
            self.love = (self.love ?? 0) + increment
        case .wow:
            self.wow = (self.wow ?? 0) + increment
        case .partyPopper:
            self.partyPopper = (self.partyPopper ?? 0) + increment
        case .clappingHand:
            self.clappingHand = (self.clappingHand ?? 0) + increment
        }
    }

    func increaseReactionCount(type: String) {
        updateReactionCount(type: type, increase: true)
    }

    func decreaseReactionCount(type: String) {
        updateReactionCount(type: type, increase: false)
    }
}
