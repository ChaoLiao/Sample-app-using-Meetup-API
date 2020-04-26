//
//  Group.swift
//  Meetup
//
//  Created by YIN CHAO LIAO on 1/20/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import Foundation

struct Group: Decodable {
    
    let id: Int
    let name: String
    let location: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location = "localized_location"
    }
}
