//
//  AllMethods.swift
//  LittleSDK
//
//  Created by Gabriel John on 10/05/2021.
//

import Foundation
import UIKit

class SDKAllMethods {
    
    let prefs:UserDefaults
    let wrapper:LittleSDKKCWrapper
    let cn = SDKConstants()
    
    init(){
        prefs = UserDefaults.standard
        wrapper = LittleSDKKCWrapper.standard
    }
    
    // MARK: - Save Functions
    
    func saveSDKMobileNumber(data: String) {
        wrapper.set(data, forKey: "SDKMobileNumber")
    }
    
    func saveSDKPackageName(data: String) {
        wrapper.set(data, forKey: "SDKPackageName")
    }
    
    func saveSDKAccounts(data: String) {
        wrapper.set(data, forKey: "SDKAccounts")
    }
    
    func saveFromSearch(data: Bool) {
        wrapper.set(data, forKey: "FromSearch")
    }
    
    func savePicture(data: String) {
        wrapper.set(data, forKey: "Picture")
    }
    
    func saveSessionToken(data: String) {
        wrapper.set(data, forKey: "SessionToken")
    }
    
    func saveFullName(data: String){
        wrapper.set(data, forKey: "FullName")
    }
    
    func savePICKUPADDRESS(data: String) {
        wrapper.set(data, forKey: "PICKUPADDRESS")
    }
    
    func saveFromPickupLoc(data:Bool) {
        wrapper.set(data, forKey: "FromPickupLoc")
    }
    
    func saveFarLeft(data: String) {
        wrapper.set(data, forKey: "FarLeft")
    }
    
    func saveNearRight(data: String) {
        wrapper.set(data, forKey: "NearRight")
    }
    
    func saveCurrentLocation(data:String) {
        wrapper.set(data, forKey: "CurrentLocation")
    }
    
    func saveRecentPlacesNames(data:[String]) {
        prefs.setValue(data, forKey: "RecentPlacesNames")
    }
    
    func saveRecentPlacesFormattedAddress(data:[String]) {
        prefs.setValue(data, forKey: "RecentPlacesFormattedAddress")
    }
    
    func saveRecentPlacesCoords(data:[String]) {
        prefs.setValue(data, forKey: "RecentPlacesCoords")
    }
    
    func saveRecentPlaces(coordinates: [String], names: [String], subtitles: [String]) {
        var myCoordinates = coordinates
        var myNames = names
        var mySubtitles = subtitles
        
        var removeCoordinates = [Int]()
        var removeNames = [Int]()
        var removeSubtitles = [Int]()
        
        for (idx, name) in myNames.enumerated() {
            let coordinate = myCoordinates[idx].trimmingCharacters(in: .whitespacesAndNewlines)
            let myName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            if myName.isEmpty && idx != 0 && idx != 1 {
                removeNames.append(idx)
                removeCoordinates.append(idx)
                removeSubtitles.append(idx)
            } else {
                if coordinate.isEmpty && !myName.isEmpty {
                    if idx == 0 || idx == 1 {
                        if idx == 0 {
                            myNames[idx] = "Add Home"
                        } else {
                            myNames[idx] = "Add Work"
                        }
                        mySubtitles[idx] = ""
                    } else {
                        removeNames.append(idx)
                        removeCoordinates.append(idx)
                        removeSubtitles.append(idx)
                    }
                }
            }
        }
        
        removeNames.forEach({ myNames.remove(at: $0) })
        removeCoordinates.forEach({ myCoordinates.remove(at: $0) })
        removeSubtitles.forEach({ mySubtitles.remove(at: $0) })
        
        prefs.setValue(myCoordinates, forKey: "RecentPlacesCoords")
        prefs.setValue(mySubtitles, forKey: "RecentPlacesFormattedAddress")
        prefs.setValue(myNames, forKey: "RecentPlacesNames")
    }
    
    func saveCountry(data: String) {
        wrapper.set(data, forKey: "Country")
    }
    
    func savePreferredDriverName(data: String) {
        wrapper.set(data, forKey: "PreferredDriverName")
    }
    
    func savePreferredDriver(data: String) {
        wrapper.set(data, forKey: "PreferredDriver")
    }
    
    func savePreferredDriverImage(data: String) {
        wrapper.set(data, forKey: "PreferredDriverImage")
    }
    
    func savePaymentMode(data: String){
        wrapper.set(data, forKey: "PaymentMode")
    }
    
    func savePaymentModeID(data: String){
        wrapper.set(data, forKey: "PaymentModeID")
    }
    
    func savePaymentModes(data: String){
        wrapper.set(data, forKey: "PaymentModes")
    }
    
    func savePaymentModeIDs(data: String){
        wrapper.set(data, forKey: "PaymentModeIDs")
    }
    
    func savePhoneNumber(data:String){
        wrapper.set(data, forKey: "PhoneNumber")
    }
    
    func saveStillRequesting(data:Bool) {
        wrapper.set(data, forKey: "StillRequesting")
    }
    
    func saveFORWARDCOUNT(data:String){
        wrapper.set(data, forKey: "FORWARDCOUNT")
    }
    
    func saveIMEI() -> String! {
        var imei = NSUUID().uuidString.replacingOccurrences(of: "-", with: "")
        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            imei = uuid.replacingOccurrences(of: "-", with: "")
        }
        wrapper.set(imei, forKey: "IMEI")
        
        return imei
    }
    
    func saveCity(data:String){
        wrapper.set(data, forKey: "City")
    }
    
    func saveCountryFilter(data:String){
        wrapper.set(data, forKey: "CountryFilter")
    }
    func saveCountryCode(data:String){
        wrapper.set(data, forKey: "CountryCode")
    }
    
    func saveForeignDropOffLocation(data:String) {
        wrapper.set(data, forKey: "ForeignDropOffLocation")
    }
    
    func saveGLOBALCURRENCY(data:String){
        wrapper.set(data, forKey: "GLOBALCURRENCY")
    }
    
    func saveMESSAGE(data:String) {
        wrapper.set(data, forKey: "MESSAGE")
    }
    
    func savePROMOTITLE(data:String) {
        wrapper.set(data, forKey: "PROMOTITLE")
    }
    
    func savePROMOTEXT(data:String) {
        wrapper.set(data, forKey: "PROMOTEXT")
    }
    
    func savePROMOIMAGEURL(data:String) {
        wrapper.set(data, forKey: "PROMOIMAGEURL")
    }
    
    func savePROMOAMOUNT(data:String) {
        wrapper.set(data, forKey: "PROMOAMOUNT")
    }
    
    func saveCarType(data:String) {
        wrapper.set(data, forKey: "CarType")
    }
    
    func saveInitialLocation(data:String) {
        wrapper.set(data, forKey: "InitialLocation")
    }
    
    func saveSelectedLocIndex(data: Int) {
        wrapper.set(data, forKey: "SelectedLocIndex")
    }
    
    func saveTIME(data: String) {
        wrapper.set(data, forKey: "TIME")
    }
    
    func saveDROPOFFADDRESS(data:String) {
        wrapper.set(data, forKey: "DROPOFFADDRESS")
    }
    
    func saveDeviceToken(data:String){
        wrapper.set(data, forKey: "DeviceToken")
    }
    
    func saveTRIPID(data:String){
        wrapper.set(data, forKey: "TRIPID")
    }
    
    func saveLASTSERVED(data:String){
        wrapper.set(data, forKey: "LASTSERVED")
    }
    
    func saveTIMEDISTANCE(data:String){
        wrapper.set(data, forKey: "TIMEDISTANCE")
    }
    
    func saveROADDISTANCE(data:String){
        wrapper.set(data, forKey: "ROADDISTANCE")
    }
    
    func saveVIEWID(data:String){
        wrapper.set(data, forKey: "VIEWID")
    }
    
    func saveDRIVERNAME(data:String){
        wrapper.set(data, forKey: "DRIVERNAME")
    }
    
    func saveDRIVERMOBILE(data:String){
        wrapper.set(data, forKey: "DRIVERMOBILE")
    }
    
    func saveDRIVEREMAIL(data:String){
        wrapper.set(data, forKey: "DRIVEREMAIL")
    }
    
    func saveDRIVERPICTURE(data:String){
        wrapper.set(data, forKey: "DRIVERPICTURE")
    }
    
    func saveDRIVERLATITUDE(data:String){
        wrapper.set(data, forKey: "DRIVERLATITUDE")
    }
    
    func saveDRIVERLONGITUDE(data:String){
        wrapper.set(data, forKey: "DRIVERLONGITUDE")
    }
    
    func saveMODEL(data:String){
        wrapper.set(data, forKey: "MODEL")
    }
    
    func saveNUMBER(data:String){
        wrapper.set(data, forKey: "NUMBER")
    }
    
    func saveCOLOR(data:String){
        wrapper.set(data, forKey: "COLOR")
    }
    
    func saveRATING(data:String){
        wrapper.set(data, forKey: "RATING")
    }
    
    func saveTRIPSTATUS(data:String){
        wrapper.set(data, forKey: "TRIPSTATUS")
    }
    
    func saveWIFIPASS(data:String){
        wrapper.set(data, forKey: "WIFIPASS")
    }
    
    func saveDRIVERBEARING(data:String){
        wrapper.set(data, forKey: "DRIVERBEARING")
    }
    
    func saveLIVEFARE(data:String){
        wrapper.set(data, forKey: "LIVEFARE")
    }
    func saveDISTANCE(data:String){
        wrapper.set(data, forKey: "DISTANCE")
    }
    
    func saveDISTANCETOTALCOST(data:String){
        wrapper.set(data, forKey: "DISTANCETOTALCOST")
    }
    
    func saveTIMETOTALCOST(data:String){
        wrapper.set(data, forKey: "TIMETOTALCOST")
    }
    
    func savePERKM(data:String){
        wrapper.set(data, forKey: "PERKM")
    }
    
    func savePERMIN(data:String){
        wrapper.set(data, forKey: "PERMIN")
    }
    
    func saveCORPORATECODE(data:String){
        wrapper.set(data, forKey: "CORPORATECODE")
    }
    
    func savePAYMENTCODES(data:String){
        wrapper.set(data, forKey: "PAYMENTCODES")
    }
    
    func savePAYMENTCOSTS(data:String){
        wrapper.set(data, forKey: "PAYMENTCOSTS")
    }
    
    func saveET(data:String) {
        wrapper.set(data, forKey: "ET")
    }
    
    func saveED(data:String) {
        wrapper.set(data, forKey: "ED")
    }
    
    func saveBASEPRICE(data:String){
        wrapper.set(data, forKey: "BASEPRICE")
    }
    
    func saveBASEFARE(data:String){
        wrapper.set(data, forKey: "BASEFARE")
    }
    
    func saveVEHICLETYPE(data:String) {
        wrapper.set(data, forKey: "VEHICLETYPE")
    }
    
    func saveVEHICLEIMAGE(data:String) {
        wrapper.set(data, forKey: "VEHICLEIMAGE")
    }
    
    func saveUniqueID(data:String){
        wrapper.set(data, forKey: "UniqueID")
    }
    
    func saveMyUniqueID(data:String){
        wrapper.set(data, forKey: "MyUniqueID")
    }
    
    func saveMyKeyID(data:String){
        wrapper.set(data, forKey: "MyKeyID")
    }
    
    func saveMyEncryptionKey(data:String){
        wrapper.set(data, forKey: "MyEncryptionKey")
    }
    
    func saveMyEncryptionIV(data:String){
        wrapper.set(data, forKey: "MyEncryptionIV")
    }
    
    func saveMyUserName(data:String){
        wrapper.set(data, forKey: "MyUserName")
    }
    
    func saveMyPlatform(data:String){
        wrapper.set(data, forKey: "MyPlatform")
    }
    
    func saveMyCodeBase(data:String){
        wrapper.set(data, forKey: "MyCodeBase")
    }
    
    func saveIsOSM(data:Bool) {
        wrapper.set(data, forKey: "IsOSM")
    }
    
    func saveAmount(data:String) {
        wrapper.set(data, forKey: "Amount")
    }
    
    func saveWalletDiscount(data:String) {
        wrapper.set(data, forKey: "WalletDiscount")
    }
    
    func saveWalletAmount(data:String) {
        wrapper.set(data, forKey: "WalletAmount")
    }
    
    func saveCARDS(data:String) {
        wrapper.set(data, forKey: "CARDS")
    }
    
    func saveFromConfirmOrder(data: Bool) {
        wrapper.set(data, forKey: "FromConfirmOrder")
    }
    
    func saveFromTrip(data:Bool) {
        wrapper.set(data, forKey: "FromTrip")
    }
    
    func saveOnTrip(data:Bool) {
        wrapper.set(data, forKey: "OnTrip")
    }
    
    func saveStartTripOTP(data:String){
        wrapper.set(data, forKey: "StartTripOTP")
    }
    
    func saveEndTripOTP(data:String){
        wrapper.set(data, forKey: "EndTripOTP")
    }
    
    func saveParkingFeeOTP(data:String){
        wrapper.set(data, forKey: "ParkingFeeOTP")
    }
    
    func saveCHAT(data:String){
        wrapper.set(data, forKey: "CHAT")
    }
    
    func savePANICBUTTONSHOW(data:String){
        wrapper.set(data, forKey: "PANICBUTTONSHOW")
    }
    
    func saveSOSMESSAGE(data:String) {
        wrapper.set(data, forKey: "SOSMESSAGE")
    }
    
    func saveEmail(data:String) {
        wrapper.set(data, forKey: "Email")
    }
    
    func saveFEEDBACKID(data:String) {
        wrapper.set(data, forKey: "FEEDBACKID")
    }
    
    func saveFEEDBACK(data:String) {
        wrapper.set(data, forKey: "FEEDBACK")
    }
    
    // MARK: - Get Functions
    
    func getFromSearch() -> Bool! {
        var check = wrapper.bool(forKey: "FromSearch")
        if check == nil {
            check = false
        }
        return check
    }
    
    func getPicture() -> String! {
        var check=wrapper.string(forKey: "Picture")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getSessionToken() -> String! {
        var check=wrapper.string(forKey: "SessionToken")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getFullName() -> String! {
        var check=wrapper.string(forKey: "FullName")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPICKUPADDRESS() -> String! {
        var check=wrapper.string(forKey: "PICKUPADDRESS")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getFromPickupLoc() -> Bool! {
        var check=wrapper.bool(forKey: "FromPickupLoc")
        if check == nil {
            check = false
        }
        return check
    }
    
    func getFarLeft() -> String! {
        var check=wrapper.string(forKey: "FarLeft")
        if check == nil {
            check = "0.0,0.0"
        }
        return check
    }
    
    func getNearRight() -> String! {
        var check=wrapper.string(forKey: "NearRight")
        if check == nil {
            check = "0.0,0.0"
        }
        return check
    }
    
    func getCurrentLocation() -> String! {
        var check=wrapper.string(forKey: "CurrentLocation")
        if check == nil {
            check = "0.0,0.0"
        }
        return check
    }
    
    func getRecentPlacesNames()->[String]!{
        let check=prefs.array(forKey: "RecentPlacesNames")
        if check==nil {
            return []
        }
        return check as! [String]?
    }
    
    func getRecentPlacesFormattedAddress()->[String]!{
        let check=prefs.array(forKey: "RecentPlacesFormattedAddress")
        if check==nil {
            return []
        }
        return check as! [String]?
    }
    
    func getRecentPlacesCoords()->[String]!{
        let check=prefs.array(forKey: "RecentPlacesCoords")
        if check==nil {
            return []
        }
        return check as! [String]?
    }
    
    func getCountry()->String!{
        var check=wrapper.string(forKey: "Country")
        if check == nil || check == "" {
            check = "KENYA"
        }
        return check
    }
    
    func getPreferredDriverName() -> String! {
        var check=wrapper.string(forKey: "PreferredDriverName")
        if check == nil {
            check = ""
        }
        return check
    }
    func getPreferredDriver() -> String! {
        var check=wrapper.string(forKey: "PreferredDriver")
        if check == nil {
            check = ""
        }
        return check
    }
    func getPreferredDriverImage() -> String! {
        var check=wrapper.string(forKey: "PreferredDriverImage")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPaymentMode() -> String! {
        var check=wrapper.string(forKey: "PaymentMode")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPaymentModeID() -> String! {
        var check=wrapper.string(forKey: "PaymentModeID")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPaymentModes() -> String! {
        var check=wrapper.string(forKey: "PaymentModes")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPaymentModeIDs() -> String! {
        var check=wrapper.string(forKey: "PaymentModeIDs")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPhoneNumber() -> String! {
        var check=wrapper.string(forKey: "PhoneNumber")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getIMEI() -> String! {
        if let check = wrapper.string(forKey: "IMEI") {
            return check
        } else {
            return saveIMEI()
        }
    }
    
    func getCity() -> String! {
        var check=wrapper.string(forKey: "City")
        if check == nil || check == "" {
            check = "NAIROBI"
        }
        return check
    }
    func getCountryFilter() -> String! {
        var check=wrapper.string(forKey: "CountryFilter")
        if check == nil || check == "" {
            check = "KE"
        }
        return check
    }
    func getCountryCode() -> String! {
        var check=wrapper.string(forKey: "CountryCode")
        if check == nil || check == "" {
            check = "254"
        }
        return check
    }
    
    func getStillRequesting() -> Bool! {
        var check=wrapper.bool(forKey: "StillRequesting")
        if check == nil {
            check = false
        }
        return check
    }
    
    func getFORWARDCOUNT() -> String! {
        var check=wrapper.string(forKey: "FORWARDCOUNT")
        if check == nil {
            check = "0"
        }
        return check
    }
    
    func getGLOBALCURRENCY() -> String! {
        var check=wrapper.string(forKey: "GLOBALCURRENCY")
        if check == nil {
            check = "KES"
        }
        return check
    }
    
    func getMESSAGE() -> String! {
        var check=wrapper.string(forKey: "MESSAGE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPROMOTITLE() -> String! {
        var check=wrapper.string(forKey: "PROMOTITLE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPROMOTEXT() -> String! {
        var check=wrapper.string(forKey: "PROMOTEXT")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPROMOIMAGEURL() -> String! {
        var check=wrapper.string(forKey: "PROMOIMAGEURL")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPROMOAMOUNT() -> String! {
        var check=wrapper.string(forKey: "PROMOAMOUNT")
        if check == nil {
            check = "0.00"
        }
        return check
    }
    
    func getCarType() -> String! {
        var check=wrapper.string(forKey: "CarType")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getInitialLocation() -> String! {
        var check=wrapper.string(forKey: "InitialLocation")
        if check == nil {
            check = "0.0,0.0"
        }
        return check
    }
    
    func getSelectedLocIndex() -> Int! {
        var check=wrapper.integer(forKey: "SelectedLocIndex")
        if check == nil {
            check = 0
        }
        return Int(check!)
    }

    func getTIME() -> String! {
        var check=wrapper.string(forKey: "TIME")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getDROPOFFADDRESS() -> String! {
        var check=wrapper.string(forKey: "DROPOFFADDRESS")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getDeviceToken() -> String! {
        var check=wrapper.string(forKey: "DeviceToken")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getTRIPID() -> String! {
        var check=wrapper.string(forKey: "TRIPID")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getLASTSERVED() -> String! {
        var check=wrapper.string(forKey: "LASTSERVED")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getTIMEDISTANCE() -> String! {
        var check=wrapper.string(forKey: "TIMEDISTANCE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getROADDISTANCE() -> String! {
        var check=wrapper.string(forKey: "ROADDISTANCE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getVIEWID() -> String! {
        var check=wrapper.string(forKey: "VIEWID")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getDRIVERNAME() -> String! {
        var check=wrapper.string(forKey: "DRIVERNAME")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getDRIVERMOBILE() -> String! {
        var check=wrapper.string(forKey: "DRIVERMOBILE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getDRIVEREMAIL() -> String! {
        var check=wrapper.string(forKey: "DRIVEREMAIL")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getDRIVERPICTURE() -> String! {
        var check=wrapper.string(forKey: "DRIVERPICTURE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getDRIVERLATITUDE() -> String! {
        var check=wrapper.string(forKey: "DRIVERLATITUDE")
        if check == nil {
            check = "0.0"
        }
        return check
    }
    
    func getDRIVERLONGITUDE() -> String! {
        var check=wrapper.string(forKey: "DRIVERLONGITUDE")
        if check == nil {
            check = "0.0"
        }
        return check
    }
    
    func getMODEL() -> String! {
        var check=wrapper.string(forKey: "MODEL")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getNUMBER() -> String! {
        var check=wrapper.string(forKey: "NUMBER")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getCOLOR() -> String! {
        var check=wrapper.string(forKey: "COLOR")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getRATING() -> String! {
        var check=wrapper.string(forKey: "RATING")
        if check == nil {
            check = ""
        } 
        return check
    }
    
    func getTRIPSTATUS() -> String! {
        var check=wrapper.string(forKey: "TRIPSTATUS")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getWIFIPASS() -> String! {
        var check=wrapper.string(forKey: "WIFIPASS")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getDRIVERBEARING() -> String! {
        var check=wrapper.string(forKey: "DRIVERBEARING")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getLIVEFARE() -> String! {
        var check=wrapper.string(forKey: "LIVEFARE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getDISTANCE() -> String! {
        var check=wrapper.string(forKey: "DISTANCE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getDISTANCETOTALCOST() -> String! {
        var check=wrapper.string(forKey: "DISTANCETOTALCOST")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getTIMETOTALCOST() -> String! {
        var check=wrapper.string(forKey: "TIMETOTALCOST")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPERKM() -> String! {
        var check=wrapper.string(forKey: "PERKM")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPERMIN() -> String! {
        var check=wrapper.string(forKey: "PERMIN")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getCORPORATECODE() -> String! {
        var check=wrapper.string(forKey: "CORPORATECODE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPAYMENTCODES() -> String! {
        var check=wrapper.string(forKey: "PAYMENTCODES")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getPAYMENTCOSTS() -> String! {
        var check=wrapper.string(forKey: "PAYMENTCOSTS")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getET() -> String! {
        var check=wrapper.string(forKey: "ET")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getED() -> String! {
        var check=wrapper.string(forKey: "ED")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getBASEPRICE() -> String! {
        var check=wrapper.string(forKey: "BASEPRICE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getBASEFARE() -> String! {
        var check=wrapper.string(forKey: "BASEFARE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getVEHICLETYPE() -> String! {
        var check=wrapper.string(forKey: "VEHICLETYPE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getVEHICLEIMAGE() -> String! {
        var check=wrapper.string(forKey: "VEHICLEIMAGE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getUniqueID() -> String!{
        var check=wrapper.string(forKey: "UniqueID")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getMyUniqueID() -> String!{
        var check=wrapper.string(forKey: "MyUniqueID")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getMyKeyID() -> String!{
        var check=wrapper.string(forKey: "MyKeyID")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getMyEncryptionKey() -> String!{
        var check=wrapper.string(forKey: "MyEncryptionKey")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getMyEncryptionIV() -> String!{
        var check=wrapper.string(forKey: "MyEncryptionIV")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getMyUserName() -> String!{
        var check=wrapper.string(forKey: "MyUserName")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getMyPlatform() -> String!{
        var check=wrapper.string(forKey: "MyPlatform")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getMyCodeBase() -> String!{
        var check=wrapper.string(forKey: "MyCodeBase")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getIsOSM() -> Bool! {
        var check=wrapper.bool(forKey: "IsOSM")
        if check == nil {
            check = true
        }
        return check
    }
    
    func getAmount() -> String!{
        var check=wrapper.string(forKey: "Amount")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getWalletDiscount()->String!{
        var check=wrapper.string(forKey: "WalletDiscount")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getWalletAmount()->String!{
        var check=wrapper.string(forKey: "WalletAmount")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getCARDS()->String!{
        var check=wrapper.string(forKey: "CARDS")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getFromConfirmOrder()->Bool!{
        let check=wrapper.bool(forKey: "FromConfirmOrder")
        if check == nil {
            return false
        }
        return check
    }
    
    func getSDKMobileNumber()->String!{
        var check=wrapper.string(forKey: "SDKMobileNumber")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getSDKPackageName()->String!{
        var check=wrapper.string(forKey: "SDKPackageName")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getSDKAccounts()->String!{
        var check=wrapper.string(forKey: "SDKAccounts")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getFromTrip()->Bool!{
        let check=wrapper.bool(forKey: "FromTrip")
        if check == nil {
            return false
        }
        return check
    }
    
    func getOnTrip()->Bool!{
        let check=wrapper.bool(forKey: "OnTrip")
        if check == nil {
            return false
        }
        return check
    }
    
    func getStartTripOTP()->String!{
        var check=wrapper.string(forKey: "StartTripOTP")
        if check == nil {
            check = ""
        }
        return check
    }
    func getEndTripOTP()->String!{
        var check=wrapper.string(forKey: "EndTripOTP")
        if check == nil {
            check = ""
        }
        return check
    }
    func getParkingFeeOTP()->String!{
        var check=wrapper.string(forKey: "ParkingFeeOTP")
        if check == nil {
           check = ""
        }
        return check
    }
    func getCHAT()->String!{
        var check=wrapper.string(forKey: "CHAT")
        if check == nil {
           check = ""
        }
        return check
    }
    
    func getPANICBUTTONSHOW()->String!{
        var check=wrapper.string(forKey: "PANICBUTTONSHOW")
        if check == nil {
            check = "0"
        }
        return check
    }
    
    func getSOSMESSAGE()->String!{
        var check=wrapper.string(forKey: "SOSMESSAGE")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getEmail()->String!{
        var check=wrapper.string(forKey: "Email")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getFEEDBACKID()->String!{
        var check=wrapper.string(forKey: "FEEDBACKID")
        if check == nil {
            check = ""
        }
        return check
    }
    
    func getFEEDBACK()->String!{
        var check=wrapper.string(forKey: "FEEDBACK")
        if check == nil {
            check = ""
        }
        return check
    }
    
    
    // MARK: - Encryption
    
    func EncodeDataBase64(DataToSend:String) -> NSString {
        if let plainData = (DataToSend as NSString).data(using: String.Encoding.utf8.rawValue) {
            let base64String = plainData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            return base64String as NSString
        }
        
        return ""
    }
    
    func EncryptDataKC(DataToSend: String) -> String {
        let aes = LittleSDKAES(key: cn.chainkey as String, iv: cn.iv as String)
        if let encrypteddata = aes?.encrypt(string: DataToSend) {
            let encryptedstr = encrypteddata.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            return encryptedstr
        }
        return ""
    }
    
    func EncryptDataHeaders(DataToSend: String) -> String {
        let aes = LittleSDKAES(key: cn.headerkey as String, iv: cn.headeriv as String)
        if let encrypteddata = aes?.encrypt(string: DataToSend) {
            let encryptedstr = encrypteddata.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            return encryptedstr
        }
        return ""
    }
    
    func EncryptDataAES(DataToSend:String)->String{
        let aes = LittleSDKAES(key: am.getMyEncryptionKey() ?? "", iv: am.getMyEncryptionIV() ?? "")
        if let encrypteddata = aes?.encrypt(string: DataToSend) {
            let encryptedstr = encrypteddata.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            return encryptedstr
        }
        return ""
    }
    
    func EncryptDataMD5(DataToSend: String) -> String {
        let encrypteddata:String = md5Hash(str: DataToSend)
        return encrypteddata
    }
    
    // MARK: - Decryption
    
    func DecodeDataBase64(DataToSend:String) -> NSString {
        
        let base64Decoded = NSData(base64Encoded: DataToSend, options: NSData.Base64DecodingOptions(rawValue: 0))
        let dataString = NSString(data: base64Decoded! as Data, encoding:String.Encoding.utf8.rawValue)
        return dataString ?? ""
    }
    
    func DecryptDataKC(DataToSend:String)->NSString{
        let aes = LittleSDKAES(key: cn.chainkey as String, iv: cn.iv as String)
        if let b64encdata1 = Data(base64Encoded: DataToSend, options: NSData.Base64DecodingOptions(rawValue: 0)) {
            let decryptedstr = aes?.decrypt(data: b64encdata1)
            return (decryptedstr ?? "") as NSString
        }
        return ""
    }
    
    func DecryptDataHeaders(DataToSend: String) -> NSString {
        let aes = LittleSDKAES(key: cn.headerkey as String, iv: cn.headeriv as String)
        if let b64encdata1 = Data(base64Encoded: DataToSend, options: NSData.Base64DecodingOptions(rawValue: 0)) {
            let decryptedstr = aes?.decrypt(data: b64encdata1)
            return (decryptedstr ?? "") as NSString
        }
        return ""
    }
    
    func DecryptDataAES(DataToSend:String)->NSString{
        let aes = LittleSDKAES(key: am.getMyEncryptionKey() ?? "", iv: am.getMyEncryptionIV() ?? "")
        if let b64encdata1 = Data(base64Encoded: DataToSend, options: NSData.Base64DecodingOptions(rawValue: 0)) {
            let decryptedstr = aes?.decrypt(data: b64encdata1)
            return (decryptedstr ?? "") as NSString
        }
        return ""
    }
    
}
