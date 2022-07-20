//
//  RecordData.swift
//  finalProject
//
//  Created by Shakthi  Prashanth champaka on 9/5/2022.
//

import UIKit

class RecordData: NSObject, Decodable {
    
    var playgrounds: [PlaygroundData]?
    
    private enum CodingKeys: String, CodingKey {
     case playgrounds = "records"
    }


}
