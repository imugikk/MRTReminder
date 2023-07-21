//
//  File.swift
//  
//
//  Created by Muhammad Fauzul Akbar on 21/07/23.
//

import Foundation
import CoreLocation

public class Station {
    var name: String
    var coordinate: CLLocationCoordinate2D
    public var left, right: Station?
    
    init(name: String, coordinate: CLLocationCoordinate2D) {
        self.name = name
        self.coordinate = coordinate
    }
}
