//
//  Photo.swift
//  Meetup
//
//  Created by YIN CHAO LIAO on 1/20/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import Foundation

struct EventPhoto: Decodable {
    
    let id: Int
    let highresLink: String
    let photoLink: String
    let thumbLink: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case highresLink = "highres_link"
        case photoLink = "photo_link"
        case thumbLink = "thumb_link"
    }
}
