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

    let window: UIWindow
    
    var dataLayer: DataLayer?
    var rootModule: RootModule?
    
    override init() {
        self.window = UIWindow()
    }


    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.setupWindowAndPresentFastLoadingScreen(inWindow: self.window)
        
        DataLayer.createAndConfigure { (taskResult) in
            switch taskResult {
                case .succeeded(let dataLayer):
                    self.dataLayer = dataLayer
                    self.rootModule = RootModule.make(withServices: dataLayer, andPresentInWindow: self.window)
                
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
}

extension AppDelegate {
    private func setupWindowAndPresentFastLoadingScreen(inWindow: UIWindow) {
        window.rootViewController = LightweightLaunchViewController()
        window.makeKeyAndVisible()
    }
}
