//
//  AddViewModelDelegate.swift
//  Hoot
//
//  Created by Kristian Helenius on 12/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation
import UIKit

protocol AddViewModelDelegate: class {
    
    func controlOkButtonStateWasCalled()
    
    func setImageWasCalled(image: UIImage)
    
    func presentAlertControllerWasCalled(alert: UIAlertController)
    
    func presentViewControllerWasCalled(vc: UIViewController, animated: Bool)
    
    func presentActionSheetWasCalled(ac: UIAlertController)
    
    func dismissViewControllerWasCalled(vc: UIViewController, animated: Bool)
    
    func setupDeleteSoundButtonWasCalled()
    
    func setupStopSoundButtonWasCalled()
    
    func setupDeleteVideoButtonWasCalled()
    
    func removeDeleteSoundButtonWasCalled()
    
    func removeDeleteVideoButtonWasCalled()
    
    func popViewControllerWasCalled()
    
    func setRarityTextFieldTextWasCalled(text: String)
    
    func setUIInteractionStateWasCalled(enabled: Bool)
    
    func setLoaderStateWasCalled(show: Bool)
    
    func getObservationContentWasCalled()
    
    func keyboardDismissWasCalled()
}
