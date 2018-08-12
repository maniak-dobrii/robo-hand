//
//  PalmControlService.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 8/12/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

final class PalmControlService: PalmControlServiceProtocol {
    var webTransformerConfiguration: WebTransformerConfiguration
    private let webService: JSONOverHTTPService
    
    init(webService: JSONOverHTTPService, webTransformerConfiguration: WebTransformerConfiguration) {
        self.webService = webService
        self.webTransformerConfiguration = webTransformerConfiguration
    }
}

extension PalmControlService {
    typealias Milliseconds = SetPostureWebTransformer.Milliseconds
    
    // experiment specifying concrete error
    enum SetPostureError: Error {
        case webServiceError(error: WebServiceError)
        
        var localizedDescription: String {
            switch self {
                case .webServiceError(let error):
                    return "webServiceError: \(error.localizedDescription)"
            }
        }
    }
    
    @discardableResult
    func sendSetPostureCommand(after: Milliseconds,
                               posture: Posture,
                               completionHandler: TaskResultCompletionBlock<Void, SetPostureError>?) -> CancellableTask? {
        let webTransformer = SetPostureWebTransformer(webService: self.webService)
        let postureDescriptor =
            SetPostureWebTransformer.PostureDescriptor(thumbExtensionRate: posture.thumbExtensionRate,
                                                       indexExtensionRate: posture.indexExtensionRate,
                                                       middleExtensionRate: posture.middleExtensionRate,
                                                       ringExtensionRate: posture.ringExtensionRate,
                                                       pinkyExtensionRate: posture.pinkyExtensionRate)
        
        return webTransformer.setPosture(configuration: self.webTransformerConfiguration,
                                         posture: postureDescriptor,
                                         after: after,
                                         completionHandler: { (taskResult) in
            let transformedTaskResult: TaskResult<Void, SetPostureError> =
                taskResult.map(success: { $0 },
                               failed: { .webServiceError(error: $0) })
            completionHandler?(transformedTaskResult)
        })
    }
}

extension PalmControlService {
    // experiment specifying concrete error
    enum GetDeviceInfoError: Error, LocalizedError {
        case webServiceError(error: WebServiceError)
        
        var localizedDescription: String {
            switch self {
                case .webServiceError(let error):
                    return "webServiceError: \(error.localizedDescription)"
            }
        }
    }
    
    @discardableResult
    func getDeviceInfo(completionHandler: TaskResultCompletionBlock<DeviceInfo, GetDeviceInfoError>?) -> CancellableTask? {
        let webTransformer = GetDeviceInfoWebTransformer(webService: self.webService)
        return webTransformer.getDeviceInfo(configuration: self.webTransformerConfiguration,
                                            completionHandler: { (taskResult) in
            let transformedTaskResult: TaskResult<DeviceInfo, GetDeviceInfoError> =
                taskResult.map(success: { $0 },
                               failed: { .webServiceError(error: $0) })
            completionHandler?(transformedTaskResult)
        })
    }
}
