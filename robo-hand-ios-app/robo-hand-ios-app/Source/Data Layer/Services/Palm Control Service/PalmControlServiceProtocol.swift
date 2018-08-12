//
//  PalmControlServiceProtocol.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 8/12/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

protocol PalmControlServiceProtocol {
    //
    // Send posture command
    typealias Milliseconds = PalmControlService.Milliseconds
    typealias SetPostureError = PalmControlService.SetPostureError
    
    @discardableResult
    func sendSetPostureCommand(after: Milliseconds,
                               posture: Posture,
                               completionHandler: TaskResultCompletionBlock<Void, SetPostureError>?) -> CancellableTask?
    
    
    //
    // Get device info
    typealias GetDeviceInfoError = PalmControlService.GetDeviceInfoError
    
    @discardableResult
    func getDeviceInfo(completionHandler: TaskResultCompletionBlock<DeviceInfo, GetDeviceInfoError>?) -> CancellableTask?
}
