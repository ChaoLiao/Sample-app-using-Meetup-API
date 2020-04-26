//
//  MeetupAPI.swift
//  Meetup
//
//  Created by YIN CHAO LIAO on 1/20/19.
//  Copyright © 2019 CHAO LIAO. All rights reserved.
//

import Foundation

extension URLSession: NetworkSession {
    func loadData(from request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> NetworkSessionDataTask {
        let task = dataTask(with: request) { (data, response, error) in
            completionHandler(data, response, error)
        }
        task.resume()
        return task
    }
}

extension URLSessionDataTask: NetworkSessionDataTask {}

class MeetupAPI {
    
    enum SearchRequestError: Error, Equatable {
        case invalidRequest
        case unsuccessfulResponse(Int?)
        case invalidDataReturned
    }
    
    private let networkSession: NetworkSession
    private var networkSessionDataTask: NetworkSessionDataTask?
    
    private let apiKey = "483f3e6c9125d502715067133215f"
    private let baseURL = URL(string: "https://api.meetup.com")
    
    init(networkSession: NetworkSession = URLSession.shared) {
        self.networkSession = networkSession
    }
    
    func request<T: EndPoint>(_ endpoint: T, completion: @escaping RequestCompletionHandler<T.ResponseModel>) {
        networkSessionDataTask?.cancel()
        
        guard let request = constructRequest(endpoint) else {
            completion(.failure(SearchRequestError.invalidRequest))
            return
        }
        
        networkSessionDataTask = networkSession.loadData(from: request) { [weak self] (data, response, error) in
            defer { self?.networkSessionDataTask = nil }
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
                else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                    completion(.failure(SearchRequestError.unsuccessfulResponse(statusCode)))
                    return
            }
            
            guard let data = data else {
                completion(.failure(SearchRequestError.invalidDataReturned))
                return
            }
            do {
                let model = try JSONDecoder().decode(T.ResponseModel.self, from: data)
                completion(.success(model))
            } catch let error {
                completion(.failure(error))
            }
        }
    }
    
    private func constructRequest<T: EndPoint>(_ endpoint: T) -> URLRequest? {
        guard let url = URL(string: endpoint.path, relativeTo: baseURL) else {
            return nil
        }
        
        guard var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "sign", value: "true"),
            URLQueryItem(name: "key", value: apiKey)
        ]
        if let httpParams = endpoint.params.httpParams {
            for (key, value) in httpParams {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                urlComponents.queryItems?.append(queryItem)
            }
        }
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = endpoint.httpMethod.rawValue
        
        if request.httpMethod == HTTPMethod.post.rawValue {
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            
            if let httpBody = endpoint.params.httpBody {
                request.httpBody = try? JSONSerialization.data(withJSONObject: httpBody, options: [])
            }
        }
        return request
    }
}
