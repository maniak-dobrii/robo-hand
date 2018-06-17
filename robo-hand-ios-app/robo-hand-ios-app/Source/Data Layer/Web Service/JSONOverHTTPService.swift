//
//  JSONOverHTTPService.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 2/24/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

/*
    Extremely simple NSURLSession wrapper for performing HTTP requests in a local network.
 
    Expects response in JSON or JSON fragments.
 
    Important behavioral details:
        o No HTTP code interpretation. Any HTTP response code is a "success".
        o For "success" response body must be rather empty or valid JSON/JSON fragment
 */


import Foundation

enum JSONOverHTTPServiceError: Error {
    /// Unable to establish connection or connection dropped in mid-air
    case unableToConnect
    
    /// Server response is not a valid JSON or JSON fragment
    case responseNotAJSON(responseData: Data)
    
    /// Server responded with bad data (that can't even be tried to get parsed as JSON)
    case badResponseFormat
    
    /// Something else unclassified, `error` contains initial error
    case other(error: Error?)
}

struct JSONOverHTTPServiceResponse {
    let httpCode: Int
    let json: Any?
}

protocol JSONOverHTTPServiceTask: CancellableTask {
}

class JSONOverHTTPService {
    // yepp, only strings as values, arrays, numbers and bools are not supported
    typealias RequestParameters = [String: String?]
    typealias Result = TaskResult<JSONOverHTTPServiceResponse, JSONOverHTTPServiceError>
    typealias CompletionHandler = ((task: JSONOverHTTPServiceTask?, result: Result)) -> Void
    
    private let session: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpMaximumConnectionsPerHost = 1 // server in device supports only one simultaneous connection
        configuration.urlCache = nil // disable response caching
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData // no caching
        
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - GET
    @discardableResult
    func get(baseURLString: String,
             path: String?,
             parameters: RequestParameters?,
             withCompletionHandler completionHandler: CompletionHandler?) -> JSONOverHTTPServiceTask? {
        
        guard let url = self.url(fromBase: baseURLString, path: path, byAddingQueryParameters: parameters) else {
            DispatchQueue.main.async {
                let error = NSError(domain: String(describing: type(of: self)),
                                    code: 0,
                                    userInfo: [NSLocalizedDescriptionKey: "Unable to construct URL"])
                let webServiceError: JSONOverHTTPServiceError = .other(error: error)
                completionHandler?((task: nil, result: .failed(error: webServiceError)))
            }
            return nil
        }
        
        return get(url: url, withCompletionHandler: completionHandler)
    }
    
    @discardableResult
    func get(url: URL, withCompletionHandler completionHandler: CompletionHandler?) -> JSONOverHTTPServiceTask {
        var callbackTask: URLSessionTask?
        
        let task = self.session.dataTask(with: url) { (data, urlResponse, error) in
            let taskResult: Result = self.processDataTask(data: data, urlResponse: urlResponse, error: error)
            completionHandler?((task: callbackTask, result: taskResult))
        }
        
        callbackTask = task
        task.resume()
        
        return task
    }
    
    
    // MARK: - Private
    private func processDataTask(data: Data?, urlResponse: URLResponse?, error: Error?) -> Result {
        guard let httpURLResponse = urlResponse as? HTTPURLResponse else { return .failed(error: .other(error: nil)) }
        
        if let data = data {
            let httpCode: Int = httpURLResponse.statusCode

            // Empty response is a valid response
            guard data.isEmpty == false else {
                let emptyResponse = JSONOverHTTPServiceResponse(httpCode: httpCode, json: nil)
                return .succeeded(result: emptyResponse)
            }
            
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: [.allowFragments]) {
                let response = JSONOverHTTPServiceResponse(httpCode: httpCode, json: jsonObject)
                return .succeeded(result: response)
            }
            else {
                return .failed(error: .responseNotAJSON(responseData: data))
            }
        }
        else {
            return self.processFailedDataTaskURLTaskError(error)
        }
    }
    
    private func processFailedDataTaskURLTaskError(_ urlTaskError: Error?) -> Result {
        guard let error = urlTaskError as? URLError else {
            return .failed(error: .other(error: urlTaskError))
        }
        
        // If URL task got cancelled return cancelled task result
        guard error.code != .cancelled else { return .cancelled }
        
        
        //
        // Classify error into one of JSONOverHTTPServiceError domain errors
        var jsonOverHTTPServiceError: JSONOverHTTPServiceError
        
        switch error.code {
            //
            // Unable to connect (this list might be reconsidered)
            case .networkConnectionLost, .cannotConnectToHost, .dnsLookupFailed:
                jsonOverHTTPServiceError = .unableToConnect
            
            //
            // Bad server response
            case .badServerResponse:
                jsonOverHTTPServiceError = .badResponseFormat
            
            //
            // Unclassified
            default:
                jsonOverHTTPServiceError = .other(error: error)
        }
        
        return .failed(error: jsonOverHTTPServiceError)
    }
    
    private func url(fromBase baseURLString: String,
                     path: String?,
                     byAddingQueryParameters queryParameters: RequestParameters?) -> URL? {
        
        guard let baseURL = URL(string: baseURLString) else { return nil }
        
        let urlComponents = NSURLComponents()
        urlComponents.path = path
        urlComponents.queryItems = self.queryItems(fromQueryParameters: queryParameters)
        
        return urlComponents.url(relativeTo: baseURL)
    }
    
    private func queryItems(fromQueryParameters queryParameters: RequestParameters?) -> [URLQueryItem]? {
        guard let queryParameters = queryParameters else { return nil }
        
        return queryParameters.map { URLQueryItem(name: $0, value: $1) }
    }
}

extension URLSessionTask: JSONOverHTTPServiceTask {
}
