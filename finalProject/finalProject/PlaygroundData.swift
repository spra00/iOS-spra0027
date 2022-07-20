//
//  PlaygroundData.swift
//  finalProject
//
//  Created by Shakthi  Prashanth champaka on 9/5/2022.
//

import UIKit

class PlaygroundData: NSObject, Decodable {
    
    var recordid: String?
    var googlemaps_drive_to: String?
    var postcode: String?
    var playground_name: String?
    var suburb_name: String?
    var latitude: Double?
    var longitude: Double?
    
    
    required init(from decoder: Decoder) throws {
        
        // decode the  main container
        let container = try decoder.container(keyedBy: RecordKeys.self)
        
        //retrive the recordid
        recordid = try container.decodeIfPresent(String.self, forKey: .recordid)
        
        //decode the field container
        let fields = try container.nestedContainer(keyedBy: PlaygroundKeys.self, forKey: .fields)
        
        //get the field data for the playground
        googlemaps_drive_to = try fields.decodeIfPresent(String.self, forKey: .googlemaps_drive_to)
        postcode = try fields.decodeIfPresent(String.self, forKey: .postcode)
        suburb_name = try fields.decodeIfPresent(String.self, forKey: .suburb_name)
        latitude = try fields.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try fields.decodeIfPresent(Double.self, forKey: .longitude)
        playground_name = try fields.decodeIfPresent(String.self, forKey: .playground_name)
        
        
    }

    
    
    
}

private enum RecordKeys: String, CodingKey {
 case recordid
 case fields
 
}


private enum PlaygroundKeys: String, CodingKey {
 case googlemaps_drive_to
 case postcode
 case playground_name
 case suburb_name
 case longitude
 case latitude
}



