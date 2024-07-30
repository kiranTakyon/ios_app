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
            (wow, "😲"),
            (partyPopper, "🎉"),
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

    func increaseReactionCount(type: String)  {
    let reaction = ReactionType(rawValue: type)

        switch reaction {
        case .like:
            if let like = like {
                self.like = like + 1
            }
            break
        case .love:
            if let love = love {
                self.love = love + 1
            }
            break
        case .wow:
            if let wow = wow {
                self.wow = wow + 1
            }
            break
        case .partyPopper:
            if let partyPopper = partyPopper {
                self.partyPopper = partyPopper + 1
            }
            break
        case .clappingHand:
            if let clappingHand = clappingHand {
                self.clappingHand = clappingHand + 1
            }
            break
        case .none:
            break
        }
    }

    func decreaseReactionCount(type: String)  {
        let reaction = ReactionType(rawValue: type)

        switch reaction {
        case .like:
            if let like = like {
                self.like = like - 1
            }
            break
        case .love:
            if let love = love {
                self.love = love - 1
            }
            break
        case .wow:
            if let wow = wow {
                self.wow = wow - 1
            }
            break
        case .partyPopper:
            if let partyPopper = partyPopper {
                self.partyPopper = partyPopper - 1
            }
            break
        case .clappingHand:
            if let clappingHand = clappingHand {
                self.clappingHand = clappingHand - 1
            }
            break
        case .none:
            break
        }
    }

}
