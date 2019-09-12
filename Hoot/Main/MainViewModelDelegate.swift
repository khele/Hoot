//
//  MainViewModelDelegate.swift
//  Hoot
//
//  Created by Kristian Helenius on 10/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation
import UIKit

protocol MainViewModelDelegate: class {
    
    func keyboardDismissWasCalled()
    
    func updateEmptyElementsWasCalled(empty: Bool)
    
    func collectionViewReloadDataWasCalled()
    
    func collectionViewScrollToTopWasCalled()
    
    func ownSwitchFlipWasCalled(isOn: Bool)
    
    func presentAlertWasCalled(alert: UIAlertController)
    
    func dismissParentWasCalled()
 
    func sortTextWasSet(text: String)
    
    func ownSwitchStateChangeWasRequested(isOn: Bool?, userActionEnabled: Bool?)
    
    func offlineLabelStateChangeWasRequested(alpha: Int)
    
}
