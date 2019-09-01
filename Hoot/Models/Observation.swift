//
//  Observation.swift
//  Hoot
//
//  Created by Kristian Helenius on 31/08/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation

struct Observation: MainItem {
    
    var species: String
    
    var rarity: String
    
    var notes: String
    
    var created: Int
    
    var lat: Double
    
    var long: Double
    
    var pictureUrl: String
    
    var videoUrl: String
    
    var soundUrl: String
    
    var uid: String
    
    var dname: String
    
    var id: String
    
    init(_ data: [String : Any]){
     
        
        species = data["species"] as! String
        
        rarity = data["rarity"] as! String
        
        notes = data["notes"] as! String
        
        created = data["created"] as! Int
        
        lat = data["lat"] as! Double
        
        long = data["long"] as! Double
        
        pictureUrl = data["pictureUrl"] as! String
        
        videoUrl = data["videoUrl"] as! String
        
        soundUrl = data["soundUrl"] as! String
        
        uid = data["uid"] as! String
        
        dname = data["dname"] as! String
        
        id = data["id"] as! String
        
    }
    
}
