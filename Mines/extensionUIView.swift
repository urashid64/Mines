//
//  extensionUIView.swift
//  Mines
//
//  Created by Usman Rashid on 10/18/18.
//  Copyright © 2018 Usman Rashid. All rights reserved.
//

import UIKit

extension UIView {
    func fadeIn (duration: TimeInterval = 0.2,
                 delay: TimeInterval = 0.0,
                 completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in})
    {
        UIView.animate (withDuration: duration,
                        delay: delay,
                        options: UIView.AnimationOptions.curveEaseIn,
                        animations: {self.alpha = 0.5},
                        completion: completion)
    }
    
    func fadeOut (duration: TimeInterval = 0.2,
                  delay: TimeInterval = 0.0,
                  completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in})
    {
        UIView.animate (withDuration: duration,
                        delay: delay,
                        options: UIView.AnimationOptions.curveEaseIn,
                        animations: {self.alpha = 0.0},
                        completion: completion)
    }
}

