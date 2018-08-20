//
//  TestViewController.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 6/17/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import UIKit

// @MANIAK_dobrii: view controllers shouldn't directly use services, this should be refactored later, anyway,
//                  that's something named `TestViewController` what did you expect?

final class TestViewController: UIViewController {
    private let palmControlService: PalmControlServiceProtocol
    
    init(palmControlService: PalmControlServiceProtocol) {
        self.palmControlService = palmControlService
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        assertionFailure("init(coder) is not supported")
        return nil
    }
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let view = self.viewIfLoaded else { assertionFailure("WTF, how come view be nil here"); return }
        view.backgroundColor = .white
        
        self.setupSubviews(inContainer: view)
    }
    
    // MARK: - Private
    // MARK: - UI
    private func setupSubviews(inContainer container: UIView) {
        let deviceInfoButton = self.makeButton(title: "Get device info", selector: #selector(onDeviceInfoTapped))
        let fuckButton = self.makeButton(title: "Fuck", selector: #selector(onFuckButtonTapped))
        let signOfHornsButton = self.makeButton(title: "Sign of horns", selector: #selector(onSignOfHornsButtonTapped))
        let allExtendedButton = self.makeButton(title: "All extended", selector: #selector(onAllExtendedButtonTapped))
        
        let stackView = UIStackView(arrangedSubviews: [deviceInfoButton, fuckButton, signOfHornsButton, allExtendedButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: container.safeAreaLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: container.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            ])
    }
    
    private func makeButton(title: String, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)

        return button
    }
    
    // MARK: - Actions
    @objc
    func onDeviceInfoTapped() {
        self.palmControlService.getDeviceInfo { (taskResult) in
            self.showDeviceInfoTaskResult(taskResult)
        }
    }
    
    @objc
    func onFuckButtonTapped() {
        let fuckPosture = Posture(thumbExtensionRate: 0,
                                  indexExtensionRate: 0,
                                  middleExtensionRate: 1,
                                  ringExtensionRate: 0,
                                  pinkyExtensionRate: 0)
        self.palmControlService.sendSetPostureCommand(after: 0, posture: fuckPosture) { (taskResult) in
            self.showSetPostureTaskResult(taskResult)
        }
    }
    
    @objc
    func onSignOfHornsButtonTapped() {
        let signOfHornsPosture = Posture(thumbExtensionRate: 0,
                                         indexExtensionRate: 1,
                                         middleExtensionRate: 0,
                                         ringExtensionRate: 0,
                                         pinkyExtensionRate: 1)
        self.palmControlService.sendSetPostureCommand(after: 0, posture: signOfHornsPosture) { (taskResult) in
            self.showSetPostureTaskResult(taskResult)
        }
    }
    
    @objc
    func onAllExtendedButtonTapped() {
        let allExtendedPosture = Posture(thumbExtensionRate: 1,
                                         indexExtensionRate: 1,
                                         middleExtensionRate: 1,
                                         ringExtensionRate: 1,
                                         pinkyExtensionRate: 1)
        self.palmControlService.sendSetPostureCommand(after: 0, posture: allExtendedPosture) { (taskResult) in
            self.showSetPostureTaskResult(taskResult)
        }
    }
    
    // MARK: - Notifications
    private func showDeviceInfoTaskResult(_ taskResult: TaskResult<DeviceInfo, PalmControlServiceProtocol.GetDeviceInfoError>) {
        let title: String?
        let body: String?

        switch taskResult {
            case .cancelled:
                title = "Cancelled"
                body = nil
            case .succeeded(let deviceInfo):
                title = "Success!"
                body = "name = '\(deviceInfo.name)', version = '\(deviceInfo.versionString)'"
            case .failed(let error):
                title = "Failed"
                body = error.localizedDescription
        }
        
        self.showNotificationAlert(withTitle: title, body: body)
    }
    
    private func showSetPostureTaskResult(_ taskResult: TaskResult<Void, PalmControlServiceProtocol.SetPostureError>) {
        let title: String?
        let body: String?
        
        switch taskResult {
            case .cancelled:
                title = "Cancelled"
                body = nil
            case .succeeded(_):
                title = "Success!"
                body = nil
            case .failed(let error):
                title = "Failed"
                body = error.localizedDescription
        }
        
        self.showNotificationAlert(withTitle: title, body: body)
    }
    
    private func showNotificationAlert(withTitle title: String?, body: String?) {
        let alertController = UIAlertController(title: title, message: body, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
