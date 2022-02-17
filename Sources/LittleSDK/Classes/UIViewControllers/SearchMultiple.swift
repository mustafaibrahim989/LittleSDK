//
//  SearchMultiple.swift
//  Little
//
//  Created by Gabriel John on 03/09/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SwiftMessages

public class SearchMultiple: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    let am = SDKAllMethods()
    
//    var sdkBundle: Bundle?
    
    var locationsEstimateSet: LocationsEstimateSetSDK?
    var locationStopsArr: [LocationSetSDK] = []
    var selectedIndex: Int?
    
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
    
    var fromSearch: Bool = false
    var restaurantLoc: Bool = false
    
    private var finishedLoadingInitialTableCells = false
    
    @IBOutlet weak var stopsTable: UITableView!
    @IBOutlet weak var locationTable: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var lblTitle: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        sdkBundle = Bundle(for: Self.self)
        
        let nib = UINib.init(nibName: "LocationCell", bundle: nil)
        self.stopsTable.register(nib, forCellReuseIdentifier: "cell")
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        if !fromSearch {
            if am.getFromPickupLoc() {
                lblTitle.text = "Select Pickup"
                buttpressed = "pickup"
            } else {
                lblTitle.text = "Select Dropoff"
                buttpressed = "dropoff"
            }
        } else {
            fromSearch = false
        }
        
        if buttpressed == "addhome" || buttpressed == "addwork" {
            selectLocation()
        } else {
            
            if locationStopsArr.count == 1 {
                addPlaceHoler()
            }
            
            if locationStopsArr.last?.name != "" && locationStopsArr.last?.subname != "" && locationStopsArr.last?.latitude != "" && locationStopsArr.last?.longitude != "" {
                addPlaceHoler()
            }
            
            setTableHeight()
            
            finishedLoadingInitialTableCells = false
            stopsTable.reloadData()
            
            locationTable.delegate = self
            locationTable.dataSource = self
            
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
            
            getLocationsReload()

            if locationStopsArr.count > 2 {
                locationTable.isHidden = true
            } else {
                locationTable.isHidden = false
            }
        }
    }
    
    func getLocationsReload() {
        
        locationTitleArr = am.getRecentPlacesNames()
        locationSubTitleArr = am.getRecentPlacesFormattedAddress()
        locationCoordsArr = am.getRecentPlacesCoords()

        finishedLoadingInitialTableCells = false
        locationTable.reloadData()
        
    }
    
    func addPlaceHoler() {
        let unique_id = NSUUID().uuidString
        locationStopsArr.append(LocationSetSDK(id: unique_id, name: "", subname: "", latitude: "", longitude: "", phonenumber: "", instructions: ""))
        finishedLoadingInitialTableCells = false
        stopsTable.reloadData()
        setTableHeight()
    }
    
    @objc func btnAddPressed(_ sender: UIButton) {
        addPlaceHoler()
    }
    
    @objc func btnRemovePressed(_ sender: UIButton) {
        let location = locationStopsArr[sender.tag]
        var index: Int?
        for i in (0..<locationStopsArr.count) {
            if locationStopsArr[i].id == location.id {
                index = i
                continue
            }
        }
        if index != nil {
            locationStopsArr.remove(at: index!)
        }
        
        var arr = locationStopsArr.filter { $0.id != locationStopsArr[0].id }
        arr.removeAll(where: { $0.name == "" })
        locationsEstimateSet = LocationsEstimateSetSDK(pickupLocation: locationsEstimateSet?.pickupLocation, dropoffLocations: arr)
        
        finishedLoadingInitialTableCells = false
        stopsTable.reloadData()
        setTableHeight()
    }
    
    @objc func btnEditInstructionsPressed(_ sender: UIButton) {
        let stop = locationStopsArr[sender.tag]
        
        let view: PopoverPlaceInfo = try! SwiftMessages.viewFromNib(named: "PopoverPlaceInfo", bundle: nil)
        view.loadPopup(placeName: stop.name, image: "")
        if stop.instructions != "" {
            view.txtAddInstructions.text = stop.instructions
        }
        if stop.phonenumber != "" {
            view.txtPopupText.text = stop.phonenumber
        }
        view.proceedAction = {
            SwiftMessages.hide()
            self.locationStopsArr[sender.tag] = LocationSetSDK(id: stop.id, name: stop.name, subname: stop.subname, latitude: stop.latitude, longitude: stop.longitude, phonenumber: view.txtPopupText.text ?? "", instructions: view.txtAddInstructions.text ?? "")
            var arr = self.locationStopsArr.filter { $0.id != self.locationStopsArr[0].id }
            arr.removeAll(where: { $0.name == "" })
            self.locationsEstimateSet = LocationsEstimateSetSDK(pickupLocation: self.locationsEstimateSet?.pickupLocation, dropoffLocations: arr)
            self.stopsTable.reloadData()
            self.setTableHeight()
        }
        view.cancelAction = {
           SwiftMessages.hide()
        }
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .center
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func setTableHeight() {
        
        printVal(object: "Location Stops: \(locationStopsArr.count)")
        
        if locationStopsArr.count > 2 {
            locationTable.isHidden = true
        } else {
            locationTable.isHidden = false
            locationTable.reloadData()
        }
        tableHeight.constant = CGFloat(60 * locationStopsArr.count)
        UIView.animate(withDuration: 0.3) {
           self.stopsTable.layoutIfNeeded()
        }
    }
    
    func selectLocation() {
        
        let vc = SearchLocationViewController()
        vc.proceedAction = { [self] in
            let data = vc.selectedLocation
            if data != nil {
                switch buttpressed {
                case "pickup":
                    
                    originLL = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                    pickupName = data?.name.cleanLocationNames() ?? "Unknown"
                    am.savePICKUPADDRESS(data: pickupName)
                    
                    performDonePickLocationLogic(data: data!, ll: originLL)
                    
                case "dropoff":
                    
                    destinationLL = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                    dropOffName = data?.subname.cleanLocationNames() ?? ""
                    am.saveDROPOFFADDRESS(data: dropOffName)
                    
                    performDonePickLocationLogic(data: data!, ll: destinationLL)
                    
                case "addhome","addwork":
                    
                    var index = 0
                    
                    (buttpressed == "addhome") ? (index = 0) : (index = 1)
                    
                    locationTitleArr[index] = (data?.name ?? "").cleanLocationNames()
                    locationSubTitleArr[index] = data?.subname.cleanLocationNames() ?? ""
                    locationCoordsArr[index] = "\(String(data?.latitude ?? "")),\(String(data?.longitude ?? ""))"
                    
                    am.saveRecentPlacesNames(data: locationTitleArr)
                    am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
                    am.saveRecentPlacesCoords(data: locationCoordsArr)
                    
                    locationTitleArr = am.getRecentPlacesNames()
                    locationSubTitleArr = am.getRecentPlacesFormattedAddress()
                    locationCoordsArr = am.getRecentPlacesCoords()
                    
                    finishedLoadingInitialTableCells = false
                    locationTable.reloadData()
                    
                default:
                    return
                }
            }
        }
        let navVC = UINavigationController(rootViewController: vc)
        self.present(navVC, animated: true)
        
    }
    
    @objc func backFromSearch(_ notification: Notification) {
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "DROPOFFMULTIPLE"), object: nil)
        
        if buttpressed == "addhome" || buttpressed == "addwork" {
            
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

            getLocationsReload()
            
        } else {
            adjustAndSetStopsAfterLocationSelect()
        }
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return locationTitleArr.count
        } else {
            return locationStopsArr.count
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! LocationTableViewCell
            
            var imageString: String = ""
            
            if indexPath.item == 0 {
                imageString = "home_force"
                if locationSubTitleArr[indexPath.item] != "" {
                    cell.locationTitle.text = "Going Home"
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
            
            cell.locationImage.image = getImage(named: imageString, bundle: nil)
            cell.selectionStyle = .none
            
            return cell
        } else {
            
            let location = locationStopsArr[indexPath.item]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! LocationCell
            
            cell.txtPlaceName.isUserInteractionEnabled = false
            cell.btnAddRemove.tag = indexPath.item
            cell.txtPlaceName.placeholder = "Add a stop"
            cell.txtPlaceName.text = location.name
            
            cell.btnAddInstructions.tag = indexPath.item
            cell.btnAddInstructions.addTarget(self, action: #selector(btnEditInstructionsPressed(_:)), for: .touchUpInside)
            cell.btnAddRemove.removeTarget(self, action: #selector(btnAddPressed(_:)), for: .touchUpInside)
            cell.btnAddRemove.removeTarget(self, action: #selector(btnRemovePressed(_:)), for: .touchUpInside)
            
            if indexPath.item == 0 {
                cell.topView.isHidden = true
                cell.imgView.isHidden = false
                cell.bottomView.isHidden = false
                cell.btnAddRemove.isHidden = true
                cell.btnAddRemove.isUserInteractionEnabled = false
            } else if indexPath.item == (locationStopsArr.count - 1) {
                cell.topView.isHidden = false
                cell.imgView.isHidden = false
                cell.bottomView.isHidden = true
                cell.btnAddRemove.isHidden = false
                cell.btnAddRemove.setImage(getImage(named: "add_icon", bundle: nil), for: .normal)
                cell.btnAddRemove.isUserInteractionEnabled = true
                cell.btnAddRemove.addTarget(self, action: #selector(btnAddPressed(_:)), for: .touchUpInside)
            } else {
                cell.topView.isHidden = false
                cell.imgView.isHidden = false
                cell.bottomView.isHidden = false
                cell.btnAddRemove.isHidden = false
                cell.btnAddRemove.setImage(getImage(named: "remove_icon", bundle: nil), for: .normal)
                cell.btnAddRemove.isUserInteractionEnabled = true
                cell.btnAddRemove.addTarget(self, action: #selector(btnRemovePressed(_:)), for: .touchUpInside)
            }
            
            if location.name != "" {
                if location.instructions == "" && location.phonenumber == "" {
                    cell.lblAddInstructions.text = "+ Add \(location.name.components(separatedBy: " ")[0])'s instructions?"
                } else {
                    cell.lblAddInstructions.text = "x Edit \(location.name.components(separatedBy: " ")[0])'s instructions?"
                }
                cell.lblAddInstructions.isHidden = false
                cell.btnAddInstructions.isHidden = false
            } else {
                cell.lblAddInstructions.isHidden = true
                cell.btnAddInstructions.isHidden = true
            }
            
            cell.selectionStyle = .none
            
            return cell

        }
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            if locationTitleArr[indexPath.item] == "Add Home" {
                buttpressed = "addhome"
                selectLocation()
            } else if locationTitleArr[indexPath.item] == "Add Work" {
                buttpressed = "addwork"
                selectLocation()
            } else {
                am.saveSelectedLocIndex(data: indexPath.item)
                if am.getFromPickupLoc() {
                    locationsEstimateSet = LocationsEstimateSetSDK(pickupLocation: LocationSetSDK(id: locationsEstimateSet?.pickupLocation?.id ?? "", name: locationTitleArr[indexPath.item], subname: locationSubTitleArr[indexPath.item], latitude: locationCoordsArr[indexPath.item].components(separatedBy: ",")[0], longitude: locationCoordsArr[indexPath.item].components(separatedBy: ",")[1], phonenumber: locationsEstimateSet?.pickupLocation?.phonenumber ?? "", instructions: locationsEstimateSet?.pickupLocation?.instructions ?? ""), dropoffLocations: locationsEstimateSet?.dropoffLocations ?? [])
                } else {
                    let unique_id = NSUUID().uuidString
                    var dropOffs = locationsEstimateSet?.dropoffLocations
                    if dropOffs!.contains(where: { $0.latitude == locationCoordsArr[indexPath.item].components(separatedBy: ",")[0]}) && dropOffs!.contains(where: { $0.longitude == locationCoordsArr[indexPath.item].components(separatedBy: ",")[1]}) {
                        if let index = dropOffs?.firstIndex(where: { $0.latitude == locationCoordsArr[indexPath.item].components(separatedBy: ",")[0]}) {
                            dropOffs?[index] = LocationSetSDK(id: unique_id, name: locationTitleArr[indexPath.item], subname: locationSubTitleArr[indexPath.item], latitude: locationCoordsArr[indexPath.item].components(separatedBy: ",")[0], longitude: locationCoordsArr[indexPath.item].components(separatedBy: ",")[1], phonenumber: "", instructions: "")
                        }
                    } else {
                        dropOffs?.append(LocationSetSDK(id: unique_id, name: locationTitleArr[indexPath.item], subname: locationSubTitleArr[indexPath.item], latitude: locationCoordsArr[indexPath.item].components(separatedBy: ",")[0], longitude: locationCoordsArr[indexPath.item].components(separatedBy: ",")[1], phonenumber: "", instructions: ""))
                    }
                    locationsEstimateSet = LocationsEstimateSetSDK(pickupLocation: locationsEstimateSet?.pickupLocation, dropoffLocations: dropOffs)
                    
                }
                
                printVal(object: locationsEstimateSet as Any)
                
                let dic = ["LocationsEstimateSet":locationsEstimateSet]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PICKUPDROPOFF"), object: nil, userInfo: dic as [AnyHashable : Any])
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            selectedIndex = indexPath.item
            if selectedIndex == 0 {
                lblTitle.text = "Select Pickup"
                buttpressed = "pickup"
                am.saveFromPickupLoc(data: true)
            } else {
                lblTitle.text = "Select Stop"
                buttpressed = "dropoff"
                am.saveFromPickupLoc(data: false)
            }
            
            self.viewWillAppear(false)
            
            selectLocation()
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if locationStopsArr.count > 0 && !finishedLoadingInitialTableCells {
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
    
    @IBAction func btnDonePressed(_ sender: UIButton) {
        
        printVal(object: locationsEstimateSet as Any)
        
        let dic = ["LocationsEstimateSet":locationsEstimateSet]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PICKUPDROPOFF"), object: nil, userInfo: dic as [AnyHashable : Any])
        self.navigationController?.popViewController(animated: true)
        
    }
    
    func performDonePickLocationLogic(data: LocationSetSDK, ll: String) {
        
        if locationTitleArr.count < 8 {
            locationTitleArr.insert(data.name, at: 2)
            locationSubTitleArr.insert(data.subname, at: 2)
            locationCoordsArr.insert(ll, at: 2)
        } else {
            locationTitleArr.removeLast()
            locationTitleArr.insert(data.name, at: 2)
            locationSubTitleArr.removeLast()
            locationSubTitleArr.insert(data.subname, at: 2)
            locationCoordsArr.removeLast()
            locationCoordsArr.insert(ll, at: 2)
        }
        
        am.saveRecentPlacesNames(data: locationTitleArr)
        am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
        am.saveRecentPlacesCoords(data: locationCoordsArr)
        
        locationTitleArr = am.getRecentPlacesNames()
        locationSubTitleArr = am.getRecentPlacesFormattedAddress()
        locationCoordsArr = am.getRecentPlacesCoords()
        
        finishedLoadingInitialTableCells = false
        locationTable.reloadData()
        
        let index = locationTitleArr.firstIndex(of: data.name)
        am.saveSelectedLocIndex(data: index!)
        
        adjustAndSetStopsAfterLocationSelect()
        
    }
    
    func adjustAndSetStopsAfterLocationSelect() {
        
        if selectedIndex == nil {
            selectedIndex = 0
        }
        
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

        getLocationsReload()
        
        locationStopsArr[selectedIndex!] = LocationSetSDK(id: locationStopsArr[selectedIndex!].id, name: locationTitleArr[am.getSelectedLocIndex()], subname: locationSubTitleArr[am.getSelectedLocIndex()], latitude: locationCoordsArr[am.getSelectedLocIndex()].components(separatedBy: ",")[0], longitude: locationCoordsArr[am.getSelectedLocIndex()].components(separatedBy: ",")[1], phonenumber: locationStopsArr[selectedIndex!].phonenumber, instructions: locationStopsArr[selectedIndex!].instructions)
        
        if am.getFromPickupLoc() {
            let arr = locationStopsArr.filter { $0.id != locationStopsArr[0].id && $0.latitude != "" }
            locationsEstimateSet = LocationsEstimateSetSDK(pickupLocation: locationStopsArr[selectedIndex!], dropoffLocations: arr)
        } else {
            let arr = locationStopsArr.filter { $0.id != locationStopsArr[0].id && $0.latitude != "" }
            locationsEstimateSet = LocationsEstimateSetSDK(pickupLocation: locationsEstimateSet?.pickupLocation, dropoffLocations: arr)
        }
        
        finishedLoadingInitialTableCells = false
        
        if (selectedIndex == (locationStopsArr.count - 1)) && (locationStopsArr.count == 2) {
            addPlaceHoler()
        } else {
            stopsTable.reloadData()
        }
        
    }
}
