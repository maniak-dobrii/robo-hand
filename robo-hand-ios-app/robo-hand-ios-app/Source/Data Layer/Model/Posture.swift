//
//  Posture.swift
//  robo-hand-ios-app
//
//  Created by Mikhail Solodovnichenko on 6/17/18.
//  Copyright © 2018 MANIAK_dobrii. All rights reserved.
//

import Foundation

/// 0 - closed, 1 - extended, normalized [0.0 - 1.0]
struct Posture {
    let thumbExtensionRate: Float
    let indexExtensionRate: Float
    let middleExtensionRate: Float
    let ringExtensionRate: Float
    let pinkyExtensionRate: Float
    
    /// Each extension rate must be normalized (0.0-1.0), this is being asserted in debug and limited in production
    init(thumbExtensionRate: Float,
         indexExtensionRate: Float,
         middleExtensionRate: Float,
         ringExtensionRate: Float,
         pinkyExtensionRate: Float) {
        self.thumbExtensionRate = Posture.assertNormalized(rawValue: thumbExtensionRate)
        self.indexExtensionRate = Posture.assertNormalized(rawValue: indexExtensionRate)
        self.middleExtensionRate = Posture.assertNormalized(rawValue: middleExtensionRate)
        self.ringExtensionRate = Posture.assertNormalized(rawValue: ringExtensionRate)
        self.pinkyExtensionRate = Posture.assertNormalized(rawValue: pinkyExtensionRate)
    }
    
    // MARK: - Private
    private static func assertNormalized(rawValue: Float) -> Float {
        assert(rawValue >= 0.0 && rawValue <= 1.0, "Value \(rawValue) is not normalized")
        
        //
        // Apps should never crash in production, so here's some questionably reasonable fallbacks.
        //
        
        if rawValue < 0.0 {
            return 0.0
        }
        if rawValue > 1.0 {
            return 1.0
            
        }
        
        return rawValue
    }
}
