//
//  SearchLocationViewController.swift
//  Little
//
//  Created by Gabriel John on 13/01/2021.
//  Copyright © 2021 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import CoreLocation

private let reuseIdentifier = "locationCell"

public class SearchLocationViewController: UIViewController {

    // MARK: - Properties
    
    let am = SDKAllMethods()
    
    var sdkBundle: Bundle?
    
    var noLocationsView: UIView!
    var imgNoLocations: UIImageView!
    var imgPoweredBy: UIImageView!
    var lblNoLocations: UILabel!
    var tableView: UITableView!
    var coverView: UIView!
    
    var activityView: NVActivityIndicatorView!
    var tableViewHeight: NSLayoutConstraint!
    
    var locationTitleArr: [String] = []
    var locationSubTitleArr: [String] = []
    var locationCoordsArr: [String] = []
    
    var locationSearch = ""
    var isOSM = true
    var isFirstLoad = true
    var keyBoardHeight = CGFloat(0)
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive // && !isSearchBarEmpty
    }
    
    var locationPredictionsArr: [LocPredictionSDK] = []
    var littlePredictionsArr: [LittlePredictionSDK] = []
    
    var selectedLocation: LocationSetSDK?
    
    var currentLocation: CLLocation?
    
    var cancelAction: (() -> Void)?
    var proceedAction: (() -> Void)?
    
    // MARK: - Init
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle.module
        
        configureUI()
        
    }
    
    // MARK: - Handlers
    
    func configureUI() {
        guard let sdkBundle = sdkBundle else { return }
        
        configureSearch()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        view.backgroundColor = .white
        
        navigationItem.title = "Search Location"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: getImage(named: "icon_close", bundle: sdkBundle)!.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleDismiss))
        
        noLocationsView = UIView()
        view.addSubview(noLocationsView)
        
        noLocationsView.translatesAutoresizingMaskIntoConstraints = false
        noLocationsView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        noLocationsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        noLocationsView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        noLocationsView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        imgNoLocations = UIImageView()
        imgNoLocations.image = getImage(named: "no_record", bundle: sdkBundle)
        noLocationsView.addSubview(imgNoLocations)
        
        imgNoLocations.translatesAutoresizingMaskIntoConstraints = false
        imgNoLocations.centerXAnchor.constraint(equalTo: noLocationsView.centerXAnchor).isActive = true
        imgNoLocations.centerYAnchor.constraint(equalTo: noLocationsView.centerYAnchor).isActive = true

        lblNoLocations = UILabel()
        lblNoLocations.textColor = UIColor(named: "appLabel")
        lblNoLocations.font = UIFont(name: "Avenir-Medium", size: 14.0)
        lblNoLocations.text = "Kindly type a search query."
        noLocationsView.addSubview(lblNoLocations)
        
        lblNoLocations.translatesAutoresizingMaskIntoConstraints = false
        lblNoLocations.topAnchor.constraint(equalTo: imgNoLocations.bottomAnchor, constant: 8).isActive = true
        lblNoLocations.centerXAnchor.constraint(equalTo: noLocationsView.centerXAnchor).isActive = true
        
        configureTableView()
        
    }
    
    func whenSearchQueryEmpty() {
        
        noLocationsView.isHidden = true
        
        isOSM = true
        
        for i in (0..<locationTitleArr.count) {
            if i != 0 && i != 1 {
                let unique_id = NSUUID().uuidString
                littlePredictionsArr.append(LittlePredictionSDK(id: unique_id, predictionDescription: locationTitleArr[i], country: "", city: "", state: "", street: locationSubTitleArr[i], countrycode: "", latlng: locationCoordsArr[i]))
            }
        }
        
        printVal(object: littlePredictionsArr)
        
        tableView.reloadData()
        
        if littlePredictionsArr.count == 0 {
            lblNoLocations.text = "Kindly type a different search query."
            noLocationsView.isHidden = false
        }
        
        isOSM = am.getIsOSM()
    }
    
    func configureTableView() {
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationsCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 80
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        tableViewHeight = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeight.isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        
        view.bringSubviewToFront(noLocationsView)
        
        imgPoweredBy = UIImageView()
        imgPoweredBy.image = getImage(named: "poweredbygoogle", bundle: sdkBundle!)
        imgPoweredBy.contentMode = .scaleAspectFit
        view.addSubview(imgPoweredBy)
        
        imgPoweredBy.translatesAutoresizingMaskIntoConstraints = false
        imgPoweredBy.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 5).isActive = true
        imgPoweredBy.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        imgPoweredBy.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        locationTitleArr = am.getRecentPlacesNames()
        locationSubTitleArr = am.getRecentPlacesFormattedAddress()
        locationCoordsArr = am.getRecentPlacesCoords()
        
        whenSearchQueryEmpty()
        tableHeightSet()
    }
    
    func configureSearch() {
        searchController.searchBar.backgroundColor = navigationController?.navigationBar.backgroundColor
        searchController.searchBar.tintColor = .darkGray
        searchController.searchBar.barStyle = .default
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Location"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }
    
    func tableHeightSet() {
        
        var tableHeight = CGFloat(0)
        
        printVal(object: littlePredictionsArr.count)
        printVal(object: locationPredictionsArr.count)
        
        if isOSM {
            for i in (0..<littlePredictionsArr.count) {
                let frame = tableView.rectForRow(at: IndexPath(item: i, section: 0))
                tableHeight = tableHeight + (frame.size.height)
            }
        } else {
            for i in (0..<locationPredictionsArr.count) {
                let frame = tableView.rectForRow(at: IndexPath(item: i, section: 0))
                printVal(object: frame.size.height)
                tableHeight = tableHeight + (frame.size.height)
            }
        }
        
        tableHeight = (view.bounds.height - (70 + keyBoardHeight))
        
        tableViewHeight.constant = tableHeight
        
    }
    
    func locationTapped(index: Int) {
        if isOSM {
            let littleLocation = littlePredictionsArr[index]
            var placeDets = ""
            if littleLocation.street != nil && littleLocation.street != "" {
                placeDets = littleLocation.street!
            } else {
                placeDets = "\(littleLocation.city ?? ""), \(littleLocation.state ?? "")"
            }
            if littleLocation.latlng != nil {
                let lat = littleLocation.latlng?.components(separatedBy: ",")[safe: 0] ?? "0"
                let long = littleLocation.latlng?.components(separatedBy: ",")[safe: 1] ?? "0"
                let unique_id = NSUUID().uuidString
                selectedLocation = LocationSetSDK(id: unique_id, name: littleLocation.predictionDescription ?? "", subname: placeDets, latitude: lat, longitude: long, phonenumber: "", instructions: "")
                self.dismiss(animated: true) {
                    self.viewClosed()
                    self.proceedAction?()
                }
            } else {
                let id = littleLocation.id
                if id != nil {
                    getPlaceDetails(placename: littleLocation.predictionDescription ?? placeDets, placeID: "\(id!)")
                }
            }
        } else {
            let selectedLocation = locationPredictionsArr[index]
            let id = selectedLocation.placeID ?? ""
            getPlaceDetails(placename: selectedLocation.structuredFormatting?.mainText ?? "" ,placeID: "\(id)")
        }
        
    }
    
    func startLoadingResults() {
        if activityView == nil {
            activityView = NVActivityIndicatorView(frame: CGRect(origin: CGPoint(x: view.bounds.width - 35, y: 10),size: CGSize(width: 25, height: 25)), type: NVActivityIndicatorType.circleStrokeSpin, color: UIColor(hex: "#5F97F7"))
            view.addSubview(activityView)
            activityView.startAnimating()
        }
    }
    
    func stopLoadingResults() {
        if activityView != nil {
            activityView.stopAnimating()
            activityView.removeFromSuperview()
            activityView = nil
        }
    }
    
    func viewClosed() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func filterContentForSearchText() {
        if isOSM {
            callLittleServers()
        } else {
            callGoogleServers()
        }
    }
    
    @objc func handleDismiss() {
        self.dismiss(animated: true) {
            self.viewClosed()
            self.cancelAction?()
        }
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        keyBoardHeight = getKeyboardHeight(notification) - 30
        tableHeightSet()
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        keyBoardHeight = 0
        tableHeightSet()
        
    }
    
    // MARK: - Server Calls
    
    func callLittleServers() {
        
        let escapedString = locationSearch.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        guard let url = URL(string: "https://maps.little.bz/api/v2/places?q=\(escapedString ?? "")&location=\(am.getCurrentLocation() ?? "0.0,0.0")&city=&country=&key=\(am.DecryptDataKC(DataToSend: cn.littleMapKey))") else { return }
        
        printVal(object: "URL: \(url)")

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                let locationPredictions = try JSONDecoder().decode(LittlePredictionsSDK.self, from: data)
                DispatchQueue.main.async {
                    self.stopLoadingResults()
                    if locationPredictions.success ?? false {
                        if locationPredictions.predictions?.count ?? 0 > 0 {
                            self.littlePredictionsArr = locationPredictions.predictions ?? []
                            printVal(object: "Locations: \(locationPredictions)")
                            self.noLocationsView.isHidden = true
                        } else {
                            self.littlePredictionsArr.removeAll()
                            self.whenSearchQueryEmpty()
                        }
                    } else {
                        self.littlePredictionsArr.removeAll()
                        self.whenSearchQueryEmpty()
                    }
                    self.tableView.reloadData()
                    self.tableHeightSet()
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.stopLoadingResults()
                    self.littlePredictionsArr.removeAll()
                    self.whenSearchQueryEmpty()
                    self.tableHeightSet()
                }
            }
        }

        task.resume()
        
    }
    
    func callGoogleServers() {
        
        let escapedString = locationSearch.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let theReal = am.DecryptDataKC(DataToSend: cn.placesKey) as String
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(escapedString ?? "")&types=geocode&location=\(am.getCurrentLocation() ?? "0.0,0.0")&radius=500&key=\(theReal)") else { return }

        printVal(object: "URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                let locationPredictions = try JSONDecoder().decode(LocationPredictionsSDK.self, from: data)
                DispatchQueue.main.async {
                    self.stopLoadingResults()
                    switch locationPredictions.status {
                    case "OK":
                        self.locationPredictionsArr = locationPredictions.predictions ?? []
                        printVal(object: "Locations: \(locationPredictions)")
                        self.noLocationsView.isHidden = true
                    case "ZERO_RESULTS":
                        self.locationPredictionsArr.removeAll()
                        self.whenSearchQueryEmpty()
                    case "REQUEST_DENIED":
                        self.locationPredictionsArr.removeAll()
                        self.lblNoLocations.text = "Kindly contact Little if this error persists\n\(locationPredictions.error_message ?? "")"
                        self.noLocationsView.isHidden = false
                    default:
                        self.locationPredictionsArr.removeAll()
                        self.lblNoLocations.text = "\(locationPredictions.error_message ?? "Kindly type a different search query.")"
                        self.noLocationsView.isHidden = false
                    }
                    self.tableView.reloadData()
                    self.tableHeightSet()
                }
                
            } catch {
                DispatchQueue.main.async {
                    self.stopLoadingResults()
                    self.locationPredictionsArr.removeAll()
                    self.whenSearchQueryEmpty()
                    self.tableHeightSet()
                }
            }
        }

        task.resume()
    }
    
    func getPlaceDetails(placename: String, placeID: String) {
        
        self.view.createLoadingNormal()
        
        let theReal = am.DecryptDataKC(DataToSend: cn.placesKey) as String
        let placeIDString = placeID.replacingOccurrences(of: "string(\"", with: "").replacingOccurrences(of: "\")", with: "")
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/geocode/json?place_id=\(placeIDString)&key=\(theReal)") else { return }
        
        printVal(object: "URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            do {
                let placeDetails = try JSONDecoder().decode(LocPlaceDetailsSDK.self, from: data)
                DispatchQueue.main.async {
                    printVal(object: "Location: \(placeDetails)")
                    self.view.removeAnimation()
                    if placeDetails.status == "OK" {
                        let lat = placeDetails.results?[safe: 0]?.geometry?.location?.lat ?? 0.0
                        let long = placeDetails.results?[safe: 0]?.geometry?.location?.lng ?? 0.0
                        let unique_id = NSUUID().uuidString
                        self.selectedLocation = LocationSetSDK(id: unique_id, name: placename, subname: placeDetails.results?[safe: 0]?.addressComponents?[safe: 0]?.longName ?? "", latitude: "\(lat)", longitude: "\(long)", phonenumber: "", instructions: "")
                        
                        self.dismiss(animated: true) {
                            self.viewClosed()
                            self.proceedAction?()
                        }
                        
                    } else {
                        self.dismiss(animated: true) {
                            self.viewClosed()
                            self.cancelAction?()
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.view.removeAnimation()
                }
            }
        }
        task.resume()
    }
    
}

extension SearchLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isOSM {
            return littlePredictionsArr.count
        } else {
            return locationPredictionsArr.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationsCell
        
        cell.layoutIfNeeded()
        
        if isOSM {
            let littleLocation = littlePredictionsArr[indexPath.item]
            
            var placeDets = ""
            
            if littleLocation.street != nil && littleLocation.street != "" {
                placeDets = littleLocation.street!
            } else {
                placeDets = "\(littleLocation.city ?? ""), \(littleLocation.state ?? "")"
            }
            cell.locationNameLabel.text = littleLocation.predictionDescription ?? ""
            cell.locationSubLabel.text = placeDets
            
        } else {
            let location = locationPredictionsArr[indexPath.item]
            cell.locationNameLabel.text = location.structuredFormatting?.mainText ?? ""
            cell.locationSubLabel.text = location.structuredFormatting?.secondaryText ?? ""
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering {
            navigationItem.searchController?.dismiss(animated: true, completion: {
                self.locationTapped(index: indexPath.item)
            })
        } else {
            self.locationTapped(index: indexPath.item)
        }
    }
}

extension SearchLocationViewController: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if searchBar.text != "" && locationSearch != searchBar.text && (searchBar.text?.count ?? 0) > 2 {
            startLoadingResults()
            locationSearch = searchBar.text!
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(filterContentForSearchText), object: nil)
            self.perform(#selector(filterContentForSearchText), with: nil, afterDelay: 0.7)
        } else if !isFirstLoad {
            stopLoadingResults()
    
            if (searchBar.text?.count ?? 0) <= 2 && searchBar.text != "" {
                
                let arr = littlePredictionsArr.filter({ ($0.predictionDescription?.contains(searchBar.text ?? "")) == true })
                self.littlePredictionsArr = arr
                self.tableView.reloadData()
                self.tableHeightSet()
                
            } else if searchBar.text == "" {
                
                self.locationPredictionsArr.removeAll()
                self.littlePredictionsArr.removeAll()
                self.tableView.reloadData()
                self.whenSearchQueryEmpty()
                self.tableHeightSet()
                
            }
        } else {
            isFirstLoad = false
        }
        
    }
}
