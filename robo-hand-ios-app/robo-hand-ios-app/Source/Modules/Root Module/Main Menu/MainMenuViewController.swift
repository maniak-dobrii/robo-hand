//
//  MainMenuViewController.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 8/13/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//


/*
    This is my experiment with generic delegates. Oh, what have I done =)
 
    The idea is that this view controller should not know anything about `MainMenuItem`s, their interface, dependencies,
    etc. So if I just had array of `MainMenuItem`s here that would made presenter and view controller more closely
    coupled (let's ignore that usually with such arcitectures there's usually 1 to 1 association, but=) ).
 
    It is easy to fix it one way, make some "item view model" based on `MainMenuItem` and fed it into view controller,
    breaks this coupling, view controller knows only about this "item view model", `MainMenuItem` is out of it's scope
    completely. But now, when you select item, how do you tell which one? I.e. "hey, presenter, I've selected this
    view model you gave me".
 
    How would presenter decide which `MainMenuItem` corresponds to which "item view model"?
    Usually that's just indices, simple - you have, say, 5 `MainMenuItems` - you get 5 "item view model"s,
    second "item view model" is second `MainMenuItem`. But that's quite plain and uninteresting.
 
    Idea here is to have some "token" or, "identifier" that identifies `MainMenuItem` in "item view model" without
    introducing closer coupling and type ereasures. View controller becomes generic on that "identifier" type, each
    "item view model" contains one such "identifier".
 
    Think twice before you reuse this (if ever), I'm just experimenting.
 */


import UIKit

protocol MainMenuViewControllerDelegate: class {
    associatedtype IdentifierType
    func mainMenuViewController(_ mainMenuViewController: MainMenuViewController<IdentifierType, Self>,
                                didSelectItemWithIdentifier: IdentifierType)
}


final class MainMenuViewController<IdentifierType, DelegateType: MainMenuViewControllerDelegate>:
    UIViewController, UITableViewDelegate, UITableViewDataSource where DelegateType.IdentifierType == IdentifierType {
    
    weak var delegate: DelegateType?
    
    
    struct Item {
        let title: String
        let identifier: IdentifierType
    }
    
    private let items: [Item]
    
    private var tableView: UITableView?
    
    init(items: [Item]) {
        self.items = items
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let containerView = self.viewIfLoaded {
            self.setupTableView(inContainerView: containerView)
        }
    }
    
    
    // MARK: - Private
    private let tableViewCellIdentifier = NSStringFromClass(UITableViewCell.self)
    
    private func setupTableView(inContainerView containerView: UIView) {
        let tableView = self.makeTableView()
        containerView.addSubview(tableView)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.tableViewCellIdentifier)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        self.tableView = tableView
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func makeTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }
    
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.tableViewCellIdentifier, for: indexPath)
        
        if let item = self.item(atIndexPath: indexPath) {
            self.configure(tableViewCell: cell, withItem: item)
        }
        
        return cell
    }
    
    private func item(atIndexPath indexPath: IndexPath) -> Item? {
        guard indexPath.row >= 0 && indexPath.row < self.items.count else {
            assertionFailure("Main menu item index out of bounds")
            return nil
        }
        
        return self.items[indexPath.row]
    }
    
    private func configure(tableViewCell: UITableViewCell, withItem item: Item) {
        tableViewCell.textLabel?.text = item.title
        tableViewCell.accessoryType = .disclosureIndicator
    }
    
    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mainMenuItem = self.item(atIndexPath: indexPath) {
            self.delegate?.mainMenuViewController(self, didSelectItemWithIdentifier: mainMenuItem.identifier)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
