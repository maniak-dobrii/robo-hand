//
//  GetDeviceInfoWebTransformer.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 6/17/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

final class GetDeviceInfoWebTransformer: WebTransformer {
    typealias CompletionHandler = TaskResultCompletionBlock<DeviceInfo, WebServiceError>
    
    private let webService: JSONOverHTTPService

    
    init(webService: JSONOverHTTPService) {
        self.webService = webService
    }
    
    func getDeviceInfo(configuration: WebTransformerConfiguration,
                       completionHandler: CompletionHandler?) -> CancellableTask? {
        return self.webService.get(baseURLString: configuration.baseURLString,
                                   path: "deviceInfo",
                                   parameters: nil,
                                   withCompletionHandler: { (aggregateResult) in
            // Preprocess result, handles HTTP codes and stuff
            let preprocessedTaskResult = self.transformWebServiceResult(aggregateResult.result)
            // Validates output, extracts device info
            let processedResult = self.processPreprocessedTaskResult(preprocessedTaskResult)
            completionHandler?(processedResult)
        })
    }
    
    // MARK: - Private
    private func processPreprocessedTaskResult(_ preProcessedTaskResult: WebTransformerTaskResult)
        -> TaskResult<DeviceInfo, WebServiceError> {
            return preProcessedTaskResult.transform(success: { json in
                if let deviceInfo = try? self.deviceInfo(fromResponseJSON: json) {
                    return .succeeded(result: deviceInfo)
                }
                else {
                    // yepp, what was returned as reason got ignored, don't want to elaborate
                    return .failed(error: .badResponseFormat(json: json))
                }
            })
    }
    
    private func deviceInfo(fromResponseJSON responseJSON: Any?) throws -> DeviceInfo {
        guard let responseJSON = responseJSON else { throw "Empty response" }
        guard let jsonObject: Dictionary<String, Any> = responseJSON as? Dictionary<String, Any> else {
            throw "Response not a JSON object"
        }
        
        guard let name: String = jsonObject["name"] as? String else { throw "Bad name" }
        guard let versionString: String = jsonObject["apiVersion"] as? String else { throw "Bad version" }
        
        return DeviceInfo(name: name, versionString: versionString)
    }
}
