# LittleSDK

This is an SDK that allows you to natively include some of the most popular Little App items right within your iOS App with minimal fuss.

For any assistance reach out at [littledevs](mailto:littledevelopers2021@gmail.com)

LittleSDK Author & Maintainer: [@littleappdevs](https://github.com/littleappdevs)

## Installation

### Swift Package Manager

1. Click File &rarr; Swift Packages &rarr; Add Package Dependency
2. Type `https://github.com/littleappdevs/littleapp.git`

Alternatively, in Xcode and search for "LittleSDK". If multiple results are found, select the one owned by [@littleappdevs](https://github.com/littleappdevs).

## Usage

- Initialize SDK

let littleFramework = LittleFramework()

var accounts = [[String: String]]()

accounts.append([
    "AccountID": "123456",
    "AccountName": "Primary Account"
])

littleFramework.initializeSDKParameters(accounts: accountsArr, mobileNumber: "254700123123", packageName: "africa.little", isUAT: true)

littleFramework.initializeSDKMapKeys(googleMapsKey: Constants.MAPS_KEY, googlePlacesKey: Constants.PLACES_KEY)

- Navigate to ride request

littleFramework.initializeToRides(UIViewController)


## Acknowledgements

Built at **[Little Limited](https://little.africa)**

Special thanks to: 

- [@GarbuJohnG](https://github.com/GarbuJohnG) for his valuable help on the SDK
