//
//  WebServiceError.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 6/17/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

enum WebServiceError: Error {
    /// Unable to establish connection for various reasons. User must fix something and try again.
    case unableToConnect
    
    /// Non HTTP 200, try again later or developers should fix something.
    case badHTTPCode(code: Int, json: Any?)
    
    /// Got JSON/JSON fragment in incorrect format, user can't do anything (unless incompatible version) - developer should fix something.
    case badResponseFormat(json: Any?)
    
    /// Something unclassified, user can't do anything
    case other(error: Error?)
}

extension WebServiceError: LocalizedError {
    var localizedDescription: String {
        switch self {
            case .unableToConnect:
                return "Unable to connect"
            
            case .badHTTPCode(let code, _):
                return "Bad HTTP status code (\(code))"
            
            case .badResponseFormat(let json):
                return "Bad response format: \(json ?? "<empty>")"
            
            case .other(let error):
                return "Unclassified error: \(error ?? "<nil>")"
        }
    }
}
