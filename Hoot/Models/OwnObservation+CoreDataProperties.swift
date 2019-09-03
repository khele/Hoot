//
//  OwnObservation+CoreDataProperties.swift
//  Hoot
//
//  Created by Kristian Helenius on 03/09/2019.
//  Copyright © 2019 Kristian Helenius. All rights reserved.
//
//

import Foundation
import CoreData


extension OwnObservation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OwnObservation> {
        return NSFetchRequest<OwnObservation>(entityName: "OwnObservation")
    }

    @NSManaged public var created: Int64
    @NSManaged public var dname: String?
    @NSManaged public var id: String?
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var notes: String?
    @NSManaged public var pictureUrl: String?
    @NSManaged public var rarity: String?
    @NSManaged public var soundUrl: String?
    @NSManaged public var species: String?
    @NSManaged public var uid: String?
    @NSManaged public var uploaded: Bool
    @NSManaged public var videoUrl: String?
    @NSManaged public var rarityNumber: Int64
    @NSManaged public var uploading: Bool

}
