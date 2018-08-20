//
//  RootModuleNavigationPresenter.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 8/12/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import UIKit

protocol RootModuleNavigationPresenterDelegate: class {
    func rootModuleNavigationPresenter(_ rootModuleNavigationPresenter: RootModuleNavigationPresenter,
                                       didPopViewController: UIViewController)
}

final class RootModuleNavigationPresenter: NSObject {
    lazy var viewController: UINavigationController = {
        return RootModuleNavigationPresenter.makeNavigationController(rootViewController: self.rootViewController,
                                                                      delegate: self)
    }()
    
    weak var delegate: RootModuleNavigationPresenterDelegate?
    
    private let rootViewController: UIViewController
    private var presentedViewControllers: Set<UIViewController>

    init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        self.presentedViewControllers = []
    }

    
    private static func makeNavigationController(rootViewController: UIViewController,
                                                 delegate: UINavigationControllerDelegate) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.delegate = delegate
        return navigationController
    }
}

extension RootModuleNavigationPresenter {
    func present(viewController: UIViewController, animated: Bool = true) {
        self.viewController.pushViewController(viewController, animated: animated)
        self.presentedViewControllers.insert(viewController)
    }
}

extension RootModuleNavigationPresenter: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        guard navigationController === self.viewController else { return }
        
        for presentedViewController in self.presentedViewControllers {
            if navigationController.viewControllers.contains(presentedViewController) == false {
                self.delegate?.rootModuleNavigationPresenter(self, didPopViewController: presentedViewController)
                self.presentedViewControllers.remove(presentedViewController)
            }
        }
    }
}
