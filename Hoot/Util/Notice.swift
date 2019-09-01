//
//  Notice.swift
//  Hoot
//
//  Created by Kristian Helenius on 31/08/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation
import UIKit

struct Notice {
    
    
    var networkAlert: UIAlertController {
        
        let titleString = NSLocalizedString("No network connection available", comment: "")
        
        let okString = NSLocalizedString("Ok", comment: "")
        
        let alert = UIAlertController(title: titleString, message: "", preferredStyle: .alert)
        
        let notice = UIAlertAction(title: okString, style: .default, handler: {(UIAlertAction) in
            return
        })
        
        alert.addAction(notice)
        
        return alert
        
    }
    
    var firestoreAlert: UIAlertController {
        
        let titleString = NSLocalizedString("Operation unsuccessful, please try again later.", comment: "")
        
        let messageString = NSLocalizedString("If problem persists, please contact support.", comment: "")
        
        let okString = NSLocalizedString("Ok", comment: "")
        
        let alert = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
        
        let notice = UIAlertAction(title: okString, style: .default, handler: {(UIAlertAction) in
            return
        })
        
        alert.addAction(notice)
        
        return alert
        
    }
    
    var videoAlert: UIAlertController {
        
        let titleString = NSLocalizedString("Video length limit of 15 seconds exceeded", comment: "")
        
        let okString = NSLocalizedString("Ok", comment: "")
        
        let alert = UIAlertController(title: titleString, message: "", preferredStyle: .alert)
        
        let notice = UIAlertAction(title: okString, style: .default, handler: {(UIAlertAction) in
            return
        })
        
        alert.addAction(notice)
        
        return alert
        
    }
    
}
