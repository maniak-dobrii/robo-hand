//
//  SetPostureWebTransformer.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 6/17/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

final class SetPostureWebTransformer: WebTransformer {
    private let webService: JSONOverHTTPService
    
    typealias Milliseconds = UInt

    /// Describes palm posture, 0 => closed, 1 => opened
    struct PostureDescriptor {
        let thumbExtensionRate: Float?
        let indexExtensionRate: Float?
        let middleExtensionRate: Float?
        let ringExtensionRate: Float?
        let pinkyExtensionRate: Float?
    }
    
    init(webService: JSONOverHTTPService) {
        self.webService = webService
    }
    
    func setPosture(configuration: WebTransformerConfiguration,
                    posture: PostureDescriptor,
                    after: Milliseconds,
                    completionHandler: TaskResultCompletionBlock<Void, WebServiceError>?) -> CancellableTask? {
        let parameters = self.requestParameters(forPosture: posture, after: after)
        return self.webService.get(baseURLString: configuration.baseURLString,
                                   path: "setPosture",
                                   parameters: parameters,
                                   withCompletionHandler: { (aggregateResult) in
            // Oh, what have I done=)
            // This pre-processes raw task result from JSONOverHTTPService into something simplier and checks HTTP codes
            let taskResult = self.transformWebServiceResult(aggregateResult.result)
            // This maps taskResult into something that is abstracted away for the calling side.
            // As this implementations only relies on 200 HTTP code it does not validate response body and not
            // introduce any more levels of errors.
            let transformedResult = taskResult.map(success: { _ in return Void() },
                                                   failed: { return $0 })
            completionHandler?(transformedResult)
        })
    }
    
    // MARK: - Private
    func requestParameters(forPosture posture: PostureDescriptor,
                           after: Milliseconds) -> JSONOverHTTPService.RequestParameters {
        var parameters: JSONOverHTTPService.RequestParameters = [:]
        
        parameters["afterMilliseconds"] = "\(after)"
        
        if let thumb = posture.thumbExtensionRate {
            parameters["thumb"] = "\(thumb)"
        }
        
        if let index = posture.indexExtensionRate {
            parameters["index"] = "\(index)"
        }
        
        if let middle = posture.middleExtensionRate {
            parameters["middle"] = "\(middle)"
        }
        
        if let ring = posture.ringExtensionRate {
            parameters["ring"] = "\(ring)"
        }
        
        if let pinky = posture.pinkyExtensionRate {
            parameters["pinky"] = "\(pinky)"
        }
        
        return parameters
    }
}
