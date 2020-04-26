//
//  Event.swift
//  Meetup
//
//  Created by YIN CHAO LIAO on 1/20/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import Foundation

struct Event: Decodable {
    
    let id: String
    let name: String
    let localDate: String
    let localTime: String
    let yesRsvpCount: Int
    let group: Group
    let photo: EventPhoto?
    let venue: Venue?
    
    var isFavorited = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case localDate = "local_date"
        case localTime = "local_time"
        case yesRsvpCount = "yes_rsvp_count"
        case group
        case photo = "featured_photo"
        case venue
    }
    
}
