//
//  EventViewModel.swift
//  Meetup
//
//  Created by YIN CHAO LIAO on 1/21/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import UIKit

class EventCellViewModel {
    
    let id: String
    let name: String
    let group: String
    let imageUrl: URL?
    let venue: String
    let dateTime: String
    let yesRsvp: String
    
    private var imageDataTask: NetworkSessionDataTask?
    var image: UIImage?
    var isFavorited = false
    
    static let dateFormatterForDate: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return dateFormatter
    }()
    
    static let dateFormatterForString: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MM/dd/yyyy HH:MM a"
        return dateFormatter
    }()
    
    init(eventModel: Event) {
        self.id = eventModel.id
        self.name = eventModel.name
        self.group = eventModel.group.name
        
        if let photoLink = eventModel.photo?.photoLink {
            self.imageUrl = URL(string: photoLink)
        } else {
            self.imageUrl = nil
        }
        
        self.venue = eventModel.venue?.name ?? "This event has no venue"
        
        if let date = EventCellViewModel.dateFormatterForDate.date(from: "\(eventModel.localDate)T\(eventModel.localTime)") {
            self.dateTime = EventCellViewModel.dateFormatterForString.string(from: date)
        } else {
            self.dateTime = ""
        }
        
//        self.dateTime = EventCellViewModel.formateDate(isoString: "\(eventModel.localDate)T\(eventModel.localTime)")
        
        if eventModel.yesRsvpCount == 1 {
            self.yesRsvp = "1 person is going"
        } else if eventModel.yesRsvpCount > 1 {
            self.yesRsvp = "\(eventModel.yesRsvpCount) people are going"
        } else {
            self.yesRsvp = ""
        }
        self.isFavorited = eventModel.isFavorited
    }
    
//    static func formateDate(isoString: String) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
//        guard let date = dateFormatter.date(from: isoString) else {
//            return ""
//        }
//        dateFormatter.dateFormat = "EEE, MM/dd/yyyy HH:MM a"
//        return dateFormatter.string(from: date)
//    }
    
    func loadImage(networkSession: NetworkSession = URLSession.shared, completionHandler: @escaping (_ image: UIImage?) -> Void) {
        guard let imageUrl = imageUrl else {
            completionHandler(nil)
            return
        }
        if let image = image {
            completionHandler(image)
            return
        }
        imageDataTask?.cancel()
        
        let request = URLRequest(url: imageUrl)
        imageDataTask = networkSession.loadData(from: request) { [weak self] (data, response, error) in
            guard let `self` = self else { return }
            if let error = error {
                print(error.localizedDescription)
                completionHandler(nil)
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200,
                let data = data,
                let image = UIImage(data: data)
                else {
                    completionHandler(nil)
                    return
            }
            self.image = image
            completionHandler(image)
        }
    }
}
