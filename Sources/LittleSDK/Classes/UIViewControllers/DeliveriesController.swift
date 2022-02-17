//
//  DeliveriesController.swift
//  Little
//
//  Created by Gabriel John on 27/03/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftMessages
import SDWebImage
import UIView_Shimmer

extension UILabel: ShimmeringViewProtocol { }
extension UIImageView: ShimmeringViewProtocol { }
extension UITextView: ShimmeringViewProtocol { }
extension UIStepper: ShimmeringViewProtocol { }

public class DeliveriesController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    var sdkBundle: Bundle?
    
    var deliveryData: Data?
    
    var currentPlaceCoordinates: CLLocationCoordinate2D! 
    var fromSearch: Bool = false
    var selectedRestaurant: Restaurant?
    var paymentSourceArr: [Balance] = []
    var selectedCategory: Int?
    var category: String = ""
    var myRestaurantID: String = ""
    var myMenuID: String = ""
    var myPromoCode: String = ""
    var searchTerm = ""
    
    var paymentVC: UIViewController?
    
    var locationManager = CLLocationManager()
    
    private var finishedLoadingInitialTableCells = false
    
    var shopArr: [Restaurant] = [Restaurant(offerText: "", menuOnOffer: "", promoCode: "", restaurantID: "     ", restaurantName: "            ", typeOfRestaurant: "", locationName: "              ", foodCategory: "", averageTime: "", address: "            ", deliveryCharges: 150, distance: 1, latitude: 0.0, longitude: 0.0, image: "", rating: 0.0, deliveryModes: [], offline: false)]
    var sortedArr: [Restaurant] = [Restaurant(offerText: "", menuOnOffer: "", promoCode: "", restaurantID: "     ", restaurantName: "            ", typeOfRestaurant: "", locationName: "              ", foodCategory: "", averageTime: "", address: "            ", deliveryCharges: 150, distance: 1, latitude: 0.0, longitude: 0.0, image: "", rating: 0.0, deliveryModes: [], offline: false)]
    
    var offersArr: [Restaurant] = []
    var offersSortedArr: [Restaurant] = []
    var categoryArr: [String] = []
    
    @IBOutlet weak var shopTable: UITableView!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var btnSearch: UIBarButtonItem!
    @IBOutlet weak var btnCancelSearch: UIButton!
    @IBOutlet weak var lblSearchResults: UILabel!
    
    @IBOutlet weak var noShopsView: UIView!
    @IBOutlet weak var imgNoShops: UIImageView!
    @IBOutlet weak var lblNoShops: UILabel!
    
    @IBOutlet weak var loadOffersView: UIView!
    @IBOutlet weak var offersView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var offersCollection: UICollectionView!
    @IBOutlet weak var categoryCollection: UICollectionView!
    
    @IBOutlet weak var offersConstraint: NSLayoutConstraint!
    @IBOutlet weak var restaurantConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle(for: Self.self)

        let nib = UINib.init(nibName: "RestaurantCell", bundle: sdkBundle!)
        shopTable.register(nib, forCellReuseIdentifier: "cell")
        
        let nib1 = UINib.init(nibName: "OffersCell", bundle: sdkBundle!)
        offersCollection.register(nib1, forCellWithReuseIdentifier: "cell")
        
        let nib2 = UINib.init(nibName: "MenuCategoryCell", bundle: sdkBundle!)
        self.categoryCollection.register(nib2, forCellWithReuseIdentifier: "cell")
        
        adjustOffersView()
        
        shopTable.reloadData()
        shopTable.layoutIfNeeded()
        
        btnLocation.titleLabel?.numberOfLines = 0
        btnLocation.titleLabel?.textAlignment = .center
        
        if am.getPICKUPADDRESS() != "" {
            btnLocation.setTitle(am.getPICKUPADDRESS(), for: UIControl.State())
        }
        
        btnSearch.isEnabled = false
        
        currentPlaceCoordinates = CLLocationCoordinate2D(latitude: CLLocationDegrees(am.getCurrentLocation()?.components(separatedBy: ",")[0] ?? "0.0")! , longitude: CLLocationDegrees(am.getCurrentLocation()?.components(separatedBy: ",")[1] ?? "0.0")!)

        let backButton = UIBarButtonItem(image: getImage(named: "backios", bundle: sdkBundle!)!.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backHome))
        backButton.imageInsets = UIEdgeInsets(top: 1, left: -8, bottom: 1, right: 10)
        
        
        self.navigationItem.leftBarButtonItem = backButton
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        view.setTemplateWithSubviews(true, viewBackgroundColor: .white)
    }

    override func viewWillAppear(_ animated: Bool) {
        
        lblNoShops.text = "We unfortunately couldn't find a \(self.title?.lowercased() ?? "") provider within your area. We are however working hard to ensure all areas have \(self.title?.lowercased() ?? "") providers within your reach."
        imgNoShops.image = getImage(named: "no_\(category.replacingOccurrences(of: "ORDER", with: "").lowercased())", bundle: sdkBundle!)
        if imgNoShops.image == nil {
            imgNoShops.image = getImage(named: "no_products", bundle: sdkBundle!)
        }
        
        if fromSearch {
            fromSearch = false
            getRestaurants()
        } else {
            
            btnSearch.isEnabled = false
            checkLocation()
        }
        
        if am.getFromConfirmOrder() {
            am.saveFromConfirmOrder(data: false)
            if let viewController = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "OrderHistoryController") as? OrderHistoryController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        
        
    }
    
    @objc func backHome() {
        var isPopped = true
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller == popToRestorationID {
                printVal(object: "ToView")
                if self.navShown ?? false {
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                } else {
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                }
                self.navigationController!.popToViewController(controller, animated: true)
                break
            } else {
                isPopped = false
            }
        }
        
        if !isPopped {
            printVal(object: "ToRoot")
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func adjustOffersView() {
        
        self.view.layoutIfNeeded()
        
        let tableHeight = CGFloat(320 * sortedArr.count)
        if offersSortedArr.count > 0 {
            offersConstraint.constant = 280
            if offersView.isHidden {
                offersView.alpha = 0
                offersView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.offersView.alpha = 1
                }
            }
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            offersConstraint.constant = 0
            offersView.isHidden = true
        }
        var categoryConst: CGFloat = 0
        if categoryArr.count > 0 {
            categoryConst = 50
        }
        
        restaurantConstraint.constant = tableHeight + offersConstraint.constant + categoryConst
        if restaurantConstraint.constant == 0.0 {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top ?? 40.0
            let bottomPadding = window?.safeAreaInsets.bottom ?? 50.0
            
            restaurantConstraint.constant = view.frame.height - topPadding - bottomPadding - 105
        }
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Server Calls and Responses
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID()!)\",\"MobileNumber\":\"\(am.getSDKMobileNumber()!)\",\"IMEI\":\"\(am.getIMEI()!)\",\"CodeBase\":\"\(am.getMyCodeBase()!)\",\"PackageName\":\"\(am.getSDKPackageName()!)\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation()!)\",\"LatLong\":\"\(am.getCurrentLocation()!)\",\"TripID\":\"\",\"City\":\"\(am.getCity()!)\",\"RegisteredCountry\":\"\(am.getCountry()!)\",\"Country\":\"\(am.getCountry()!)\",\"UniqueID\":\"\(am.getMyUniqueID()!)\",\"CarrierName\":\"\(getCarrierName()!)\""
        
        return str
    }
    
    func getRestaurants() {
        
        view.setTemplateWithSubviews(true, viewBackgroundColor: .white)
        
        noShopsView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadRestaurants),name:NSNotification.Name(rawValue: "GETRESTAURANTSFoodDelivery"), object: nil)
        
        let dataToSend = "{\"FormID\":\"GETRESTAURANTS\"\(commonCallParams()),\"CATEGORY\":\"\(category)\",\"ModuleID\":\"\(category)\"}"
        
        hc.makeServerCall(sb: dataToSend, method: "GETRESTAURANTSFoodDelivery", switchnum: 0)
        
    }
    
    @objc func loadRestaurants(_ notification: NSNotification) {
        
        self.view.setTemplateWithSubviews(false)
        
        btnSearch.isEnabled = true
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETRESTAURANTSFoodDelivery"), object: nil)
        
        if data != nil {
            do {
                if deliveryData != data {
                    deliveryData = data!
                    categoryArr.removeAll()
                    shopArr.removeAll()
                    sortedArr.removeAll()
                    offersArr.removeAll()
                    offersSortedArr.removeAll()
                    let getRestaurants = try JSONDecoder().decode(GetRestaurants.self, from: data!)
                    
                    shopArr = getRestaurants[0].restaurants ?? []
                    sortedArr = getRestaurants[0].restaurants ?? []
                    offersArr = getRestaurants[0].offers ?? []
                    offersSortedArr = getRestaurants[0].offers ?? []
                    paymentSourceArr = getRestaurants[0].balance ?? []
                    finishedLoadingInitialTableCells = false
                    categoryArr.append("All")
                    selectedCategory = 0
                    for each in shopArr {
                        if each.foodCategory != nil && each.foodCategory != "" {
                            let arr = each.foodCategory?.components(separatedBy: "•") ?? []
                            for str in arr {
                                if !(categoryArr.contains(str)) {
                                    categoryArr.append(str)
                                }
                            }
                        }
                    }
                    
                    if categoryArr.count == 1 {
                        categoryArr.removeAll()
                    }
                    
                    printVal(object: paymentSourceArr)
                    
                    offersCollection.reloadData()
                    shopTable.reloadData()
                    categoryCollection.reloadData()
                    
                    adjustOffersView()
                    
                    if myRestaurantID != "" {
                        let index = sortedArr.firstIndex(where: { $0.restaurantID == myRestaurantID })
                        if index != nil {
                            printVal(object: sortedArr[index!])
                            selectedRestaurant = sortedArr[index!]
                            myRestaurantID = ""
                            
                            let popOverVC = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "NewPopoverController") as! NewPopoverController
                            self.addChild(popOverVC)
                            popOverVC.popLink = sortedArr[index!].image ?? ""
                            popOverVC.popTitle = "\(sortedArr[index!].restaurantName ?? "")"
                            popOverVC.popDesc = "\nTap proceed to redirect you to \(sortedArr[index!].restaurantName ?? "") to receive the desired offer.\n"
                            popOverVC.choice = "OFFERPROCEED"
                            popOverVC.view.frame = UIScreen.main.bounds
                            self.view.addSubview(popOverVC.view)
                            popOverVC.didMove(toParent: self)
                            
                            let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
                            view.loadPopup(title: "\(sortedArr[index!].restaurantName ?? "")", message: "\nTap proceed to redirect you to \(sortedArr[index!].restaurantName ?? "") to receive the desired offer.\n", image: sortedArr[index!].image ?? "", action: "")
                            view.proceedAction = {
                                SwiftMessages.hide()
                                if let viewController = UIStoryboard(name: "Deliveries", bundle: self.sdkBundle!).instantiateViewController(withIdentifier: "ProductController") as? ProductController {
                                    viewController.selectedRestaurant = self.selectedRestaurant
                                    viewController.paymentSourceArr = self.paymentSourceArr
                                    viewController.myMenuID = self.myMenuID
                                    viewController.myPromoCode = self.myPromoCode
                                    viewController.category = self.category
                                    viewController.paymentVC = self.paymentVC
                                    if let navigator = self.navigationController {
                                        navigator.pushViewController(viewController, animated: true)
                                    }
                                }
                            }
                            view.cancelAction = {
                                SwiftMessages.hide()
                            }
                            view.configureDropShadow()
                            var config = SwiftMessages.defaultConfig
                            config.duration = .forever
                            config.presentationStyle = .bottom
                            config.dimMode = .gray(interactive: false)
                            SwiftMessages.show(config: config, view: view)
                            
                        }
                    }
                }
                
            } catch {
                shopArr = []
                sortedArr = []
                offersCollection.reloadData()
                shopTable.reloadData()
                adjustOffersView()
            }
        }
        if sortedArr.count > 0 {
            noShopsView.isHidden = true
        } else {
            noShopsView.alpha = 0
            noShopsView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.noShopsView.alpha = 1
            }
        }
        
    }
    
    func getLocationName(currentCoordinate: CLLocationCoordinate2D) {
        var proceedToCallGoogle: Bool = true
        
        for i in (0..<am.getRecentPlacesCoords().count) {
            if am.getRecentPlacesCoords()[i] != "" {
                
                let origin = CLLocation(latitude: CLLocationDegrees(Double(am.getRecentPlacesCoords()[i].components(separatedBy: ",")[0]) ?? 0.0), longitude: CLLocationDegrees(Double(am.getRecentPlacesCoords()[i].components(separatedBy: ",")[1]) ?? 0.0))
                
                var distanceInMeters: CLLocationDistance = 0.0
                
                distanceInMeters = origin.distance(from: CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude))
                
                if distanceInMeters <= 50 {
                    
                    proceedToCallGoogle = false
                    
                    printVal(object: "Location Local")
                    
                    DispatchQueue.main.async {
                        self.am.savePICKUPADDRESS(data: self.am.getRecentPlacesNames()[i].cleanLocationNames())
                        self.btnLocation.setTitle(self.am.getRecentPlacesNames()[i].cleanLocationNames().cleanLocationNames(), for: UIControl.State())
                    }
                    
                    getRestaurants()
                    
                    break
                }
                
            }
        }
        
        if proceedToCallGoogle {
            getLocationNameFromKB(currentCoordinate: currentCoordinate)
        }
    }
    
    func getLocationNameFromKB(currentCoordinate: CLLocationCoordinate2D) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadLocationName),name:NSNotification.Name(rawValue: "GETLOCATIONNAMESHOPJSONData"), object: nil)
        
        let dataToSend = "{\"FormID\":\"GETLOCATIONNAME\"\(commonCallParams()),\"LocationName\":{\"Latitude\":\"\(currentCoordinate.latitude)\",\"Longitude\":\"\(currentCoordinate.longitude)\",\"LocationNameAtLL\":\"\",\"FormID\":\"MAIN\"}}"
        
        hc.makeServerCall(sb: dataToSend, method: "GETLOCATIONNAMESHOPJSONData", switchnum: 0)
        
    }
    
    @objc func loadLocationName(_ notification: NSNotification) {
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "GETLOCATIONNAMESHOPJSONData"), object: nil)
        
        let data = notification.userInfo?["data"] as? Data
        
        if data != nil {
            do {
                let defaultMessage = try JSONDecoder().decode(DefaultMessage.self, from: data!)
                
                if defaultMessage.status == "000" {
                    DispatchQueue.main.async {
                        self.am.savePICKUPADDRESS(data: defaultMessage.message?.cleanLocationNames() ?? "")
                        self.btnLocation.setTitle(defaultMessage.message?.cleanLocationNames(), for: UIControl.State())
                    }
                    
                    printVal(object: "Location KB")
                    getRestaurants()
                    
                } else {
                    self.getRestaurants()
                    self.removeLoadingPage()
                }
                
            } catch {
                self.getRestaurants()
                self.removeLoadingPage()
            }
        }
        
    }
    
    // MARK: - Functions & IBActions
    
    @objc func fromOrderLocation() {
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "LOCATIONORDER"), object: nil)

        let index = am.getSelectedLocIndex()!
        var latitude: Double
        var longitude: Double
        latitude = Double(am.getRecentPlacesCoords()[index].components(separatedBy: ",")[0])!
        longitude = Double(am.getRecentPlacesCoords()[index].components(separatedBy: ",")[1])!
        
        am.saveCurrentLocation(data: "\(latitude),\(longitude)")
        let pickupName = am.getRecentPlacesNames()[index].cleanLocationNames()
        am.savePICKUPADDRESS(data: pickupName)
        btnLocation.setTitle(pickupName, for: UIControl.State())
        
        getRestaurants()
    }
    
    @objc func loadFromSearch(_ notification: Notification) {
        let data = notification.userInfo?["data"] as? String
        if data != nil {
            if data != "" {
                
                searchTerm = data!
                searchFromReataurants()
                
            } else {
                closeSearch()
            }
        } else {
            closeSearch()
        }
    }
    
    func searchFromReataurants() {
        
        var arr: [Restaurant] = []
        var arr1: [Restaurant] = []
        for each in shopArr {
            if each.restaurantName?.lowercased().contains(searchTerm.lowercased()) ?? false  {
                arr.append(each)
            }
        }
        for each in offersArr {
            if each.restaurantName?.lowercased().contains(searchTerm.lowercased()) ?? false  {
                arr1.append(each)
            }
        }
        sortedArr = arr
        offersSortedArr = arr1
        
        shopTable.reloadData()
        offersCollection.reloadData()
        
        btnCancelSearch.isHidden = false
        lblSearchResults.text = "Search results for \"\(searchTerm)\""
        
        adjustOffersView()
    }
    
    func closeSearch() {
        lblSearchResults.text = ""
        btnCancelSearch.isHidden = true
        if selectedCategory != 0 {
            filterByCategory(indexPath: IndexPath(row: selectedCategory!, section: 0))
        } else {
            sortedArr = shopArr
            offersSortedArr = offersArr
            shopTable.reloadData()
            offersCollection.reloadData()
            adjustOffersView()
        }
    }
    
    func filterByCategory(indexPath: IndexPath) {
        sortedArr.removeAll()
        offersSortedArr.removeAll()
        selectedCategory = indexPath.item
        for each in shopArr {
            if categoryArr[indexPath.item] == "All" {
                sortedArr.append(each)
            } else if (each.foodCategory?.contains("\(categoryArr[indexPath.item])") ?? false) {
                sortedArr.append(each)
            }
        }
        for each in offersArr {
            if categoryArr[indexPath.item] == "All" {
                offersSortedArr.append(each)
            } else if (each.foodCategory?.contains("\(categoryArr[indexPath.item])") ?? false) {
                offersSortedArr.append(each)
            }
        }
        finishedLoadingInitialTableCells = false
        categoryCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        if lblSearchResults.text != "" {
            searchFromReataurants()
        } else {
            shopTable.reloadData()
            offersCollection.reloadData()
            adjustOffersView()
        }
        categoryCollection.reloadData()
    }
    
    @IBAction func btnSearchPressed(_ sender: UIBarButtonItem) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadFromSearch),name:NSNotification.Name(rawValue: "FROMSEARCH"), object: nil)
        
        closeSearch()
        
        let popOverVC = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "SearchController") as! SearchController
        self.addChild(popOverVC)
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
    @IBAction func btnCloseSearch(_ sender: UIButton) {
        closeSearch()
    }
    
    @IBAction func btnLocationPressed(_ sender: UIButton) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(fromOrderLocation),name:NSNotification.Name(rawValue: "LOCATIONORDER"), object: nil)
        
        am.saveFromPickupLoc(data: true)
        fromSearch = true
        if let viewController = UIStoryboard(name: "Trip", bundle: sdkBundle!).instantiateViewController(withIdentifier: "SearchLocViewController") as? SearchLocViewController {
            viewController.restaurantLoc = true
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func btnHistoryPressed(_ sender: UIButton) {
        if let viewController = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "OrderHistoryController") as? OrderHistoryController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    // MARK: - Check Location
    
    @objc func checkLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            if SDKReachability.isConnectedToNetwork() {
                switch(CLLocationManager.authorizationStatus()) {
                    
                case .restricted, .denied:
                    
                    // printVal(object: "No access: Restricted/Denied")
                    
                    removeLoadingPage()
                    allowLocationAccessMessage()
                    
                case .notDetermined:
                    
                    // printVal(object: "No access: Not Determined")
                    
                    removeLoadingPage()
                    locationManager.delegate = self
                    locationManager.requestWhenInUseAuthorization()
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    
                    // printVal(object: "Access")
                    
                    locationManager.delegate = self
                    locationManager.distanceFilter = 100.0
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.startUpdatingLocation()
                    
                    // printVal(object: "Getting location")
                @unknown default:
                    removeLoadingPage()
                    allowLocationAccessMessage()
                }
            } else {
                // showOfflineMessage()
            }
        } else {
            removeLoadingPage()
            allowLocationAccessMessage()
        }
        
    }
    
    func allowLocationAccessMessage() {
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
         view.loadPopup(title: "", message: "\nLocation Services Disabled. Please enable location services in settings to help identify your current location. This will be used by emergency responders if the SOS button is pressed.\n", image: "", action: "")
         view.proceedAction = {
            SwiftMessages.hide()
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                 return
             }
             if UIApplication.shared.canOpenURL(settingsUrl) {
                 UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                     printVal(object: "Settings opened: \(success)") // Prints true
                 })
             }
         }
         view.cancelAction = {
             SwiftMessages.hide()
         }
         view.btnProceed.setTitle("Allow location access", for: .normal)
         view.configureDropShadow()
         var config = SwiftMessages.defaultConfig
         config.duration = .forever
        config.presentationStyle = .bottom
         config.dimMode = .gray(interactive: false)
         SwiftMessages.show(config: config, view: view)
        
    }
    
    // MARK: - TableView Delegates and Datasources

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 320
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let product = sortedArr[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RestaurantCell
        cell.imgShopImage.layoutIfNeeded()
        cell.lblShopName.text = product.restaurantName ?? ""
        cell.lblShopLocation.text = product.address ?? ""
        cell.lblShopDistance.text = "\(product.distance ?? 0.0) kms away"
        cell.lblShopDelivery.text = "Delivery \(formatCurrency(String(product.deliveryCharges ?? 0)))"
        cell.lblRating.text = "\(product.rating ?? 5)"
        
         if (product.foodCategory ?? "") != "" {
            cell.lblCategory.text = "   \(product.foodCategory ?? "")   "
            cell.lblCategory.alpha = 0
            cell.lblCategory.isHidden = false
            UIView.animate(withDuration: 0.3) {
                cell.lblCategory.alpha = 1
            }
        } else {
            cell.lblCategory.isHidden = true
        }

        if (product.averageTime ?? "") != "" {
            cell.lblAverageTime.text = "   \(product.averageTime ?? "")   "
            cell.lblAverageTime.alpha = 0
            cell.lblAverageTime.isHidden = false
            UIView.animate(withDuration: 0.3) {
                cell.lblAverageTime.alpha = 1
            }
        } else {
            cell.lblAverageTime.isHidden = true
        }
        
        if (product.offerText ?? "") != "" {
            cell.lblOfferText.text = "   \(product.offerText ?? "")   "
            cell.lblOfferText.alpha = 0
            cell.lblOfferText.isHidden = false
            UIView.animate(withDuration: 0.3) {
                cell.lblOfferText.alpha = 1
            }
        } else {
            cell.lblOfferText.isHidden = true
        }
        
        if product.offline ?? false {
            cell.closedView.isHidden = false
            cell.lblClosed.isHidden = false
            
            SDWebImageManager.shared.imageCache.removeImage(forKey: product.image ?? "", cacheType: .all)
            cell.imgShopImage.sd_setImage(with: URL(string: product.image ?? ""), placeholderImage: getImage(named: "default_restaurant", bundle: sdkBundle!)) { _,_,_,_  in
                
            }
            cell.layoutIfNeeded()
        } else {
            cell.closedView.isHidden = true
            cell.lblClosed.isHidden = true
            SDWebImageManager.shared.imageCache.removeImage(forKey: product.image ?? "", cacheType: .all)
            cell.imgShopImage.sd_setImage(with: URL(string: product.image ?? ""), placeholderImage: getImage(named: "default_restaurant", bundle: sdkBundle!)) { _,_,_,_  in
                
            }
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        printVal(object: sortedArr[indexPath.item])
        selectedRestaurant = sortedArr[indexPath.item]
        if let viewController = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "ProductController") as? ProductController {
            viewController.selectedRestaurant = selectedRestaurant
            viewController.paymentSourceArr = paymentSourceArr
            viewController.paymentVC = paymentVC
            viewController.category = category
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if sortedArr.count > 0 && !finishedLoadingInitialTableCells {
            if let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows,
                let lastIndexPath = indexPathsForVisibleRows.last, lastIndexPath.row == indexPath.row {
                lastInitialDisplayableCell = true
            }
        }
        
        if !finishedLoadingInitialTableCells {
            
            if lastInitialDisplayableCell {
                finishedLoadingInitialTableCells = true
            }
            
            //animates the cell as it is being displayed for the first time
            cell.transform = CGAffineTransform(translationX: 0, y: 22)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
    
    // MARK: - CollectionView Delegates and Datasources
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0 {
            return CGSize(width: 300, height: 240)
        } else {
            let font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15.0)!
            
            let varia = CGFloat(50.0)
            
            let size = CGSize(width: ((categoryArr[indexPath.item].width(withConstrainedHeight: 30.0, font: font)) ) + varia, height: 40.0)
            
            return size
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return offersSortedArr.count
        } else {
            return categoryArr.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if collectionView.tag == 0 {
            let product = offersSortedArr[indexPath.item]
                    
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! OffersCell
            
            cell.imgShopImage.layoutIfNeeded()
            cell.lblShopName.text = product.restaurantName ?? ""
            cell.lblShopLocation.text = product.address ?? ""
            cell.lblShopDistance.text = "\(product.distance ?? 0.0) kms away"
            cell.lblShopDelivery.text = "Delivery \(formatCurrency(String(product.deliveryCharges ?? 0)))"
            cell.lblRating.text = "\(product.rating ?? 5)"
            
            cell.lblCategory.isHidden = true
            
            if (product.averageTime ?? "") != "" {
                cell.lblAverageTime.text = "   \(product.averageTime ?? "")   "
                cell.lblAverageTime.alpha = 0
                cell.lblAverageTime.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    cell.lblAverageTime.alpha = 1
                }
            } else {
                cell.lblAverageTime.isHidden = true
            }
            
            if (product.offerText ?? "") != "" {
                cell.lblOfferText.text = "   \(product.offerText ?? "")   "
                cell.lblOfferText.alpha = 0
                cell.lblOfferText.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    cell.lblOfferText.alpha = 1
                }
            } else {
                cell.lblOfferText.isHidden = true
            }
            
            if product.offline ?? false {
                cell.closedView.isHidden = false
                cell.lblClosed.isHidden = false
                // cell.isUserInteractionEnabled = false
                SDWebImageManager.shared.imageCache.removeImage(forKey: product.image ?? "", cacheType: .all)

                cell.imgShopImage.sd_setImage(with: URL(string: product.image ?? ""), placeholderImage: getImage(named: "default_restaurant", bundle: sdkBundle!)) { _,_,_,_  in
                    
                }
                cell.layoutIfNeeded()
            } else {
                cell.closedView.isHidden = true
                cell.lblClosed.isHidden = true
                // cell.isUserInteractionEnabled = true
                SDWebImageManager.shared.imageCache.removeImage(forKey: product.image ?? "", cacheType: .all)
                cell.imgShopImage.sd_setImage(with: URL(string: product.image ?? ""), placeholderImage: getImage(named: "default_restaurant", bundle: sdkBundle!))
            }
            
            cell.imgShopImage.alpha = 1
            
            cell.backGround.layer.cornerRadius = 10
            cell.foreGround.layer.cornerRadius = 10
            cell.layoutIfNeeded()
            
            cell.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! MenuCategoryCell
                if selectedCategory != nil {
                    if selectedCategory == indexPath.item {
                        cell.categoryView.backgroundColor = cn.littleSDKThemeColor
                        cell.lblCategory.textColor = .white
                    } else {
                        cell.categoryView.backgroundColor = cn.littleSDKCellBackgroundColor
                        cell.lblCategory.textColor = cn.littleSDKLabelColor
                    }
                } else {
                    cell.categoryView.backgroundColor = cn.littleSDKCellBackgroundColor
                    cell.lblCategory.textColor = cn.littleSDKLabelColor
                }
                cell.lblCategory.text = categoryArr[indexPath.item]
            
                cell.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                    cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: nil)
                
                return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0 {
            printVal(object: offersSortedArr[indexPath.item])
            selectedRestaurant = offersSortedArr[indexPath.item]
            if let viewController = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "ProductController") as? ProductController {
                viewController.selectedRestaurant = selectedRestaurant
                viewController.paymentSourceArr = paymentSourceArr
                viewController.myMenuID = selectedRestaurant?.menuOnOffer ?? ""
                viewController.myPromoCode = selectedRestaurant?.promoCode ?? ""
                viewController.paymentVC = paymentVC
                viewController.category = category
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        } else {
            lblSearchResults.text = ""
            btnCancelSearch.isHidden = true
            
            filterByCategory(indexPath: indexPath)
        }
    }
}

extension DeliveriesController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        if manager.location != nil {
            
            let location = locations.last!
            am.saveInitialLocation(data: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
            am.saveCurrentLocation(data: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
            getLocationName(currentCoordinate: location.coordinate)
            
        } else {
            checkLocation()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        removeLoadingPage()
        // printVal(object: error.localizedDescription)
        // printVal(object: "Location Error")
        checkLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocation()
    }
    
}
