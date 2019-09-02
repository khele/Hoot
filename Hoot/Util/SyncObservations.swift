//
//  SyncObservations.swift
//  Hoot
//
//  Created by Kristian Helenius on 02/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation
import Firebase
import CoreData


struct SyncObservations {

    
    let fileManager = FileManager.default
    
    let pictureRef = Storage.storage().reference().child("picture")
    
    let soundRef = Storage.storage().reference().child("sound")
    
    let videoRef = Storage.storage().reference().child("video")
    
    let observationRef = Firestore.firestore().collection("observation")
    
    let uid = Auth.auth().currentUser?.uid
    
    
    
    
    
}
