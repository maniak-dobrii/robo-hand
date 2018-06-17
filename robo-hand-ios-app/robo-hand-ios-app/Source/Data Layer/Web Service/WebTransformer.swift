//
//  WebTransformer.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 6/17/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

/// Intermediate task result used by `WebTransformer`-s to simplify `JSONOverHTTPService` response interpretation.
typealias WebTransformerTaskResult = TaskResult<Any?, WebServiceError>

protocol WebTransformer {
    /**
     Web transformers use this against `JSONOverHTTPService` task results.
     
     Implementation is responsible for two main points:
     1. Ensures basic API contract rules. Currently it is only that 200 is the only "good" HTTP status code.
     2. Translates `JSONOverHTTPService` level errors into `WebServiceError` level errors.
     */
    func transformWebServiceResult(_ webServiceResult: JSONOverHTTPService.Result) -> WebTransformerTaskResult
}

extension WebTransformer {
    func transformWebServiceResult(_ webServiceResult: JSONOverHTTPService.Result) -> WebTransformerTaskResult {
        switch webServiceResult {
            case .cancelled:
                return .cancelled
            case .failed(let error):
                return self.transformFailedResult(error)
            case .succeeded(let result):
                return self.transformSucceededResult(result)
        }
    }
    
    // MARK: - Private
    private func transformFailedResult(_ error: JSONOverHTTPServiceError?) -> WebTransformerTaskResult {
        let webServiceError: WebServiceError
        
        if let error = error {
            switch error {
                case .unableToConnect:
                    webServiceError = .unableToConnect
                default:
                    webServiceError = .other(error: error)
            }
        }
        else {
            webServiceError = .other(error: nil)
        }
        
        return .failed(error: webServiceError)
    }
    
    private func transformSucceededResult(_ result: JSONOverHTTPServiceResponse) -> WebTransformerTaskResult {
        // Only 200 is good code, that's part of API contract
        if result.httpCode == 200 {
            return .succeeded(result: result.json)
        }
        else {
            return .failed(error: .badHTTPCode(code: result.httpCode, json: result.json))
        }
    }
}
