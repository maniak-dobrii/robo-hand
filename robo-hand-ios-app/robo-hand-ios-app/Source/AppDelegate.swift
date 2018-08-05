//
//  AppDelegate.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 2/4/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import UIKit
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var dataLayer: DataLayer?


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.setupWindowAndPresentFastLoadingScreen()
        
        DataLayer.createAndConfigure { (taskResult) in
            switch taskResult {
                case .succeeded(let dataLayer):
                    self.dataLayer = dataLayer
                    self.presentTestViewController(dataLayer: dataLayer)
                
                case .failed(let error):
                    os_log("Failed to init dataLayer with error: %{public}@", error.localizedDescription)
                
                case .cancelled:
                    // This imposes another `TaskResult` abstraction issue, as sometimes .cancelled is not
                    // relevant for the task. I.e. `TaskResult` suits cancellable tasks, but what about non-cancellable?
                    // I'll avoid introducing `CancellableTaskResult` and `TaskResult` and stick with only cancellable
                    // variant. Let's see how bad it really is.
                    os_log("dataLayer init cancelled, how did you even?")
            }
        }
        
        return true
    }
    
    // MARK: - Private
    private func presentTestViewController(dataLayer: DataLayer) {
        let testViewController = TestViewController(dataLayer: dataLayer)
        self.window?.rootViewController = testViewController
    }
}

extension AppDelegate {
    fileprivate func setupWindowAndPresentFastLoadingScreen() {
        let window = UIWindow()
        window.rootViewController = LightweightLaunchViewController()
        
        window.makeKeyAndVisible()
        
        self.window = window
    }
}
