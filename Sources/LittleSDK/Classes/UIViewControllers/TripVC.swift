//
//  TripVC.swift
//  Little
//
//  Created by Gabriel John on 03/06/2019.
//  Copyright © 2019 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import GoogleMaps
import GooglePlaces
import UserNotifications
import MessageUI
import SwiftMessages
import Alamofire
import EasyNotificationBadge

public class TripVC: UIViewController {

    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    let cn = SDKConstants()
    let locationManager = CLLocationManager()
    
    var sdkBundle: Bundle?
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    var observersArray: [String] = []
    var tripDropOffDetails: [TripDropOffDetail] = []
    
    var arrived = false
    var driverLoc: CLLocation!
    var userLoc: CLLocation!
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var timer:Timer!
    var mapcleared = false
    var driverOnWay = false
    var driverWaitAccept = false
    var isContinueRequest = false
    var doIRing = true
    var tripstart = false
    var routeShowing = false
    var destinationChange = 0.0
    var destinationTotal = 10.0
    var isAnimating = false
    var isLocal = false
    var isBraking = false
    var isBrakingCount = 0
    
    var cancelReason = ""
    var notificationMessage = ""
    var reasonsArr: [String] = ["I was not ready","Driver took too long","Driver asked me to cancel","Other"]
    
    
    // Map Variables
    
    var gmsMapView: GMSMapView!
    var marker: GMSMarker!
    
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
    
    var popLink: String = ""
    var popTitle: String = ""
    var popDesc: String = ""
    var chatSetUp: Bool = false
    var toChat: Bool = false
    
    var centerMapCoordinate: CLLocationCoordinate2D!
    
    var audioPlayer:AVAudioPlayer!
    var path = ""
    
    var paymentVC: UIViewController?
    
    @IBOutlet weak var homeInBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var btnStops: UIButton!
    
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var imgDriverPic: UIImageView!
    @IBOutlet weak var imgCarType: UIImageView!
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var coverView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewShadow: UIView!
    @IBOutlet weak var onTripView: UIView!
    
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblYouAreDrivenBy: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblArrivalTime: UILabel!
    @IBOutlet weak var lblCarModelColor: UILabel!
    @IBOutlet weak var lblPlateNumber: UILabel!
    @IBOutlet weak var lblETA: UILabel!
    
    @IBOutlet weak var lblPaymentMode: UILabel!
    @IBOutlet weak var lblPaymentModeTrip: UILabel!
    @IBOutlet weak var lblCorporatePromo: UILabel!
    @IBOutlet weak var lblCorporatePromoName: UILabel!
    @IBOutlet weak var lblCorporatePromoName2: UILabel!
    
    @IBOutlet weak var panicBtnInfoView: UIView!
    @IBOutlet weak var panicBtnTxt: UILabel!
    @IBOutlet weak var panicBtnInfoBtn: UIButton!
    @IBOutlet weak var panicButton: UIButton!
    
    @IBOutlet weak var btnMuteAudio: UIButton!
    
    @IBOutlet weak var progressSlider: UISlider!
    
    @IBOutlet weak var lblDistanceTravelled: UILabel!
    @IBOutlet weak var lblTripCost: UILabel!
    @IBOutlet weak var lblTripCurrency: UILabel!
    @IBOutlet weak var lblTripDuration: UILabel!
    
    @IBOutlet weak var lblTripAt: UILabel!
    @IBOutlet weak var viewTripAT: UIView!
    
    @IBOutlet weak var lblStartTripLabel: UILabel!
    @IBOutlet weak var lblStartTripCode: UILabel!
    @IBOutlet weak var btnStartTripHint: UIButton!
    @IBOutlet weak var imgStartTripHint: UIImageView!
    
    @IBOutlet weak var lblEndTripLabel: UILabel!
    @IBOutlet weak var lblEndTripCode: UILabel!
    @IBOutlet weak var btnEndTripHint: UIButton!
    @IBOutlet weak var imgEndTripHint: UIImageView!
    
    @IBOutlet weak var lblParkingLabel: UILabel!
    @IBOutlet weak var lblParkingCode: UILabel!
    @IBOutlet weak var btnParkingHint: UIButton!
    @IBOutlet weak var imgParkingHint: UIImageView!
    
    @IBOutlet weak var btnChat: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle.module
        guard let sdkBundle = sdkBundle else { return }
        
        path = sdkBundle.path(forResource: "sparkle.wav", ofType:nil)!
        
        let loadBackGround = createLoadingScreen()
        self.view.addSubview(loadBackGround)
        
        self.profPic.isHidden = true
        self.menuBtn.imageEdgeInsets = UIEdgeInsets.init(top: 3,left: 3,bottom: 3,right: 3)
        self.menuBtn.addTarget(self, action: #selector(postBackHome), for: .touchUpInside)
        self.menuBtn.setImage(getImage(named: "back_super_app", bundle: sdkBundle), for: UIControl.State())
        
        observersArray = ["HidePanic","ShowPanic"]
        NotificationCenter.default.addObserver(self, selector: #selector(hidePanicBtn),name:NSNotification.Name(rawValue: "HidePanic"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPanicBtn),name:NSNotification.Name(rawValue: "ShowPanic"), object: nil)
        
        progressSlider.isUserInteractionEnabled = false
        progressSlider.setThumbImage(getImage(named: "sliderpoint", bundle: sdkBundle), for: .normal)
        
        am.saveFromTrip(data: true)
        am.saveOnTrip(data: true)
        
        self.view.layoutIfNeeded()
        
        // Setup Map
        
        gmsMapView = GMSMapView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: mapContainerView.bounds.height))
        gmsMapView.showMapStyleForView()
        gmsMapView.delegate = self
        gmsMapView.isMyLocationEnabled = true
        gmsMapView.isBuildingsEnabled = true
        let padding = UIEdgeInsets(top: 30, left: 0, bottom: 30, right: 0)
        gmsMapView.padding = padding
        
        mapContainerView.addSubview(gmsMapView)
        
        destinationCoordinate = SDKUtils.extractCoordinate(string: am.getCurrentLocation() ?? "")
        
        checkLocation()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        if animatetimer != nil {
            animatetimer.invalidate()
        }
        if !toChat {
            if timer != nil {
                timer.invalidate()
            }
        } else {
            toChat = false
        }
    }
 
    // MARK: - Functions
    
    @objc func postBackHome() {
        
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
    
    @objc func checkLocation() {
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .restricted, .denied:
                
                printVal(object: "No access: Restricted/Denied")
                showDriverDetails()
                getTripStatus()
                startCheckingStatusUpdate()
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
                printVal(object: "Wuuueh!")
            }
        } else {
            showDriverDetails()
            getTripStatus()
            startCheckingStatusUpdate()
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
    
    @objc func showPanicBtn() {
        DispatchQueue.main.async {
            self.panicButton.isHidden = false
            self.panicBtnInfoBtn.isHidden = false
            self.panicBtnInfoView.isHidden = true
        }
        printVal(object: "show")
    }
    
    @objc func hidePanicBtn() {
        DispatchQueue.main.async {
            self.panicButton.isHidden = true
            self.panicBtnInfoBtn.isHidden = true
            self.panicBtnInfoView.isHidden = true
        }
        printVal(object: "hide")
    }
    
    @objc func TimerRequestStatus() {
        if isContinueRequest {
            getTripStatus()
        }
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
            timer.invalidate()
        }
    }
    
    func panicButtonCall() {
        
        if userLoc != nil {
            
            let datatosend = "FORMID|PANICBUTTON|LL|\(userLoc.coordinate.latitude),\(userLoc.coordinate.longitude)|EMAIL|\(am.getEmail() ?? "")|TRIPID|\(am.getTRIPID() ?? "")|"
            
            hc.makeServerCall(sb: datatosend, method: "PANICBUTTON", switchnum: 0)
            
        } else {
            allowLocationAccessMessage()
        }
    }
    
    func scheduleNotifications() {
        
        let content = UNMutableNotificationContent()
        let requestIdentifier = "littleNotification"
        
        content.body = notificationMessage
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            
            if error != nil {
                // printVal(object: error?.localizedDescription ?? "")
            }
            printVal(object: "Notification Register Success")
        }
        
    }
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID() ?? "")\",\"MobileNumber\":\"\(am.getSDKMobileNumber() ?? "")\",\"IMEI\":\"\(am.getIMEI() ?? "")\",\"CodeBase\":\"\(am.getMyCodeBase() ?? "")\",\"PackageName\":\"\(am.getSDKPackageName() ?? "")\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"LatLong\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"TripID\":\"\(am.getTRIPID() ?? "")\",\"City\":\"\(am.getCity() ?? "")\",\"RegisteredCountry\":\"\(am.getCountry() ?? "")\",\"Country\":\"\(am.getCountry() ?? "")\",\"UniqueID\":\"\(am.getMyUniqueID() ?? "")\",\"CarrierName\":\"\(getCarrierName() ?? "")\",\"UserAdditionalData\":\(am.getSDKAdditionalData())"
        
        return str
    }
    
    @objc func cancelTrip() {
    
        var dataToSend = "{\"FormID\":\"CANCELREQUEST\"\(commonCallParams()),\"CancelTrip\":{\"TripID\":\"\(am.getTRIPID() ?? "")\",\"Reason\":\"\(cancelReason)\"}}"
        
        printVal(object: dataToSend)
        
        dataToSend = am.EncryptDataAES(DataToSend: dataToSend) as String
        
        let string = am.DecryptDataKC(DataToSend: cn.link()) as String
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: "Content-Type", value: "application/json; charset=utf-8"),
            HTTPHeader(name: "KeyID", value: "\(am.EncryptDataHeaders(DataToSend: am.getMyKeyID() ?? ""))"),
            HTTPHeader(name: "Accounts", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKAccounts() ?? "")"))"),
            HTTPHeader(name: "MobileNumber", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKMobileNumber() ?? "")"))"),
            HTTPHeader(name: "PackageName", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKPackageName() ?? "")"))")
        ]
        
        AF.request("\(string)",
               method: .post,
               parameters: [:], encoding: dataToSend, headers: headers).response { response in

                let data = response.data

                if data != nil {
                    do {
                        let sDKData = try JSONDecoder().decode(SDKData.self, from: data!)
                        let stringVal = self.am.DecryptDataAES(DataToSend: sDKData.data ?? "") as String
                        let strData = Data(stringVal.utf8)
                        
                        do {
                            
                            let requestStatusResponse = try JSONDecoder().decode(DefaultMessages.self, from: strData)
                            guard let response = requestStatusResponse[safe: 0] else { return }
                            
                            self.stopCheckingStatusUpdate()
                            self.am.saveTRIPID(data: "")
                            self.notificationMessage = "\(response.message ?? "Request successfully cancelled")"
                            UNUserNotificationCenter.current().delegate = self
                            self.scheduleNotifications()
                            self.am.saveOnTrip(data: false)
                            
                            self.removeAllObservers(array: self.observersArray)
                            self.postBackHome()
                            
                        } catch {
                        }
        
                    } catch {}
                }
        }
        
    }
    
    func getTripStatus() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMakeRequestStatusJSON(_:)),name:NSNotification.Name(rawValue: "GETREQUESTSTATUSJSONData"), object: nil)
        
        am.saveStillRequesting(data: false)
        
        let dataToSend = "{\"FormID\":\"GETREQUESTSTATUS\"\(commonCallParams()),\"GetRequestStatus\":{\"TripID\":\"\(am.getTRIPID() ?? "")\"}}"
        
        hc.makeServerCall(sb: dataToSend, method: "GETREQUESTSTATUSJSONData", switchnum: 0)
        
    }
    
    @objc func loadMakeRequestStatusJSON(_ notification: Notification) {
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name(rawValue: "GETREQUESTSTATUSJSONData"), object: nil)
        
        if data != nil {
            var STATUS = ""
            var TRIPSTATUS = ""
            var WIFIPASS = ""
            var DRIVERLATITUDE = ""
            var DRIVERLONGITUDE = ""
            var DRIVERBEARING = ""
            var VEHICLETYPE = ""
            var LIVEFARE = ""
            var BASEPRICE = ""
            var PERMIN = ""
            var PERKM = ""
            var CORPORATECODE = ""
            var BASEFARE = ""
            var DISTANCE = ""
            var TIME = ""
            var DISTANCETOTALCOST = ""
            var TIMETOTALCOST = ""
            var PAYMENTCODES = ""
            var PAYMENTCOSTS = ""
            var ET = ""
            var ED = ""
            var MESSAGE = ""
            var CURRENCY = ""
            var STARTOTP = ""
            var ENDOTP = ""
            var PARKOTP = ""
            var CHAT = ""
            
            am.saveTRIPSTATUS(data: TRIPSTATUS)
            am.saveWIFIPASS(data: WIFIPASS)
            am.saveDRIVERLATITUDE(data: DRIVERLATITUDE)
            am.saveDRIVERLONGITUDE(data: DRIVERLONGITUDE)
            am.saveDRIVERBEARING(data: DRIVERBEARING)
            am.saveVEHICLETYPE(data: VEHICLETYPE)
            am.savePERMIN(data: PERMIN)
            am.savePERKM(data: PERKM)
            am.saveCORPORATECODE(data: CORPORATECODE)
            am.saveLIVEFARE(data: LIVEFARE)
            am.saveBASEPRICE(data: BASEPRICE)
            am.saveBASEFARE(data: BASEFARE)
            am.saveDISTANCE(data: DISTANCE)
            am.saveTIME(data: TIME)
            am.saveGLOBALCURRENCY(data: CURRENCY)
            am.saveDISTANCETOTALCOST(data: DISTANCETOTALCOST)
            am.saveTIMETOTALCOST(data: TIMETOTALCOST)
            am.savePAYMENTCODES(data: PAYMENTCODES)
            am.savePAYMENTCOSTS(data: PAYMENTCOSTS)
            am.saveET(data: ET)
            am.saveED(data: ED)
            am.saveMESSAGE(data: MESSAGE)
            am.saveStartTripOTP(data: STARTOTP)
            am.saveEndTripOTP(data: ENDOTP)
            am.saveParkingFeeOTP(data: PARKOTP)
            am.saveCHAT(data: CHAT)
            
            do {
                let requestStatusResponse = try JSONDecoder().decode(RequestStatusResponse.self, from: data!)
                guard let response = requestStatusResponse[safe: 0] else { return }
                
                STATUS = response.status ?? ""
                TRIPSTATUS = response.tripStatus ?? ""
                WIFIPASS = response.wifiPass ?? ""
                DRIVERLATITUDE = "\(response.driverLatitude ?? "0.0")"
                DRIVERLONGITUDE = "\(response.driverLongitude ?? "0.0")"
                DRIVERBEARING = "\(response.driverBearing ?? "0.0")"
                VEHICLETYPE = response.vehicleType ?? ""
                LIVEFARE = response.liveFare ?? ""
                BASEFARE = response.minimumFare ?? ""
                BASEPRICE = response.basePrice ?? ""
                PERMIN = "\(response.costPerMinute ?? "0.0")"
                PERKM = "\(response.costPerKilometer ?? "0.0")"
                CORPORATECODE = response.corporateID ?? ""
                DISTANCE = response.distance ?? ""
                TIME = response.time ?? ""
                DISTANCETOTALCOST = response.distanceTotalCost ?? ""
                TIMETOTALCOST = response.timeTotalCost ?? ""
                PAYMENTCODES = response.paymentCodes ?? ""
                PAYMENTCOSTS = response.paymentCosts ?? ""
                ET = response.et ?? ""
                ED = response.ed ?? ""
                MESSAGE = response.message ?? ""
                CURRENCY = response.currency ?? ""
                STARTOTP = response.startOTP ?? ""
                ENDOTP = response.endOTP ?? ""
                PARKOTP = response.parkingOTP ?? ""
                CHAT = response.tripChat ?? ""
                
                printVal(object: "ET: \(ET)")
                
                am.saveTRIPSTATUS(data: TRIPSTATUS)
                am.saveWIFIPASS(data: WIFIPASS)
                am.saveDRIVERLATITUDE(data: DRIVERLATITUDE)
                am.saveDRIVERLONGITUDE(data: DRIVERLONGITUDE)
                am.saveDRIVERBEARING(data: DRIVERBEARING)
                am.saveVEHICLETYPE(data: VEHICLETYPE)
                am.savePERMIN(data: PERMIN)
                am.savePERKM(data: PERKM)
                am.saveCORPORATECODE(data: CORPORATECODE)
                am.saveLIVEFARE(data: LIVEFARE)
                am.saveBASEPRICE(data: BASEPRICE)
                am.saveBASEFARE(data: BASEFARE)
                am.saveDISTANCE(data: DISTANCE)
                am.saveTIME(data: TIME)
                am.saveGLOBALCURRENCY(data: CURRENCY)
                am.saveDISTANCETOTALCOST(data: DISTANCETOTALCOST)
                am.saveTIMETOTALCOST(data: TIMETOTALCOST)
                am.savePAYMENTCODES(data: PAYMENTCODES)
                am.savePAYMENTCOSTS(data: PAYMENTCOSTS)
                am.saveET(data: ET)
                am.saveED(data: ED)
                am.saveMESSAGE(data: MESSAGE)
                am.saveStartTripOTP(data: STARTOTP)
                am.saveEndTripOTP(data: ENDOTP)
                am.saveParkingFeeOTP(data: PARKOTP)
                am.saveCHAT(data: CHAT)
                am.savePaymentMode(data: response.paymentMode ?? "")
                
                if STATUS != "000" {
                    am.saveTRIPSTATUS(data: "")
                }
                
                tripDropOffDetails = response.tripDropOffDetails ?? []
                
                if tripDropOffDetails.count > 0 {
                    let stopsArr = tripDropOffDetails.filter({ $0.endedOn == "Y"})
                    var badgeAppearance = BadgeAppearance()
                    badgeAppearance.animate = true
                    badgeAppearance.distanceFromCenterX = 15
                    
                    btnStops.badge(text: "\(stopsArr.count)/\(tripDropOffDetails.count)",appearance: badgeAppearance)
                    btnStops.isHidden = false
                }
                
                loadRequestStatus()
                
            } catch {}
        }
        
    }
    
    @objc func loadRequestStatus() {
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "GETREQUESTSTATUS_NEW"), object: nil)
        
        if am.getCHAT() == "1" && !chatSetUp {
            chatSetUp = true
        }
        
        switch am.getTRIPSTATUS() {
        case "1":
            
            if userLoc != nil {
                gmsMapView.animate(toLocation: userLoc.coordinate)
            }
            
        case "2":
            
            originCoordinate = CLLocationCoordinate2DMake(Double(am.getDRIVERLATITUDE() ?? "0.0") ?? 0, Double(am.getDRIVERLONGITUDE() ?? "0.0") ?? 0)
            updateDriverLocation(coordinates: originCoordinate)
            
            if driverOnWay == false {
                
                if am.getDRIVERLATITUDE() != "" && am.getDRIVERLONGITUDE() != "" {
                    driverLoc = CLLocation(latitude: Double(am.getDRIVERLATITUDE() ?? "0.0") ?? 0, longitude: Double(am.getDRIVERLONGITUDE() ?? "0.0") ?? 0)
                    originCoordinate = CLLocationCoordinate2DMake(Double(am.getDRIVERLATITUDE() ?? "0.0") ?? 0, Double(am.getDRIVERLONGITUDE() ?? "0.0") ?? 0)
                    let bounds = GMSCoordinateBounds(coordinate: originCoordinate, coordinate: destinationCoordinate)
                    gmsMapView.moveCamera(GMSCameraUpdate.fit(bounds, withPadding: 60.0))
                }
                showDriverDetails()
                notificationMessage = "Your ride is on the way."
                UNUserNotificationCenter.current().delegate = self
                // scheduleNotifications()
                driverOnWay = true
            }
            lblPaymentMode.text = am.getPaymentMode()
            lblPaymentModeTrip.text = "\(am.getPaymentMode()?.uppercased() ?? "Cash") TRIP"
            if destinationCoordinate != nil {
                drawPath()
            }
        case "3":
            
            if btnMuteAudio.isHidden == true {
                btnMuteAudio.isHidden = false
            }
            originCoordinate = CLLocationCoordinate2DMake(Double(am.getDRIVERLATITUDE() ?? "0.0") ?? 0, Double(am.getDRIVERLONGITUDE() ?? "0.0") ?? 0)
            updateDriverLocation(coordinates: originCoordinate)
            
            if arrived == false {
                showDriverDetails()
                driverArrived()
                notificationMessage = "Your ride has arrived."
                lblArrivalTime.text = "Your ride has arrived."
                UNUserNotificationCenter.current().delegate = self
                scheduleNotifications()
                arrived = true
            }
            lblPaymentMode.text = am.getPaymentMode()
            lblPaymentModeTrip.text = "\(am.getPaymentMode()?.uppercased() ?? "Cash") TRIP"
            if destinationCoordinate != nil {
                drawPath()
            }
            if doIRing == false {
                btnMuteAudio.setImage(getImage(named: "volume_off", bundle: sdkBundle!), for: .normal)
            } else {
                btnMuteAudio.setImage(getImage(named: "volume_on", bundle: sdkBundle!), for: .normal)
                DispatchQueue.main.async {
                    self.playsound()
                }
            }
        case "4":
            
            if btnMuteAudio.isHidden == false {
                btnMuteAudio.isHidden = true
            }
            
            gmsMapView.isMyLocationEnabled = false
            onTripView.isHidden = false
            lblPaymentMode.text = am.getPaymentMode()
            lblPaymentModeTrip.text = "\(am.getPaymentMode()?.uppercased() ?? "Cash") TRIP"
            if mapcleared == false {
                animatePath = GMSPath()
                gmsMapView.clear()
                mapcleared = true
            }
            
            if tripstart == false {
                
                originMarker = nil
                
                notificationMessage = "Your trip is now in progress."
                UNUserNotificationCenter.current().delegate = self
                scheduleNotifications()
                
                destinationChange = Double(am.getDISTANCE() ?? "0") ?? 0
                if am.getPANICBUTTONSHOW() == "1" {
                    if am.getSOSMESSAGE() != "" {
                        panicBtnTxt.text = am.getSOSMESSAGE()
                        showPanicBtn()
                        panicBtnInfoBtn.setImage(getImage(named: "info", bundle: sdkBundle!), for: .normal)
                    }
                }
                
            }
            
            if originCoordinate != nil {
                if originCoordinate.latitude == (Double(am.getDRIVERLATITUDE() ?? "0.0") ?? 0) &&  originCoordinate.longitude == (Double(am.getDRIVERLONGITUDE() ?? "0.0") ?? 0) {
                    isBrakingCount += 1
                    if isBrakingCount == 4 {
                        isBraking = true
                    }
                } else {
                    isBrakingCount = 0
                    isBraking = false
                }
            }
            
            originCoordinate = CLLocationCoordinate2DMake(Double(am.getDRIVERLATITUDE() ?? "0.0") ?? 0, Double(am.getDRIVERLONGITUDE() ?? "0.0") ?? 0)
            
            updateDriverLocation(coordinates: originCoordinate)
            
            var amount = Double(am.getLIVEFARE() ?? "0")
            if amount == nil {
                amount = 0.0
            }
            
            lblTripCurrency.text = "\(am.getGLOBALCURRENCY()?.capitalized ?? "KES")"
            lblTripCost.text = "\(Int(amount!.roundTo(places: 0)))"
            lblTripDuration.text = "\(am.getTIME() ?? "")"
            let dist = Double(am.getDISTANCE() ?? "0")
            lblDistanceTravelled.text = String(format: "%.2f", dist!)
            
            tripStarted()
            
        case "5":
            
            stopCheckingStatusUpdate()
            notificationMessage = "Your trip has ended."
            UNUserNotificationCenter.current().delegate = self
            scheduleNotifications()
            am.saveOnTrip(data: false)
           
            if let viewController = UIStoryboard(name: "Trip", bundle: sdkBundle!).instantiateViewController(withIdentifier: "ReceiptVC") as? ReceiptVC {
                if let navigator = self.navigationController {
                    viewController.popToRestorationID = popToRestorationID
                    viewController.navShown = navShown
                    viewController.paymentVC = paymentVC
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            
        case "6":
            
            stopCheckingStatusUpdate()
            notificationMessage = "Your trip has ended."
            UNUserNotificationCenter.current().delegate = self
            scheduleNotifications()
            am.saveOnTrip(data: false)
            if let viewController = UIStoryboard(name: "Trip", bundle: sdkBundle!).instantiateViewController(withIdentifier: "TripRatingVC") as? TripRatingVC {
                if let navigator = self.navigationController {
                    viewController.popToRestorationID = popToRestorationID
                    viewController.navShown = navShown
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            
            
        case "7":
            
            stopCheckingStatusUpdate()
            am.saveTRIPID(data: "")
            notificationMessage = "Your trip has ended."
            UNUserNotificationCenter.current().delegate = self
            scheduleNotifications()
            am.saveOnTrip(data: false)
            UIView.animate(withDuration: 1, delay:3, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            }, completion: { finished in
                self.removeAllObservers(array: self.observersArray)
                self.postBackHome()
            })
            
        case "091":
            
            stopCheckingStatusUpdate()
            notificationMessage = "Your trip has ended."
            UNUserNotificationCenter.current().delegate = self
            scheduleNotifications()
            
            NotificationCenter.default.addObserver(self, selector: #selector(loadCancelRate(_:)),name:NSNotification.Name(rawValue: "RATECANCEL"), object: nil)
            
            let popOverVC = UIStoryboard(name: "Trip", bundle: sdkBundle!).instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
            self.addChild(popOverVC)
            popOverVC.driverName = am.getDRIVERNAME() ?? ""
            popOverVC.driverImage = am.getDRIVERPICTURE()
            popOverVC.view.frame = UIScreen.main.bounds
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParent: self)
            
        default:
            
            stopCheckingStatusUpdate()
            am.saveTRIPID(data: "")
            am.saveOnTrip(data: false)
            
            UIView.animate(withDuration: 1, delay:3, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            }, completion: { finished in
                self.removeAllObservers(array: self.observersArray)
                self.postBackHome()
            })

        }
        
        removeLoadingPage()
    }
    
    
    func submitDriverRate(message: String, rating: String) {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadRate),name:NSNotification.Name(rawValue: "RATEJSONData"), object: nil)
        
        let dataToSend = "{\"FormID\":\"RATE\"\(commonCallParams()),\"RateAgent\":{\"DriverEmail\":\"\(am.getDRIVEREMAIL() ?? "")\",\"DriverMobileNumber\":\"\(am.getDRIVERMOBILE() ?? "")\",\"Rating\":\"\(rating)\",\"TripID\":\"\(am.getTRIPID() ?? "")\",\"Comments\":\"\(message)\"}}"
        
        printVal(object: dataToSend)
        
        hc.makeServerCall(sb: dataToSend, method: "RATEJSONData", switchnum: 0)
        
        
    }
    
    @objc func loadRate(_ notification: NSNotification) {
        
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name(rawValue: "RATEJSONData"), object: nil)
        
        am.saveOnTrip(data: false)
        am.saveTRIPID(data: "")
        
        UIView.animate(withDuration: 1, delay:3, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
        }, completion: { finished in
            self.removeAllObservers(array: self.observersArray)
            self.postBackHome()
        })
    }
    
    @objc func loadCancelRate(_ notification: Notification) {
        
        let data = notification.userInfo!["data"] as! String
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "RATECANCEL"), object: nil)
        
        if data.components(separatedBy: ":::").count > 1 {
            let message = data.components(separatedBy: ":::")[1]
            let rating = data.components(separatedBy: ":::")[0]
            
            submitDriverRate(message: message, rating: rating)
            
        } else {
            
            am.saveOnTrip(data: false)
            am.saveTRIPID(data: "")
            
            UIView.animate(withDuration: 1, delay:3, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
            }, completion: { finished in
                self.removeAllObservers(array: self.observersArray)
                self.postBackHome()
            })
        }
        
    }
    
    
    func playsound() {
        
        let url = NSURL(fileURLWithPath: path)
        
        do{
            
            audioPlayer = try AVAudioPlayer(contentsOf: url as URL)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
        }catch let error as NSError{
            printVal(object: error)
        }
    }
    
    func tripStarted() {
        
        if am.getED() != "" {
            destinationTotal = Double(am.getED()) ?? 0
        } else {
            destinationTotal = 10.0
        }
        
        if destinationChange >= destinationTotal {
            
            UIView.animate(withDuration: 1, delay:0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
                self.progressSlider.value = Float(100)
                self.view.layoutIfNeeded()
            }, completion: nil)
            
        } else {
            UIView.animate(withDuration: 0.5, delay:0, options:UIView.AnimationOptions.transitionFlipFromTop, animations: {
                self.progressSlider.value = Float(self.destinationChange/self.destinationTotal*100)
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        
        
        if am.getET() != "" {
            lblETA.isHidden = false
            
            let now = NSDate()
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
            dateFormatter.dateFormat = "HH:mm"
            
            let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
            let offsetComponents = NSDateComponents()
            offsetComponents.minute = Int("\(am.getET() ?? "0")") ?? 0
            let eta = gregorian!.date(byAdding: offsetComponents as DateComponents, to: now as Date, options: []) ?? Date()
            let strTime = dateFormatter.string(from: eta as Date)
            printVal(object: "myETA: \(am.getET() ?? "")")
            
            lblETA.text = "ETA: \(strTime) Hrs"
        }
        
        gmsMapView.isBuildingsEnabled = true
        gmsMapView.settings.tiltGestures = false
        gmsMapView.settings.rotateGestures = false
        
        driverLoc = CLLocation(latitude: Double(am.getDRIVERLATITUDE() ?? "0.0") ?? 0, longitude: Double(am.getDRIVERLONGITUDE() ?? "0.0") ?? 0)
        
        // driverLoc.coordinate.latitude
        
        if !tripstart {
            let camera = GMSCameraPosition.camera(withLatitude: driverLoc.coordinate.latitude,
                                                  longitude: driverLoc.coordinate.longitude,
                                                  zoom: 18,
                                                  bearing: CLLocationDegrees(am.getDRIVERBEARING() ?? "0") ?? 0,
                                                  viewingAngle: 60)
            gmsMapView.animate(to: camera)
            tripstart = true
        } else {
            CATransaction.begin()
            CATransaction.setValue(6.0, forKey: kCATransactionAnimationDuration)
            gmsMapView.animate(toBearing: CLLocationDegrees(am.getDRIVERBEARING() ?? "0") ?? 0)
            gmsMapView.animate(toLocation: driverLoc.coordinate)
            CATransaction.commit()
        }
        
        // gmsMapView.animate(toBearing: CLLocationDegrees(am.getDRIVERBEARING() ?? "0") ?? 0)
        
        //cashCentre
    }
    
    func driverArrived() {
        originCoordinate = CLLocationCoordinate2DMake(Double(am.getDRIVERLATITUDE() ?? "0.0") ?? 0, Double(am.getDRIVERLONGITUDE() ?? "0.0") ?? 0)
        // driverNameLbl.text = "\(am.getDRIVERNAME()?.capitalized ?? "") has arrived."
    }
    
    func showDriverDetails() {
        
        imgDriverPic.sd_setImage(with: URL(string: am.getDRIVERPICTURE()), placeholderImage: getImage(named: "default", bundle: sdkBundle!))
        imgCarType.sd_setImage(with: URL(string: am.getVEHICLEIMAGE()), placeholderImage: getImage(named: am.getVEHICLETYPE(), bundle: sdkBundle!))
        let amount = Double(am.getRATING() ?? "0")
        if amount != nil {
            lblRating.text = String(format: "%.1f", amount!)
        } else {
            lblRating.text = ""
        }
        
        if am.getMESSAGE() != "" {
            lblCorporatePromo.isHidden = true
            lblCorporatePromoName.isHidden = false
            lblCorporatePromoName2.isHidden = false
            lblCorporatePromoName.text = am.getMESSAGE()
            lblCorporatePromoName2.text = am.getMESSAGE()
        } else {
            lblCorporatePromo.isHidden = true
            lblCorporatePromoName.isHidden = true
            lblCorporatePromoName2.isHidden = true
        }
        
        viewTripAT.isHidden = false
        lblTripAt.text = am.getPERKM()
        
        lblCarModelColor.text = "\(am.getMODEL()?.capitalized ??  "") - \(am.getCOLOR()?.capitalized ?? "0")"
        lblPlateNumber.text = "\(am.getNUMBER()?.uppercased() ?? "")"
        lblDriverName.text = "\(am.getDRIVERNAME()?.capitalized ?? "")"
        lblYouAreDrivenBy.text = "You are being driven by \(am.getDRIVERNAME()?.capitalized ?? "")"
        printVal(object: "timeAr: \(am.getET() ?? "")")
        if let et = am.getET() {
            if let min = Double(et), min >= 1 {
                lblArrivalTime.text = "ETA \(String(format: "%.0f", et))mins."
            } else {
                lblArrivalTime.text = "ETA 0mins."
            }
        } else {
            lblArrivalTime.text = "ETA 0mins."
        }
        lblPaymentMode.text = "\(am.getPaymentMode() ?? "Cash")"
        lblPaymentModeTrip.text = "\(am.getPaymentMode()?.uppercased() ?? "Cash") TRIP"
        
        
    }
    
    func updateDriverLocation(coordinates: CLLocationCoordinate2D) {
        
        if am.getStartTripOTP() != "" {
            lblStartTripCode.text = am.getStartTripOTP()
            lblStartTripLabel.isHidden = false
            lblStartTripCode.isHidden = false
            btnStartTripHint.isHidden = false
            imgStartTripHint.isHidden = false
        }
        if am.getEndTripOTP() != "" {
            lblEndTripCode.text = am.getEndTripOTP()
            lblEndTripLabel.isHidden = false
            lblEndTripCode.isHidden = false
            btnEndTripHint.isHidden = false
            imgEndTripHint.isHidden = false
        }
        
        if am.getParkingFeeOTP() != "" {
            lblParkingCode.text = am.getParkingFeeOTP()
            lblParkingLabel.isHidden = false
            lblParkingCode.isHidden = false
            btnParkingHint.isHidden = false
            imgParkingHint.isHidden = false
        }
        
        if originMarker == nil
        {
            originMarker = GMSMarker()
            originMarker.position = coordinates
            if am.getTRIPSTATUS() != "4" {
                if am.getDRIVERBEARING() != "" {
                    originMarker.rotation = CLLocationDegrees(am.getDRIVERBEARING() ?? "0") ?? 0
                }
                
                var imageName = ""
                
                if am.getVEHICLETYPE()?.replacingOccurrences(of: " ", with: "").lowercased() == "littleboda" {
                    imageName = "BodaNew1"
                } else {
                    imageName = "ComfortNew1"
                }
                
                let image = getImage(named: imageName, bundle: sdkBundle!)
                originMarker.icon = scaleImage(image: image!,size: 0.08)
            } else {
                originMarker.rotation = CLLocationDegrees(0.0)
                let image = getImage(named: "Map_Car", bundle: sdkBundle!)
                originMarker.appearAnimation = .pop
                originMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                originMarker.tracksViewChanges = true
                originMarker.icon = scaleImage(image: image!,size: 0.7)
                
                if am.getDRIVERBEARING() != "" {
                    // originMarker.rotation = CLLocationDegrees(am.getDRIVERBEARING() ?? 0) ?? CLLocationDegrees("0")
                }
            }
            originMarker.title = "My Ride"
            originMarker.map = gmsMapView
            originMarker.appearAnimation = GMSMarkerAnimation.pop
        }
        else
        {
            CATransaction.begin()
            CATransaction.setAnimationDuration(6.0)
            if am.getTRIPSTATUS() != "4" {
                if am.getDRIVERBEARING() != "" {
                    originMarker.rotation = CLLocationDegrees(am.getDRIVERBEARING() ?? "0") ?? 0
                }
            } else {
                var imageName = ""
                
                if am.getVEHICLETYPE()?.replacingOccurrences(of: " ", with: "").lowercased() == "littleboda" {
                    if isBraking {
                        imageName = "Map_Boda2"
                    } else {
                        imageName = "Map_Boda"
                    }
                } else {
                    if isBraking {
                        imageName = "Map_Car2"
                    } else {
                        imageName = "Map_Car"
                    }
                }
                
                let image = getImage(named: imageName, bundle: sdkBundle!)
                originMarker.rotation = CLLocationDegrees(0.0)
                originMarker.icon = scaleImage(image: image!,size: 0.7)
            }
            originMarker.position =  coordinates
            CATransaction.commit()
        }
    }
    
    func updateMyLocation(coordinates:CLLocationCoordinate2D) {
        if destinationMarker == nil
        {
            destinationMarker = GMSMarker()
            destinationMarker.position = coordinates
            destinationMarker.title = "Me"
            destinationMarker.icon = GMSMarker.markerImage(with: UIColor(hex: "3090FE"))
            destinationMarker.map = gmsMapView
            destinationMarker.appearAnimation = GMSMarkerAnimation.pop
        }
        else
        {
            CATransaction.begin()
            CATransaction.setAnimationDuration(1.0)
            destinationMarker.position =  coordinates
            CATransaction.commit()
        }
    }
    
    func muteAudio() {
        if doIRing {
            doIRing=false
            btnMuteAudio.setImage(getImage(named: "volume_off", bundle: sdkBundle!), for: .normal)
        }else{
            doIRing=true
            btnMuteAudio.setImage(getImage(named: "volume_on", bundle: sdkBundle!), for: .normal)
        }
    }
    
    func cancelRide() {
        let cancelOptions = UIAlertController(title: nil, message: "Reason for cancelling", preferredStyle: .actionSheet)
        let normalColor = SDKConstants.littleSDKThemeColor
        for reason in reasonsArr {
            let reasonBtn = UIAlertAction(title: reason, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                if reason != "Other" {
                    self.cancelReason = reason
                    self.cancelTrip()
                } else {
                    self.enterOtherReason()
                }
            })
            reasonBtn.setValue(normalColor, forKey: "titleTextColor")
            cancelOptions.addAction(reasonBtn)
        }
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.cancelReason = ""
        })
        
        cancelOptions.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            cancelOptions.popoverPresentationController?.sourceView = self.btnMuteAudio
            cancelOptions.popoverPresentationController?.sourceRect = CGRect(x: self.btnMuteAudio.bounds.size.width / 2.0, y: self.btnMuteAudio.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        DispatchQueue.main.async {self.present(cancelOptions, animated: true, completion: nil)}
        
    }
    
    func enterOtherReason() {
        
        let view: PopoverEnterText = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "", message: "\nType reason for cancelling trip.\n", image: "", placeholderText: "Type Reason", type: "")
        view.proceedAction = {
           SwiftMessages.hide()
            if view.txtPopupText.text != "" {
                self.cancelReason = view.txtPopupText.text!
                self.cancelTrip()
           } else {
               self.showAlerts(title: "",message: "Reason required.")
           }
        }
        view.cancelAction = {
            SwiftMessages.hide()
            self.cancelReason = ""
        }
        view.btnProceed.setTitle("Cancel Trip", for: .normal)
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func drawPath() {
        goLocal()
//       if am.getCountry()?.uppercased() == "KENYA" {
//            goLocal()
//       } else {
//            goGoogle()
//        }
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
                        let directionURL = "https://maps.little.bz/api/direction/full?origin=\(origin)&destination=\(destination)&key=\(am.DecryptDataKC(DataToSend: cn.littleMapKey))"

                        guard let url = URL(string: directionURL) else { return }
                        
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            if error != nil {
//                                self.goGoogle()
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
                                } catch let error as NSError {
//                                    self.goGoogle()
                                    // printVal(object: error)
                                }
                            }
        
                        }.resume()
                    }
        }
    }
    
    func configureMapAndMarkersForRoute() {
        
        updateDriverLocation(coordinates: originCoordinate)
        updateMyLocation(coordinates: destinationCoordinate)
        
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
    
    // MARK: - IBOutlet Functions
    
    
    @IBAction func btnChatWithDriverPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func muteBtnPressed(_ sender: UIButton) {
        muteAudio()
    }
    
    @IBAction func callBtnPressed(_ sender: UIButton) {
        var number = am.getDRIVERMOBILE() ?? ""
        if number != "" {
            number="+"+number
            guard let url = URL(string: "telprompt://\(number)") else {
              return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        cancelRide()
    }
    
    @IBAction func homeInBtnPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func panicBtnInfoPressed(_ sender: UIButton) {
        if panicBtnInfoView.isHidden == true {
            panicBtnInfoView.isHidden = false
            panicBtnInfoBtn.setImage(getImage(named: "cancel", bundle: sdkBundle!), for: .normal)
        } else {
            panicBtnInfoView.isHidden = true
            panicBtnInfoBtn.setImage(getImage(named: "info", bundle: sdkBundle!), for: .normal)
        }
    }
    
    
    @IBAction func panicButtonPressed(_ sender: UIButton) {
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "", message: "\nWould you like to send a distress call to authorities near you?\n", image: "", action: "")
        view.proceedAction = {
           SwiftMessages.hide()
           self.panicButtonCall()
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
    
    @IBAction func sambazaTripBtn(_ sender: UIButton) {
        
        if am.getVIEWID() == "" {
            am.saveVIEWID(data: String(am.getTRIPID()?.prefix(5) ?? ""))
        }
        
        let firstActivityItem = "Take a look at my ride with LittleCab\r\n https://little.bz/app/route/?id="+(am.getVIEWID() ?? "")+"\r\nOR view a trip on your Little App with ID \(am.getVIEWID() ?? "")"
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            activityViewController.popoverPresentationController?.sourceView = (sender as UIButton?)
        }
        
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        DispatchQueue.main.async {self.present(activityViewController, animated: true, completion: nil)}
        
        
        
    }
    
    @IBAction func btnStopsPressed(_ sender: UIButton) {
        let controller = ShowTripStopsController()
        controller.tripDropOffDetails = tripDropOffDetails
        present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }
    
    @IBAction func btnStartTripPressed(_ sender: UIButton) {
        showMessageOTP(title: "Start Trip Code: \(am.getStartTripOTP() ?? "")", message: "A start trip code will be required by \(am.getDRIVERNAME()?.capitalized ?? ""), your driver, to start this trip. Kindly provide him the code: \(am.getEndTripOTP() ?? "") so as to start the trip.")
    }
    
    @IBAction func btnEndTripPressed(_ sender: UIButton) {
        showMessageOTP(title: "End Trip Code: \(am.getEndTripOTP() ?? "")", message: "An end trip code will be requested by \(am.getDRIVERNAME()?.capitalized ?? ""), your driver, in order to successfully END your trip. Please note that this code changes after every KM and only give to driver if he is ending at the right destination.")
    }
    
    @IBAction func btnParkingPressed(_ sender: UIButton) {
        showMessageOTP(title: "Parking Fee Code: \(am.getParkingFeeOTP() ?? "")", message: "Kindly give the driver this code ONLY if a parking fee charge was incurred at any particular point during this trip. Also make sure the amount is right.")
    }
    
    func showMessageOTP(title: String, message: String) {
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: title, message: "\n\(message)\n", image: "", action: "")
        view.proceedAction = {
            SwiftMessages.hide()
        }
        view.btnProceed.setTitle("Dismiss", for: .normal)
        view.btnDismiss.isHidden = true
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
    }
}

extension TripVC: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if CLLocationManager.locationServicesEnabled() {
            
            switch(CLLocationManager.authorizationStatus()) {
                
            case .restricted, .denied:
                
                printVal(object: "No access: Restricted/Denied")
                showDriverDetails()
                getTripStatus()
                startCheckingStatusUpdate()
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
                
            }
        } else {
            showDriverDetails()
            getTripStatus()
            startCheckingStatusUpdate()
            allowLocationAccessMessage()
        }
        
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        if manager.location != nil {
            
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            self.userLoc = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            self.destinationCoordinate = manager.location!.coordinate
            // let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 16)
            self.gmsMapView.isTrafficEnabled=true
            self.gmsMapView.settings.compassButton = true
            
            self.showDriverDetails()
            self.getTripStatus()
            self.startCheckingStatusUpdate()
            
            
        } else {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        
        
    }
}

extension TripVC: GMSMapViewDelegate{
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

extension TripVC: UNUserNotificationCenterDelegate {
    
    //for displaying notification when app is in foreground
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //If you don't want to show notification when app is open, do something here else and make a return here.
        //Even you you don't implement this delegate method, you will not see the notification on the specified controller. So, you have to implement this delegate and make sure the below line execute. i.e. completionHandler.
        
        completionHandler([.alert,.badge])
    }
    
    // For handling tap and user actions
    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "action1":
            printVal(object: "Action First Tapped")
        case "action2":
            printVal(object: "Action Second Tapped")
        default:
            break
        }
        completionHandler()
    }
    
}
