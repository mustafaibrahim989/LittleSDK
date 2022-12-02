//
//  File.swift
//  
//
//  Created by Little Developers on 14/09/2022.
//

import Foundation
import CoreLocation
import UIKit
import CoreTelephony

class SDKUtils {
    static func dictionaryArrayToJson(from object: [[String: String]]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: object)
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    static func dictionaryToJson(from object: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: object)
        return String(data: data, encoding: .utf8) ?? ""
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
    
    static func commonJsonTags(formId: String) -> [String: Any] {
        return [
            "FormID": formId,
            "SessionID": am.getMyUniqueID() ?? "",
            "MobileNumber": am.getSDKMobileNumber() ?? "",
            "IMEI": am.getIMEI() ?? "",
            "CodeBase": am.getMyCodeBase() ?? "",
            "PackageName": am.getSDKPackageName() ?? "",
            "DeviceName": SDKUtils.getPhoneType(),
            "SOFTWAREVERSION": SDKUtils.getAppVersion(),
            "RiderLL": am.getCurrentLocation() ?? "0.0,0.0",
            "LatLong": am.getCurrentLocation() ?? "0.0,0.0",
            "TripID": "",
            "City": am.getCity() ?? "",
            "Country": am.getCountry() ?? "",
            "RegisteredCountry": am.getCountry() ?? "",
            "UniqueID": am.getMyUniqueID() ?? "",
            "CarrierName": SDKUtils.getCarrierName() ?? "",
            "UserAdditionalData": am.getSDKAdditionalData(),
        ]
    }
    
    static func commonJsonPipedTags() -> String {
        let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String
        return "UNIQUEID|\(am.getMyUniqueID() ?? "")|MOBILENUMBER|\(am.getSDKMobileNumber() ?? "")|APKVERSION|\(SDKUtils.getAppVersion())|CODEBASE|APPLE|CITY|\(am.getCity() ?? "")|COUNTRY|\(am.getCountry() ?? "")|DEVICENAME|\(SDKUtils.getPhoneType())|IMEI|\(am.getIMEI() ?? "")|CURRENTLL|\(am.getCurrentLocation() ?? "0.0,0.0")|LanguageID|\(Locale.current.languageCode ?? "en")|NetworkCountry|\(countryCode ?? "")|CarrierName|\(SDKUtils.getCarrierName() ?? "")|"
    }

    func commonJsonTagsString(formId: String) -> String {
        let params = SDKUtils.commonJsonTags(formId: formId)
        return (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
    }
    
    static func getAppVersion() -> String {
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        
        return version
        
    }
    
    static func getPhoneType() -> String {
        let modelName = UIDevice.modelName
        return modelName
    }
    
    static func getCarrierName() -> String! {
        // Setup the Network Info and create a CTCarrier object
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        // Get carrier name
        var carrierName = carrier?.carrierName
        
        if carrierName == nil {
            carrierName = ""
        }
        
        return carrierName
    }
    
    static func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let range = testStr.range(of: emailRegEx, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    static func cleanDeliveryDate(dateStr: String) -> String {
        if dateStr.containsIgnoringCase("Today".localized) {
            let today = Date()
            return dateStr.replacingLastOccurrenceOfString("Today".localized, with: today.scheduleDateOnlyFormat())
            
        } else if dateStr.containsIgnoringCase("Tomorrow".localized) {
            let tomorrow = Date().adding(.day, value: 1)
            return dateStr.replacingLastOccurrenceOfString("Tomorrow".localized, with: tomorrow.scheduleDateOnlyFormat())
        }
        
        return dateStr
    }
}
