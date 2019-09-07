//
//  DeleteObservationDelegate.swift
//  Hoot
//
//  Created by Kristian Helenius on 07/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation

protocol DeleteObservationDelegate: class {
    
    func deleteObservationDidRun(result: DeleteResult)
    
}
