//
//  LightweightLaunchViewController.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 2/23/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

/*
    Light view controller to make app launch feel faster.
    Shows activity indicator after delay.
 */

import UIKit

class LightweightLaunchViewController: UIViewController {
    /// Delay after -viewWillAppear in seconds before activity indicator appears
    private let activityIndicatorDelay: TimeInterval = 0.3
    
    private var activityIndicator: UIActivityIndicatorView? // non-nil if displayed
    private var displayActivityIndicatorDispatchItem: DispatchWorkItem?
    
    //
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewIfLoaded?.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.layoutActivityIndicator()
    }
    
    private func layoutActivityIndicator() {
        if let activityIndicator = self.activityIndicator,
            let view = self.viewIfLoaded {
            activityIndicator.center = view.center
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cancelDisplayActivityIndicatorAfterDelay()
        self.displayActivityIndicator(afterDelay: self.activityIndicatorDelay)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cancelDisplayActivityIndicatorAfterDelay()
    }
    
    
    //
    // MARK: - Activity indicator management
    private func cancelDisplayActivityIndicatorAfterDelay() {
        self.displayActivityIndicatorDispatchItem?.cancel()
        self.displayActivityIndicatorDispatchItem = nil
    }
    
    private func displayActivityIndicator(afterDelay delay: TimeInterval) {
        self.cancelDisplayActivityIndicatorAfterDelay()
        
        let displayActivityIndicatorItem = DispatchWorkItem { [weak self] in
            self?.displayActivityIndicatorAnimated()
            // DispatchQueue does not retain work item, so I release it here
            self?.displayActivityIndicatorDispatchItem = nil
        }
        self.displayActivityIndicatorDispatchItem = displayActivityIndicatorItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: displayActivityIndicatorItem)
    }
    
    // presents only if it is not already presented
    private func displayActivityIndicatorAnimated() {
        if self.activityIndicator == nil {
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            // layout is managed in
            activityIndicator.translatesAutoresizingMaskIntoConstraints = true
            activityIndicator.alpha = 0.0
            self.viewIfLoaded?.addSubview(activityIndicator)
            
            self.activityIndicator = activityIndicator
            
            UIView.animate(withDuration: 0.3, animations: {
                activityIndicator.alpha = 1.0
                activityIndicator.startAnimating()
            })
        }
    }
}
