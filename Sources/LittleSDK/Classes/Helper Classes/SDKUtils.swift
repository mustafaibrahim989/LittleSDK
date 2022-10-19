//
//  File.swift
//  
//
//  Created by Little Developers on 14/09/2022.
//

import Foundation
import CoreLocation

class SDKUtils {
    static func dictionaryArrayToJson(from object: [[String: String]]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: object)
        return String(data: data, encoding: .utf8)!
    }
    
    static func extractCoordinate(string: String?) -> CLLocationCoordinate2D {
        guard let string = string else { return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
        
        if string.isEmpty {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        let components = string.components(separatedBy: ",")
        if components.count > 1 {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(components[0]) ?? 0, longitude: CLLocationDegrees(components[1]) ?? 0)
        }
        
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
    static func extractStringCoordinateLatitude(string: String?) -> String {
        guard let string = string else { return "0.0" }
        
        if string.isEmpty {
            return  "0.0"
        }
        
        let components = string.components(separatedBy: ",")
        if components.count > 1 {
            return components[0]
        }
        
        return  "0.0"
    }
    
    static func extractStringCoordinateLongitude(string: String?) -> String {
        guard let string = string else { return "0.0" }
        
        if string.isEmpty {
            return  "0.0"
        }
        
        let components = string.components(separatedBy: ",")
        if components.count > 1 {
            return components[1]
        }
        
        return  "0.0"
    }
    
    static func extractCoordinate(array: [String]?, index: Int) -> CLLocationCoordinate2D {
        guard let array = array else { return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
        
        if index > (array.count - 1) {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        let string = array[index]
        
        if string.isEmpty {
            return CLLocationCoordinate2D(latitude: 0, longitude: 0)
        }
        
        let components = string.components(separatedBy: ",")
        if components.count > 1 {
            return CLLocationCoordinate2D(latitude: CLLocationDegrees(components[0]) ?? 0, longitude: CLLocationDegrees(components[1]) ?? 0)
        }
        
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
}
