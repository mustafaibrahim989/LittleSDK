//
//  TrackOrderController.swift
//  Little
//
//  Created by Gabriel John on 03/04/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import UIView_Shimmer
import SwiftMessages

public class TrackOrderController: UIViewController {
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    let cn = SDKConstants()
    
    var sdkBundle: Bundle?
    
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var routePolyline: GMSPolyline!
    var oldPolylineArr = [GMSPolyline]()
    var nearDriverMarker = [Int: GMSMarker]()
    var animatePath = GMSPath()
    var animationPath = GMSMutablePath()
    var animationPolyline = GMSPolyline()
    var selectedRoute: Dictionary<String, AnyObject>!
    var overviewPolyline: Dictionary<String, AnyObject>!
    var overviewPolylineString: String!
    var originAddress: String!
    var destinationAddress: String!
    
    var i: UInt = 0
    var animatetimer: Timer!
    
    var gmsMapView: GMSMapView!
    var marker: GMSMarker!
    var destinationCoordinate: CLLocationCoordinate2D!
    var originCoordinate: CLLocationCoordinate2D!
    
    var timer: Timer?
    var trackID: String = ""
    var isContinueRequest = false
    var isLocal = false
    var routeShowing = false
    var isAnimating = false
    
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var lblETA: UILabel!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverRating: UILabel!
    @IBOutlet weak var lblDriverCar: UILabel!
    @IBOutlet weak var lblDriverPlates: UILabel!
    @IBOutlet weak var imgDriverImage: UIImageView!
    @IBOutlet weak var imgCarImage: UIImageView!
    @IBOutlet weak var mapContainerView: UIView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle.module
        
        // Setup Map
        
        view.layoutIfNeeded()
        
        gmsMapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: mapContainerView.bounds.height))
        gmsMapView.showMapStyleForView()
        gmsMapView.delegate = self
        gmsMapView.isMyLocationEnabled = true
        gmsMapView.isBuildingsEnabled = true
        let padding = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        gmsMapView.padding = padding
        mapContainerView.addSubview(gmsMapView)
        
        mapContainerView.layoutIfNeeded()
        
        checkLocation()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        resumeTrip()
        loadingScreen()
        
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        stopCheckingStatusUpdate()
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            let hasUserInterfaceStyleChanged = previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false
            if hasUserInterfaceStyleChanged {
                gmsMapView.showMapStyleForView()
            }
        }
    }
    
    // MARK: - Server Calls & Responses
    
    func resumeTrip() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadCreateRequest),name:NSNotification.Name(rawValue: "CREATEREQUEST_NEW"), object: nil)
        let datatosend = "FORMID|RESUME|TRIPID|\(am.getTRIPID() ?? "")|"
        hc.makeServerCall(sb: datatosend, method: "CREATEREQUEST_NEW", switchnum: 0)
    }
       
    @objc func loadCreateRequest() {
           
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "CREATEREQUEST_NEW"), object: nil)
        showDriverDetails()
        getTripStatus()
        startCheckingStatusUpdate()
        
    }
    
    func getTripStatus() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadRequestStatus),name:NSNotification.Name(rawValue: "GETREQUESTSTATUS_NEW"), object: nil)
        
        let datatosend = "FORMID|GETREQUESTSTATUS_V1|TRIPID|\(trackID)|GETET|Y|DEVICETOKEN|\(am.getDeviceToken() ?? "")|CORPORATETRIPID||"
        
        hc.makeServerCall(sb: datatosend, method: "GETREQUESTSTATUS_NEW", switchnum: 0)
        
    }
    
    @objc func loadRequestStatus() {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "GETREQUESTSTATUS_NEW"), object: nil)
        
        originCoordinate = CLLocationCoordinate2DMake(Double(am.getDRIVERLATITUDE() ?? "0") ?? 0.0, Double(am.getDRIVERLONGITUDE() ?? "0") ?? 0.0)
        
        let endedMessage = "Your order has already been marked delivered and signed for. Thank you for using Little!"
        
        switch am.getTRIPSTATUS() {
            case "1","2","3","4":
                updateDriverLocation(coordinates: originCoordinate)
                if destinationCoordinate != nil {
                    drawPath()
                } else {
                    gmsMapView.animate(toLocation: originCoordinate)
                }
            case "5":
                updateDriverLocation(coordinates: originCoordinate)
                tripEnded(message: endedMessage)
            case "6":
                updateDriverLocation(coordinates: originCoordinate)
                tripEnded(message: endedMessage)
            case "7":
                updateDriverLocation(coordinates: originCoordinate)
                tripEnded(message: endedMessage)
            default:
                updateDriverLocation(coordinates: originCoordinate)
                tripEnded(message: am.getMESSAGE() ?? "")
        }
    }
    
    // MARK: - Functions & IBActions
    
    func loadingScreen() {
        view.layoutIfNeeded()
        view.setTemplateWithSubviews(true, viewBackgroundColor: .white)
    }
    
    func stopLoading() {
        view.layoutIfNeeded()
        view.setTemplateWithSubviews(false)
    }
    
    func startCheckingStatusUpdate() {
        stopCheckingStatusUpdate()
        isContinueRequest=true
        let timerdelay=Double(6.0)
        timer = Timer.scheduledTimer(timeInterval: timerdelay, target: self, selector: #selector(TimerRequestStatus), userInfo: nil, repeats: true)
        
    }
    
    func stopCheckingStatusUpdate() {
        isContinueRequest=false
        if timer != nil {
            timer!.invalidate()
        }
    }
    
    func showDriverDetails() {
        
        imgDriverImage.sd_setImage(with: URL(string: am.getDRIVERPICTURE()), placeholderImage: getImage(named: "default", bundle: sdkBundle!))
        
        let amount = Double(am.getRATING() ?? "0")
        if amount != nil {
            lblDriverRating.text = String(format: "%.1f", amount!)
        } else {
            lblDriverRating.text = ""
        }
        
        originCoordinate = CLLocationCoordinate2DMake(Double(am.getDRIVERLATITUDE() ?? "0") ?? 0.0, Double(am.getDRIVERLONGITUDE() ?? "0") ?? 0.0)
        
        let camera = GMSCameraPosition.camera(withLatitude: originCoordinate.latitude, longitude: originCoordinate.longitude, zoom: 16)
        gmsMapView.animate(to: camera)
        
        lblDriverCar.text = "\(am.getMODEL()?.capitalized ??  "") - \(am.getCOLOR()?.capitalized ?? "")"
        lblDriverPlates.text = "\(am.getNUMBER()?.uppercased() ?? "")"
        lblDriverName.text = "\(am.getDRIVERNAME()?.capitalized ?? "")"
        lblDriverName.text = "Order being delivered by \(am.getDRIVERNAME()?.capitalized ?? "")"
        
        stopLoading()
    }
    
    func tripEnded(message: String) {
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "", message: "\n\(message)\n", image: "", action: "")
        view.proceedAction = {
           SwiftMessages.hide()
           self.navigationController?.popViewController(animated: true)
        }
        view.btnDismiss.isHidden = true
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func updateDriverLocation(coordinates: CLLocationCoordinate2D) {
        
        var time = "soon..."
        if am.getET() != "" {
            if am.getET() == "1" {
                time = "in \(am.getET() ?? "0") min"
            } else {
                time = "in \(am.getET() ?? "0") mins"
            }
            
        }
        lblETA.text = "Arriving \(time)"
        
        if originMarker == nil {
            originMarker = GMSMarker()
            originMarker.position = coordinates
            if am.getDRIVERBEARING() != "" {
                originMarker.rotation = CLLocationDegrees(am.getDRIVERBEARING() ?? "0") ?? CLLocationDegrees(0)
            }
            let imageName = "PARCELTOP"
            let image = getImage(named: imageName, bundle: sdkBundle!)
            originMarker.icon = scaleImage(image: image!,size: 0.25)
            originMarker.title = "My Ride"
            originMarker.map = gmsMapView
            originMarker.appearAnimation = GMSMarkerAnimation.pop
        } else {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            if am.getDRIVERBEARING() != "" {
                originMarker.rotation = CLLocationDegrees(am.getDRIVERBEARING() ?? "0") ?? CLLocationDegrees(0)
            }
            let imageName = "PARCELTOP"
            let image = getImage(named: imageName, bundle: sdkBundle!)
            originMarker.icon = scaleImage(image: image!,size: 0.25)
            originMarker.position =  coordinates
            CATransaction.commit()
        }
    }
    
    func drawPath() {
       if am.getCountry()?.uppercased() == "KENYA" {
            goLocal()
       } else {
            goGoogle()
        }
    }
    
    func goGoogle() {
        
        isLocal = false
        
        animatePath = GMSPath()
        if originCoordinate != nil {
            if destinationCoordinate != nil {
                
                let origin = "\(originCoordinate.latitude),\(originCoordinate.longitude)"
                let destination = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
                
                
                let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=\(am.DecryptDataKC(DataToSend: cn.placesKey))"
                
                let url = URL(string: directionURL)
                URLSession.shared.dataTask(with:url!) { (data, response, error) in
                    if error != nil {
                        // printVal(object: error as Any)
                    } else {
                        do {
                            
                            let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                            
                            let status = parsedData["status"] as! String
                            
                            if status == "OK" {
                                guard let routes = parsedData["routes"], let route = (routes as? Array<Dictionary<String, AnyObject>>)?.first else { return }
                                self.selectedRoute = route
                                self.overviewPolyline = self.selectedRoute["overview_polyline"] as? Dictionary<String, AnyObject>
                                
                                guard let legs = self.selectedRoute["legs"], let myLegs = legs as? Array<Dictionary<String, AnyObject>> else { return }
                                guard let firstLeg = myLegs.first else { return }
                                
                                guard let startLocationDictionary = firstLeg["start_location"] as? Dictionary<String, AnyObject> else { return }
                                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                
                                guard let endLocationDictionary = myLegs[myLegs.count - 1]["end_location"] as? Dictionary<String, AnyObject> else { return }
                                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                
                                self.originAddress = firstLeg["start_address"] as? String
                                self.destinationAddress = myLegs[myLegs.count - 1]["end_address"] as? String
                                DispatchQueue.main.async {
                                    
                                    for p in (0 ..< self.oldPolylineArr.count) {
                                        self.oldPolylineArr[p].map = nil
                                    }
                                    
                                    self.configureMapAndMarkersForRoute()
                                    self.drawRoute()
                                }
                                
                            }
                            else {
                                
                            }
                            
                            // printVal(object: parsedData.description)
                        } catch let error as NSError {
                            printVal(object: error)
                        }
                    }
                    
                    }.resume()
                
            }
        }
    }
    
    func goLocal() {
        
        isLocal = true
        
        animatePath = GMSPath()
        if originCoordinate != nil {
                    if destinationCoordinate != nil {
                        let origin = "\(originCoordinate.latitude),\(originCoordinate.longitude)"
                        let destination = "\(destinationCoordinate.latitude),\(destinationCoordinate.longitude)"
                        let directionURL = "https://maps.little.bz/api/v2/direction/full?origin=\(origin)&destination=\(destination)&key=\(am.DecryptDataKC(DataToSend: cn.littleMapKey))"
        
                        let url = URL(string: directionURL)
                        URLSession.shared.dataTask(with:url!) { (data, response, error) in
                            if error != nil {
                                self.goGoogle()
                                // printVal(object: error as Any)
                            } else {
                                do {
        
                                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
        
                                    let paths = parsedData["paths"] as? Array<Dictionary<String, AnyObject>>
                                    
                                    self.overviewPolylineString = paths?[safe: 0]?["points"] as? String
                                    
                                    DispatchQueue.main.async {
                                        self.configureMapAndMarkersForRoute()
                                        self.drawRoute()
                                    }
                                    
                                    // printVal(object: "This is local")
                                    
                                    // printVal(object: parsedData.description)
                                } catch _ as NSError {
                                    self.goGoogle()
                                    // printVal(object: error)
                                }
                            }
        
                        }.resume()
                    }
        }
    }
    
    func configureMapAndMarkersForRoute() {
        
        if routeShowing == false {
            let bounds = GMSCoordinateBounds(coordinate: originCoordinate, coordinate: destinationCoordinate)
            gmsMapView.moveCamera(GMSCameraUpdate.fit(bounds, withPadding: 60.0))
            routeShowing = true
        }
    }
    
    func drawRoute() {
        
        self.i = 0
        self.animationPath = GMSMutablePath()
        self.animationPolyline.map = nil
        
        var route = ""
        
        if isLocal {
            if overviewPolylineString != nil {
                route = overviewPolylineString
            }
        } else {
            route = overviewPolyline["points"] as? String ?? ""
        }
        
        if let path: GMSPath = GMSPath(fromEncodedPath: route) {
            routePolyline = GMSPolyline(path: path)
            routePolyline.strokeWidth = 3
            routePolyline.strokeColor = UIColor.darkGray.withAlphaComponent(0.6)
            routePolyline.map = gmsMapView
            animatePath = path
            oldPolylineArr.append(routePolyline)
            
            if !isAnimating {
                isAnimating = true
                self.animatetimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
            }
        }
        
    }
    
    @objc func animatePolylinePath() {
        
        if (self.i < animatePath.count()) {
            self.animationPath.add(animatePath.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = SDKConstants.littleSDKThemeColor
            self.animationPolyline.strokeWidth = 4
            self.animationPolyline.map = self.gmsMapView
            self.i += 1
        }
        else {
            self.i = 0
            self.animationPath = GMSMutablePath()
            self.animationPolyline.map = nil
        }
    }
    
    @objc func TimerRequestStatus() {
        if isContinueRequest {
            getTripStatus()
        }
    }
    
    @IBAction func btnBackPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCallDriverPressed(_ sender: UIButton) {
        var number = am.getDRIVERMOBILE() ?? ""
        if number != "" {
            number="+"+number
            guard let url = URL(string: "telprompt://\(number)") else {
              return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func btnHomeInPressed(_ sender: UIButton) {
        if destinationCoordinate != nil {
            gmsMapView.animate(toLocation: destinationCoordinate)
        }
    }
    
    @objc func checkLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .restricted, .denied:
                
                printVal(object: "No access: Restricted/Denied")
                allowLocationAccessMessage()
                
            case .notDetermined:
                
                printVal(object: "No access: Not Determined")
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                
            case .authorizedAlways, .authorizedWhenInUse:
                
                printVal(object: "Access")
                
                locationManager.delegate = self
                locationManager.distanceFilter = 100.0
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                
                // printVal(object: "Getting location")
                
            @unknown default:
                allowLocationAccessMessage()
            }
        } else {
            allowLocationAccessMessage()
        }
        
    }
    
    func allowLocationAccessMessage() {
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "", message: "\nLocation Services Disabled. Please enable location services in settings to help identify your current location. This will be used by keep track of your current order.\n", image: "", action: "")
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
}

extension TrackOrderController: GMSMapViewDelegate{
    
    func placeMarkerOnCenter(centerMapCoordinate:CLLocationCoordinate2D) {
        let color = SDKConstants.littleSDKThemeColor
        if marker == nil {
            marker = GMSMarker()
            marker.icon = GMSMarker.markerImage(with: color)
            marker.accessibilityHint = "Pin"
        }
        marker.position = centerMapCoordinate
        marker.map = self.gmsMapView
    }
    
}

extension TrackOrderController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .restricted, .denied:
                
                printVal(object: "No access: Restricted/Denied")
                allowLocationAccessMessage()
                
            case .notDetermined:
                
                printVal(object: "No access: Not Determined")
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                
            case .authorizedAlways, .authorizedWhenInUse:
                
                printVal(object: "Access")
                
                locationManager.delegate = self
                locationManager.distanceFilter = 100.0
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.startUpdatingLocation()
                
            @unknown default:
                allowLocationAccessMessage()
            }
        } else {
            allowLocationAccessMessage()
        }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        if manager.location != nil {
            
            self.destinationCoordinate = manager.location!.coordinate
            self.gmsMapView.isTrafficEnabled=true
            self.gmsMapView.settings.compassButton = true
            
        } else {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        
        
    }
}
