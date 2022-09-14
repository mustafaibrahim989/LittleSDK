//
//  File.swift
//  
//
//  Created by Little Developers on 14/09/2022.
//

import Foundation

class SDKUtils {
    static func dictionaryArrayToJson(from object: [[String: String]]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: object)
        return String(data: data, encoding: .utf8)!
    }
}
