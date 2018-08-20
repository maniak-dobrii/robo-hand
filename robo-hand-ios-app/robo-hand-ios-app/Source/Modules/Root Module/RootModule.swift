//
//  RootModule.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 8/12/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import UIKit

final class RootModule {
    private let services: ServicesProviderProtocol
    private(set) lazy var navigationPresenter: RootModuleNavigationPresenter =
        RootModule.makeNavigationPresenter(rootViewController: self.mainMenuPresenter.viewController, delegate: self)
    private(set) lazy var mainMenuPresenter: MainMenuPresenter =
        RootModule.makeMainMenuPresenter(rootModule: self, services: self.services)
    
    private var presentedModule: RootModuleEmbeddableModule?
    
    
    static func make(withServices services: ServicesProviderProtocol,
                     andPresentInWindow window: UIWindow) -> Self {
        let rootModule = self.init(services: services)
        rootModule.present(inWindow: window)
        
        return rootModule
    }
    
    // MARK: - Private
    private init(services: ServicesProviderProtocol) {
        self.services = services
    }
    
    private func present(inWindow window: UIWindow) {
        window.rootViewController = self.navigationPresenter.viewController
    }
    
    private static func makeNavigationPresenter(rootViewController: UIViewController,
                                                delegate: RootModuleNavigationPresenterDelegate) -> RootModuleNavigationPresenter {
        let navigationPresenter = RootModuleNavigationPresenter(rootViewController: rootViewController)
        navigationPresenter.delegate = delegate
        return navigationPresenter
    }
    
    private static func makeMainMenuPresenter(rootModule: RootModule,
                                              services: ServicesProviderProtocol) -> MainMenuPresenter {
        let mainMenuItemsProvider = MainMenuItemsProvider()
        let mainMenuItems = mainMenuItemsProvider.makeMenuItems(forRootModule: rootModule, services: services)
        let mainMenuPresenter = MainMenuPresenter(mainMenuItems: mainMenuItems)
        mainMenuPresenter.delegate = rootModule
        return mainMenuPresenter
    }
}

extension RootModule {
    private func presentModule(_ module: RootModuleEmbeddableModule) {
        guard self.presentedModule == nil else {
            assertionFailure("Trying to present module before dismissing previous one")
            return
        }
        
        self.presentedModule = module
        self.navigationPresenter.present(viewController: module.rootViewController)
    }
    
    private func dropPresentedModule() {
        self.presentedModule = nil
    }
}

extension RootModule: MainMenuPresenterDelegate {
    func mainMenuPresenter(_ mainMenuPresenter: MainMenuPresenter, didSelectMainMenuItem mainMenuItem: MainMenuItem) {
        let module = mainMenuItem.module
        self.presentModule(module)
    }
}

extension RootModule: RootModuleNavigationPresenterDelegate {
    func rootModuleNavigationPresenter(_ rootModuleNavigationPresenter: RootModuleNavigationPresenter,
                                       didPopViewController poppedViewController: UIViewController) {
        guard let currentModuleRootViewController = self.presentedModule?.rootViewController else { return }
        
        if currentModuleRootViewController === poppedViewController {
            self.dropPresentedModule()
        }
    }
}
