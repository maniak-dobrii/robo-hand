//
//  TestModule.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 8/12/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import UIKit

class TestModule: RootModuleEmbeddableModule {
    lazy var rootViewController = self.presenter.viewController
    
    private let presenter: TestPresenter
    
    init(palmControlService: PalmControlServiceProtocol) {
        self.presenter = TestPresenter(palmControlService: palmControlService)
    }
}
