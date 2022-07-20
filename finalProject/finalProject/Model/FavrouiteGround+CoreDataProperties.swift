//
//  FavrouiteGround+CoreDataProperties.swift
//  finalProject
//
//  Created by Shakthi  Prashanth champaka on 7/6/2022.
//
//

import Foundation
import CoreData


extension FavrouiteGround {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavrouiteGround> {
        return NSFetchRequest<FavrouiteGround>(entityName: "FavrouiteGround")
    }

    @NSManaged public var recordid: String?
    @NSManaged public var postcode: String?
    @NSManaged public var playground_name: String?
    @NSManaged public var suburb_name: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension FavrouiteGround : Identifiable {

}
