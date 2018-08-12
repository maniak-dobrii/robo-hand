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
    
    var palmControlService: PalmControlServiceProtocol {
        return self._palmControlService
    }
    
    
    // @MANIAK_dobrii: Currently it is constant until I implement connectivity settings in app
    private let configuration: WebTransformerConfiguration
    
    private let webService: JSONOverHTTPService
    private lazy var _palmControlService = PalmControlService(webService: self.webService,
                                                              webTransformerConfiguration: self.configuration)
    
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
