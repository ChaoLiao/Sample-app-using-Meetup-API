//
//  Mocks.swift
//  MeetupTests
//
//  Created by YIN CHAO LIAO on 1/20/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import Foundation
@testable import Meetup

class NetworkSessionMock: NetworkSession {
    var data: Data?
    var response: URLResponse?
    var error: Error?
    private(set) var didLoadData = false
    
    init(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    func loadData(from request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkSessionDataTask {
        didLoadData = true
        completionHandler(data, response, error)
        return NetworkSessionDataTaskMock()
    }
}

class NetworkSessionDataTaskMock: NetworkSessionDataTask {
    func cancel() {}
}

class KeyValueStoreMock: KeyValueStoreProtocol {
    var store = [String: Any]()
    
    func set(_ value: Any?, forKey key: String) {
        store[key] = value
    }
    
    func dictionary(forKey key: String) -> [String: Any]? {
        if let value = store[key] as? [String: Any] {
            return value
        }
        return nil
    }
}

