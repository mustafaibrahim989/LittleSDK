//
//  Structures.swift
//  LittleSDK
//
//  Created by Gabriel John on 10/05/2021.
//

import Foundation

struct FareEstimate_Base : Codable {
    
    let currency : String?
    let vehicleType : String?
    let subVehicleType: String?
    let maxSize : Int?
    let costDistance : Double?
    let costTime : Double?
    let minimumCost : Double?
    let basePrice : Double?
    let vehicleICON : String?
    let tripCost : Double?
    let maxAmount : Double?
    let minAmount : Double?
    let textLabels : String?
    let costEstimate : String?
    let oldTripCost : String?
    let vehicleCategory : String?
    let bannerImage: String?
    let bannerText, newitem: String?
    
    enum CodingKeys: String, CodingKey {
        
        case currency = "Currency"
        case vehicleType = "VehicleType"
        case subVehicleType = "SubVehicleType"
        case maxSize = "MaxSize"
        case costDistance = "CostDistance"
        case costTime = "CostTime"
        case minimumCost = "MinimumCost"
        case basePrice = "BasePrice"
        case vehicleICON = "VehicleICON"
        case tripCost = "TripCost"
        case maxAmount = "MaxAmount"
        case minAmount = "MinAmount"
        case textLabels = "TextLabels"
        case costEstimate = "CostEstimate"
        case oldTripCost = "OldTripCost"
        case vehicleCategory = "VehicleCategory"
        case bannerImage = "BannerImage"
        case bannerText = "BannerText"
        case newitem = "Newitem"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currency = try values.decodeIfPresent(String.self, forKey: .currency)
        vehicleType = try values.decodeIfPresent(String.self, forKey: .vehicleType)
        subVehicleType = try values.decodeIfPresent(String.self, forKey: .subVehicleType)
        maxSize = try values.decodeIfPresent(Int.self, forKey: .maxSize)
        costDistance = try values.decodeIfPresent(Double.self, forKey: .costDistance)
        costTime = try values.decodeIfPresent(Double.self, forKey: .costTime)
        minimumCost = try values.decodeIfPresent(Double.self, forKey: .minimumCost)
        basePrice = try values.decodeIfPresent(Double.self, forKey: .basePrice)
        vehicleICON = try values.decodeIfPresent(String.self, forKey: .vehicleICON)
        tripCost = try values.decodeIfPresent(Double.self, forKey: .tripCost)
        maxAmount = try values.decodeIfPresent(Double.self, forKey: .maxAmount)
        minAmount = try values.decodeIfPresent(Double.self, forKey: .minAmount)
        textLabels = try values.decodeIfPresent(String.self, forKey: .textLabels)
        oldTripCost = try values.decodeIfPresent(String.self, forKey: .oldTripCost)
        costEstimate = try values.decodeIfPresent(String.self, forKey: .costEstimate)
        vehicleCategory = try values.decodeIfPresent(String.self, forKey: .vehicleCategory)
        newitem = try values.decodeIfPresent(String.self, forKey: .newitem)
        bannerText = try values.decodeIfPresent(String.self, forKey: .bannerText)
        bannerImage = try values.decodeIfPresent(String.self, forKey: .bannerImage)
    }
    
}

// MARK: - LocationSet

struct LocationSetSDK: Codable {
    let id: String
    let name: String
    let subname: String
    let latitude: String
    let longitude: String
    let phonenumber: String
    let instructions: String
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case subname
        case latitude
        case longitude
        case phonenumber
        case instructions
    }
}

// MARK: - FareEstimateSet

struct LocationsEstimateSetSDK: Codable {
    let pickupLocation: LocationSetSDK?
    let dropoffLocations: [LocationSetSDK]?
    enum CodingKeys: String, CodingKey {
        case pickupLocation
        case dropoffLocations
    }
}

// MARK: - GetPendingResult
struct GetPendingResult: Codable {
    let status, message, city, country: String?
    let currency, gif, event, eventImage, eventColor, forwardCount, tripID, forceLogout: String?
    let popupTitle, popupImage, popupMessage, popupType, forceUpdate: String?
    let waitTime: Int?
    let wallets: [Wallet]?
    let paymentTypes: [PaymentTypeSDK]?
    let recentTrips: [RecentTrip]?
    
    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case city = "City"
        case country = "Country"
        case currency = "Currency"
        case gif = "GIF"
        case event = "Event"
        case eventImage = "EventImage"
        case eventColor = "EventColor"
        case forwardCount = "ForwardCount"
        case tripID = "TripID"
        case forceLogout = "ForceLogout"
        case popupTitle = "PopupTitle"
        case popupImage = "PopupImage"
        case popupMessage = "PopupMessage"
        case popupType = "PopupType"
        case forceUpdate = "ForceUpdate"
        case waitTime = "WaitTime"
        case wallets = "Wallets"
        case paymentTypes = "PaymentTypes"
        case recentTrips = "RecentTrips"
    }
}

// MARK: - RecentTrip
struct RecentTrip: Codable {
    let pickupLL, dropOffLL, pickupName, dropOffName: String?

    enum CodingKeys: String, CodingKey {
        case pickupLL = "PickupLL"
        case dropOffLL = "DropOffLL"
        case pickupName = "PickupName"
        case dropOffName = "DropOffName"
    }
}

// MARK: - PaymentType
struct PaymentTypeSDK: Codable {
    let paymentMode: String?
    
    enum CodingKeys: String, CodingKey {
        case paymentMode = "PaymentMode"
    }
}

// MARK: - Wallet
struct Wallet: Codable {
    let walletUniqueID, walletName: String?

    enum CodingKeys: String, CodingKey {
        case walletUniqueID = "WalletUniqueID"
        case walletName = "WalletName"
    }
}

typealias GetPendingResults = [GetPendingResult]

// MARK: - DefaultMessage
struct DefaultMessage: Codable {
    let status, message: String?
    
    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
    }
}

typealias DefaultMessages = [DefaultMessage]

// MARK: - TripDropOffDetail
struct TripDropOffDetail: Codable {
    let tripID: String?
    let dropOffNumber: Double?
    let dropOffAddress, dropOffLL, contactMobileNumber, contactName: String?
    let notes, endedOn: String?

    enum CodingKeys: String, CodingKey {
        case tripID = "TripID"
        case dropOffNumber = "DropOffNumber"
        case dropOffAddress = "DropOffAddress"
        case dropOffLL = "DropOffLL"
        case contactMobileNumber = "ContactMobileNumber"
        case contactName = "ContactName"
        case notes = "Notes"
        case endedOn = "EndedOn"
    }
}

// MARK: - TripResponseElement
struct TripResponseElement: Codable {
    let status, message, tripID, driverName, driverMobileNumber: String?
    let driverPIC, driverMobile: String?
    let driverLatitude, driverLongitude, carModel, carNumber: String?
    let carColor, driverRating, roadDistance, timeDistance: String?
    let friendCode, socialMediaID, tripDistance, tripTime: String?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case tripID = "TripID"
        case driverName = "DriverName"
        case driverMobileNumber = "DriverMobileNumber"
        case driverMobile = "DriverMobile"
        case driverPIC = "DriverPIC"
        case driverLatitude = "DriverLatitude"
        case driverLongitude = "DriverLongitude"
        case carModel = "CarModel"
        case carNumber = "CarNumber"
        case carColor = "CarColor"
        case driverRating = "DriverRating"
        case roadDistance = "RoadDistance"
        case timeDistance = "TimeDistance"
        case friendCode = "FriendCode"
        case socialMediaID = "SocialMediaID"
        case tripDistance = "TripDistance"
        case tripTime = "TripTime"
    }
}

typealias TripResponse = [TripResponseElement]

// MARK: - RequestStatusResponseElement
struct RequestStatusResponseElement: Codable {
    let status, message, tripStatus: String?
    let driverLongitude, driverLatitude, driverBearing: String?
    let costPerKilometer, costPerMinute: String?
    let liveFare, et, ed, vehicleType: String?
    let corporateID, paymentMode, currency, wifiPass: String?
    let minimumFare, basePrice, distance, distanceTotalCost, timeTotalCost: String?
    let time, paymentCodes, paymentCosts: String?
    let startOTP, endOTP, parkingOTP, tripChat: String?
    let tripDropOffDetails: [TripDropOffDetail]?
    let dropOffLL, pickupLL: String?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case tripStatus = "TripStatus"
        case driverLongitude = "DriverLongitude"
        case driverLatitude = "DriverLatitude"
        case driverBearing = "DriverBearing"
        case costPerKilometer = "PerKM"
        case costPerMinute = "PerMin"
        case liveFare = "LiveFare"
        case et = "ET"
        case ed = "ED"
        case vehicleType = "VehicleType"
        case corporateID = "CorporateID"
        case paymentMode = "PaymentMode"
        case currency = "Currency"
        case wifiPass = "WifiPass"
        case minimumFare = "MinimumFare"
        case basePrice = "BasePrice"
        case distance = "Distance"
        case time = "Time"
        case paymentCodes = "PaymentCodes"
        case paymentCosts = "PaymentCosts"
        case distanceTotalCost = "DistanceTotalCost"
        case timeTotalCost = "TimeTotalCost"
        case startOTP = "StartTripOTP"
        case endOTP = "EndTripOTP"
        case parkingOTP = "ParkingOTP"
        case tripChat = "TripChat"
        case tripDropOffDetails = "TripDropOffDetails"
        case dropOffLL = "DropOffLL"
        case pickupLL = "PickUpLL"
    }
}

typealias RequestStatusResponse = [RequestStatusResponseElement]

// MARK: - SDKConfirmElement
struct SDKConfirmElement: Codable {
    var uniqueID, keyID, encryptionKey, encryptionIV: String?
    var userName, platform, codeBase: String?

    enum CodingKeys: String, CodingKey {
        case uniqueID = "UniqueID"
        case keyID = "KeyID"
        case encryptionKey = "EncryptionKey"
        case encryptionIV = "EncryptionIV"
        case userName = "UserName"
        case platform = "Platform"
        case codeBase = "CodeBase"
    }
}

typealias SDKConfirm = [SDKConfirmElement]

// MARK: - SDKData
struct SDKData: Codable {
    var data: String?

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

// MARK: - TripProviders
struct TripProviders: Codable {
    var status, vehicleType: String?
    var providerDriverLocationList: [ProviderDriverLocationList]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case vehicleType = "VehicleType"
        case providerDriverLocationList = "ProviderDriverLocationList"
    }
}

// MARK: - ProviderDriverLocationList
struct ProviderDriverLocationList: Codable {
    var latitude, longitude, bearing: String?

    enum CodingKeys: String, CodingKey {
        case latitude = "Latitude"
        case longitude = "Longitude"
        case bearing = "Bearing"
    }
}

// MARK: - PreferredDrivers
struct PreferredDrivers: Codable {
    var status: String?
    var listPreferredDrivers: [ListPreferredDriver]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case listPreferredDrivers = "ListPreferredDrivers"
    }
}

// MARK: - ListPreferredDriver
struct ListPreferredDriver: Codable {
    var driverEMailID, driverName: String?
    var driverImage: String?
    var roadDistance, timeDistance, rating, lastServed: String?
    var aboutMe: String?

    enum CodingKeys: String, CodingKey {
        case driverEMailID = "DriverEMailID"
        case driverName = "DriverName"
        case driverImage = "DriverImage"
        case roadDistance = "RoadDistance"
        case timeDistance = "TimeDistance"
        case rating = "Rating"
        case lastServed = "LastServed"
        case aboutMe = "AboutMe"
    }
}

// MARK: - Balance
struct Balance: Codable {
    let walletID, walletName: String?
    let balance: Double?

    enum CodingKeys: String, CodingKey {
        case walletID = "WalletID"
        case walletName = "WalletName"
        case balance = "WalletBalance"
    }
}

// MARK: - Field
struct Field: Codable {
    let fieldTitle, fieldType, fieldValue, fieldCategory, fieldAnswer: String?

    enum CodingKeys: String, CodingKey {
        case fieldTitle = "FieldTitle"
        case fieldType = "FieldType"
        case fieldValue = "FieldValue"
        case fieldCategory = "FieldCategory"
        case fieldAnswer = "FieldAnswer"
    }
}

// MARK: - NearbyMerchant
struct NearbyMerchant: Codable {
    let status, paymentCode, name: String?
    let distance: Double?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case paymentCode = "PaymentCode"
        case name = "Name"
        case distance = "Distance"
    }
}

typealias NearbyMerchants = [NearbyMerchant]

// MARK: - MerchantValidateElement
struct MerchantValidateElement: Codable {
    let status, message, merchantValidateDescription, name: String?
    let logo: String?
    let minimumAmount, maximumAmount: Double?
    let fields: [Field]?
    let balance: [Balance]?
    let customerDiscount, merchantDiscount: Double?
    let merchantDescription: String?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case merchantValidateDescription = "Description"
        case name = "Name"
        case logo = "Logo"
        case minimumAmount = "MinimumAmount"
        case maximumAmount = "MaximumAmount"
        case fields = "Fields"
        case balance = "Balance"
        case customerDiscount = "CustomerDiscount"
        case merchantDiscount = "MerchantDiscount"
        case merchantDescription = "MerchantDescription"
    }
}

typealias MerchantValidate = [MerchantValidateElement]

// MARK: - MerchantPay
struct MerchantPay: Codable {
    let status, message, merchantReference: String?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case merchantReference = "MerchantReference"
    }
}

// MARK: - WalletsToLoadElement
struct WalletsToLoadElement: Codable {
    let status, message, askID, kycMessage: String?
    let wallets: [Wallet]?
    let toWallets: [ToWallet]?
    let trx: [TrxWallet]?
    let kycFields: [KYCField]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case askID = "AskID"
        case kycMessage = "KYCMessage"
        case wallets = "Wallets"
        case toWallets = "ToWallets"
        case trx = "Trx"
        case kycFields = "KYCFields"
    }
}

// MARK: - KYCField
struct KYCField: Codable {
    let fieldID, fieldName, fieldType, incentiveText, kycValue: String?
    let incentive: Double?

    enum CodingKeys: String, CodingKey {
        case fieldID = "FieldID"
        case fieldName = "FieldName"
        case fieldType = "FieldType"
        case incentiveText = "IncentiveText"
        case incentive = "Incentive"
        case kycValue = "KycValue"
    }
}

// MARK: - ToWallet
struct ToWallet: Codable {
    let toWalletID, toWalletName: String?

    enum CodingKeys: String, CodingKey {
        case toWalletID = "ToWalletID"
        case toWalletName = "ToWalletName"
    }
}

// MARK: - Trx
struct TrxWallet: Codable {
    let loadDate: String?
    let amountLoaded, offerAmount: Double?
    let paymentSource, reference: String?

    enum CodingKeys: String, CodingKey {
        case loadDate = "LoadDate"
        case amountLoaded = "AmountLoaded"
        case offerAmount = "OfferAmount"
        case paymentSource = "PaymentSource"
        case reference = "Reference"
    }
}

typealias WalletsToLoad = [WalletsToLoadElement]

// MARK: - CouponStatusElement
struct CouponStatusElement: Codable {
    let status, message, toWalletID, couponType, couponName: String?
    let couponURL, description: String?
    let couponText: String?
    let amount: Double?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case toWalletID = "ToWalletID"
        case couponType = "CouponType"
        case description = "Description"
        case couponText = "CouponText"
        case couponName = "CouponName"
        case couponURL = "CouponURL"
        case amount = "Amount"
    }
}

typealias CouponStatus = [CouponStatusElement]

struct QRData: Codable {
    var status, message, merchantID, amount, reference: String?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case merchantID = "MerchantID"
        case amount = "Amount"
        case reference = "Reference"
    }
}

// MARK: - GetRestaurant
struct GetRestaurant: Codable {
    let status: String?
    let restaurants: [Restaurant]?
    let offers: [Restaurant]?
    let paymentModes: [PaymentMode]?
    let riderBalance: [RiderBalance]?
    let balance: [Balance]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case restaurants = "Restaurants"
        case offers = "Offers"
        case paymentModes = "PaymentModes"
        case riderBalance = "RiderBalance"
        case balance = "Wallet"
    }
}

// MARK: - PaymentMode
struct PaymentMode: Codable {
    let paymentMode: String?
    let balance: Double?
    let currency: String?

    enum CodingKeys: String, CodingKey {
        case paymentMode = "PaymentMode"
        case balance = "Balance"
        case currency = "Currency"
    }
}

// MARK: - Restaurant
struct Restaurant: Codable {
    let offerText, menuOnOffer, promoCode, restaurantID, restaurantName, typeOfRestaurant, locationName: String?
    let foodCategory, averageTime: String?
    let address: String?
    let deliveryCharges: Double?
    let distance, latitude, longitude: Double?
    let image: String?
    let rating: Double?
    let deliveryModes: [DeliveryMode]?
    let offline: Bool?

    enum CodingKeys: String, CodingKey {
        case offerText = "OfferText"
        case menuOnOffer = "MenuOnOffer"
        case promoCode = "PromoCode"
        case restaurantID = "RestaurantID"
        case restaurantName = "RestaurantName"
        case typeOfRestaurant = "TypeOfRestaurant"
        case locationName = "LocationName"
        case foodCategory = "FoodCategory"
        case averageTime = "AverageTime"
        case address = "Address"
        case deliveryCharges = "DeliveryCharges"
        case distance = "Distance"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case image = "Image"
        case rating = "Rating"
        case deliveryModes = "DeliveryModes"
        case offline = "Offline"
    }
}

// MARK: - RiderBalance
struct RiderBalance: Codable {
    let balanceType: String?
    let balance: Double?

    enum CodingKeys: String, CodingKey {
        case balanceType = "BalanceType"
        case balance = "Balance"
    }
}

// MARK: - DeliveryMode
struct DeliveryMode: Codable {
    let deliveryModes, deliveryModeDescription: String?
    let deliveryCharges: Double?

    enum CodingKeys: String, CodingKey {
        case deliveryModes = "DeliveryModes"
        case deliveryModeDescription = "Description"
        case deliveryCharges = "DeliveryCharges"
    }
}

typealias GetRestaurants = [GetRestaurant]

// MARK: - OrderHistoryElement
struct OrderHistoryElement: Codable {
    let status: String?
    let listTrips: [ListTrip]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case listTrips = "ListTrips"
    }
}

// MARK: - ListTrip
struct ListTrip: Codable {
    let orderedOn, deliveryTripID, serviceTripID, requestSendToDriver: String?
    let tripStatus, restaurantName, currencyID: String?
    let orderAmount: Double?
    let deliveryCharges: Double?
    let totalCharges: Double?
    let promo: Double?
    let driverName: String?
    let driverProfile: String?

    enum CodingKeys: String, CodingKey {
        case orderedOn = "OrderedOn"
        case deliveryTripID = "DeliveryTripID"
        case serviceTripID = "ServiceTripID"
        case requestSendToDriver = "RequestSendToDriver"
        case tripStatus = "TripStatus"
        case restaurantName = "RestaurantName"
        case currencyID = "CurrencyID"
        case orderAmount = "OrderAmount"
        case deliveryCharges = "DeliveryCharges"
        case totalCharges = "TotalCharges"
        case promo = "Promo"
        case driverName = "DriverName"
        case driverProfile = "DriverProfile"
    }
}


typealias OrderHistory = [OrderHistoryElement]


// MARK: - OrderSummaryElement
struct OrderSummaryElement: Codable {
    let status, driverEMail, serviceTripID: String?
    let deliveryCharges: Double?
    let promo: Double?
    let deliveryTripDetails: [DeliveryTripDetail]?
    let deliveryLogs: [DeliveryLog]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case driverEMail = "DriverEMail"
        case serviceTripID = "ServiceTripID"
        case deliveryCharges = "DeliveryCharges"
        case promo = "Promo"
        case deliveryTripDetails = "DeliveryTripDetails"
        case deliveryLogs = "DeliveryLogs"
    }
}

// MARK: - DeliveryTripDetail
struct DeliveryTripDetail: Codable {
    let foodName: String?
    let price: Double?
    let price1, quantity: Double?

    enum CodingKeys: String, CodingKey {
        case foodName = "FoodName"
        case price = "Price"
        case price1 = "Price1"
        case quantity = "Quantity"
    }
}

// MARK: - DeliveryLog
struct DeliveryLog: Codable {
    let eventName, eventTime, name, email, mobileNumber: String?

    enum CodingKeys: String, CodingKey {
        case eventName = "EventName"
        case eventTime = "EventTime"
        case name = "Name"
        case email = "Email"
        case mobileNumber = "MobileNumber"
    }
}

typealias OrderSummary = [OrderSummaryElement]

// MARK: - CartItems
struct CartItems: Codable {
    let itemID: String?
    let addonID: String?
    let number: Double?

    enum CodingKeys: String, CodingKey {
        case itemID = "itemID"
        case addonID = "addonID"
        case number = "number"
    }
}

// MARK: - GetRestaurantMenuElement
struct GetRestaurantMenuElement: Codable {
    let status, currency: String?
    let foodMenu: [FoodMenu]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case currency = "Currency"
        case foodMenu = "FoodMenu"
    }
}

// MARK: - FoodMenu
struct FoodMenu: Codable {
    let menuID, foodCategory, foodName, foodDescription: String?
    let originalPrice, specialPrice: Double?
    let foodImage: String?
    let extraItem: String?
    let addonID: String?
    let extraItems: [GroupDetail]?

    enum CodingKeys: String, CodingKey {
        case menuID = "MenuID"
        case foodCategory = "FoodCategory"
        case foodName = "FoodName"
        case foodDescription = "FoodDescription"
        case originalPrice = "OriginalPrice"
        case specialPrice = "SpecialPrice"
        case foodImage = "FoodImage"
        case extraItem = "ExtraItem"
        case addonID = "AddonID"
        case extraItems = "ExtraItems"
    }
}

typealias GetRestaurantMenu = [GetRestaurantMenuElement]

// MARK: - ExtraMenuItem
struct ExtraMenuItem: Codable {
    let status, message, groupTitle, typeOfSelection: String?
    let finalNotes: String?
    let extraMenuItemRequired: Bool?
    let groupDetails: [GroupDetail]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case groupTitle = "GroupTitle"
        case typeOfSelection = "TypeOfSelection"
        case finalNotes = "FinalNotes"
        case extraMenuItemRequired = "Required"
        case groupDetails = "GroupDetails"
    }
}

// MARK: - GroupDetail
struct GroupDetail: Codable {
    let extraItemID, extraItemName, extraItemDescription: String?
    let specialPrice: Double?

    enum CodingKeys: String, CodingKey {
        case extraItemID = "ExtraItemID"
        case extraItemName = "ExtraItemName"
        case extraItemDescription = "ExtraItemDescription"
        case specialPrice = "SpecialPrice"
    }
}

typealias ExtraMenuItems = [ExtraMenuItem]

// MARK: - OrderResponseElement
struct OrderResponseElement: Codable {
    let status, message, tripID, eMailID, driverInAppID: String?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case tripID = "TripID"
        case eMailID = "EMailID"
        case driverInAppID = "DriverInAppID"
    }
}

typealias OrderResponse = [OrderResponseElement]

typealias TripHistoryResponse = [TripHistory]

// MARK: - TripHistory
struct TripHistory: Codable {
    let status: String?
    let trips: [TripItem]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case trips = "Trips"
    }
}

// MARK: - TripItem
struct TripItem: Codable {
    let createdOn: String?
    let tripID: String?
    let rideType: String?
    let paymentAmount, rating: Double?
    let riderMobileNumber: String?
    let riderName: String?
    let vehicleType: String?
    let vehicleICON: String?
    let pickupAddress: String?
    let dropOffAddress: String?
    let currency: String?
    let number: String?
    let driverDetails: [DriverDetail]?
    let paymentMode: String?
    let blocked: String?
    let driverEmail: String?

    enum CodingKeys: String, CodingKey {
        case createdOn = "CreatedOn"
        case tripID = "TripID"
        case rideType = "RideType"
        case paymentAmount = "PaymentAmount"
        case rating = "Rating"
        case riderMobileNumber = "RiderMobileNumber"
        case riderName = "RiderName"
        case vehicleType = "VehicleType"
        case vehicleICON = "VehicleICON"
        case pickupAddress = "PickupAddress"
        case dropOffAddress = "DropOffAddress"
        case currency = "Currency"
        case number = "Number"
        case driverDetails = "DriverDetails"
        case paymentMode = "PaymentMode"
        case blocked = "DriverBlocked"
        case driverEmail = "DriverEmail"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.createdOn = try? container.decodeIfPresent(String.self, forKey: .createdOn)
        self.tripID = try? container.decodeIfPresent(String.self, forKey: .tripID)
        self.rideType = try? container.decodeIfPresent(String.self, forKey: .rideType)
        self.riderMobileNumber = try? container.decodeIfPresent(String.self, forKey: .riderMobileNumber)
        self.riderName = try? container.decodeIfPresent(String.self, forKey: .riderName)
        self.vehicleType = try? container.decodeIfPresent(String.self, forKey: .vehicleType)
        self.vehicleICON = try? container.decodeIfPresent(String.self, forKey: .vehicleICON)
        self.pickupAddress = try? container.decodeIfPresent(String.self, forKey: .pickupAddress)
        self.dropOffAddress = try? container.decodeIfPresent(String.self, forKey: .dropOffAddress)
        self.currency = try? container.decodeIfPresent(String.self, forKey: .currency)
        self.number = try? container.decodeIfPresent(String.self, forKey: .number)
        self.driverDetails = try? container.decodeIfPresent([DriverDetail].self, forKey: .driverDetails)
        self.paymentMode = try? container.decodeIfPresent(String.self, forKey: .paymentMode)
        self.blocked = try? container.decodeIfPresent(String.self, forKey: .blocked)
        self.driverEmail = try? container.decodeIfPresent(String.self, forKey: .driverEmail)
        
        if let paymentAmount = try? container.decodeIfPresent(Double.self, forKey: .paymentAmount) {
            self.paymentAmount = paymentAmount
        } else if let paymentAmount = try? container.decodeIfPresent(String.self, forKey: .paymentAmount) {
            self.paymentAmount = Double(paymentAmount)
        } else {
            self.paymentAmount = nil
        }
        
        if let rating = try? container.decodeIfPresent(Double.self, forKey: .rating) {
            self.rating = rating
        } else if let rating = try? container.decodeIfPresent(String.self, forKey: .rating) {
            self.rating = Double(rating)
        } else {
            self.rating = nil
        }
    }
}

// MARK: - DriverDetail
struct DriverDetail: Codable {
    let model: String?
    let profilePicture: String?
    let fullName: String?
    let isSuspended: Bool?
    let mobileNumber: String?
    let number: String?

    enum CodingKeys: String, CodingKey {
        case model = "Model"
        case profilePicture = "ProfilePicture"
        case fullName = "FullName"
        case isSuspended = "IsSuspended"
        case mobileNumber = "MobileNumber"
        case number = "Number"
    }
}

typealias CommonResponse = [CommonResponseData]

// MARK: - CommonResponseData
struct CommonResponseData: Codable {
    let status: String
    let message: String?

    enum CodingKeys: String, CodingKey {
        case message = "Message"
        case status = "Status"
    }
}

// MARK: - MovieTheatre
struct MovieTheatre: Codable {
    let movieProviderID, name: String?
    let logo: String?
    let restaurantID: String?
    let locationName: String?
    let latitude, longitude: Double?
    let rating: Double?
    let distance: Double?
    let rideCost: Double?
    let mobileNumber: String?
    let wallet: [Balance]?

    enum CodingKeys: String, CodingKey {
        case movieProviderID = "MovieProviderID"
        case name = "Name"
        case logo = "Logo"
        case restaurantID = "RestaurantID"
        case locationName = "LocationName"
        case latitude = "Latitude"
        case longitude = "Longitude"
        case rating = "Rating"
        case distance = "Distance"
        case rideCost = "RideCost"
        case mobileNumber = "MobileNumber"
        case wallet = "Wallet"
    }
}

typealias MovieTheatres = [MovieTheatre]

typealias AllMoviesRunning = [MovieRunning]

// MARK: - NewMovieTheatre
struct MovieRunning: Codable {
    var status: String?
    var wallet: [Balance]?
    var moviesRunning: [Movie]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case wallet = "Wallet"
        case moviesRunning = "MoviesRunning"
    }
}

// MARK: - MoviesRunning
struct MoviesRunning: Codable {
    var movieID, movieName, actors, director: String?
    var censorRating: String?
    var duration: Double?
    var movieImageSmall, movieImageBig, movieTrailer: String?
    var moviesRunningDescription: String?
    var showTimes: [ShowTime]?

    enum CodingKeys: String, CodingKey {
        case movieID = "MovieID"
        case movieName = "MovieName"
        case actors = "Actors"
        case director = "Director"
        case censorRating = "CensorRating"
        case duration = "Duration"
        case movieImageSmall = "MovieImageSmall"
        case movieImageBig = "MovieImageBig"
        case movieTrailer = "MovieTrailer"
        case moviesRunningDescription = "Description"
        case showTimes = "ShowTimes"
    }
}

// MARK: - Movie
struct Movie: Codable {
    let movieID, movieName, actors, director: String?
    let censorRating: String?
    let duration: Double?
    let movieImageSmall, movieImageBig: String?
    let movieTrailer: String?
    let movieDescription: String?
    var movieTimeings: [MovieTimeing]?
    let showTimes: [ShowTime]?
    let wallet: [Balance]?

    enum CodingKeys: String, CodingKey {
        case movieID = "MovieID"
        case movieName = "MovieName"
        case actors = "Actors"
        case director = "Director"
        case censorRating = "CensorRating"
        case duration = "Duration"
        case movieImageSmall = "MovieImageSmall"
        case movieImageBig = "MovieImageBig"
        case movieTrailer = "MovieTrailer"
        case movieDescription = "Description"
        case movieTimeings = "MovieTimeings"
        case showTimes = "ShowTimes"
        case wallet = "Wallet"
    }
}

// MARK: - ShowTime
struct ShowTime: Codable {
    let showTime: String?
    let showID: String?
    let movieProviderID: String?
    let screenDescription: String?
    let name: String?
    let ticketPrice: Double?
    let screenID: String?
    let screenName: String?
    let restaurantID: String?
    enum CodingKeys: String, CodingKey {
        case restaurantID = "RestaurantID"
        case showTime = "ShowTime"
        case showID = "ShowID"
        case movieProviderID = "MovieProviderID"
        case screenDescription = "ScreenDescription"
        case name = "Name"
        case ticketPrice = "TicketPrice"
        case screenID = "ScreenID"
        case screenName = "ScreenName"
    }
}

// MARK: - MovieTimeing
struct MovieTimeing: Codable {
    let showTime: String?
    let showID: String?
    let screenDescription: String?
    let screenID: String?
    let screenName: String?
    let ticketPrice: Double?
    enum CodingKeys: String, CodingKey {
        case showTime = "ShowTime"
        case showID = "ShowID"
        case screenID = "ScreenID"
        case screenDescription = "ScreenDescription"
        case screenName = "ScreenName"
        case ticketPrice = "TicketPrice"
    }
}

typealias Movies = [Movie]

// MARK: - PurpleMovieDate
struct PurpleMovieDate: Codable {
    let status: String?
    let message: String?
    let promoAmount, maxPromoAmount: Double?
    let promoCode, promoType: String?
    let movieDates: [MovieDateMovieDate]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case promoCode = "PromoCode"
        case promoAmount = "PromoAmount"
        case promoType = "PromoType"
        case maxPromoAmount = "MaxPromoAmount"
        case movieDates = "MovieDates"
    }
}

// MARK: - MovieDateMovieDate
struct MovieDateMovieDate: Codable {
    let showDates: String?
    let showDetails: [MovieTimeing]?

    enum CodingKeys: String, CodingKey {
        case showDates = "ShowDates"
        case showDetails = "ShowDetails"
    }
}

typealias MovieDates = [PurpleMovieDate]

//   let seatRows = try? newJSONDecoder().decode(SeatRows.self, from: jsonData)

// MARK: - ScreenLayout

struct ScreenLayout: Codable {
    let status: String?
    let maxManualSeats, markup: Int?
    let message: String?
    let seatLayout: [SeatRow]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case maxManualSeats = "MaxManualSeats"
        case message = "Message"
        case markup = "Markup"
        case seatLayout = "SeatLayout"
    }
}

// MARK: - SeatRow
struct SeatRow: Codable {
    let displayOrder, maxManualSeats: Int?
    let message, rowLayout, rowName: String?
    let seatPrice, ticketCode: String?
    var allocatedSeats: [AllocatedSeat]?

    enum CodingKeys: String, CodingKey {
        case displayOrder = "DisplayOrder"
        case maxManualSeats = "MaxManualSeats"
        case message = "Message"
        case rowLayout = "RowLayout"
        case rowName = "RowName"
        case seatPrice = "SeatPrice"
        case ticketCode = "TicketCode"
        case allocatedSeats = "AllocatedSeats"
    }
}

// MARK: - SelectedSeat
struct SelectedSeat: Codable {
    let seatNumber: String?
    let seatPrice: Int?
    let ticketCode: String?

    enum CodingKeys: String, CodingKey {
        case seatNumber = "SeatNumber"
        case seatPrice = "SeatPrice"
        case ticketCode = "TicketCode"
    }
}

// MARK: - AllocatedSeat
struct AllocatedSeat: Codable {
    var seatNumber: String?

    enum CodingKeys: String, CodingKey {
        case seatNumber = "SeatNumber"
    }
}

typealias SeatRows = [ScreenLayout]

// MARK: - QRCodeResponseElement
struct QRCodeResponseElement: Codable {
    let status, title, message: String?
    let coponAmount: Int?
    let walletToLoad: String?
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case title = "Title"
        case message = "Message"
        case coponAmount = "CoponAmount"
        case walletToLoad = "WalletToLoad"
        case imageURL = "ImageURL"
    }
}

typealias QRCodeResponse = [QRCodeResponseElement]

// MARK: - QRCodeLoadResponseElement
struct QRCodeLoadResponseElement: Codable {
    let status, message: String?
    let amount: Double?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case amount = "Amount"
    }
}

typealias QRCodeLoadResponse = [QRCodeLoadResponseElement]

// let movieTickets = try? newJSONDecoder().decode(MovieTickets.self, from: jsonData)

// MARK: - MovieTicket
struct MovieTicket: Codable {
    var uniqueID, showDate, currentDate: String?
    var movieProvider: [MovieProvider]?
    var movieName: String?
    var movieImageSmall: String?
    var totalSeats, mobileNumber: String?
    var amount: Double?
    var bookingID: String?
    var fullName: String?
    var seats: [Seat]?
    var wallet: [Wallet]?
    var restaurantMenu: [RestaurantMenu]?

    enum CodingKeys: String, CodingKey {
        case uniqueID = "MovieTransactionsID"
        case showDate = "ShowDate"
        case currentDate = "CurrentDate"
        case movieProvider = "MovieProvider"
        case movieName = "MovieName"
        case movieImageSmall = "MovieImageSmall"
        case totalSeats = "TotalSeats"
        case mobileNumber = "MobileNumber"
        case amount = "Amount"
        case bookingID = "BookingID"
        case fullName = "FullName"
        case seats = "Seats"
        case wallet = "Wallet"
        case restaurantMenu = "RestaurantMenu"
    }
}


// MARK: - CheckPPResponse
struct CheckPPResponse: Codable {
    let status, message: String?
    let wallets: [PPWallet]?
    let promoTypes: [PromoType]?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case message = "Message"
        case wallets = "Wallets"
        case promoTypes = "PromoTypes"
    }
}

// MARK: - PromoType
struct PromoType: Codable {
    let promoType, promoName: String?

    enum CodingKeys: String, CodingKey {
        case promoType = "PromoType"
        case promoName = "PromoName"
    }
}

// MARK: - Wallet
struct PPWallet: Codable {
    let walletID, walletName: String?
    let balance: Double?

    enum CodingKeys: String, CodingKey {
        case walletID = "WalletID"
        case walletName = "WalletName"
        case balance = "Balance"
    }
}

// MARK: - MovieProvider
struct MovieProvider: Codable {
    var name: String?
    var latitude, longitude: Double?

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case latitude = "Latitude"
        case longitude = "Longitude"
    }
}

// MARK: - RestaurantMenu
struct RestaurantMenu: Codable {
    var foodName: String?
    var foodImage: String?
    var quantity: Int?

    enum CodingKeys: String, CodingKey {
        case foodName = "FoodName"
        case foodImage = "FoodImage"
        case quantity = "Quantity"
    }
}

// MARK: - Seat
struct Seat: Codable {
    var seatNumber, movieTransactionsID: String?

    enum CodingKeys: String, CodingKey {
        case seatNumber = "SeatNumber"
        case movieTransactionsID = "MovieTransactionsID"
    }
}

typealias MovieTickets = [MovieTicket]

// MARK: - ResumeTripDetail
struct ResumeTripDetail: Codable {
    var status, tripID, driverName, driverMobile: String?
    var driverPIC: String?
    var driverLatitude, driverLongitude, carModel, carNumber: String?
    var carColor, driverRating, driverBearing, liveFare: String?
    var basePrice, distance, distanceTotalCost, time: String?
    var timeTotalCost, badgeText, badgeColor, badgeLink: String?

    enum CodingKeys: String, CodingKey {
        case status = "Status"
        case tripID = "TripID"
        case driverName = "DriverName"
        case driverMobile = "DriverMobile"
        case driverPIC = "DriverPIC"
        case driverLatitude = "DriverLatitude"
        case driverLongitude = "DriverLongitude"
        case carModel = "CarModel"
        case carNumber = "CarNumber"
        case carColor = "CarColor"
        case driverRating = "DriverRating"
        case driverBearing = "DriverBearing"
        case liveFare = "LiveFare"
        case basePrice = "BasePrice"
        case distance = "Distance"
        case distanceTotalCost = "DistanceTotalCost"
        case time = "Time"
        case timeTotalCost = "TimeTotalCost"
        case badgeText = "BadgeText"
        case badgeColor = "BadgeColor"
        case badgeLink = "BadgeLink"
    }
}

typealias ResumeTripDetails = [ResumeTripDetail]

struct PickerItem {
    var name: String
    var value: String
    var secondaryValue: String
    var displayName: String
    
    init(name: String, displayName: String, value: String, secondaryValue: String) {
        self.name = name
        self.value = value
        self.displayName = displayName
        self.secondaryValue = secondaryValue
    }
}

enum SDKClient {
    case EQUITY
    case VOOMA
}
