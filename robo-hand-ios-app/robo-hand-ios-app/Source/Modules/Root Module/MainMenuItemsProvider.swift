//
//  MainMenuItemsProvider.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 8/12/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

class MainMenuItemsProvider {    
    func makeMenuItems(forRootModule rootModule: RootModule,
                       services: ServicesProviderProtocol) -> [MainMenuItem] {
        var items: [MainMenuItem] = []
        
        items.append(self.makeTestMenuItem(services: services))
        
        return items
    }
    
    // MARK: - Private
    private func makeTestMenuItem(services: ServicesProviderProtocol) -> MainMenuItem {
        return MainMenuItem(title: "Test", makeModule: { () -> RootModuleEmbeddableModule in
            let testModule = TestModule(palmControlService: services.palmControlService)
            return testModule as RootModuleEmbeddableModule
        })
    }
}
