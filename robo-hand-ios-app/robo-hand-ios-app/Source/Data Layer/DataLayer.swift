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
    
    private init() {}
    
    class func createAndConfigure(with completionHandler: TaskResultCompletionBlock<DataLayer, ConfigurationError>) {
        let dataLayer = DataLayer()
        
        DispatchQueue.main.async {
            completionHandler(.succeeded(result: dataLayer))
        }
    }
}
