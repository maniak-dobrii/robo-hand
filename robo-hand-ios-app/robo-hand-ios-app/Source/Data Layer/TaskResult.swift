//
//  TaskResult.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 2/24/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

enum TaskResult<ResultType, ErrorType:Error> {
    case succeeded(result: ResultType)
    case failed(error: ErrorType)
    case cancelled
}

typealias TaskResultCompletionBlock<ResultType, ErrorType:Error> = (TaskResult<ResultType, ErrorType>) -> Void


// I'm experimenting with this stuff
extension TaskResult {
    func map<NewResultType, NewErrorResultType:Error>(success successTransform: (_ result: ResultType) -> NewResultType,
                                                      failed failedTransform: (_ error: ErrorType) -> NewErrorResultType)
        -> TaskResult<NewResultType, NewErrorResultType> {
            
        switch self {
            case .cancelled:
                return .cancelled
            case .succeeded(let result):
                return .succeeded(result: successTransform(result))
            case .failed(let error):
                return .failed(error: failedTransform(error))
        }
    }
    
    func transform<NewResultType>(success successTransform: (_ result: ResultType) -> TaskResult<NewResultType, ErrorType>)
        -> TaskResult<NewResultType, ErrorType> {
            
        switch self {
            case .cancelled:
                return .cancelled
            case .succeeded(let result):
                return successTransform(result)
            case .failed(let error):
                return .failed(error: error)
        }
    }
}
