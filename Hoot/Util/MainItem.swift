//
//  MainItem.swift
//  Hoot
//
//  Created by Kristian Helenius on 31/08/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//

import Foundation

protocol MainItem {
    
    var species: String? { get }
    
    var rarity: String? { get }
    
    var notes: String? { get }
    
    var created: Int64 { get }
    
    var lat: Double { get }
    
    var long: Double { get }
    
    var pictureUrl: String? { get }
    
    var videoUrl: String? { get }
    
    var soundUrl: String? { get }
    
    var uid: String? { get }
    
    var dname: String? { get }
    
    var id: String? { get }
    
    var rarityNumber: Int64 { get }
    
}
