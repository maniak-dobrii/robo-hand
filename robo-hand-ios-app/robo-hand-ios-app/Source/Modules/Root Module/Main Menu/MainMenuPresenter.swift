//
//  MainMenuPresenter.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 8/19/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import UIKit

protocol MainMenuPresenterDelegate: class {
    func mainMenuPresenter(_ mainMenuPresenter: MainMenuPresenter, didSelectMainMenuItem mainMenuItem: MainMenuItem)
}

final class MainMenuPresenter {
    var viewController: UIViewController {
        return self.mainMenuViewController
    }
    
    weak var delegate: MainMenuPresenterDelegate?
    
    
    typealias MainViewControllerType = MainMenuViewController<MainMenuItem, MainMenuPresenter>
    
    private lazy var mainMenuViewController: MainViewControllerType = self.makeViewController()
    
    private let mainMenuItems: [MainMenuItem]
    
    init(mainMenuItems: [MainMenuItem]) {
        self.mainMenuItems = mainMenuItems
    }
    
    
    // MARK: - Private
    private func makeViewController() -> MainViewControllerType {
        let items = self.mainMenuViewControllerItems(forMainMenuItems: self.mainMenuItems)
        let vc = MainMenuViewController(items: items)
        vc.delegate = self
        return vc
    }
    
    private func mainMenuViewControllerItems(forMainMenuItems mainMenuItems: [MainMenuItem]) -> [MainViewControllerType.Item] {
        return mainMenuItems.map { MainViewControllerType.Item(title: $0.title, identifier: $0) }
    }
}

extension MainMenuPresenter: MainMenuViewControllerDelegate {
    typealias IdentifierType = MainMenuItem
    
    func mainMenuViewController(_ mainMenuViewController: MainViewControllerType,
                                didSelectItemWithIdentifier identifier: IdentifierType) {
        // `IdentifierType` is exactly `MainMenuItem`
        let mainMenuItem = identifier as MainMenuItem
        self.delegate?.mainMenuPresenter(self, didSelectMainMenuItem: mainMenuItem)
    }
}
