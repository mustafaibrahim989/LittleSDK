//
//  SearchLocViewController.swift
//  Little Redo
//
//  Created by Gabriel John on 24/04/2018.
//  Copyright © 2018 Craft Silicon Ltd. All rights reserved.

import UIKit
import GoogleMaps
import GooglePlaces

class SearchLocViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    let am = SDKAllMethods()
    
    var sdkBundle: Bundle?
    
    var locationTitleArr: [String] = ["Add Home","Add Work"]
    var locationSubTitleArr: [String] = ["",""]
    var locationCoordsArr: [String] = ["",""]
    
    var buttonTag: Int = 0
    var buttpressed: String = ""
    var originAddress: String!
    var originLL: String = ""
    var destinationAddress: String!
    var destinationLL: String = "0.0,0.0"
    var pickupName: String = ""
    var dropOffName: String = " "
    
    var restaurantLoc: Bool = false
    
    var selectedLocation: LocationSetSDK?
    
    private var finishedLoadingInitialTableCells = false
    
    @IBOutlet weak var btnPickupLoc: UIButton!
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var locationTable: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle(for: Self.self)
        
        btnPickupLoc.titleLabel?.numberOfLines = 0
        btnPickupLoc.titleLabel?.textAlignment = .center
        
        if am.getRecentPlacesNames().count == 0 {
            am.saveRecentPlacesNames(data: locationTitleArr)
            am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
            am.saveRecentPlacesCoords(data: locationCoordsArr)
        }
        
        if am.getRecentPlacesFormattedAddress().count == 0 || am.getRecentPlacesCoords().count == 0 {
            am.saveRecentPlacesNames(data: locationTitleArr)
            am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
            am.saveRecentPlacesCoords(data: locationCoordsArr)
        }
        
        
        // print(am.getRecentPlacesFormattedAddress())
        
        locationTitleArr = am.getRecentPlacesNames()
        locationSubTitleArr = am.getRecentPlacesFormattedAddress()
        locationCoordsArr = am.getRecentPlacesCoords()
        
        finishedLoadingInitialTableCells = false
        locationTable.reloadData()
        
        if restaurantLoc {
            lblTitle.text = "Select order location"
            if am.getPICKUPADDRESS() != "" {
                btnPickupLoc.setTitle(am.getPICKUPADDRESS(), for: .normal)
                self.view.layoutIfNeeded()
            }
            buttpressed = "pickup"
        } else {
            if am.getFromPickupLoc() {
                lblTitle.text = "Select Pickup"
                if am.getPICKUPADDRESS() != "" {
                    btnPickupLoc.setTitle(am.getPICKUPADDRESS(), for: .normal)
                    self.view.layoutIfNeeded()
                }
                buttpressed = "pickup"
            } else {
                lblTitle.text = "Select Dropoff"
                buttpressed = "dropoff"
            }
        }
        
        if buttpressed == "pickup" {
            imgIcon.image = getImage(named: "dropoff_location", bundle: sdkBundle!)
        } else {
            imgIcon.image = getImage(named: "pickup_location", bundle: sdkBundle!)
        }
        
        if buttpressed == "addhome" || buttpressed == "addwork" {
            searchLocs()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if restaurantLoc {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if restaurantLoc {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func insertAndSaveLocData(_ data: LocationSetSDK?) {
            
        if !(locationCoordsArr.contains(where: { $0 == originLL })) {
            if locationTitleArr.count < 8 {
                locationTitleArr.insert(data?.name ?? "", at: 2)
                locationSubTitleArr.insert(data?.subname ?? "", at: 2)
                locationCoordsArr.insert(originLL, at: 2)
            } else {
                locationTitleArr.removeLast()
                locationTitleArr.insert(data?.name ?? "", at: 2)
                locationSubTitleArr.removeLast()
                locationSubTitleArr.insert(data?.subname ?? "", at: 2)
                locationCoordsArr.removeLast()
                locationCoordsArr.insert(originLL, at: 2)
            }
        } else {
            let index = locationCoordsArr.firstIndex(where: { $0 == originLL })
            if index != nil {
                locationTitleArr = rearrange(array: locationTitleArr, fromIndex: index!, toIndex: 2)
                locationSubTitleArr = rearrange(array: locationSubTitleArr, fromIndex: index!, toIndex: 2)
                locationCoordsArr = rearrange(array: locationCoordsArr, fromIndex: index!, toIndex: 2)
            }
        }
        
        am.saveRecentPlacesNames(data: locationTitleArr)
        am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
        am.saveRecentPlacesCoords(data: locationCoordsArr)
        
        locationTitleArr = am.getRecentPlacesNames()
        locationSubTitleArr = am.getRecentPlacesFormattedAddress()
        locationCoordsArr = am.getRecentPlacesCoords()
        
    }

    func searchLocs() {
        let vc = SearchLocationViewController()
        vc.proceedAction = { [self] in
            let data = vc.selectedLocation
            if data != nil {
                if (buttpressed == "pickup"){
                    
                    originLL = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                    pickupName = data?.name.cleanLocationNames() ?? "Unknown"
                    am.savePICKUPADDRESS(data: pickupName)
                    btnPickupLoc.setTitle(data?.name.cleanLocationNames(), for: UIControl.State.normal)
                    self.view.layoutIfNeeded()
                    
                    insertAndSaveLocData(data)
                    
                    finishedLoadingInitialTableCells = false
                    locationTable.reloadData()
                    
                    let index = locationTitleArr.firstIndex(of: data?.name ?? "")
                    am.saveSelectedLocIndex(data: index!)
                    
                    if restaurantLoc {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LOCATIONORDER"), object: nil)
                    } else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PICKUP"), object: nil)
                    }
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                    
                } else if (buttpressed == "dropoff"){
                    
                    btnPickupLoc.setTitle(data?.subname.cleanLocationNames(), for: .normal)
                    self.view.layoutIfNeeded()
                    destinationLL = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                    dropOffName = data?.subname.cleanLocationNames() ?? ""
                    am.saveDROPOFFADDRESS(data: dropOffName)
                    
                    insertAndSaveLocData(data)
                    
                    finishedLoadingInitialTableCells = false
                    locationTable.reloadData()
                    
                    let index = locationTitleArr.firstIndex(of: data?.name ?? "")
                    am.saveSelectedLocIndex(data: index!)
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DROPOFF"), object: nil)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DROPOFFMULTIPLE"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.popViewController(animated: true)
                    
                } else if (buttpressed == "addhome") {
                    
                    locationTitleArr[0] = (data?.name ?? "").cleanLocationNames()
                    locationSubTitleArr[0] = data?.subname.cleanLocationNames() ?? ""
                    locationCoordsArr[0] = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                    
                    am.saveRecentPlacesNames(data: locationTitleArr)
                    am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
                    am.saveRecentPlacesCoords(data: locationCoordsArr)
                    
                    locationTitleArr = am.getRecentPlacesNames()
                    locationSubTitleArr = am.getRecentPlacesFormattedAddress()
                    locationCoordsArr = am.getRecentPlacesCoords()
                    
                    finishedLoadingInitialTableCells = false
                    locationTable.reloadData()
                    
                    self.dismiss(animated: true, completion: nil)
                    
                } else if (buttpressed == "addwork") {
                    
                    locationTitleArr[1] = (data?.name ?? "").cleanLocationNames()
                    locationSubTitleArr[1] = data?.subname ?? ""
                    locationCoordsArr[1] = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                    
                    am.saveRecentPlacesNames(data: locationTitleArr)
                    am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
                    am.saveRecentPlacesCoords(data: locationCoordsArr)
                    
                    locationTitleArr = am.getRecentPlacesNames()
                    locationSubTitleArr = am.getRecentPlacesFormattedAddress()
                    locationCoordsArr = am.getRecentPlacesCoords()
                    
                    finishedLoadingInitialTableCells = false
                    locationTable.reloadData()
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return locationTitleArr.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! LocationTableViewCell
        
        var imageString: String = ""
        
        if indexPath.item == 0 {
            imageString = "home_force"
            if locationSubTitleArr[indexPath.item] != "" {
                cell.locationTitle.text = "Going Home" // "Add home for faster selection before ride"
                cell.locationSubTitle.text = locationSubTitleArr[indexPath.item]
            } else {
                cell.locationTitle.text = "Add Home"
                cell.locationSubTitle.text = "Add home for faster selection before ride"
            }
        } else if indexPath.item == 1 {
            imageString = "work_force"
            if locationSubTitleArr[indexPath.item] != "" {
                cell.locationTitle.text = "Going to Work"
                cell.locationSubTitle.text = locationSubTitleArr[indexPath.item]
            } else {
                cell.locationTitle.text = "Add Work"
                cell.locationSubTitle.text = "Add work for faster selection before ride"
            }
        } else {
            if buttpressed == "pickup" {
                imageString = "dropoff_location"
            } else {
                imageString = "pickup_location"
            }
            cell.locationTitle.text = locationTitleArr[indexPath.item]
            cell.locationSubTitle.text = locationSubTitleArr[indexPath.item]
        }
        
        cell.locationImage.image = getImage(named: imageString, bundle: sdkBundle!)
        cell.selectionStyle = .none
        
        return cell
        
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if locationTitleArr[indexPath.item] == "Add Home" {
            buttpressed = "addhome"
            searchLocs()
        } else if locationTitleArr[indexPath.item] == "Add Work" {
            buttpressed = "addwork"
            searchLocs()
        } else {
            
            let index = locationTitleArr.firstIndex(of: locationTitleArr[indexPath.item])
            am.saveSelectedLocIndex(data: index!)
            
            if self.am.getFromPickupLoc() {
                if restaurantLoc {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LOCATIONORDER"), object: nil)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PICKUP"), object: nil)
                }
            } else {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DROPOFF"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DROPOFFMULTIPLE"), object: nil)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if locationTitleArr.count > 0 && !finishedLoadingInitialTableCells {
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
            cell.transform = CGAffineTransform(translationX: 0, y: 25)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPickupPressed(_ sender: UIButton) {
        searchLocs()
    }
    
}

// MARK: New Little Call

extension SearchLocViewController {
    @objc func fromSearching(_ notification: Notification) {
        let data = notification.userInfo?["Location"] as? LocationSetSDK
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "LITTLESEARCH"), object: nil)
        if data != nil {
            if (buttpressed == "pickup"){
                
                originLL = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                pickupName = data?.name.cleanLocationNames() ?? "Unknown"
                am.savePICKUPADDRESS(data: pickupName)
                btnPickupLoc.setTitle(data?.name.cleanLocationNames(), for: UIControl.State.normal)
                self.view.layoutIfNeeded()

                if locationTitleArr.count < 8 {
                    locationTitleArr.insert(data?.name ?? "", at: 2)
                    locationSubTitleArr.insert(data?.subname ?? "", at: 2)
                    locationCoordsArr.insert(originLL, at: 2)
                } else {
                    locationTitleArr.removeLast()
                    locationTitleArr.insert(data?.name ?? "", at: 2)
                    locationSubTitleArr.removeLast()
                    locationSubTitleArr.insert(data?.subname ?? "", at: 2)
                    locationCoordsArr.removeLast()
                    locationCoordsArr.insert(originLL, at: 2)
                }
                
                am.saveRecentPlacesNames(data: locationTitleArr)
                am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
                am.saveRecentPlacesCoords(data: locationCoordsArr)
                
                locationTitleArr = am.getRecentPlacesNames()
                locationSubTitleArr = am.getRecentPlacesFormattedAddress()
                locationCoordsArr = am.getRecentPlacesCoords()
                
                finishedLoadingInitialTableCells = false
                locationTable.reloadData()
                
                let index = locationTitleArr.firstIndex(of: data?.name ?? "")
                am.saveSelectedLocIndex(data: index!)
                
                if restaurantLoc {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "LOCATIONORDER"), object: nil)
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PICKUP"), object: nil)
                }
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                
            } else if (buttpressed == "dropoff"){
                
                btnPickupLoc.setTitle(data?.subname.cleanLocationNames(), for: .normal)
                self.view.layoutIfNeeded()
                destinationLL = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                dropOffName = data?.subname.cleanLocationNames() ?? ""
                am.saveDROPOFFADDRESS(data: dropOffName)
                
                if locationTitleArr.count < 8 {  
                    locationTitleArr.insert(data?.name ?? "", at: 2)
                    locationSubTitleArr.insert(data?.subname ?? "", at: 2)
                    locationCoordsArr.insert(destinationLL, at: 2)
                } else {
                    locationTitleArr.removeLast()
                    locationTitleArr.insert(data?.name ?? "", at: 2)
                    locationSubTitleArr.removeLast()
                    locationSubTitleArr.insert(data?.subname ?? "", at: 2)
                    locationCoordsArr.removeLast()
                    locationCoordsArr.insert(destinationLL, at: 2)
                }
                
                am.saveRecentPlacesNames(data: locationTitleArr)
                am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
                am.saveRecentPlacesCoords(data: locationCoordsArr)
                
                locationTitleArr = am.getRecentPlacesNames()
                locationSubTitleArr = am.getRecentPlacesFormattedAddress()
                locationCoordsArr = am.getRecentPlacesCoords()
                
                finishedLoadingInitialTableCells = false
                locationTable.reloadData()
                
                let index = locationTitleArr.firstIndex(of: data?.name ?? "")
                am.saveSelectedLocIndex(data: index!)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DROPOFF"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DROPOFFMULTIPLE"), object: nil)
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popViewController(animated: true)
                
            } else if (buttpressed == "addhome") {
                
                locationTitleArr[0] = (data?.name ?? "").cleanLocationNames()
                locationSubTitleArr[0] = data?.subname.cleanLocationNames() ?? ""
                locationCoordsArr[0] = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                
                am.saveRecentPlacesNames(data: locationTitleArr)
                am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
                am.saveRecentPlacesCoords(data: locationCoordsArr)
                
                locationTitleArr = am.getRecentPlacesNames()
                locationSubTitleArr = am.getRecentPlacesFormattedAddress()
                locationCoordsArr = am.getRecentPlacesCoords()
                
                finishedLoadingInitialTableCells = false
                locationTable.reloadData()
                
                self.dismiss(animated: true, completion: nil)
                
            } else if (buttpressed == "addwork") {
                
                locationTitleArr[1] = (data?.name ?? "").cleanLocationNames()
                locationSubTitleArr[1] = data?.subname ?? ""
                locationCoordsArr[1] = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                
                am.saveRecentPlacesNames(data: locationTitleArr)
                am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
                am.saveRecentPlacesCoords(data: locationCoordsArr)
                
                locationTitleArr = am.getRecentPlacesNames()
                locationSubTitleArr = am.getRecentPlacesFormattedAddress()
                locationCoordsArr = am.getRecentPlacesCoords()
                
                finishedLoadingInitialTableCells = false
                locationTable.reloadData()
                
                self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
}
