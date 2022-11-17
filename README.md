# LittleSDK

This is an SDK that allows you to natively include some of the most popular Little App items right within your iOS App with minimal fuss.

For any assistance reach out at [littledevs](mailto:littledevelopers2021@gmail.com)

LittleSDK Author & Maintainer: [@littleappdevs](https://github.com/littleappdevs)

## Installation

### Swift Package Manager

1. Click File &rarr; Swift Packages &rarr; Add Package Dependency
2. Type `https://github.com/boazjameslittle/LittleSDK`

## Usage

### Initialize SDK

let littleFramework = LittleFramework()

let accounts = \[\[
    "AccountID": "123456",
    "AccountName": "Account Name"
\]\] \/\/ Array of Dictionary\<String, String\>

\/\/ Additional data to be passed on callbacks

let addionalData = "String"

littleFramework.initializeSDKParameters(accounts: accounts, additionalData: addionalData, mobileNumber: "254700408386", packageName: "com.craftsilicon.littlesdk", APIKey: "", isUAT: true)

\/\/ Initialize SDK
littleFramework.initializeSDKParameters(accounts: accountsArr, mobileNumber: "254700123123", packageName: "Bundle Identifier", isUAT: true)

\/\/ Map Keys
littleFramework.initializeSDKMapKeys(googleMapsKey: Constants.MAPS_KEY, googlePlacesKey: Constants.PLACES_KEY)

### Navigate to ride request

littleFramework.initializeToRides(UIViewController)

### Navigate to ride history

littleFramework.initializeToRideHistory(UIViewController)

### Navigate to delivery
littleFramework.initializeToDeliveries(self, deliveryType: .food)  \/\/ Delivery Types - food, supermarket, groceries, drinks, medicine or cakes


## Acknowledgements

Built at **[Little Limited](https://little.africa)**
