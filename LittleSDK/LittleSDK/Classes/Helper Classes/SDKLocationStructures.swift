//
//  LocationStructures.swift
//  LittleSDK
//
//  Created by Gabriel John on 12/05/2021.
//

import Foundation

// MARK: - LocationPredictions
struct LocationPredictionsSDK: Codable {
    var predictions: [LocPredictionSDK]?
    var status: String? // ZERO_RESULTS, REQUEST_DENIED, OK
    var error_message: String?
}

// MARK: - Prediction
struct LocPredictionSDK: Codable {
    var predictionDescription: String?
    var matchedSubstrings: [LocMatchedSubstringSDK]?
    var placeID, reference: String?
    var structuredFormatting: LocStructuredFormattingSDK?
    var terms: [LocTermSDK]?
    var types: [String]?

    enum CodingKeys: String, CodingKey {
        case predictionDescription = "description"
        case matchedSubstrings = "matched_substrings"
        case placeID = "place_id"
        case reference
        case structuredFormatting = "structured_formatting"
        case terms, types
    }
}

// MARK: - MatchedSubstring
struct LocMatchedSubstringSDK: Codable {
    var length, offset: Int?
}

// MARK: - StructuredFormatting
struct LocStructuredFormattingSDK: Codable {
    var mainText: String?
    var mainTextMatchedSubstrings: [LocMatchedSubstringSDK]?
    var secondaryText: String?

    enum CodingKeys: String, CodingKey {
        case mainText = "main_text"
        case mainTextMatchedSubstrings = "main_text_matched_substrings"
        case secondaryText = "secondary_text"
    }
}

// MARK: - Term
struct LocTermSDK: Codable {
    var offset: Int?
    var value: String?
}

//   let locationPredictions = try? newJSONDecoder().decode(LocationPredictions.self, from: jsonData)

// MARK: - LittlePredictions
struct LittlePredictionsSDK: Codable {
    var success: Bool?
    var predictions: [LittlePredictionSDK]?
}

// MARK: - Prediction
struct LittlePredictionSDK: Codable {
    var id: String?
    var predictionDescription, country, city, state: String?
    var street, countrycode, latlng: String?

    enum CodingKeys: String, CodingKey {
        case id
        case predictionDescription = "description"
        case country, city, state, street, countrycode, latlng
    }
}

// MARK: - PlaceDetails
struct LocPlaceDetailsSDK: Codable {
    var results: [LocResultSDK]?
    var status: String?
}

// MARK: - Result
struct LocResultSDK: Codable {
    var addressComponents: [LocAddressComponentSDK]?
    var formattedAddress: String?
    var geometry: LocGeometrySDK?
    var placeID: String?
    var plusCode: LocPlusCodeSDK?
    var types: [String]?

    enum CodingKeys: String, CodingKey {
        case addressComponents = "address_components"
        case formattedAddress = "formatted_address"
        case geometry
        case placeID = "place_id"
        case plusCode = "plus_code"
        case types
    }
}

// MARK: - AddressComponent
struct LocAddressComponentSDK: Codable {
    var longName, shortName: String?
    var types: [String]?

    enum CodingKeys: String, CodingKey {
        case longName = "long_name"
        case shortName = "short_name"
        case types
    }
}

// MARK: - Geometry
struct LocGeometrySDK: Codable {
    var location: LocLocationSDK?
    var locationType: String?
    var viewport: LocViewportSDK?

    enum CodingKeys: String, CodingKey {
        case location
        case locationType = "location_type"
        case viewport
    }
}

// MARK: - Location
struct LocLocationSDK: Codable {
    var lat, lng: Double?
}

// MARK: - Viewport
struct LocViewportSDK: Codable {
    var northeast, southwest: LocLocationSDK?
}

// MARK: - PlusCode
struct LocPlusCodeSDK: Codable {
    var compoundCode, globalCode: String?

    enum CodingKeys: String, CodingKey {
        case compoundCode = "compound_code"
        case globalCode = "global_code"
    }
}
