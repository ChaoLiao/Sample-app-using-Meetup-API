//
//  EventCellViewModelTest.swift
//  MeetupTests
//
//  Created by YIN CHAO LIAO on 1/22/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import XCTest
@testable import Meetup

class EventCellViewModelTest: XCTestCase {
    
    var venue: Venue!
    var group: Group!
    var photo: EventPhoto!
    
    override func setUp() {
        venue = Venue(id: 10, name: "test venue")
        group = Group(id: 11, name: "test group", location: "test location")
        photo = EventPhoto(id: 30, highresLink: "", photoLink: "testphotolink", thumbLink: "")
    }
    
    func testViewModelFromDataModel() {
        let expectedEventId = "30"
        let expectedName = "test name"
        let expectedGroup = "test group"
        let expectedVenue = "test venue"
        let expectedImageUrl = "testImageUrl"
        
        let expectedYesRsvpCount = 101
        let expectedYesRsvpString = "\(expectedYesRsvpCount) people are going"
        
        
        let isoDateString = "2012-03-09T19:00"
        let expectedDateTime: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            let date = dateFormatter.date(from: isoDateString)!
            dateFormatter.dateFormat = "EEE, MM/dd/yyyy HH:MM a"
            return dateFormatter.string(from: date)
        }()
        
        let venue = Venue(id: 10, name: expectedVenue)
        let group = Group(id: 20, name: expectedGroup, location: "test location")
        let photo = EventPhoto(id: 30, highresLink: "", photoLink: expectedImageUrl, thumbLink: "")
        let event1 = Event(id: expectedEventId, name: expectedName, localDate: "2012-03-09", localTime: "19:00", yesRsvpCount: expectedYesRsvpCount, group: group, photo: photo, venue: venue, isFavorited: true)
        
        let viewModel1 = EventCellViewModel(eventModel: event1)
        
        XCTAssertEqual(viewModel1.id, expectedEventId)
        XCTAssertEqual(viewModel1.name, expectedName)
        XCTAssertEqual(viewModel1.group, expectedGroup)
        XCTAssertEqual(viewModel1.venue, expectedVenue)
        XCTAssertEqual(viewModel1.imageUrl, URL(string: expectedImageUrl))
        XCTAssertEqual(viewModel1.dateTime, expectedDateTime)
        XCTAssertEqual(viewModel1.yesRsvp, expectedYesRsvpString)
        XCTAssertTrue(viewModel1.isFavorited)
    }
    
    func testViewModelNoYesRsvp() {
        let event = Event(id: "1", name: "test name", localDate: "2012-03-09", localTime: "19:00", yesRsvpCount: 0, group: group, photo: nil, venue: venue, isFavorited: true)
        let viewModel = EventCellViewModel(eventModel: event)
        XCTAssertEqual(viewModel.yesRsvp, "")
    }
    
    func testViewModelOneYesRsvp() {
        let event = Event(id: "1", name: "test name", localDate: "2012-03-09", localTime: "19:00", yesRsvpCount: 1, group: group, photo: nil, venue: venue, isFavorited: true)
        let viewModel = EventCellViewModel(eventModel: event)
        XCTAssertEqual(viewModel.yesRsvp, "1 person is going")
    }
    
    func testViewModelNoVenue() {
        let event = Event(id: "1", name: "test name", localDate: "2012-03-09", localTime: "19:00", yesRsvpCount: 1, group: group, photo: nil, venue: nil, isFavorited: true)
        let viewModel = EventCellViewModel(eventModel: event)
        XCTAssertEqual(viewModel.venue, "This event has no venue")
    }

    func testLoadImageWithoutImageUrl() {
        let event = Event(id: "13", name: "test name", localDate: "2019-02-19", localTime: "03:00", yesRsvpCount: 0, group: group, photo: nil, venue: venue, isFavorited: false)
        
        let viewModel = EventCellViewModel(eventModel: event)
        let networkSessionMock = NetworkSessionMock()
        var completionHandlerCalled = false
        
        viewModel.loadImage(networkSession: networkSessionMock) { (image) in
            completionHandlerCalled = true
            XCTAssertNil(image)
            XCTAssertFalse(networkSessionMock.didLoadData)
        }
        XCTAssertTrue(completionHandlerCalled)
    }
    
    func testLoadImageWhenImageAlreadyLoaded() {
        let event = Event(id: "13", name: "test name", localDate: "2019-02-19", localTime: "03:00", yesRsvpCount: 0, group: group, photo: photo, venue: venue, isFavorited: false)
        
        let viewModel = EventCellViewModel(eventModel: event)
        viewModel.image = UIImage()
        let networkSessionMock = NetworkSessionMock()
        var completionHandlerCalled = false
        
        viewModel.loadImage(networkSession: networkSessionMock) { (image) in
            completionHandlerCalled = true
            XCTAssertNotNil(image)
            XCTAssertFalse(networkSessionMock.didLoadData)
        }
        XCTAssertTrue(completionHandlerCalled)
    }
    
    func testLoadImageFromUrl() {
        let event = Event(id: "13", name: "test name", localDate: "2019-02-19", localTime: "03:00", yesRsvpCount: 0, group: group, photo: photo, venue: venue, isFavorited: false)
        
        let viewModel = EventCellViewModel(eventModel: event)
        
        let response = HTTPURLResponse(url: URL(string: "testthumblink")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let data = UIImage(named: "icon-placeholder")!.pngData()
        let networkSessionMock = NetworkSessionMock(data: data, response: response, error: nil)
        var completionHandlerCalled = false
        
        viewModel.loadImage(networkSession: networkSessionMock) { (image) in
            completionHandlerCalled = true
            XCTAssertNotNil(image)
            XCTAssertTrue(networkSessionMock.didLoadData)
        }
        XCTAssertTrue(completionHandlerCalled)
    }
}
