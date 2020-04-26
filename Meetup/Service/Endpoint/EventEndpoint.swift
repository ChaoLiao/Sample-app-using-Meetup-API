//
//  EventRequest.swift
//  Meetup
//
//  Created by YIN CHAO LIAO on 1/20/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import Foundation

struct EventsEndPoint: EndPoint {
    typealias Params = EventsEndPointParams
    typealias ResponseModel = [Event]
    
    let path = "find/events"
    let httpMethod = HTTPMethod.get
    
    let params: Params
}

struct EventsEndPointParams: EndPointParams {
    
    enum FieldName: String {
        case featuredPhoto = "featured_photo"
    }
    
    let searchKey: String
    let fields: [FieldName]?
    
    var httpParams: [String : Any]? {
        var params = [
            "text": searchKey
        ]
        if let fields = fields {
            params["fields"] = fields.reduce("") { (currentString, field) in
                if currentString!.isEmpty {
                    return currentString! + field.rawValue
                } else {
                    return currentString! + ",\(field.rawValue)"
                }
            }
        }
        return params
    }
    
    var httpBody: [String : Any]? {
        return nil
    }
}


extension MeetupAPI {
    func events(with searchKey: String, favoritedEventIds: [String: Bool] = [:], completion: @escaping RequestCompletionHandler<[Event]>) {
        let params = EventsEndPointParams(searchKey: searchKey, fields: [.featuredPhoto])
        let endpoint = EventsEndPoint(params: params)
        self.request(endpoint) { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(var events):
                for (i, event) in events.enumerated() {
                    if let isFavorited = favoritedEventIds[event.id], isFavorited {
                        events[i].isFavorited = true
                    }
                }
                completion(.success(events))
            }
        }
    }
}
