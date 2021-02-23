//
//  DetailViewModelDelegate.swift
//  Hoot
//
//  Created by Kristian Helenius on 12/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation
import UIKit

protocol DetailViewModelDelegate: class {
    
    func presentViewControllerWasCalled(vc: UIViewController)
    
    func presentAlertWasCalled(alert: UIAlertController)
    
    func setUIInterActionStateWasCalled(enable: Bool)
    
    func setLoaderStateWasCalled(show: Bool)
    
    func popViewControllerWasCalled()
    
}
