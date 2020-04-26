//
//  MeetupAPITest.swift
//  MeetupTests
//
//  Created by YIN CHAO LIAO on 1/20/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import XCTest
@testable import Meetup

class MeetupAPITest: XCTestCase {

    func testFindEventsWithError() {
        struct TestError: Error {}
        let networkSession = NetworkSessionMock(error: TestError())
        let meetupAPI = MeetupAPI(networkSession: networkSession)
        var completionHandlerCalled = false
        
        meetupAPI.events(with: "test search key") { (result) in
            completionHandlerCalled = true
            switch result {
            case .success(_):
                XCTAssert(false, "The request should fail.")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertTrue(error is TestError)
            }
        }
        
        XCTAssertTrue(completionHandlerCalled)
    }
    
    func testFindEventsWithUnsuccessfulResponse() {
        let expectedStatusCode = 400
        let response = HTTPURLResponse(url: URL(string: "testurl")!, statusCode: expectedStatusCode, httpVersion: nil, headerFields: nil)
        let networkSession = NetworkSessionMock(response: response)
        let meetupAPI = MeetupAPI(networkSession: networkSession)
        var completionHandlerCalled = false
        
        meetupAPI.events(with: "test search key") { (result) in
            completionHandlerCalled = true
            switch result {
            case .success(_):
                XCTAssert(false, "The request should fail.")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertTrue(error is MeetupAPI.SearchRequestError)
                
                let error = error as! MeetupAPI.SearchRequestError
                XCTAssertEqual(error, .unsuccessfulResponse(expectedStatusCode))
            }
        }
        XCTAssertTrue(completionHandlerCalled)
    }
    
    func testFindEventsWithoutData() {
        let response = HTTPURLResponse(url: URL(string: "testurl")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let networkSession = NetworkSessionMock(data: nil, response: response, error: nil)
        let meetupAPI = MeetupAPI(networkSession: networkSession)
        var completionHandlerCalled = false
        
        meetupAPI.events(with: "test search key") { (result) in
            completionHandlerCalled = true
            switch result {
            case .success(_):
                XCTAssert(false, "The request should fail.")
            case .failure(let error):
                XCTAssertNotNil(error)
                XCTAssertTrue(error is MeetupAPI.SearchRequestError)
                
                let error = error as! MeetupAPI.SearchRequestError
                XCTAssertEqual(error, .invalidDataReturned)
            }
        }
        XCTAssertTrue(completionHandlerCalled)
    }

    func testFindEventsSuccess() {
        let response = HTTPURLResponse(url: URL(string: "testurl")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        let json: [[String: Any]] = [
            [
                "id": "1",
                "name": "test name",
                "local_date": "2012-03-12",
                "local_time": "18:45",
                "yes_rsvp_count": 21,
                "group": [
                    "id": 10,
                    "name": "NYC Meditation",
                    "localized_location": "Manhattan, NY"
                ],
                "venue": [
                    "id": 100,
                    "name": "Madison Square Garden"
                ],
                "featured_photo": [
                    "id": 1000,
                    "highres_link": "highres_link",
                    "photo_link": "photo_link",
                    "thumb_link": "thumb_link"
                ]
            ],
            [
                "id": "2",
                "name": "test name 2",
                "local_date": "2012-03-13",
                "local_time": "18:45",
                "yes_rsvp_count": 169,
                "group": [
                    "id": 20,
                    "name": "SF Salsa Dance",
                    "localized_location": "San Francisco, CA"
                ],
                "venue": [
                    "id": 200,
                    "name": "Space 550"
                ],
            ]
            
        ]
        let data: Data?
        do {
            data = try JSONSerialization.data(withJSONObject: json)
        } catch {
            XCTAssert(false, "invalid json data")
            return
        }
        let networkSession = NetworkSessionMock(data: data, response: response)
        
        let meetupAPI = MeetupAPI(networkSession: networkSession)
        
        var completionHandlerCalled = false
        meetupAPI.events(with: "test search key", favoritedEventIds: ["1": true]) { (result) in
            completionHandlerCalled = true
            switch result {
            case .failure(let error):
                XCTAssert(false, "The request should succeed but encountered the error: \(error)")
            case .success(let events):
                XCTAssertFalse(events.isEmpty)
                XCTAssertTrue(events[0].isFavorited)
                XCTAssertFalse(events[1].isFavorited)
            }
        }
        
        XCTAssertTrue(completionHandlerCalled)
    }

}
