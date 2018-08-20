//
//  TestPresenter.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 8/12/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import UIKit

class TestPresenter {
    lazy var viewController: UIViewController = TestViewController(palmControlService: self.palmControlService)
    
    private var palmControlService: PalmControlServiceProtocol
    
    init(palmControlService: PalmControlServiceProtocol) {
        self.palmControlService = palmControlService
    }
}
