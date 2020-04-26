//
//  Architecture.swift
//  Meetup
//
//  Created by YIN CHAO LIAO on 1/20/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import Foundation

protocol NetworkSessionDataTask {
    func cancel()
}

protocol NetworkSession {
    func loadData(from request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkSessionDataTask
}

protocol EndPointParams {
    var httpParams: [String: Any]? { get }
    var httpBody: [String: Any]? { get }
}

protocol EndPoint {
    associatedtype Params: EndPointParams
    associatedtype ResponseModel: Decodable
    
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var params: Params { get }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum Result<T> {
    case success(_ value: T)
    case failure(_ error: Error)
}

typealias RequestCompletionHandler<T> = (Result<T>) -> ()

