//
//  CustomPin.swift
//  finalProject
//  A custom pin used in the maps
//  Created by Shakthi  Prashanth champaka on 9/5/2022.
//

import UIKit
import MapKit

// A class for a custom made Pin
class CustomPin: MKPointAnnotation {
    
    //Additional data for each pin
    var recordid: String?
    var postcode: String?
    var playground_name: String?
    var suburb_name: String?
    var latitude: Double?
    var longitude: Double?
    
    //different colour for the favourite color
    var pinTintColor: UIColor?
    

}
