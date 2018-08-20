//
//  MainMenuItem.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 8/12/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

class MainMenuItem {
    let title: String
    
    var module: RootModuleEmbeddableModule {
        if let cachedModule = self.moduleCache {
            return cachedModule
        }
        else {
            let newModule = self.makeModule()
            self.moduleCache = newModule
            return newModule
        }
    }
    
    func dropModule() {
        self.moduleCache = nil
    }
    
    private var moduleCache: RootModuleEmbeddableModule?
    private let makeModule: () -> RootModuleEmbeddableModule
    
    init(title: String, makeModule: @escaping () -> RootModuleEmbeddableModule) {
        self.title = title
        self.makeModule = makeModule
    }
}
