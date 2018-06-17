//
//  DataLayer.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 2/4/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

final class DataLayer {
    public enum ConfigurationError: Error, LocalizedError {
    }
    
    // @MANIAK_dobrii: Currently it is constant until I implement connectivity settings in app
    private let configuration: WebTransformerConfiguration
    
    private let webService: JSONOverHTTPService
    
    private init() {
        self.configuration = WebTransformerConfiguration(baseURLString: "http://192.168.4.1/")
        self.webService = JSONOverHTTPService()
    }
    
    class func createAndConfigure(with completionHandler: @escaping TaskResultCompletionBlock<DataLayer, ConfigurationError>) {
        let dataLayer = DataLayer()
        
        DispatchQueue.main.async {
            completionHandler(.succeeded(result: dataLayer))
        }
    }
}

extension DataLayer {
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
        
        return webTransformer.setPosture(configuration: self.configuration,
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

extension DataLayer {
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
        return webTransformer.getDeviceInfo(configuration: self.configuration,
                                            completionHandler: { (taskResult) in
            let transformedTaskResult: TaskResult<DeviceInfo, GetDeviceInfoError> =
                taskResult.map(success: { $0 },
                               failed: { .webServiceError(error: $0) })
            completionHandler?(transformedTaskResult)
        })
    }
}
