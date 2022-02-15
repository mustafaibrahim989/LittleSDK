//
//  LittleRideVC.swift
//  Little
//
//  Created by Gabriel John on 16/07/2019.
//  Copyright © 2019 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import MessageUI
import UserNotifications
import LocalAuthentication
import StoreKit
import SwiftMessages
import Alamofire

class LittleRideVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // Constants
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    let cn = SDKConstants()
    var tapGestureRecognizer = UITapGestureRecognizer()
    
    // Variables
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    var sdkBundle: Bundle?
    
    // yPositions
    
    var yPositionDestinationOriginal: CGFloat?
    var yPositionDestinationOpen: CGFloat?
    var yPositionFareOriginal: CGFloat?
    var yPositionFareOpen: CGFloat?
    var yPositionParcelOriginal: CGFloat?
    var yPositionParcelOpen: CGFloat?
    var yPositionDriveMeOriginal: CGFloat?
    var yPositionDriveMeOpen: CGFloat?
    var yPositionConfirmOriginal: CGFloat?
    var yPositionConfirmOpen: CGFloat?
    
    // Rand
    
    var topSafeAreaConst: CGFloat = 0.0
    var bottomSafeAreaConst: CGFloat = 0.0
    
    var DestinationsArr: [String]?
    var SuggestionsArr: [String]?
    
    var locationTitleArr: [String] = ["Add Home","Add Work"]
    var locationSubTitleArr: [String] = ["",""]
    var locationCoordsArr: [String] = ["",""]
    
    // Preferred Drivers
    
    var preferredDriversArr=[ListPreferredDriver]()
    
    private var finishedLoadingInitialTableCells = false
    
    var buttonTag: Int = 0
    var buttpressed: String = ""
    var originAddress: String!
    var originLL: String = ""
    var destinationAddress: String!
    var destinationLL: String = "0.0,0.0"
    var pickupName: String = ""
    var dropOffName: String = " "
    
    var fareEstimateIndex: Int = 0
    var carTypeCount: Int = 0
    var travelReason: String = ""
    var forwardCount: Int = 0
    var forwardSkipDrivers: String = ""
    
    var stage: String = "Destination"
    
    var pathShowing: Bool = false
    var revealed: Bool = false
    var alreadyPushed: Bool = false
    var isGettingTypes: Bool = false
    var isLoadingPendingRequests: Bool = false
    var firstTryCartypes: Bool = false
    var secondTry: Bool = true
    var isMainTabUp: Bool = true
    var preferredDriver: Bool = false
    var mappingCorporate: Bool = false
    var approvedSelected: Bool = false
    var isCorporate: Bool = false
    var yPositionsSet: Bool = false
    var isLocal: Bool = false
    var isManual: Bool = false
    var isToReload: Bool = false
    var isCancellingRequest: Bool = false
    
    var IDType: String = ""
    var carCorporateSelected: String = ""
    
    var observersArray: [String] = []
    
    var PaymentModes: [String] = []
    var PaymentModeIDs: [String] = []
    var selectedPaymentMode: Int = 0
    var PaymentMode = "Cash"
    var PaymentModeID = "CASH"
    
    var confirmBtn = "Payments"
    
    var makeRequestDefaultMessage = ""
    var parcelSize = "SMALL"
    
    var listDriver = [LittleDriver]()
    
    var returnTrip = 0
    
    var flySaveDetails = ""
    
    // Route Variables
    
    var totalTime: String!
    var originMarker: GMSMarker!
    var destinationMarker: GMSMarker!
    var routePolyline: GMSPolyline!
    var nearDriverMarker = [Int: GMSMarker]()
    var animationPolyline = GMSPolyline()
    var animationPath = GMSMutablePath()
    var path = GMSPath()
    
    // Map Variables
    
    var gmsMapView: GMSMapView!
    var marker: GMSMarker!
    var centerMapCoordinate: CLLocationCoordinate2D!
    
    // Promo Variables
    
    var promoText: String = ""
    var promoVerified: Bool = false
    
    // Timer Variables
    
    var timer:Timer!
    var isContinueRequest = false
    var i: UInt = 0
    var animatetimer: Timer!
    var providertimer: Timer!
    
    // Location Variables
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var zoomLevel: Float = 15.5
    var initialPlaceName: String!
    var currentPlaceName: String?
    var dropOffPlaceName: String!
    var initialPlaceCoordinates: CLLocationCoordinate2D!
    var currentPlaceCoordinates: CLLocationCoordinate2D!
    var dropOffCoordinates: CLLocationCoordinate2D!
    
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var selectedRoute: Dictionary<String, AnyObject>!
    var overviewPolyline: Dictionary<String, AnyObject>!
    
    var overviewPolylineString: String!
    
    var myOrigin: CLLocation!
    var myDestination: CLLocation!
    
    // Cartype Variables
    var selectedCarIndex: Int = 0
    var selectedDriveMeIndex: Int = 0
    var selectedDriveMeSecIndex: Int = 0
    var CarTypes: [String] = []
    var SubVehicleTypes: [String] = []
    var carCostEstimate: [String] = []
    var carCurrency: [String] = []
    var carOldTripCost: [String] = []
    var carActiveIcons: [String] = []
    var carInActiveIcons: [String] = []
    var carVTypeTimes: [String] = []
    var carMinFares: [String] = []
    var carBaseFares: [String] = []
    var carPerKms: [String] = []
    var carPerMins: [String] = []
    var carMaxPasss: [String] = []
    var carTypeModeCount: Int = 0
    var carTypePriceEstimate: [String] = []
    var carVehicleCategory: [String] = []
    var driveMeTypes: [FareEstimate_Base] = []
    var carisNew: [String] = []
    var carBannerImage: [String] = []
    var carBannerText: [String] = []
    
    var bbox: [Double] = []
    
    var locationsEstimateSet: LocationsEstimateSetSDK?
    var locationStopsArr: [LocationSetSDK] = []
    
    //
    
    var reasonTest: String = ""
    var makerChecker: Bool = false
    var presentingActionSheets = false
    var isGift = true
    var isUAT = false
    
    // Corporate Variables
    
    var CC = ""
    var CN = ""
    var CorporateTripID = ""
    
    // Colors
    
    var littleBlue: UIColor?
    var littleGreen: UIColor?
    var littleRed: UIColor?
    
    
    var paymentVC: UIViewController?
    
    // IBOutlets
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var profilePicView: UIView!
    
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var approxDestinationTimeView: UIView!
    @IBOutlet weak var testingView: UIView!
    @IBOutlet weak var informationTopView: UIView!
    @IBOutlet weak var coverView: UIView!
    
    @IBOutlet weak var approxMinsLbl: UILabel!
    @IBOutlet weak var mapBottomConstant: NSLayoutConstraint!
    
    @IBOutlet weak var btnDestinationInformation: UIButton!
    @IBOutlet weak var btnPickupInformation: UIButton!
    @IBOutlet weak var btnBackStage: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var cardViewController: CardViewController!
    var visualEffectView: UIVisualEffectView!
    
    var cardHeight: CGFloat = 700
    var cardHandleAreaHeight: CGFloat = 200
    
    var cardVisible = false
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle(for: Self.self)
        
        setupCard()
        setupObservers()
        initAppSetup()
        buttonSetup()
        initAppMap()
        adjustMapBottomConst()
        proceedToLoadApp()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        reloadLocations()
        
        if am.getFromSearch() {
            am.saveFromSearch(data: false)
        } else {
            if isToReload {
                isToReload = false
                toReload()
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        gmsMapView.isUserInteractionEnabled = true
        forwardSkipDrivers = ""
        getUserImage(userImage: profilePic, bundle: sdkBundle!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if providertimer != nil {
            providertimer.invalidate()
        }
        if animatetimer != nil {
            animatetimer.invalidate()
        }
        if timer != nil {
            timer.invalidate()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !yPositionsSet {
            yPositionsSet = true
            if #available(iOS 11.0, *) {
                let window = UIApplication.shared.keyWindow
                topSafeAreaConst = window?.safeAreaInsets.top ?? 40
                bottomSafeAreaConst = window?.safeAreaInsets.bottom ?? 50
            } else {
                topSafeAreaConst = topLayoutGuide.length
                bottomSafeAreaConst = bottomLayoutGuide.length
            }
            topSafeAreaConst = 0
            bottomSafeAreaConst = 0
            
            printVal(object: "topSafeArea: \(topSafeAreaConst)")
            printVal(object: "bottomSafeArea: \(bottomSafeAreaConst)")
            
            if getPhoneFaceIdType() {
                yPositionDestinationOriginal = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 225)
            } else {
                yPositionDestinationOriginal = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 200)
            }
            
            let diff = CGFloat((250 + (50 * DestinationsArr!.count)))
            let max = self.view.frame.height - (topSafeAreaConst + bottomSafeAreaConst)
            
            if (max - diff) > 130 {
                yPositionDestinationOpen = max - diff
            } else {
                yPositionDestinationOpen = 130
            }
            
            cardHeight = view.frame.height - yPositionDestinationOpen!
            if yPositionDestinationOpen! >= yPositionDestinationOriginal! {
                cardHandleAreaHeight = view.frame.height - yPositionDestinationOpen!
            } else {
                cardHandleAreaHeight = view.frame.height - yPositionDestinationOriginal!
            }
            
            if getPhoneFaceIdType() {
                yPositionParcelOriginal = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 555))
                yPositionParcelOpen = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 545))
                yPositionDriveMeOriginal = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 445))
                yPositionDriveMeOpen = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 455))
                yPositionConfirmOriginal = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 300))
                yPositionConfirmOpen = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 425))
            } else {
                yPositionParcelOriginal = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 530))
                yPositionParcelOpen = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 540))
                yPositionDriveMeOriginal = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 420))
                yPositionDriveMeOpen = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 430))
                yPositionConfirmOriginal = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 275))
                yPositionConfirmOpen = (view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 400))
            }
            
            
        }
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            let hasUserInterfaceStyleChanged = previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false
            if hasUserInterfaceStyleChanged {
                if gmsMapView != nil {
                    gmsMapView.showMapStyleForView()
                }
            }
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // Setup Functions
    
    func setupCard() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topSafeAreaConst = window?.safeAreaInsets.top ?? 40
            bottomSafeAreaConst = window?.safeAreaInsets.bottom ?? 50
        } else {
            topSafeAreaConst = topLayoutGuide.length
            bottomSafeAreaConst = bottomLayoutGuide.length
        }
        
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        
        let cardViewBundle = Bundle(for: LittleRideVC.self)
        
        cardViewController = CardViewController(nibName:"CardViewController", bundle: cardViewBundle)
        self.addChild(cardViewController)
        self.view.addSubview(cardViewController.view)
        
        visualEffectView.isHidden = true
        
        if getPhoneFaceIdType() {
            cardHandleAreaHeight = cardHandleAreaHeight - 55
        } else {
            cardHandleAreaHeight = cardHandleAreaHeight - 20
        }
        
        cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - (cardHandleAreaHeight + topSafeAreaConst + bottomSafeAreaConst), width: self.view.bounds.width, height: cardHeight)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCardTap(_:)))
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleCardPan(_:)))
        
        cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
        cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    func setupObservers() {
        observersArray = ["CLOSEPROMO","REFRESHFROMSLEEP"]
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadclosepromo),name:NSNotification.Name(rawValue: "CLOSEPROMO"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fromSleep),name:NSNotification.Name(rawValue: "REFRESHFROMSLEEP"), object: nil)
        
        
    }
    
    func initAppSetup() {
        if am.getSessionToken() == "" {
            let unique_id = NSUUID().uuidString
            am.saveSessionToken(data: unique_id.replacingOccurrences(of: "-", with: ""))
        }
        
        self.profilePic.isHidden = true
        self.menuBtn.imageEdgeInsets = UIEdgeInsets.init(top: 3,left: 3,bottom: 3,right: 3)
        self.menuBtn.addTarget(self, action: #selector(postBackHome), for: .touchUpInside)
        self.menuBtn.setImage(getImage(named: "back_super_app", bundle: sdkBundle!), for: UIControl.State())
        
        
        approxDestinationTimeView.isHidden = true
        
        let font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17.0)!
        cardViewController.btnDestination.titleLabel?.font =  font
        cardViewController.btnDestination.setTitle("Where do you want to go \(am.getFullName()?.components(separatedBy: " ")[0].capitalized ?? "")?", for: UIControl.State())
        btnDestinationInformation.setTitle("", for: UIControl.State())
        
        cardViewController.requestingViewConstraint.constant = 180
        
        cardViewController.txtParcelName.delegate = self
        cardViewController.txtReceiversName.delegate = self
        cardViewController.txtReceiversNumber.delegate = self
        cardViewController.txtReceiversAddress.delegate = self
        
        cardViewController.carTypeTableView.delegate = self
        cardViewController.paymentOptionsTableView.delegate = self
        cardViewController.preferredDriverTableView.delegate = self
        cardViewController.suggestedPlacesCollectionView.delegate = self
        cardViewController.driveMeCarsCollectionView.delegate = self
        cardViewController.popularDropOffTable.delegate = self
        
        cardViewController.carTypeTableView.dataSource = self
        cardViewController.paymentOptionsTableView.dataSource = self
        cardViewController.preferredDriverTableView.dataSource = self
        cardViewController.suggestedPlacesCollectionView.dataSource = self
        cardViewController.driveMeCarsCollectionView.dataSource = self
        cardViewController.popularDropOffTable.dataSource = self
        
        let cellBundle = Bundle(for: LittleRideVC.self)
        
        let nib = UINib.init(nibName: "NewCartypeTableViewCell", bundle: cellBundle)
        cardViewController.carTypeTableView.register(nib, forCellReuseIdentifier: "cell")
        
        let nib2 = UINib.init(nibName: "NewImgLblTableViewCell", bundle: cellBundle)
        cardViewController.paymentOptionsTableView.register(nib2, forCellReuseIdentifier: "cell")
        
        let nib3 = UINib.init(nibName: "NewPreferredTableViewCell", bundle: cellBundle)
        cardViewController.preferredDriverTableView.register(nib3, forCellReuseIdentifier: "cell")
        
        let nib4 = UINib.init(nibName: "PlaceSuggestionCell", bundle: cellBundle)
        cardViewController.suggestedPlacesCollectionView.register(nib4, forCellWithReuseIdentifier: "cell")
        
        let nib5 = UINib.init(nibName: "DestinationCell", bundle: cellBundle)
        cardViewController.popularDropOffTable.register(nib5, forCellReuseIdentifier: "cell")
        
        let nib6 = UINib.init(nibName: "DriveMeCell", bundle: cellBundle)
        cardViewController.driveMeCarsCollectionView.register(nib6, forCellWithReuseIdentifier: "cell")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backToCarTypes))
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(backToCarTypes))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(tapCancelRideRequest))
        
        cardViewController.imgParcelCartype.addGestureRecognizer(tap1)
        cardViewController.requestingLoadingView.addGestureRecognizer(tap3)
        cardViewController.viewCarToRequest.addGestureRecognizer(tap)
        
        cardViewController.requestingLoadingView.isUserInteractionEnabled = false
        
        // Setup Recent Locations
        
        reloadLocations()
        
        // Setup Buttons
        
        cardViewController.btnPickup.titleLabel?.minimumScaleFactor = 0.5
        cardViewController.btnPickup.titleLabel?.numberOfLines = 1
        cardViewController.btnPickup.titleLabel?.adjustsFontSizeToFitWidth = true
        
        cardViewController.btnDestination.titleLabel?.minimumScaleFactor = 0.5
        cardViewController.btnDestination.titleLabel?.numberOfLines = 1
        cardViewController.btnDestination.titleLabel?.adjustsFontSizeToFitWidth = true
        
        btnPickupInformation.titleLabel?.minimumScaleFactor = 0.5
        btnPickupInformation.titleLabel?.numberOfLines = 1
        btnPickupInformation.titleLabel?.adjustsFontSizeToFitWidth = true
        
        btnDestinationInformation.titleLabel?.minimumScaleFactor = 0.5
        btnDestinationInformation.titleLabel?.numberOfLines = 1
        btnDestinationInformation.titleLabel?.adjustsFontSizeToFitWidth = true
        
        cardViewController.btnCorporateDepartment.titleLabel?.minimumScaleFactor = 0.5
        cardViewController.btnCorporateDepartment.titleLabel?.numberOfLines = 1
        cardViewController.btnCorporateDepartment.titleLabel?.adjustsFontSizeToFitWidth = true
        
        //
        
        littleBlue = cn.littleSDKThemeColor
       
    }
    
    func buttonSetup() {
        
        cardViewController.btnPickup.addTarget(self, action: #selector(btnPickupPressed(_:)), for: .touchUpInside)
        cardViewController.btnDestination.addTarget(self, action: #selector(btnDestinationPressed(_:)), for: .touchUpInside)
        cardViewController.btnPickupCancel.addTarget(self, action: #selector(btnPickupPressed(_:)), for: .touchUpInside)
        cardViewController.btnPayment.addTarget(self, action: #selector(btnPaymentsPressed(_:)), for: .touchUpInside)
        cardViewController.btnPromoCode.addTarget(self, action: #selector(btnPromoCodePressed(_:)), for: .touchUpInside)
        cardViewController.btnPreferredDriver.addTarget(self, action: #selector(btnPreferredDriverPressed(_:)), for: .touchUpInside)
        // cardViewController.indiviCorporateSeg.addTarget(self, action: #selector(individualCorporateToggle(_:)), for: .valueChanged)
        cardViewController.transmissionTypeSeg.addTarget(self, action: #selector(driveMeToggle(_:)), for: .valueChanged)
        // cardViewController.btnCorporateDepartment.addTarget(self, action: #selector(btnCorporateChoices(_:)), for: .touchUpInside)
        // cardViewController.btnSubmitToApprover.addTarget(self, action: #selector(btnSubmitToApproverPressed(_:)), for: .touchUpInside)
        cardViewController.btnRequest.addTarget(self, action: #selector(requestRideBtnPressed(_:)), for: .touchUpInside)
        cardViewController.btnValidatePromo.addTarget(self, action: #selector(btnAddPromoTextPressed(_:)), for: .touchUpInside)
        cardViewController.btnAddPromoText.addTarget(self, action: #selector(btnAddPromoTextPressed(_:)), for: .touchUpInside)
        cardViewController.btnCancelDestination.addTarget(self, action: #selector(btnRemoveDestination(_:)), for: .touchUpInside)
        cardViewController.btnSearchDestination.addTarget(self, action: #selector(btnDestinationPressed(_:)), for: .touchUpInside)
        cardViewController.btnParcelProceedRequest.addTarget(self, action: #selector(btnProceedConfirmPressed(_:)), for: .touchUpInside)
        cardViewController.btnParcelSelect.addTarget(self, action: #selector(btnParcelPressed(_:)), for: .touchUpInside)
        cardViewController.btnGoodsSelect.addTarget(self, action: #selector(btnGoodsPressed(_:)), for: .touchUpInside)
        cardViewController.btnDriveMeProceedRequest.addTarget(self, action: #selector(btnDriveMeProceedPressed(_:)), for: .touchUpInside)
        
    }
    
    func initAppMap() {
        // Setup Map
        
        view.layoutIfNeeded()
        
        gmsMapView = GMSMapView(frame: CGRect.zero)
        gmsMapView.showMapStyleForView()
        gmsMapView.delegate = self
        gmsMapView.isMyLocationEnabled = true
        gmsMapView.isBuildingsEnabled = true
        var offset = CGFloat(10)
        if getPhoneFaceIdType() {
            offset = 20
        }
        let padding = UIEdgeInsets(top: 100, left: 0, bottom: offset, right: 0)
        gmsMapView.padding = padding
        mapContainerView.addSubview(gmsMapView)
        
        gmsMapView.translatesAutoresizingMaskIntoConstraints = false
        gmsMapView.leftAnchor.constraint(equalTo: mapContainerView.leftAnchor).isActive = true
        gmsMapView.rightAnchor.constraint(equalTo: mapContainerView.rightAnchor).isActive = true
        gmsMapView.topAnchor.constraint(equalTo: mapContainerView.topAnchor).isActive = true
        gmsMapView.bottomAnchor.constraint(equalTo: mapContainerView.bottomAnchor).isActive = true
        
        adjustMapBottomConst()
        
    }
    
    func resetPreferredDriverBtn() {
        am.savePreferredDriver(data: "")
        am.savePreferredDriverImage(data: "")
        am.savePreferredDriverName(data: "")
        
        cardViewController.lblPreferredDriver.text = "Preferred Driver"
        cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
        cardViewController.imgPreferred.image = UIImage()
        cardViewController.btnPreferredDriver.alpha = 0.6
        cardViewController.btnPreferredDriver.layer.cornerRadius = 0
        cardViewController.btnPreferredDriver.clipsToBounds = false
        preferredDriver = false
    }
    
    // objc func handlers
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        cardViewController.parcelViewConstraint.constant = self.getKeyboardHeight(notification) + 550
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        cardViewController.parcelViewConstraint.constant = 550
        
    }
    
    @objc func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        let textfieldOffset = CGPoint(x: 0, y: textField.bounds.maxY + 180)
        cardViewController.parcelScrollView.setContentOffset(textfieldOffset, animated: true)
    }
    
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        
    }

    @objc func fromSleep() {
        printVal(object: "FROMSLEEP")
        toReload()
    }
    
    @objc func toReload() {
        
        let loadBackGround = self.createLoadingScreen()
        self.view.addSubview(loadBackGround)
        
        reloadLocations()
        
        self.view.layoutIfNeeded()
        
        stage = "FareEstimate"
        
        btnBackStage.sendActions(for: .touchUpInside)
        
        if !coverView.isHidden {
            menuBtn.sendActions(for: .touchUpInside)
        }
    }
    
    
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
    
    func adjustMapBottomConst() {
    
        var offset = 0
        if getPhoneFaceIdType() {
            offset = 40
        }
        mapBottomConstant.constant = cardHandleAreaHeight - CGFloat(offset)
        
        UIView.animate(withDuration: 0.2, animations: {
            self.mapContainerView.layoutIfNeeded()
        })
        printVal(object: "Map Const: \(mapBottomConstant.constant)")
    }
    
    @objc func backToCarTypes(sender: UITapGestureRecognizer) {
        
        cardViewController.confirmRequestView.isHidden = true
        cardViewController.parcelTypeView.isHidden = true
        cardViewController.driveMeView.isHidden = true
        
        if !cardViewController.confirmRequestPreferred.isHidden {
            preferredPageReveal(open: false)
        }
        
        if !cardViewController.confirmRequestPayments.isHidden {
            paymentsPageReveal(open: false)
        }
        
        if !cardViewController.confirmRequestPromo.isHidden {
            promoPageReveal(open: false)
        }
        
        stage = "FareEstimate"
        
        changeStageHeight()
        
    }
    
    @objc func tapCancelRideRequest(sender: UITapGestureRecognizer) {
        
        stopMakeRequestStatusUpdate()
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "", message: "\nAre you sure you want to cancel ride?\n", image: "", action: "")
        view.proceedAction = {
           SwiftMessages.hide()
            self.cardViewController.requestingLoadingView.createLoadingDanger()
            self.cardViewController.lblRequestingText.textColor = self.littleRed
            self.cardViewController.lblRequestingText.text = "Cancelling ride request..."
            self.cancelRequest()
        }
        view.cancelAction = {
            SwiftMessages.hide()
            self.isContinueRequest = true
            self.MakeRequestStatus()
        }
        view.btnProceed.setTitle("Cancel Request", for: .normal)
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    @objc func proceedToLoadApp() {
        
        let loadBackGround = self.createLoadingScreen()
        self.view.addSubview(loadBackGround)
        
        checkLocation()
    }
    
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
                    
                    cardViewController.requestingLoadingView.alpha = 0.6
                    cardViewController.requestingLoadingView.isHidden = false
                    cardViewController.requestingLoadingView.createLoadingNormal()
                    
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
                showOfflineMessage()
            }
        } else {
            removeLoadingPage()
            allowLocationAccessMessage()
        }
        
    }
    
    @objc func quitApp() {
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "AUTHSUCCESS"), object: nil)
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "AUTHFAIL"), object: nil)
        
        exit(0)
    }
    
    @objc func handleCardTap(_ recognzier:UITapGestureRecognizer) {
        switch recognzier.state {
        case .ended:
            if stage != "Confirmation" {
                effectChangesBeforeHeights()
                animateTransitionIfNeeded(state: nextState, duration: 0.3)
            } else {
                changeConfirmHeight(open: !isMainTabUp)
                confirmViewButtonsViewSetup(open: !isMainTabUp)
            }
        default:
            break
        }
    }
    
    @objc func handleCardPan(_ recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.3)
        case .changed:
            let translation = recognizer.translation(in: self.cardViewController.handleArea)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
        
    }
    
    func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
        self.visualEffectView.isHidden = false
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
                case .collapsed:
                    self.cardViewController.view.frame.origin.y = self.view.frame.height - (self.cardHandleAreaHeight + self.topSafeAreaConst + self.bottomSafeAreaConst)
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut)
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
            }
            blurAnimator.addCompletion { _ in
                switch state {
                case .expanded:
                    self.isMainTabUp = true
                    self.visualEffectView.isHidden = false
                case .collapsed:
                    self.isMainTabUp = false
                    self.visualEffectView.isHidden = true
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
            
        }
    }
    
    func startInteractiveTransition(state: CardState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            if stage != "Confirmation" {
                effectChangesBeforeHeights()
                animateTransitionIfNeeded(state: state, duration: duration)
            } else {
                changeConfirmHeight(open: !isMainTabUp)
                confirmViewButtonsViewSetup(open: !isMainTabUp)
            }
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    // Normal Functions
    
    func beforeSearchSetup() {
        if locationStopsArr.count > 0 {
            if originLL != "" {
                var firstLoc = locationStopsArr.first(where:  {$0.id == locationStopsArr[0].id})
                firstLoc = LocationSetSDK(id: locationStopsArr[0].id, name: am.getPICKUPADDRESS(), subname: am.getPICKUPADDRESS(), latitude: originLL.components(separatedBy: ",")[0], longitude:
                                                        originLL.components(separatedBy: ",")[1], phonenumber: locationStopsArr[0].phonenumber, instructions: locationStopsArr[0].instructions)
                locationStopsArr.removeAll()
                locationStopsArr.append(firstLoc!)
                if (locationsEstimateSet?.dropoffLocations?.count ?? 0) > 0 {
                    for each in locationsEstimateSet?.dropoffLocations ?? [] {
                        if each.name != "" {
                            locationStopsArr.append(each)
                        }
                    }
                }
            }
            
        } else {
            let unique_id = NSUUID().uuidString
            let unique_id2 = NSUUID().uuidString
            locationStopsArr.append(LocationSetSDK(id: unique_id, name: am.getPICKUPADDRESS(), subname: am.getPICKUPADDRESS(), latitude: (am.getCurrentLocation()?.components(separatedBy: ",")[0])!, longitude: (am.getCurrentLocation()?.components(separatedBy: ",")[1])!, phonenumber: "", instructions: ""))
            locationStopsArr.append(LocationSetSDK(id: unique_id2, name: "", subname: "", latitude: "", longitude: "", phonenumber: "", instructions: ""))
        }
    }
    
    func allowLocationAccessMessage() {
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "", message: "\nLocation Services Disabled. Please enable location services in settings to help find the nearest cab to you. You can also type your location in pick-up location.\n", image: "", action: "")
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
            self.buttpressed = "manualpickup"
            self.am.saveFromSearch(data: true)
            self.isToReload = false
            
            self.am.savePICKUPADDRESS(data: self.currentPlaceName ?? "")
            self.am.saveFromPickupLoc(data: true)
            
            let visibleRegion = self.gmsMapView.projection.visibleRegion()
            
            self.am.saveFarLeft(data: "\(visibleRegion.farLeft.latitude),\(visibleRegion.farLeft.longitude)")
            self.am.saveNearRight(data: "\(visibleRegion.nearRight.latitude),\(visibleRegion.nearRight.longitude)")
            
            self.beforeSearchSetup()
            
            if let viewController = UIStoryboard(name: "Trip", bundle: self.sdkBundle!).instantiateViewController(withIdentifier: "SearchLocViewController") as? SearchLocViewController {
                if let navigator = self.navigationController {
                    // viewController.locationStopsArr = self.locationStopsArr
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        view.btnProceed.setTitle("Allow location access", for: .normal)
        view.btnDismiss.setTitle("Type location manually", for: .normal)
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func showOfflineMessage() {
        
        self.removeLoadingPage()
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "", message: "\nYou appear to be offline. Kindly check your Internet connection and try again.\n", image: "", action: "")
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
        view.btnProceed.setTitle("Open Settings", for: .normal)
        view.btnDismiss.isHidden = true
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func reloadLocations() {
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
        
        locationTitleArr = am.getRecentPlacesNames()
        locationSubTitleArr = am.getRecentPlacesFormattedAddress()
        locationCoordsArr = am.getRecentPlacesCoords()
        
        var containsView = false
        if SuggestionsArr?.contains("View Approved") ?? false {
            containsView = true
        }
        SuggestionsArr = locationTitleArr
        if let index = SuggestionsArr?.firstIndex(where: {$0 == "Add Home"}) {
            SuggestionsArr?.remove(at: index)
        }
        if let index = SuggestionsArr?.firstIndex(where: {$0 == "Add Work"}) {
            SuggestionsArr?.remove(at: index)
        }
        if SuggestionsArr?.count == 0 {
            SuggestionsArr?.append("+ Add frequent destination?")
        } else {
            SuggestionsArr?.append("+")
        }
        
        if containsView {
            SuggestionsArr?.insert("View Approved", at: 0)
        }
        
        DestinationsArr = locationTitleArr
        DestinationsArr?.removeFirst()
        DestinationsArr?.removeFirst()
        
        if DestinationsArr?.count == 0 {
            cardViewController.lblNoDestinationHistory.isHidden = false
        } else {
            cardViewController.lblNoDestinationHistory.isHidden = true
        }
        
        cardViewController.suggestedPlacesCollectionView.reloadData()
        cardViewController.popularDropOffTable.reloadData()
        
    }
    
    func changeStageHeight() {
        UIView.animate(withDuration: 0.2) {
            self.cardViewController.view.frame.origin.y = self.view.frame.height - (self.cardHandleAreaHeight)
        }
        isMainTabUp = true
        effectChangesBeforeHeights()
        cardVisible = true
        animateTransitionIfNeeded(state: nextState, duration: 0.3)
    }
    
    func changeConfirmHeight(open: Bool) {
        if open {
            isMainTabUp = false
            effectChangesBeforeHeights()
            cardVisible = false
        } else {
            isMainTabUp = true
            effectChangesBeforeHeights()
            cardVisible = true
        }
        animateTransitionIfNeeded(state: nextState, duration: 0.3)
    }
    
    func effectChangesBeforeHeights() {
        
        if stage == "Destination" {
            
            cardHeight = view.frame.height - yPositionDestinationOpen!
            if yPositionDestinationOpen! >= yPositionDestinationOriginal! {
                cardHandleAreaHeight = view.frame.height - yPositionDestinationOpen!
            } else {
                cardHandleAreaHeight = view.frame.height - yPositionDestinationOriginal!
            }
            
            if isMainTabUp {
                
                cardViewController.suggestedPlacesView.isHidden = false
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.cardViewController.popularDropOffView.alpha = 0.0
                    self.cardViewController.suggestedPlacesView.alpha = 1.0
                    self.cardViewController.imgUp.alpha = 1.0
                    self.cardViewController.imgDown.alpha = 0.0
                }, completion: { finished in
                    self.cardViewController.popularDropOffView.isHidden = true
                })
                
            } else {
                
                cardViewController.popularDropOffView.isHidden = false
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.cardViewController.suggestedPlacesView.alpha = 0.0
                    self.cardViewController.popularDropOffView.alpha = 1.0
                    self.cardViewController.imgUp.alpha = 0.0
                    self.cardViewController.imgDown.alpha = 1.0
                }, completion: { finished in
                    self.cardViewController.suggestedPlacesView.isHidden = true
                    if self.cardViewController.popularDropOffView.isHidden == true {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.cardViewController.popularDropOffView.isHidden = false
                        })
                    }
                })
            }
            
        } else if stage == "FareEstimate" {
            
            if yPositionFareOriginal != nil {
                cardHeight = view.frame.height - (yPositionFareOpen ?? 0)
                if (yPositionFareOpen ?? 0) >= (yPositionFareOriginal ?? 0) {
                    cardHandleAreaHeight = view.frame.height - (yPositionFareOpen ?? 0)
                } else {
                    cardHandleAreaHeight = view.frame.height - (yPositionFareOriginal ?? 0)
                }
            }
            
            if isMainTabUp {
                
                if getPhoneFaceIdType() {
                    cardViewController.carTypesTableViewConstraint.constant = view.frame.height - (yPositionFareOriginal ?? 200.0) - 100
                } else {
                    cardViewController.carTypesTableViewConstraint.constant = view.frame.height - (yPositionFareOriginal ?? 200.0) - 55
                }
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.cardViewController.imgUp.alpha = 1.0
                    self.cardViewController.imgDown.alpha = 0.0
                }, completion: nil)
                
            } else {
                
                if getPhoneFaceIdType() {
                    cardViewController.carTypesTableViewConstraint.constant = view.frame.height - (yPositionFareOpen ?? 200.0) - 100
                } else {
                    cardViewController.carTypesTableViewConstraint.constant = view.frame.height - (yPositionFareOpen ?? 200.0) - 55
                }
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.cardViewController.imgUp.alpha = 0.0
                    self.cardViewController.imgDown.alpha = 1.0
                }, completion: nil)
                
            }
            
        } else if stage == "Parcel" {
            
            cardHeight = view.frame.height - yPositionParcelOpen!
            cardHandleAreaHeight = view.frame.height - yPositionParcelOriginal!
            
            if isMainTabUp {
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.cardViewController.imgUp.alpha = 1.0
                    self.cardViewController.imgDown.alpha = 0.0
                }, completion: nil)
                
            } else {
                
                cardViewController.parcelViewConstraint.constant = 500
                
                if isMainTabUp {
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.cardViewController.imgUp.alpha = 1.0
                        self.cardViewController.imgDown.alpha = 0.0
                    }, completion: nil)
                    
                } else {
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.cardViewController.imgUp.alpha = 0.0
                        self.cardViewController.imgDown.alpha = 1.0
                    }, completion: nil)
                }
            }
        
        } else if stage == "DriveMe" {
            
            cardHeight = view.frame.height - yPositionDriveMeOpen!
            cardHandleAreaHeight = view.frame.height - yPositionDriveMeOriginal!
            
            if isMainTabUp {
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.cardViewController.imgUp.alpha = 1.0
                    self.cardViewController.imgDown.alpha = 0.0
                }, completion: nil)
                
            } else {
                if isMainTabUp {
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.cardViewController.imgUp.alpha = 1.0
                        self.cardViewController.imgDown.alpha = 0.0
                    }, completion: nil)
                    
                } else {
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        self.cardViewController.imgUp.alpha = 0.0
                        self.cardViewController.imgDown.alpha = 1.0
                    }, completion: nil)
                }
            }
            
        } else if stage == "Confirmation" {
            
            cardHeight = view.frame.height - yPositionConfirmOpen!
            cardHandleAreaHeight = view.frame.height - yPositionConfirmOriginal!
            
            if isMainTabUp {
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.cardViewController.imgUp.alpha = 1.0
                    self.cardViewController.imgDown.alpha = 0.0
                }, completion: nil)
                
            } else {
                
                if getPhoneFaceIdType() {
                    cardViewController.preferredTableConstraint.constant = cardHeight - 290
                    cardViewController.paymentTableConstraint.constant = cardHeight - 290
                } else {
                    cardViewController.preferredTableConstraint.constant = cardHeight - 245
                    cardViewController.paymentTableConstraint.constant = cardHeight - 245
                }
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.cardViewController.imgUp.alpha = 0.0
                    self.cardViewController.imgDown.alpha = 1.0
                }, completion: nil)
            }
            
        }
        
        adjustMapBottomConst()
    }

    
    func paymentsPageReveal(open: Bool) {
        
        changeConfirmHeight(open: open)
        
        if open {
            
            cardViewController.btnPayment.setImage(getImage(named: "new_wallet_blue", bundle: sdkBundle!), for: UIControl.State())
            cardViewController.btnPromoCode.setImage(getImage(named: "new_promo", bundle: sdkBundle!), for: UIControl.State())
            if !preferredDriver {
                cardViewController.imgPreferred.image = UIImage()
                cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPreferredDriver.alpha = 0.6
            } else {
                cardViewController.btnPreferredDriver.alpha = 1.0
            }
            
            cardViewController.btnPayment.alpha = 1.0
            cardViewController.btnPromoCode.alpha = 0.6
            
            cardViewController.lblPayments.textColor = littleBlue
            cardViewController.lblPromoCode.textColor = UIColor.lightGray
            cardViewController.lblPreferredDriver.textColor = UIColor.lightGray
            
            cardViewController.btnRequest.isHidden = true
            cardViewController.confirmRequestPayments.isHidden = false
            
        } else {
            
            cardViewController.btnPayment.setImage(getImage(named: "new_wallet", bundle: sdkBundle!), for: UIControl.State())
            cardViewController.btnPromoCode.setImage(getImage(named: "new_promo", bundle: sdkBundle!), for: UIControl.State())
            if !preferredDriver {
                cardViewController.imgPreferred.image = UIImage()
                cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPreferredDriver.alpha = 0.6
            } else {
                cardViewController.btnPreferredDriver.alpha = 1.0
            }
            
            cardViewController.btnPayment.alpha = 0.6
            cardViewController.btnPromoCode.alpha = 0.6
            
            cardViewController.lblPayments.textColor = UIColor.lightGray
            cardViewController.lblPromoCode.textColor = UIColor.lightGray
            cardViewController.lblPreferredDriver.textColor = UIColor.lightGray
            
            let payStr: String? = PaymentModes[selectedPaymentMode]
            if let paymentStr = payStr {
                if reasonTest == "" && !isCorporate {
                    if promoVerified {
                        cardViewController.lblPaymentMode.text = "\(paymentStr) with \(promoText) Promo"
                    } else {
                        cardViewController.lblPaymentMode.text = "\(paymentStr)"
                    }
                }
            }
            
            cardViewController.confirmRequestPayments.isHidden = true
            cardViewController.btnRequest.isHidden = false
            cardViewController.confirmRequestPayments.isHidden = true
        }
    }
    
    func promoPageReveal(open: Bool) {
        
        changeConfirmHeight(open: open)
        
        if open {
            
            cardViewController.btnPayment.setImage(getImage(named: "new_wallet", bundle: sdkBundle!), for: UIControl.State())
            cardViewController.btnPromoCode.setImage(getImage(named: "new_promo_blue", bundle: sdkBundle!), for: UIControl.State())
            if !preferredDriver {
                cardViewController.imgPreferred.image = UIImage()
                cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPreferredDriver.alpha = 0.6
            } else {
                cardViewController.btnPreferredDriver.alpha = 1.0
            }
            
            cardViewController.btnPayment.alpha = 0.6
            cardViewController.btnPromoCode.alpha = 1.0
            
            cardViewController.lblPayments.textColor = UIColor.lightGray
            cardViewController.lblPromoCode.textColor = littleBlue
            cardViewController.lblPreferredDriver.textColor = UIColor.lightGray
            
            cardViewController.btnRequest.isHidden = true
            cardViewController.confirmRequestPromo.isHidden = false
            
        } else {
            
            cardViewController.btnPayment.setImage(getImage(named: "new_wallet", bundle: sdkBundle!), for: UIControl.State())
            cardViewController.btnPromoCode.setImage(getImage(named: "new_promo", bundle: sdkBundle!), for: UIControl.State())
            if !preferredDriver {
                cardViewController.imgPreferred.image = UIImage()
                cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPreferredDriver.alpha = 0.6
            } else {
                cardViewController.btnPreferredDriver.alpha = 1.0
            }
            
            cardViewController.btnPayment.alpha = 0.6
            cardViewController.btnPromoCode.alpha = 0.6
            
            cardViewController.lblPayments.textColor = UIColor.lightGray
            cardViewController.lblPromoCode.textColor = UIColor.lightGray
            cardViewController.lblPreferredDriver.textColor = UIColor.lightGray
           
            cardViewController.btnRequest.isHidden = false
            cardViewController.confirmRequestPromo.isHidden = true
        }
    }
    
    func preferredPageReveal(open: Bool) {
        
        changeConfirmHeight(open: open)
        
        if open {
            
            cardViewController.btnPayment.setImage(getImage(named: "new_wallet", bundle: sdkBundle!), for: UIControl.State())
            cardViewController.btnPromoCode.setImage(getImage(named: "new_promo", bundle: sdkBundle!), for: UIControl.State())
            if !preferredDriver {
                cardViewController.imgPreferred.image = UIImage()
                cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred_blue", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPreferredDriver.alpha = 1.0
            } else {
                cardViewController.btnPreferredDriver.alpha = 1.0
            }
            
            cardViewController.btnPayment.alpha = 0.6
            cardViewController.btnPromoCode.alpha = 0.6
            
            cardViewController.lblPayments.textColor = UIColor.lightGray
            cardViewController.lblPromoCode.textColor = UIColor.lightGray
            cardViewController.lblPreferredDriver.textColor = littleBlue
            
            cardViewController.btnRequest.isHidden = true
            cardViewController.confirmRequestPreferred.isHidden = false
            
        } else {
            
            cardViewController.btnPayment.setImage(getImage(named: "new_wallet", bundle: sdkBundle!), for: UIControl.State())
            cardViewController.btnPromoCode.setImage(getImage(named: "new_promo", bundle: sdkBundle!), for: UIControl.State())
            if !preferredDriver {
                cardViewController.imgPreferred.image = UIImage()
                cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred_blue", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPreferredDriver.alpha = 0.6
            } else {
                cardViewController.btnPreferredDriver.alpha = 1.0
            }
            
            cardViewController.btnPayment.alpha = 0.6
            cardViewController.btnPromoCode.alpha = 0.6
            
            cardViewController.lblPayments.textColor = UIColor.lightGray
            cardViewController.lblPromoCode.textColor = UIColor.lightGray
            cardViewController.lblPreferredDriver.textColor = UIColor.lightGray
            
            cardViewController.btnRequest.isHidden = false
            cardViewController.confirmRequestPreferred.isHidden = true
        }
    }
    
    func loadDestinationAsSelected(indexPath: IndexPath, source: String) {
        
        var ind = 0
        
        if source == "Table" {
            ind = locationTitleArr.firstIndex(of: DestinationsArr![indexPath.item])!
        } else if source == "Collection" {
            ind = locationTitleArr.firstIndex(of: SuggestionsArr![indexPath.item])!
        }
        
        let index = ind
        var latitude: Double
        var longitude: Double
        latitude = Double(locationCoordsArr[index].components(separatedBy: ",")[0])!
        longitude = Double(locationCoordsArr[index].components(separatedBy: ",")[1])!
        cardViewController.btnDestination.setTitle(locationTitleArr[index], for: UIControl.State())
        btnDestinationInformation.setTitle(locationTitleArr[index].components(separatedBy: ",")[0], for: UIControl.State())
        myDestination = CLLocation(latitude: latitude, longitude: longitude)
        destinationCoordinate = myDestination.coordinate
        destinationLL = locationCoordsArr[index]
        dropOffName = locationTitleArr[index]
        
        beforeSearchSetup()
        
        if locationStopsArr.count > 0 {
            locationStopsArr[0] = LocationSetSDK(id: locationStopsArr[0].id, name: dropOffName, subname: dropOffName, latitude: "\(latitude)", longitude: "\(longitude)", phonenumber: locationStopsArr[0].phonenumber, instructions: locationStopsArr[0].instructions)
        } else {
            let unique_id = NSUUID().uuidString
            locationStopsArr.append(LocationSetSDK(id: unique_id, name: dropOffName, subname: dropOffName, latitude: "\(latitude)", longitude: "\(longitude)", phonenumber: "", instructions: ""))
        }
        
        locationsEstimateSet = LocationsEstimateSetSDK(pickupLocation: locationsEstimateSet?.pickupLocation, dropoffLocations: [locationStopsArr[0]])
        
        drawPath()
        fareEstimateIndex = 0
        
        var distanceInMeters: CLLocationDistance = 0.0
        if self.myOrigin != nil {
            distanceInMeters = self.myOrigin.distance(from: CLLocation(latitude: latitude, longitude: longitude))
        } else {
            distanceInMeters = 0.0
        }
        
        if (distanceInMeters > 100000) {
            // Destination is far, could not get fare estimate
            
            carTypePriceEstimate.removeAll()
            for _ in CarTypes {
                carTypePriceEstimate.append("  ")
            }
            
            approxMinsLbl.text = "Destination is far, could not get fare estimate"
            
            showAlerts(title: "", message: "The destination selected is too far. Could not get the fare estimate.")
            
        } else {
            
            informationTopView.alpha = 0.0
            informationTopView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.informationTopView.alpha = 1.0
            }
            
            menuBtn.isHidden = true
            
            stage = "FareEstimate"
            
            changeStageHeight()
            
            cardViewController.carTypeTableView.isHidden = true
            cardViewController.carTypeView.isHidden = false
            
            carTypePriceEstimate.removeAll()
            cardViewController.carTypeLoadingView.createLoadingNormal()
            // getFareEstimate()
            
            getFareEstimateMultiple()
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
                    
                    self.initialPlaceName = am.getRecentPlacesNames()[i].cleanLocationNames()
                    self.currentPlaceName = am.getRecentPlacesNames()[i].cleanLocationNames()
                    
                    let unique_id = NSUUID().uuidString
                    self.locationsEstimateSet = LocationsEstimateSetSDK(pickupLocation: LocationSetSDK(id: unique_id, name: am.getRecentPlacesNames()[i].cleanLocationNames(), subname: am.getRecentPlacesNames()[i].cleanLocationNames(), latitude: "\(currentCoordinate.latitude)", longitude: "\(currentCoordinate.longitude)", phonenumber: "", instructions: ""), dropoffLocations: self.locationsEstimateSet?.dropoffLocations ?? [])
                    
                    self.am.savePICKUPADDRESS(data: self.currentPlaceName ?? "")
                    self.pickupName = am.getRecentPlacesNames()[i]
                    self.currentPlaceName = am.getRecentPlacesNames()[i]
                    self.cardViewController.btnPickup.layer.removeAllAnimations()
                    self.cardViewController.btnPickup.setTitle(am.getRecentPlacesNames()[i].components(separatedBy: ",")[0], for: UIControl.State())
                    self.btnPickupInformation.setTitle(am.getRecentPlacesNames()[i].components(separatedBy: ",")[0].cleanLocationNames(), for: UIControl.State())
                    
                    self.getPendingRequests()
                    
                    proceedToCallGoogle = false
                    
                    printVal(object: "Location Local")
                    
                    break
                }
                
            }
        }
        
        if proceedToCallGoogle {
            getLocationNameFromKB(currentCoordinate: currentCoordinate)
        }

    }
    
    func confirmViewButtonsViewSetup(open: Bool) {
        if confirmBtn == "Payments" {
            if open {
                
                cardViewController.btnPayment.setImage(getImage(named: "new_wallet_blue", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPromoCode.setImage(getImage(named: "new_promo", bundle: sdkBundle!), for: UIControl.State())
                if !preferredDriver {
                    cardViewController.imgPreferred.image = UIImage()
                    cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                    cardViewController.btnPreferredDriver.alpha = 0.6
                } else {
                    cardViewController.btnPreferredDriver.alpha = 1.0
                }
                
                cardViewController.btnPayment.alpha = 1.0
                cardViewController.btnPromoCode.alpha = 0.6
                
                
                cardViewController.lblPayments.textColor = littleBlue
                cardViewController.lblPromoCode.textColor = UIColor.lightGray
                cardViewController.lblPreferredDriver.textColor = UIColor.lightGray
                
                cardViewController.btnRequest.isHidden = true
                
                cardViewController.confirmRequestPayments.isHidden = false
                cardViewController.confirmRequestPromo.isHidden = true
                cardViewController.confirmRequestPreferred.isHidden = true
                
            } else {
                
                cardViewController.btnPayment.setImage(getImage(named: "new_wallet", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPromoCode.setImage(getImage(named: "new_promo", bundle: sdkBundle!), for: UIControl.State())
                if !preferredDriver {
                    cardViewController.imgPreferred.image = UIImage()
                    cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                    cardViewController.btnPreferredDriver.alpha = 0.6
                } else {
                    cardViewController.btnPreferredDriver.alpha = 1.0
                }
                
                cardViewController.btnPayment.alpha = 0.6
                cardViewController.btnPromoCode.alpha = 0.6
                
                cardViewController.lblPayments.textColor = UIColor.lightGray
                cardViewController.lblPromoCode.textColor = UIColor.lightGray
                cardViewController.lblPreferredDriver.textColor = UIColor.lightGray
                
                if reasonTest == "" && !isCorporate {
                    cardViewController.lblPaymentMode.text = "\(PaymentModes[selectedPaymentMode])"
                }
                
                cardViewController.confirmRequestPayments.isHidden = true
                
                cardViewController.btnRequest.isHidden = false
                
                cardViewController.confirmRequestPayments.isHidden = true
                cardViewController.confirmRequestPromo.isHidden = true
                cardViewController.confirmRequestPreferred.isHidden = true
            }
        } else if confirmBtn == "Promo" {
            if open {
                
                cardViewController.btnPayment.setImage(getImage(named: "new_wallet", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPromoCode.setImage(getImage(named: "new_promo_blue", bundle: sdkBundle!), for: UIControl.State())
                if !preferredDriver {
                    cardViewController.imgPreferred.image = UIImage()
                    cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                    cardViewController.btnPreferredDriver.alpha = 0.6
                } else {
                    cardViewController.btnPreferredDriver.alpha = 1.0
                }
                
                cardViewController.btnPayment.alpha = 0.6
                cardViewController.btnPromoCode.alpha = 1.0
                
                cardViewController.lblPayments.textColor = UIColor.lightGray
                cardViewController.lblPromoCode.textColor = littleBlue
                cardViewController.lblPreferredDriver.textColor = UIColor.lightGray
                
                cardViewController.btnRequest.isHidden = true
                
                cardViewController.confirmRequestPayments.isHidden = true
                cardViewController.confirmRequestPromo.isHidden = false
                cardViewController.confirmRequestPreferred.isHidden = true
                
            } else {
                
                cardViewController.btnPayment.setImage(getImage(named: "new_wallet", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPromoCode.setImage(getImage(named: "new_promo", bundle: sdkBundle!), for: UIControl.State())
                if !preferredDriver {
                    cardViewController.imgPreferred.image = UIImage()
                    cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                    cardViewController.btnPreferredDriver.alpha = 0.6
                } else {
                    cardViewController.btnPreferredDriver.alpha = 1.0
                }
                
                cardViewController.btnPayment.alpha = 0.6
                cardViewController.btnPromoCode.alpha = 0.6
                
                cardViewController.lblPayments.textColor = UIColor.lightGray
                cardViewController.lblPromoCode.textColor = UIColor.lightGray
                cardViewController.lblPreferredDriver.textColor = UIColor.lightGray
                
                cardViewController.btnRequest.isHidden = false
                
                cardViewController.confirmRequestPayments.isHidden = true
                cardViewController.confirmRequestPromo.isHidden = true
                cardViewController.confirmRequestPreferred.isHidden = true
            }
        } else if confirmBtn == "Preferred" {
            if open {
                
                cardViewController.btnPayment.setImage(getImage(named: "new_wallet", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPromoCode.setImage(getImage(named: "new_promo", bundle: sdkBundle!), for: UIControl.State())
                if !preferredDriver {
                    cardViewController.imgPreferred.image = UIImage()
                    cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred_blue", bundle: sdkBundle!), for: UIControl.State())
                    cardViewController.btnPreferredDriver.alpha = 1.0
                } else {
                    cardViewController.btnPreferredDriver.alpha = 1.0
                }
                
                cardViewController.btnPayment.alpha = 0.6
                cardViewController.btnPromoCode.alpha = 0.6
                
                cardViewController.lblPayments.textColor = UIColor.lightGray
                cardViewController.lblPromoCode.textColor = UIColor.lightGray
                cardViewController.lblPreferredDriver.textColor = littleBlue
                
                cardViewController.btnRequest.isHidden = true
                
                cardViewController.confirmRequestPayments.isHidden = true
                cardViewController.confirmRequestPromo.isHidden = true
                cardViewController.confirmRequestPreferred.isHidden = false
                
            } else {
                
                cardViewController.btnPayment.setImage(getImage(named: "new_wallet", bundle: sdkBundle!), for: UIControl.State())
                cardViewController.btnPromoCode.setImage(getImage(named: "new_promo", bundle: sdkBundle!), for: UIControl.State())
                if !preferredDriver {
                    cardViewController.imgPreferred.image = UIImage()
                    cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                    cardViewController.btnPreferredDriver.alpha = 0.6
                } else {
                    cardViewController.btnPreferredDriver.alpha = 1.0
                }
                
                cardViewController.btnPayment.alpha = 0.6
                cardViewController.btnPromoCode.alpha = 0.6
                
                cardViewController.lblPayments.textColor = UIColor.lightGray
                cardViewController.lblPromoCode.textColor = UIColor.lightGray
                cardViewController.lblPreferredDriver.textColor = UIColor.lightGray
                
                cardViewController.btnRequest.isHidden = false
                
                cardViewController.confirmRequestPayments.isHidden = true
                cardViewController.confirmRequestPromo.isHidden = true
                cardViewController.confirmRequestPreferred.isHidden = true
            }
        }
        
    }
    
    func drawPath() {
        if am.getCountry()?.uppercased() == "KENYA" {
            goLocalMultiple()
        } else {
            goGoogleMultiple()
        }
    }
    
    func goGoogleMultiple() {
        
        isLocal = false
        overviewPolylineString = ""
        totalTime = "0"
        
        var waypoints = ""
        
        var allDrops = locationsEstimateSet?.dropoffLocations ?? []
        
        let origin = "\(originCoordinate.latitude),\(originCoordinate.longitude)"
        let destination = "\(allDrops.last?.latitude ?? ""),\(allDrops.last?.longitude ?? "")"
        
        if allDrops.count > 1 {
            
            allDrops.removeLast()
            
            waypoints = "&waypoints="
            for each in allDrops {
                if each.id != allDrops.last?.id {
                    waypoints.append("via:\(each.latitude)%2C\(each.longitude)&7C")
                } else {
                    waypoints.append("via:\(each.latitude)%2C\(each.longitude)")
                }
            }
        }
        
        let directionURL = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)\(waypoints)&mode=driving&key=\(am.DecryptDataKC(DataToSend: cn.mapsKey))"
        
        let url = URL(string: directionURL)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil {
            } else {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    
                    let status = parsedData["status"] as! String
                    
                    if status == "OK" {
                        self.selectedRoute = (parsedData["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                        self.overviewPolyline = self.selectedRoute["overview_polyline"] as? Dictionary<String, AnyObject>
                        
                        let bounds = self.selectedRoute["bounds"] as! Dictionary<String, AnyObject>
                        let northEast = bounds["northeast"] as! Dictionary<String, AnyObject>
                        let southWest = bounds["southwest"] as! Dictionary<String, AnyObject>
                        
                        self.bbox.removeAll()
                        self.bbox.append(southWest["lng"] as! Double)
                        self.bbox.append(southWest["lat"] as! Double)
                        self.bbox.append(northEast["lng"] as! Double)
                        self.bbox.append(northEast["lat"] as! Double)
                        
                        let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                        
                        let timeDictionary = legs[0]["duration"] as! Dictionary<String, AnyObject>
                        self.totalTime = timeDictionary["text"] as? String
                        
                        let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                        self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                        
                        let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                        self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                        
                        self.originAddress = legs[0]["start_address"] as? String
                        self.destinationAddress = legs[legs.count - 1]["end_address"] as? String
                        
                        
                        
                        DispatchQueue.main.async {
                            self.gmsMapView.clear()
                            self.configureMapAndMarkersForRoute()
                            self.drawRoute()
                        }
                        
                    }
                } catch _ as NSError {
                }
            }
            
            }.resume()
        
    }
    
    func goLocalMultiple() {
        
        isLocal = true
        
        if originCoordinate != nil {
            if destinationCoordinate != nil {
                let origin = "\(originCoordinate.latitude),\(originCoordinate.longitude)"
                
                var points = "&point=\(origin)"
                let allDrops = locationsEstimateSet?.dropoffLocations ?? []
                if allDrops.count > 1 {
                    for each in allDrops {
                        points.append("&point=\(each.latitude),\(each.longitude)")
                    }
                }
                
                let directionURL = "https://maps.little.bz/api/v2/direction/full?\(points)&key=\(am.DecryptDataKC(DataToSend: cn.littleMapKey))"

                let url = URL(string: directionURL)
                URLSession.shared.dataTask(with:url!) { (data, response, error) in
                    if error != nil {
                        self.goGoogleMultiple()
                    } else {
                        do {
                            let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]

                            let paths = parsedData["paths"] as? Array<Dictionary<String, AnyObject>>
                            
                            self.overviewPolylineString = paths?[0]["points"] as? String
                            self.bbox.removeAll()
                            self.bbox = paths?[0]["bbox"] as? Array<Double> ?? []
                            
                            DispatchQueue.main.async {
                                self.gmsMapView.clear()
                                self.configureMapAndMarkersForRoute()
                                self.drawRoute()
                            }
                        } catch _ as NSError {
                            self.goGoogleMultiple()
                        }
                    }

                }.resume()
            }
        }
    }
    
    func configureMapAndMarkersForRoute() {
        
        if self.originCoordinate != nil && self.destinationCoordinate != nil {
            gmsMapView.clear()
            
            if marker != nil {
                marker.map = nil
            }
            
            if totalTime != nil {
                
                approxMinsLbl.text = "Approx. \(totalTime!) from pickup to destination"
                let boldFont = UIFont(name: "AppleSDGothicNeo-Bold", size: 15.0)!
                let text = (approxMinsLbl.text)!
                let underlineAttriString = NSMutableAttributedString(string: text)
                let range1 = (text as NSString).range(of: totalTime)
                let color = cn.littleSDKThemeColor
                underlineAttriString.addAttribute(.font, value: boldFont, range: range1)
                underlineAttriString.addAttribute(.foregroundColor, value: color, range: range1)
                approxMinsLbl.attributedText = underlineAttriString
                
                approxDestinationTimeView.alpha = 0.0
                approxDestinationTimeView.isHidden = false
                
                UIView.animate(withDuration: 0.3) {
                    self.approxDestinationTimeView.alpha = 1.0
                }
                
            }
            
            var bounds = GMSCoordinateBounds()
            
            let startLoc = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(locationsEstimateSet?.pickupLocation?.latitude ?? "0.0")!), longitude: CLLocationDegrees(Double(locationsEstimateSet?.pickupLocation?.longitude ?? "0.0")!))
            
            originMarker = GMSMarker(position: startLoc)
            originMarker.map = self.gmsMapView
            let image1 = scaleImage(image: getImage(named: "dropoff_location", bundle: sdkBundle!) ?? UIImage(), size: 0.1) // UIImage(contentsOfFile: "dropoff_location") ?? UIImage()
            originMarker.icon = image1
            originMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            originMarker.appearAnimation = GMSMarkerAnimation.pop
            originMarker.title = "Pick-up"
            
            bounds = bounds.includingCoordinate(startLoc)
            
            let allDrops = locationsEstimateSet?.dropoffLocations ?? []
            
            for each in allDrops {
                
                let eachLoc = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(each.latitude)!), longitude: CLLocationDegrees(Double(each.longitude)!))
                
                if each.id == allDrops.last?.id {
                    destinationMarker = GMSMarker(position: eachLoc)
                    destinationMarker.map = self.gmsMapView
                    
                    
                    
                    let image2 = scaleImage(image: getImage(named: "pickup_location", bundle: sdkBundle!) ?? UIImage(), size: 0.1)
                    destinationMarker.icon = image2
                    destinationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.75)
                    destinationMarker.appearAnimation = GMSMarkerAnimation.pop
                    destinationMarker.title = "Destination"
                } else {
                    var onTheWayMarker: GMSMarker!
                    onTheWayMarker = GMSMarker(position: eachLoc)
                    onTheWayMarker.map = self.gmsMapView
                    let image2 = scaleImage(image: getImage(named: "dropoff_location", bundle: sdkBundle!) ?? UIImage(), size: 0.08)
                    onTheWayMarker.icon = image2
                    onTheWayMarker.groundAnchor = CGPoint(x: 0.5, y: 0.75)
                    onTheWayMarker.appearAnimation = GMSMarkerAnimation.pop
                    onTheWayMarker.title = each.name
                }
                bounds = bounds.includingCoordinate(eachLoc)
            }
            
            if bbox.count == 4 {
                let southWest = CLLocationCoordinate2D(latitude: CLLocationDegrees(bbox[1]), longitude: CLLocationDegrees(bbox[0]))
                let northEast = CLLocationCoordinate2D(latitude: CLLocationDegrees(bbox[3]), longitude: CLLocationDegrees(bbox[2]))
                bounds.includingCoordinate(northEast)
                bounds.includingCoordinate(southWest)
            }
        
            gmsMapView.moveCamera(GMSCameraUpdate.fit(bounds, withPadding: 70.0))
            
        }
    }
    
    func drawRoute() {
        
        var route = ""
        
        if isLocal {
            if overviewPolylineString != nil {
                route = overviewPolylineString!
            } else {
                goGoogleMultiple()
                return
            }

        } else {
            route = overviewPolyline["points"] as! String
        }
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)!
        
        routePolyline = GMSPolyline(path: path)
        routePolyline.strokeWidth = 3
        routePolyline.strokeColor = UIColor(named: "littleBlack")?.withAlphaComponent(0.5) ?? UIColor.black.withAlphaComponent(0.5)
        routePolyline.map = gmsMapView
        
        self.path = path
        
        self.animatetimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(animatePolylinePath), userInfo: nil, repeats: true)
        
        pathShowing = true
        
    }
    
    @objc func animatePolylinePath() {
        if (self.i < path.count()) {
            self.animationPath.add(path.coordinate(at: self.i))
            self.animationPolyline.path = self.animationPath
            self.animationPolyline.strokeColor = cn.littleSDKThemeColor
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
    
    // MARK: - TableView Delegates & DataSource
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0 {
            return 50
        } else if tableView.tag == 1 {
            return 80
        } else if tableView.tag == 2 {
            return 40
        } else {
            return 75
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return DestinationsArr?.count ?? 0
        } else if tableView.tag == 1 {
            return CarTypes.count
        } else if tableView.tag == 2 {
            return PaymentModes.count
        } else {
            return preferredDriversArr.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DestinationCell
            
            cell.lblDestination.text = DestinationsArr?[indexPath.item]
            
            cell.selectionStyle = .none
            
            return cell
        } else if tableView.tag == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewCartypeTableViewCell
            
            cell.lblCarName.text = CarTypes[indexPath.item]
            
            cell.imgCarType.image = nil
            
            if carisNew[indexPath.item] == "1" {
                cell.lblIsNew.isHidden = false
            } else {
                cell.lblIsNew.isHidden = true
            }
            
            cell.btnViewCarDets.tag = indexPath.item
            cell.btnViewCarDets.addTarget(self, action: #selector(self.btnShowCarDetailsPressed(_:)), for: .touchUpInside)
            
            cell.imgCarType.sd_setImage(with: URL(string: carActiveIcons[indexPath.item]))
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                cell.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
            
            cell.lblCarTime.text = "\(carVTypeTimes[indexPath.item])"
            
            if carOldTripCost[indexPath.item] != "0" {
                
                var oldCost = ""
                
                if !carOldTripCost[indexPath.item].uppercased().contains("\(carCurrency[indexPath.item].uppercased())") {
                    oldCost = "\(carCurrency[indexPath.item].capitalized) \(carOldTripCost[indexPath.item])"
                } else {
                    oldCost = carOldTripCost[indexPath.item].capitalized
                }
                
                
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: oldCost)
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                
                cell.lblCarInitialPrice.attributedText = attributeString
                
            } else {
                cell.lblCarInitialPrice.text = ""
            }
            
            cell.selectionStyle = .none
            
            if carTypePriceEstimate.count == 0 {
                cell.lblCarFareEstimate.text = "  "
            } else {
                if indexPath.item < carTypePriceEstimate.count {
                    cell.lblCarFareEstimate.text = "\(carCostEstimate[indexPath.item])"
                } else {
                    cell.lblCarFareEstimate.text = "  "
                }
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            
            return cell
        } else if tableView.tag == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewImgLblTableViewCell
            
            cell.imgCheckedItem.isHidden = true
            
            let image = PaymentModes[indexPath.item].lowercased().replacingOccurrences(of: "", with: "")
            
            if image.contains("cash") {
                cell.imgMenuItem.image = getImage(named: "new_cash", bundle: sdkBundle!) ?? UIImage()
            } else if image.contains("bank") {
                cell.imgMenuItem.image = getImage(named: "new_bank", bundle: sdkBundle!) ?? UIImage()
            } else if image.contains("coins") {
                cell.imgMenuItem.image = getImage(named: "new_little coins", bundle: sdkBundle!) ?? UIImage()
            } else if image.contains("mpesa") || image.contains("mtnmoney") || image.contains("mobilmoney") || image.contains("airtelmoney") {
                cell.imgMenuItem.image = getImage(named: "new_mpesa", bundle: sdkBundle!) ?? UIImage()
            } else {
                cell.imgMenuItem.image = getImage(named: "new_card", bundle: sdkBundle!) ?? UIImage()
            }
            
            if selectedPaymentMode == indexPath.item {
                // cell.imgCheckedItem.isHidden = false
                
                UIView.animate(withDuration: 0.2, animations: {
                    cell.imgCheckedItem.alpha = 0.3
                    cell.imgCheckedItem.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }, completion: { finished in
                    cell.imgMenuItem.image = getImage(named: "new_checked_blue", bundle: self.sdkBundle!) ?? UIImage()
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.imgCheckedItem.alpha = 1.0
                        cell.imgCheckedItem.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                    }, completion: nil)
                })
                
            } else {
                // cell.imgCheckedItem.isHidden = true
                
            }
            
            cell.btnMenuItem.tag = indexPath.item
            cell.btnMenuItem.setTitle(PaymentModes[indexPath.item].capitalized, for: UIControl.State())
            cell.btnMenuItem.addTarget(self, action: #selector(self.btnPaymentTypePressed(_:)), for: .touchUpInside)
            
            
            return cell
        } else {
            let dist = Double(preferredDriversArr[indexPath.item].roadDistance ?? "0")
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! NewPreferredTableViewCell
            if let rating = Double(preferredDriversArr[indexPath.item].rating ?? "0") {
                cell.lblDriverRating.text = String(format: "%.1f", rating)
            } else {
                cell.lblDriverRating.text = "5.0"
            }
            cell.selectionStyle = .none
            cell.lblDriverName.text = (preferredDriversArr[indexPath.item].driverName ?? "").capitalized
            cell.lblDriverDistance.text = "\(String(format: "%.3f", dist!)) Kms away" //  (\(DriverTime[indexPath.item]) mins)
            if preferredDriversArr[indexPath.item].aboutMe != "" {
                cell.lblDriverAboutMe.text = preferredDriversArr[indexPath.item].aboutMe!.capitalized
                cell.lblDriverAboutMe.isHidden = false
                cell.imgAboutMe.isHidden = false
                cell.driverNameConst.constant = 5
                cell.layoutIfNeeded()
            } else {
                cell.lblDriverAboutMe.text = ""
                cell.lblDriverAboutMe.isHidden = true
                cell.imgAboutMe.isHidden = true
                cell.driverNameConst.constant = 15
                cell.layoutIfNeeded()
            }
            cell.imgDriverPic.sd_setImage(with: URL(string: preferredDriversArr[indexPath.item].driverImage ?? ""), placeholderImage: getImage(named: "default", bundle: sdkBundle!))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            
            loadDestinationAsSelected(indexPath: indexPath, source: "Table")
            
        } else if tableView.tag == 1 {
            
            if carVehicleCategory[indexPath.item].uppercased() == "SHUTTLE" {
                
                
            } else if CarTypes[indexPath.item].lowercased().contains("goods") {
                
                selectedCarIndex = indexPath.item
                
                cardViewController.carTypeTableView.reloadData()
                
                cardViewController.imgCarToRequest.sd_setImage(with: URL(string: carActiveIcons[indexPath.item]))
                cardViewController.lblCarToRequest.text = "Parcel: Medium"
                cardViewController.lblFareToPay.text = "\(carCostEstimate[indexPath.item])"
                cardViewController.lblMinutesToWait.text = "\(carVTypeTimes[indexPath.item])"
                cardViewController.btnRequest.isHidden = false
                
                cardViewController.mediumView.layer.borderColor = littleBlue?.cgColor
                cardViewController.smallView.layer.borderColor = UIColor.clear.cgColor
                
                cardViewController.mediumView.layer.shadowColor = littleBlue?.cgColor
                cardViewController.imgSmallCheck.isHidden = true
                cardViewController.imgMediumCheck.isHidden = false
                cardViewController.imgGoodsCartype.sd_setImage(with: URL(string: carActiveIcons[indexPath.item]))
                cardViewController.lblGoodsCartypeName.text = "Medium"
                cardViewController.lblGoodsCarTypeCost.text = "\(carCostEstimate[indexPath.item])"
                
                var goodsint = 0
                
                for i in (0..<CarTypes.count) {
                    if CarTypes[i].uppercased() == "PARCELS" {
                        goodsint = i
                        continue
                    }
                }
                
                cardViewController.smallView.layer.shadowColor = UIColor.lightGray.cgColor
                cardViewController.imgParcelCartype.sd_setImage(with: URL(string: carActiveIcons[goodsint]))
                cardViewController.lblParcelCarTypeName.text = "Small"
                cardViewController.lblParcelCarTypeCost.text = "\(carCostEstimate[goodsint])"
                
                resetPreferredDriverBtn()
                
                selectedCarIndex = indexPath.item
                
                if !isCorporate {
                    cardViewController.btnRequest.setTitle("Request \(CarTypes[selectedCarIndex].capitalized)", for: UIControl.State())
                } else {
                    cardViewController.btnRequest.setTitle("Request \(CarTypes[selectedCarIndex].capitalized) as Corporate", for: UIControl.State())
                }
                
                stage = "Parcel"
                
                cardViewController.parcelTypeView.alpha = 0.0
                cardViewController.parcelTypeView.isHidden = false
                
                UIView.animate(withDuration: 0.3) {
                    self.cardViewController.parcelTypeView.alpha = 1.0
                }
                
                changeStageHeight()
                
            } else if CarTypes[indexPath.item].lowercased().contains("parcel") {
                
                selectedCarIndex = indexPath.item
                
                cardViewController.carTypeTableView.reloadData()
                
                cardViewController.imgCarToRequest.sd_setImage(with: URL(string: carActiveIcons[indexPath.item]))
                cardViewController.lblCarToRequest.text = "Parcel: Small"
                cardViewController.lblFareToPay.text = "\(carCostEstimate[indexPath.item])"
                cardViewController.lblMinutesToWait.text = "\(carVTypeTimes[indexPath.item])"
                cardViewController.btnRequest.isHidden = false
                
                cardViewController.smallView.layer.borderColor = littleBlue?.cgColor
                cardViewController.mediumView.layer.borderColor = UIColor.clear.cgColor
                
                cardViewController.smallView.layer.shadowColor = littleBlue?.cgColor
                cardViewController.imgSmallCheck.isHidden = false
                cardViewController.imgMediumCheck.isHidden = true
                cardViewController.imgParcelCartype.sd_setImage(with: URL(string: carActiveIcons[indexPath.item]))
                cardViewController.lblParcelCarTypeName.text = "Small"
                cardViewController.lblParcelCarTypeCost.text = "\(carCostEstimate[indexPath.item])"
                
                var goodsint = 0
                
                for i in (0..<CarTypes.count) {
                    if CarTypes[i].uppercased() == "GOODS" {
                        goodsint = i
                        continue
                    }
                }
                
                cardViewController.mediumView.layer.shadowColor = UIColor.lightGray.cgColor
                cardViewController.imgGoodsCartype.sd_setImage(with: URL(string: carActiveIcons[goodsint]))
                cardViewController.lblGoodsCartypeName.text = "Medium"
                cardViewController.lblGoodsCarTypeCost.text = "\(carCostEstimate[goodsint])"
                
                resetPreferredDriverBtn()
                
                selectedCarIndex = indexPath.item
                
                if !isCorporate {
                    cardViewController.btnRequest.setTitle("Request \(CarTypes[selectedCarIndex].capitalized)", for: UIControl.State())
                } else {
                    cardViewController.btnRequest.setTitle("Request \(CarTypes[selectedCarIndex].capitalized) as Corporate", for: UIControl.State())
                }
                
                stage = "Parcel"
                
                cardViewController.parcelTypeView.alpha = 0.0
                cardViewController.parcelTypeView.isHidden = false
                
                UIView.animate(withDuration: 0.3) {
                    self.cardViewController.parcelTypeView.alpha = 1.0
                }
                
                changeStageHeight()
                
            } else if CarTypes[indexPath.item].lowercased().contains("driveme") {
                
                selectedCarIndex = indexPath.item
                
                cardViewController.carTypeTableView.reloadData()
                
                if driveMeTypes.count > 0 {
                    
                    cardViewController.imgCarToRequest.sd_setImage(with: URL(string: driveMeTypes[0].vehicleICON ?? ""))
                    if cardViewController.transmissionTypeSeg.selectedSegmentIndex == 0 {
                        cardViewController.lblCarToRequest.text = "Drive Me: \(driveMeTypes[0].vehicleType ?? "") (Automatic)".replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "")
                    } else {
                        cardViewController.lblCarToRequest.text = "Drive Me: \(driveMeTypes[0].vehicleType ?? "") (Manual)".replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "")
                    }
                    cardViewController.lblFareToPay.text = "\(driveMeTypes[0].costEstimate ?? "")"
                    cardViewController.lblMinutesToWait.text = "\(driveMeTypes[0].textLabels ?? "")"
                    cardViewController.btnRequest.isHidden = false
                    
                    cardViewController.imgDriveMe.sd_setImage(with: URL(string: driveMeTypes[0].vehicleICON ?? ""))
                    cardViewController.lblDriveMeCarType.text = "\(CarTypes[indexPath.item])"
                    cardViewController.lblDriveMeDistance.text = "\(driveMeTypes[0].vehicleType ?? "")".replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "").capitalized
                    cardViewController.lblDriveMeCost.text = "\(driveMeTypes[0].costEstimate ?? "")"
                    cardViewController.lblDriveMeTime.text = "\(driveMeTypes[0].textLabels ?? "")"
                    
                    am.savePreferredDriver(data: "")
                    am.savePreferredDriverImage(data: "")
                    am.savePreferredDriverName(data: "")
                    
                    cardViewController.lblPreferredDriver.text = "Preferred Driver"
                    cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                    cardViewController.imgPreferred.image = UIImage()
                    cardViewController.btnPreferredDriver.alpha = 0.6
                    cardViewController.btnPreferredDriver.layer.cornerRadius = 0
                    cardViewController.btnPreferredDriver.clipsToBounds = false
                    preferredDriver = false
                    
                    selectedCarIndex = indexPath.item
                    
                    if !isCorporate {
                        cardViewController.btnRequest.setTitle("Request \(CarTypes[selectedCarIndex].capitalized)", for: UIControl.State())
                    } else {
                        cardViewController.btnRequest.setTitle("Request \(CarTypes[selectedCarIndex].capitalized) as Corporate", for: UIControl.State())
                    }
                    
                    stage = "DriveMe"
                    
                    cardViewController.driveMeView.alpha = 0.0
                    cardViewController.driveMeView.isHidden = false
                    
                    UIView.animate(withDuration: 0.3) {
                        self.cardViewController.driveMeView.alpha = 1.0
                    }
                    
                    changeStageHeight()
                    
                }
                
                
            } else {
                
                selectedCarIndex = indexPath.item
                
                cardViewController.carTypeTableView.reloadData()
            
                cardViewController.imgCarToRequest.sd_setImage(with: URL(string: carActiveIcons[indexPath.item]))
                cardViewController.lblCarToRequest.text = CarTypes[indexPath.item]
                cardViewController.lblFareToPay.text = "\(carCostEstimate[indexPath.item])"
                cardViewController.lblMinutesToWait.text = "\(carVTypeTimes[indexPath.item])"
                cardViewController.btnRequest.isHidden = false
                
                resetPreferredDriverBtn()
                
                if !isCorporate {
                    cardViewController.btnRequest.setTitle("Request \(CarTypes[selectedCarIndex].capitalized)", for: UIControl.State())
                } else {
                    cardViewController.btnRequest.setTitle("Request \(CarTypes[selectedCarIndex].capitalized) as Corporate", for: UIControl.State())
                }
                
                stage = "Confirmation"
                
                cardViewController.requestingViewConstraint.constant = 250
                cardViewController.confirmRequestView.alpha = 0.0
                cardViewController.confirmRequestView.isHidden = false
                cardViewController.btnRequest.isHidden = false
                
                
                UIView.animate(withDuration: 0.3) {
                    self.cardViewController.confirmRequestView.alpha = 1.0
                }
                changeStageHeight()
            }
            
            
        } else if tableView.tag == 2 {
            
            selectedPaymentMode = indexPath.item
            
            cardViewController.paymentOptionsTableView.createLoadingNormal()
            
            cardViewController.paymentOptionsTableView.reloadData()
            
            cardViewController.paymentOptionsTableView.removeAnimation()
            
            paymentsPageReveal(open: false)
            
        } else if tableView.tag == 3 {
            
            am.savePreferredDriver(data: preferredDriversArr[indexPath.item].driverEMailID ?? "")
            am.savePreferredDriverImage(data: preferredDriversArr[indexPath.item].driverImage ?? "")
            am.savePreferredDriverName(data: preferredDriversArr[indexPath.item].driverName ?? "")
            
            cardViewController.lblPreferredDriver.text = (preferredDriversArr[indexPath.item].driverName ?? "").capitalized
            cardViewController.imgPreferred.sd_setImage(with: URL(string: preferredDriversArr[indexPath.item].driverImage ?? ""), placeholderImage: getImage(named: "default", bundle: sdkBundle!))
            
            let height = cardViewController.imgPreferred.frame.height/2
            cardViewController.btnPreferredDriver.setImage(UIImage(), for: UIControl.State())
            view.layoutIfNeeded()
            cardViewController.imgPreferred.layer.cornerRadius = height
            cardViewController.imgPreferred.layer.masksToBounds = true
            preferredDriver = true
            
            self.preferredPageReveal(open: false)
        }
    }
    
    
    // MARK: - CollectionView Delegates & DataSource
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        if collectionView.tag == 0 {
            let font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15.0)!
            
            var varia = CGFloat(50.0)
            
            var homeIndex = 0
            var workIndex = 1
            
            if (SuggestionsArr?.contains("View Approved"))! {
                homeIndex += 1
                workIndex += 1
            }
            
            if (indexPath.item == homeIndex) || (indexPath.item == workIndex) {
                varia = 80.0
            }
            
            let size = CGSize(width: ((SuggestionsArr?[indexPath.item].width(withConstrainedHeight: 30.0, font: font)) ?? 0.0) + varia, height: 40.0)
            
            return size
        } else {
            let size = CGSize(width: 100, height: 80.0)
            
            return size
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return SuggestionsArr?.count ?? 0
        } else {
            return driveMeTypes.count/2
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! PlaceSuggestionCell
            
            cell.lblPlaceSuggested.text = SuggestionsArr?[indexPath.item]
            
            if SuggestionsArr?[indexPath.item] == "View Approved" {
                cell.lblPlaceSuggested.textColor = .white
                cell.backGround.backgroundColor = cn.littleSDKThemeColor
            } else {
                cell.lblPlaceSuggested.textColor = cn.littleSDKLabelColor
                cell.backGround.backgroundColor = .white
            }
            
            cell.imgHomeWork.isHidden = true
        
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! DriveMeCell
            
            cell.imgDriveMe.sd_setImage(with: URL(string: driveMeTypes[indexPath.item].vehicleICON ?? ""))
            cell.lblDriveMe.text =  (driveMeTypes[indexPath.item].vehicleType ?? "").replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "")
            
            if selectedDriveMeSecIndex == indexPath.item {
                cell.imgSelected.isHidden = false
                
                cell.driveMeView.layer.borderColor = littleBlue?.cgColor
                cell.driveMeView.layer.shadowColor = littleBlue?.cgColor
                
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                    cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }, completion: nil)
            } else {
                cell.imgSelected.isHidden = true
                
                cell.driveMeView.layer.borderColor = UIColor.clear.cgColor
                cell.driveMeView.layer.shadowColor = UIColor.lightGray.cgColor
                
                UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
                    cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                }, completion: nil)
            }
            
            return cell
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 0 {
            func getLocationActionDesired() {
                if indexPath.item != (SuggestionsArr!.count - 1){
                    loadDestinationAsSelected(indexPath: indexPath, source: "Collection")
                } else {
                    NotificationCenter.default.addObserver(self, selector: #selector(fromDropoff),name:NSNotification.Name(rawValue: "DROPOFF"), object: nil)
                    buttpressed = "dropoff"
                    
                    self.am.saveFromPickupLoc(data: false)
                    
                    let visibleRegion = self.gmsMapView.projection.visibleRegion()
                    
                    self.am.saveFarLeft(data: "\(visibleRegion.farLeft.latitude),\(visibleRegion.farLeft.longitude)")
                    self.am.saveNearRight(data: "\(visibleRegion.nearRight.latitude),\(visibleRegion.nearRight.longitude)")
                    
                    self.beforeSearchSetup()
                    
                    if let viewController = UIStoryboard(name: "Trip", bundle: self.sdkBundle!).instantiateViewController(withIdentifier: "SearchLocViewController") as? SearchLocViewController {
                        if let navigator = self.navigationController {
                            navigator.pushViewController(viewController, animated: true)
                        }
                    }
                }
            }
            
            getLocationActionDesired()
            
            
        } else {
            
            selectedDriveMeSecIndex = indexPath.item
            
            let type = (driveMeTypes[indexPath.item].vehicleType ?? "").replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "")
            
            if cardViewController.transmissionTypeSeg.selectedSegmentIndex == 0 {
                for i in (0..<driveMeTypes.count) {
                    if driveMeTypes[i].vehicleType == "\(type)/A" {
                        selectedDriveMeIndex = i
                        continue
                    }
                }
            } else {
                for i in (0..<driveMeTypes.count) {
                    if driveMeTypes[i].vehicleType == "\(type)/M" {
                        selectedDriveMeIndex = i
                        continue
                    }
                }
            }
            
            cardViewController.imgCarToRequest.sd_setImage(with: URL(string: driveMeTypes[selectedDriveMeIndex].vehicleICON ?? ""))
            
            if cardViewController.transmissionTypeSeg.selectedSegmentIndex == 0 {
                cardViewController.lblCarToRequest.text = "Drive Me: \(driveMeTypes[selectedDriveMeIndex].vehicleType ?? "") (Automatic)".replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "")
            } else {
                cardViewController.lblCarToRequest.text = "Drive Me: \(driveMeTypes[selectedDriveMeIndex].vehicleType ?? "") (Manual)".replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "")
            }
            
            cardViewController.lblFareToPay.text = "\(driveMeTypes[selectedDriveMeIndex].costEstimate ?? "")"
            cardViewController.lblMinutesToWait.text = "\(driveMeTypes[selectedDriveMeIndex].textLabels ?? "")"
            cardViewController.btnRequest.isHidden = false
            
            cardViewController.imgDriveMe.sd_setImage(with: URL(string: driveMeTypes[selectedDriveMeIndex].vehicleICON ?? ""))
            cardViewController.lblDriveMeDistance.text = "\(driveMeTypes[selectedDriveMeIndex].vehicleType ?? "")".replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "").capitalized
            cardViewController.lblDriveMeCost.text = "\(driveMeTypes[selectedDriveMeIndex].costEstimate ?? "")"
            cardViewController.lblDriveMeTime.text = "\(driveMeTypes[selectedDriveMeIndex].textLabels ?? "")"
            
            
            cardViewController.driveMeCarsCollectionView.reloadData()
        }
    }
    
    // MARK: - Buttons
    
    @objc func requestRideBtnPressed(_ sender: UIButton) {
        
        informationTopView.isUserInteractionEnabled = false
        
        makeRideRequestNew()
        
    }
    
    @objc func btnAddPromoTextPressed(_ sender: UIButton) {
        
        if !promoVerified {
            
            let view: PopoverEnterText = try! SwiftMessages.viewFromNib(named: "PopoverEnterText", bundle: sdkBundle!)
            view.loadPopup(title: "Add Promo", message: "\nType the promocode you want to use below and verify.\n", image: "", placeholderText: "Type Promo Code", type: "")
            view.proceedAction = {
               SwiftMessages.hide()
                if view.txtPopupText.text != "" {
                   self.cardViewController.txtPromo.text = view.txtPopupText.text!
                   self.promoText = view.txtPopupText.text!
                   self.cardViewController.requestingLoadingView.isHidden = false
                   self.cardViewController.requestingLoadingView.createLoadingNormal()
                   self.verifyPromoCode()
               } else {
                   self.showAlerts(title: "",message: "Promo Code required.")
               }
            }
            view.cancelAction = {
               SwiftMessages.hide()
            }
            view.btnProceed.setTitle("Verify Promo", for: .normal)
            view.configureDropShadow()
            var config = SwiftMessages.defaultConfig
            config.duration = .forever
            config.presentationStyle = .bottom
            config.dimMode = .gray(interactive: false)
            SwiftMessages.show(config: config, view: view)
            
        } else {
            promoVerified = false
            promoText = ""
            cardViewController.promoVerifiedView.isHidden = true
            cardViewController.lblPromoVerified.text = "Promo code applied successfully."
            cardViewController.txtPromo.text = ""
            cardViewController.btnValidatePromo.setTitle("Verify Promo", for: UIControl.State())
            
            self.view.layoutIfNeeded()
            
            self.promoPageReveal(open: true)
        }
        
    }
    
    @objc func btnProceedConfirmPressed(_ sender: UIButton) {
        if cardViewController.txtParcelName.text == "" {
            showAlerts(title: "", message: "Parcel name is required.")
        } else if cardViewController.txtReceiversName.text == "" {
            showAlerts(title: "", message: "Receiver's name is required.")
        } else if cardViewController.txtReceiversNumber.text == "" {
            showAlerts(title: "", message: "Receiver's number is required.")
        } else {
            
            stage = "Confirmation"
            cardViewController.requestingViewConstraint.constant = 250
            cardViewController.confirmRequestView.alpha = 0.0
            cardViewController.confirmRequestView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.cardViewController.confirmRequestView.alpha = 1.0
            }
            
            changeStageHeight()
        }
    }
    
    @objc func btnParcelPressed(_ sender: UIButton) {
        
        cardViewController.smallView.layer.borderColor = littleBlue?.cgColor
        cardViewController.mediumView.layer.borderColor = UIColor.clear.cgColor
        cardViewController.smallView.layer.shadowColor = littleBlue?.cgColor
        cardViewController.mediumView.layer.shadowColor = UIColor.lightGray.cgColor
        
        cardViewController.imgSmallCheck.isHidden = false
        cardViewController.imgMediumCheck.isHidden = true
        
        for i in (0..<CarTypes.count) {
            if CarTypes[i].uppercased() == "PARCELS" {
                selectedCarIndex = i
                continue
            }
        }
        
        parcelSize = "SMALL"
        
        cardViewController.imgCarToRequest.sd_setImage(with: URL(string: carActiveIcons[selectedCarIndex]))
        cardViewController.lblCarToRequest.text = "Parcel: Small"
        cardViewController.lblFareToPay.text = "\(carCostEstimate[selectedCarIndex])"
        cardViewController.lblMinutesToWait.text = "\(carVTypeTimes[selectedCarIndex])"
        
    }
    
    @objc func btnGoodsPressed(_ sender: UIButton) {
        
        cardViewController.mediumView.layer.borderColor = littleBlue?.cgColor
        cardViewController.smallView.layer.borderColor = UIColor.clear.cgColor
        cardViewController.smallView.layer.shadowColor = UIColor.lightGray.cgColor
        cardViewController.mediumView.layer.shadowColor = littleBlue?.cgColor
        
        cardViewController.imgSmallCheck.isHidden = true
        cardViewController.imgMediumCheck.isHidden = false
        
        for i in (0..<CarTypes.count) {
            if CarTypes[i].uppercased() == "GOODS" {
                selectedCarIndex = i
                continue
            }
        }
        
        parcelSize = "MEDIUM"
        
        cardViewController.imgCarToRequest.sd_setImage(with: URL(string: carActiveIcons[selectedCarIndex]))
        cardViewController.lblCarToRequest.text = "Parcel: Medium"
        cardViewController.lblFareToPay.text = "\(carCostEstimate[selectedCarIndex])"
        cardViewController.lblMinutesToWait.text = "\(carVTypeTimes[selectedCarIndex])"
    }
    
    @objc func btnDriveMeProceedPressed(_ sender: UIButton) {
        
        stage = "Confirmation"
        
        cardViewController.requestingViewConstraint.constant = 250
        cardViewController.confirmRequestView.alpha = 0.0
        cardViewController.confirmRequestView.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.cardViewController.confirmRequestView.alpha = 1.0
        }
        
        changeStageHeight()
        
    }
    
    @objc func driveMeToggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isManual = false
        } else {
            isManual = true
        }
        
        cardViewController.imgCarToRequest.sd_setImage(with: URL(string: driveMeTypes[selectedDriveMeIndex].vehicleICON ?? ""))
        if cardViewController.transmissionTypeSeg.selectedSegmentIndex == 0 {
            cardViewController.lblCarToRequest.text = "Drive Me: \(driveMeTypes[selectedDriveMeIndex].vehicleType ?? "") (Automatic)".replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "")
        } else {
            cardViewController.lblCarToRequest.text = "Drive Me: \(driveMeTypes[selectedDriveMeIndex].vehicleType ?? "") (Manual)".replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "")
        }
        cardViewController.lblFareToPay.text = "\(driveMeTypes[selectedDriveMeIndex].costEstimate ?? "")"
        cardViewController.lblMinutesToWait.text = "\(driveMeTypes[selectedDriveMeIndex].textLabels ?? "")"
        cardViewController.btnRequest.isHidden = false
        
        cardViewController.imgDriveMe.sd_setImage(with: URL(string: driveMeTypes[selectedDriveMeIndex].vehicleICON ?? ""))
        cardViewController.lblDriveMeCarType.text = "\(CarTypes[selectedCarIndex])"
        cardViewController.lblDriveMeDistance.text = "\(driveMeTypes[selectedDriveMeIndex].vehicleType ?? "")".replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "").capitalized
        cardViewController.lblDriveMeCost.text = "\(driveMeTypes[selectedDriveMeIndex].costEstimate ?? "")"
        cardViewController.lblDriveMeTime.text = "\(driveMeTypes[selectedDriveMeIndex].textLabels ?? "")"
        
    }
    

    @objc func btnPaymentsPressed(_ sender: UIButton) {
        
        confirmBtn = "Payments"
        cardViewController.confirmRequestPayments.isHidden = false
        cardViewController.confirmRequestPromo.isHidden = true
        cardViewController.confirmRequestPreferred.isHidden = true
        
        if (makerChecker && reasonTest == "") || (!makerChecker && !isCorporate) {
            cardViewController.indiviCorporateSeg.selectedSegmentIndex = 0
            isCorporate = false
            cardViewController.corporateView.isHidden = true
            cardViewController.paymentOptionsTableView.alpha = 0.0
            cardViewController.paymentOptionsTableView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.cardViewController.paymentOptionsTableView.alpha = 1.0
            }
        } else {
            promoVerified = false
            promoText = ""
            cardViewController.indiviCorporateSeg.selectedSegmentIndex = 1
            isCorporate = true
            cardViewController.paymentOptionsTableView.isHidden = true
            cardViewController.corporateView.alpha = 0.0
            cardViewController.corporateView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.cardViewController.corporateView.alpha = 1.0
            }
        }
        
        adjustSiteAccordingToButton(val: 0)
        
        confirmViewButtonsViewSetup(open: true)
        
        changeConfirmHeight(open: true)
        
    }
    
    @objc func btnShowCarDetailsPressed(_ sender: UIButton) {
        let index = sender.tag
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: CarTypes[index], message: "\n\(carBannerText[index])\n", image: carBannerImage[index], action: "")
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
    
    @objc func btnPaymentTypePressed(_ sender: UIButton) {
        
        let index = sender.tag
        
        selectedPaymentMode = index
        
        cardViewController.paymentOptionsTableView.createLoadingNormal()
        
        cardViewController.paymentOptionsTableView.reloadData()
        
        cardViewController.paymentOptionsTableView.removeAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.paymentsPageReveal(open: false)
        }
    }
    
    @objc func btnPromoCodePressed(_ sender: UIButton) {
        
        if !cardViewController.lblPaymentMode.text!.contains("Corporate") {
            confirmBtn = "Promo"
            cardViewController.confirmRequestPayments.isHidden = true
            cardViewController.confirmRequestPromo.isHidden = false
            cardViewController.confirmRequestPreferred.isHidden = true
            
            cardViewController.txtPromo.text = ""
            
            if promoVerified {
                cardViewController.promoVerifiedView.alpha = 0.0
                cardViewController.promoVerifiedView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.cardViewController.promoVerifiedView.alpha = 1.0
                }
                cardViewController.btnValidatePromo.setTitle("Remove Promo", for: UIControl.State())
            } else {
                cardViewController.promoVerifiedView.isHidden = true
                cardViewController.btnValidatePromo.setTitle("Verify Promo", for: UIControl.State())
            }
            
            self.view.layoutIfNeeded()
            
            adjustSiteAccordingToButton(val: 1)
            
            confirmViewButtonsViewSetup(open: true)
            
            changeConfirmHeight(open: true)
            
        } else {
            showAlerts(title: "", message: "You cannot apply a promo code to a Corporate trip. Switch back to individual mode to use Promo")
        }
    }
    
    @objc func btnPreferredDriverPressed(_ sender: UIButton) {
        
        cardViewController.preferredDriverTableView.reloadData()
        
        confirmBtn = "Preferred"
        
        cardViewController.confirmRequestPayments.isHidden = false
        cardViewController.confirmRequestPromo.isHidden = true
        cardViewController.confirmRequestPreferred.isHidden = true
        
        am.savePreferredDriver(data: "")
        am.savePreferredDriverImage(data: "")
        am.savePreferredDriverName(data: "")
        
        cardViewController.lblPreferredDriver.text = "Preferred Driver"
        cardViewController.imgPreferred.image = UIImage()
        cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
        cardViewController.btnPreferredDriver.alpha = 0.6
        cardViewController.btnPreferredDriver.layer.cornerRadius = 0
        cardViewController.btnPreferredDriver.clipsToBounds = false
        preferredDriver = false
        
        preferredDriversArr.removeAll()
        cardViewController.preferredDriverTableView.reloadData()
        
        adjustSiteAccordingToButton(val: 2)
        
        confirmViewButtonsViewSetup(open: true)
        
        changeConfirmHeight(open: true)
        
        cardViewController.preferredDriverTableView.createLoadingNormal()
        
        pickDriver()
        
    }
    
    @IBAction func btnBackStagePressed(_ sender: UIButton) {
        
        switch stage {
        case "FareEstimate", "Confirmation", "Parcel","DriveMe":
            
            if stage == "Confirmation" {
                
                cardViewController.confirmRequestView.isHidden = true
                cardViewController.driveMeView.isHidden = true
                cardViewController.parcelTypeView.isHidden = true
                
                cardViewController.txtParcelName.text = ""
                cardViewController.txtReceiversName.text = ""
                cardViewController.txtReceiversNumber.text = ""
                cardViewController.txtReceiversAddress.text = ""
                cardViewController.homeOfficeSeg.selectedSegmentIndex = 0
                
                if !cardViewController.confirmRequestPreferred.isHidden {
                    preferredPageReveal(open: false)
                }
                
                if !cardViewController.confirmRequestPayments.isHidden {
                    paymentsPageReveal(open: false)
                }
                
                if !cardViewController.confirmRequestPromo.isHidden {
                    promoPageReveal(open: false)
                }
                
                cardViewController.btnRequest.isHidden = false
                
                stage = "FareEstimate"
                
                changeStageHeight()
                
            } else if stage == "Parcel" {
                
                cardViewController.confirmRequestView.isHidden = true
                cardViewController.driveMeView.isHidden = true
                cardViewController.parcelTypeView.isHidden = true
                
                cardViewController.txtParcelName.text = ""
                cardViewController.txtReceiversName.text = ""
                cardViewController.txtReceiversNumber.text = ""
                cardViewController.txtReceiversAddress.text = ""
                cardViewController.homeOfficeSeg.selectedSegmentIndex = 0
                
                if !cardViewController.confirmRequestPreferred.isHidden {
                    preferredPageReveal(open: false)
                }
                
                if !cardViewController.confirmRequestPayments.isHidden {
                    paymentsPageReveal(open: false)
                }
                
                if !cardViewController.confirmRequestPromo.isHidden {
                    promoPageReveal(open: false)
                }
                
                stage = "FareEstimate"
                
                changeStageHeight()
                
            } else if stage == "DriveMe" {
                
                cardViewController.confirmRequestView.isHidden = true
                cardViewController.parcelTypeView.isHidden = true
                cardViewController.driveMeView.isHidden = true
                
                cardViewController.transmissionTypeSeg.selectedSegmentIndex = 0
                
                selectedDriveMeIndex = 0
                
                if !cardViewController.confirmRequestPreferred.isHidden {
                    preferredPageReveal(open: false)
                }
                
                if !cardViewController.confirmRequestPayments.isHidden {
                    paymentsPageReveal(open: false)
                }
                
                if !cardViewController.confirmRequestPromo.isHidden {
                    promoPageReveal(open: false)
                }
                
                stage = "FareEstimate"
                
                changeStageHeight()
                
            } else {
                
                selectedPaymentMode = 0
                cardViewController.indiviCorporateSeg.selectedSegmentIndex = 0
                isCorporate = false
                mappingCorporate = false
                reasonTest = ""
                if PaymentModes.count > 0 {
                    PaymentMode = "\(PaymentModes[selectedPaymentMode])"
                    PaymentModeID = "\(PaymentModeIDs[selectedPaymentMode])"
                    cardViewController.lblPaymentMode.text = "\(PaymentModes[selectedPaymentMode])"
                }
                cardViewController.lblPaymentMode.textColor = littleBlue
                cardViewController.btnRequest.backgroundColor = cn.littleSDKThemeColor
                
                if CarTypes.count > 0 && selectedCarIndex <= CarTypes.count {
                    cardViewController.btnRequest.setTitle("Request \(CarTypes[selectedCarIndex].capitalized)", for: UIControl.State())
                }
                
                myDestination = CLLocation()
                destinationCoordinate = nil
                destinationLL = ""
                dropOffName = ""
                
                resetPreferredDriverBtn()
                
                i = 0
                animationPath = GMSMutablePath()
                animationPolyline.map = nil
                path = GMSPath()
                if animatetimer != nil {
                    animatetimer.invalidate()
                }
                
                gmsMapView.clear()
                nearDriverMarker.removeAll()
                
                menuBtn.isHidden = false
                
                cardViewController.confirmRequestPromo.isHidden = true
                cardViewController.confirmRequestPayments.isHidden = true
                cardViewController.confirmRequestPreferred.isHidden = true
                
                cardViewController.confirmRequestView.isHidden = true
                cardViewController.parcelTypeView.isHidden = true
                cardViewController.driveMeView.isHidden = true
                
                cardViewController.suggestedPlacesView.isHidden = false
                cardViewController.suggestedPlacesView.alpha = 0.0
                
                if initialPlaceCoordinates != nil {
                    let camera = GMSCameraPosition.camera(withLatitude: initialPlaceCoordinates.latitude,
                                                          longitude: initialPlaceCoordinates.longitude, zoom: 16)
                    gmsMapView.isMyLocationEnabled = true
                    
                    let group = DispatchGroup()
                    group.enter()
                    DispatchQueue.main.async {
                        self.gmsMapView.animate(to: camera)
                        group.leave()
                    }
                    group.notify(queue: .main) {
                        DispatchQueue.main.async {
                            self.checkLocation()
                        }
                    }
                } else {
                    checkLocation()
                }
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.informationTopView.alpha = 0.0
                    self.cardViewController.carTypeView.alpha = 0.0
                    self.cardViewController.popularDropOffView.alpha = 0.0
                    self.cardViewController.suggestedPlacesView.alpha = 1.0
                }, completion: { finished in
                    self.informationTopView.isHidden = true
                    self.cardViewController.carTypeView.isHidden = true
                    self.cardViewController.popularDropOffView.isHidden = true
                    self.informationTopView.alpha = 1.0
                    self.cardViewController.carTypeView.alpha = 1.0
                    self.cardViewController.popularDropOffView.alpha = 1.0
                })
                
                approxDestinationTimeView.isHidden = true
                let font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17.0)!
                cardViewController.btnDestination.titleLabel?.font =  font
                cardViewController.btnDestination.setTitle("Where do you want to go \(am.getFullName()?.components(separatedBy: " ")[0].capitalized ?? "")?", for: UIControl.State())
                btnDestinationInformation.setTitle("", for: UIControl.State())
                
                cardViewController.suggestedPlacesCollectionView.isHidden = false
                cardViewController.suggestedPlacesCollectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionView.ScrollPosition.left, animated: true)
                
                stage = "Destination"
                
                changeStageHeight()
                
            }
            
        default:
            return
        }
        
    }
    
    @IBAction func homeInBtnPressed(_ sender: UIButton) {
        if initialPlaceCoordinates != nil {
            let camera = GMSCameraPosition.camera(withLatitude: initialPlaceCoordinates.latitude,
                                                  longitude: initialPlaceCoordinates.longitude, zoom: 16)
            gmsMapView.isMyLocationEnabled = true
            
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async {
                self.gmsMapView.animate(to: camera)
                group.leave()
            }
            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    // let loadBackGround = self.createLoadingScreen()
                    // self.view.addSubview(loadBackGround)
                    self.getLocationName(currentCoordinate: self.initialPlaceCoordinates)
                }
            }
        } else {
            
        }
    }
    
    
    @IBAction func btnPickupPressed(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self, selector: #selector(fromPickup),name:NSNotification.Name(rawValue: "PICKUP"), object: nil)
          
        am.saveFromSearch(data: true)
        isToReload = false
        am.savePICKUPADDRESS(data: currentPlaceName ?? "")
        am.saveFromPickupLoc(data: true)
        
        let visibleRegion = gmsMapView.projection.visibleRegion()
        
        am.saveFarLeft(data: "\(visibleRegion.farLeft.latitude),\(visibleRegion.farLeft.longitude)")
        am.saveNearRight(data: "\(visibleRegion.nearRight.latitude),\(visibleRegion.nearRight.longitude)")
        
        beforeSearchSetup()
        
        if let viewController = UIStoryboard(name: "Trip", bundle: sdkBundle!).instantiateViewController(withIdentifier: "SearchLocViewController") as? SearchLocViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func btnDestinationPressed(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self, selector: #selector(fromNewPickupDropOff(_:)),name:NSNotification.Name(rawValue: "PICKUPDROPOFF"), object: nil)
        
        am.saveFromPickupLoc(data: false)
        
        let visibleRegion = gmsMapView.projection.visibleRegion()
        
        am.saveFarLeft(data: "\(visibleRegion.farLeft.latitude),\(visibleRegion.farLeft.longitude)")
        am.saveNearRight(data: "\(visibleRegion.nearRight.latitude),\(visibleRegion.nearRight.longitude)")
        
        beforeSearchSetup()
        
        if let viewController = UIStoryboard(name: "Trip", bundle: sdkBundle!).instantiateViewController(withIdentifier: "SearchMultiple") as? SearchMultiple {
            if let navigator = self.navigationController {
                viewController.locationStopsArr = locationStopsArr
                viewController.locationsEstimateSet = locationsEstimateSet
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @objc func btnRemoveDestination(_ sender: UIButton) {
        approxDestinationTimeView.isHidden = true
        let font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17.0)!
        cardViewController.btnDestination.titleLabel?.font =  font
        cardViewController.btnDestination.setTitle("Where do you want to go \(am.getFullName()?.components(separatedBy: " ")[0].capitalized ?? "")?", for: UIControl.State())
        btnDestinationInformation.setTitle("", for: UIControl.State())
    }
    
    // MARK: - Server Calls and Handlers

    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID()!)\",\"MobileNumber\":\"\(am.getSDKMobileNumber()!)\",\"IMEI\":\"\(am.getIMEI()!)\",\"CodeBase\":\"\(am.getMyCodeBase()!)\",\"PackageName\":\"\(am.getSDKPackageName()!)\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation()!)\",\"LatLong\":\"\(am.getCurrentLocation()!)\",\"TripID\":\"\(am.getTRIPID()!)\",\"City\":\"\(am.getCity()!)\",\"RegisteredCountry\":\"\(am.getCountry()!)\",\"Country\":\"\(am.getCountry()!)\",\"UniqueID\":\"\(am.getMyUniqueID()!)\",\"CarrierName\":\"\(getCarrierName()!)\""
        
        return str
    }
    
    func getPendingRequests() {
        NotificationCenter.default.addObserver(self, selector: #selector(loadPendingRequests),name:NSNotification.Name(rawValue: "CHECKFORTRIPJSONData"), object: nil)
        
        am.saveStillRequesting(data: false)
        
        let dataToSend = "{\"FormID\":\"CHECKFORTRIP_V1\"\(commonCallParams())}"
        
        hc.makeServerCall(sb: dataToSend, method: "CHECKFORTRIPJSONData", switchnum: 0)
    }
    
    @objc func loadPendingRequests(_ notification: NSNotification) {
        
        let data = notification.userInfo?["data"] as? Data
        
        if data == nil {
            DispatchQueue.main.async {
                let loadBackGround = self.createLoadingScreen()
                self.view.addSubview(loadBackGround)
                self.getPendingRequests()
            }
            return
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CHECKFORTRIPJSONData"), object: nil)
        
        cardViewController.requestingLoadingView.alpha = 1.0
        cardViewController.requestingLoadingView.isHidden = true
        cardViewController.requestingLoadingView.removeAnimation()
        
        do {
            let getPendingResults = try JSONDecoder().decode(GetPendingResults.self, from: data!)
            let results = getPendingResults[0]
            processGetPendingResults(results: results)
            
        } catch {
        }
        
        cardViewController.selectDestinationView.removeAnimation()
    }
    
    func processGetPendingResults(results: GetPendingResult) {
        PaymentModes.removeAll()
        PaymentModeIDs.removeAll()
        
        var paymentModesString = ""
        var paymentModeIDsString = ""
        
        for each in results.wallets ?? [] {
            PaymentModes.append(each.walletName ?? "")
            paymentModesString = paymentModesString + "\(each.walletName ?? "");"
            PaymentModeIDs.append(each.walletUniqueID ?? "")
            paymentModeIDsString = paymentModeIDsString + "\(each.walletUniqueID ?? "");"
        }
        
        am.savePaymentModes(data: paymentModesString)
        am.savePaymentModeIDs(data: paymentModeIDsString)

        if results.recentTrips != nil {
            for each in results.recentTrips! {
                if !(locationTitleArr.contains(each.dropOffName ?? "")) {
                    locationTitleArr.append(each.dropOffName ?? "")
                    locationSubTitleArr.append(each.dropOffName ?? "")
                    locationCoordsArr.append(each.dropOffLL ?? "0.0,0.0")
                }
            }
            
            am.saveRecentPlacesNames(data: locationTitleArr)
            am.saveRecentPlacesFormattedAddress(data: locationSubTitleArr)
            am.saveRecentPlacesCoords(data: locationCoordsArr)
            
            reloadLocations()
        }
        
        cardViewController.makerCheckerView.isHidden = true
        cardViewController.indiviCorporateSeg.isHidden = true
        cardViewController.corporateViewConstraint.constant = 8
        
        if results.status != "000" {
            
            if results.status == "001" {
                am.saveStillRequesting(data: true)
            }
            if am.getStillRequesting() == true {
                self.removeLoadingPage()
                am.saveStillRequesting(data: false)
                DispatchQueue.main.async {
                    if self.cardViewController.requestingLoadingView.isHidden {
                        self.cardViewController.lblRequestingText.text = "Loading trip details..."
                        self.cardViewController.requestingLoadingView.isHidden = false
                        self.cardViewController.requestingLoadingView.createLoadingNormal()
                        self.cardViewController.lblRequestingText.isHidden = false
                        self.cardViewController.requestingLoadingView.bringSubviewToFront(self.cardViewController.lblRequestingText)
                        self.forwardCount = 1
                        self.getMakeRequestStatus()
                    }
                }
            } else {
                
                // let timerdelay=Double(60.0)
                // self.providertimer = Timer.scheduledTimer(timeInterval: timerdelay, target: self, selector: #selector(callGetProvider), userInfo: nil, repeats: true)
                self.callGetProvider()
                
                am.saveFORWARDCOUNT(data: results.forwardCount ?? "1")
                
                forwardCount = Int(am.getFORWARDCOUNT()!)!
                
                cardViewController.paymentOptionsTableView.reloadData()
                
                am.saveCity(data: results.city ?? "")
                am.saveCountry(data: results.country ?? "")
                
                PaymentMode = "\(PaymentModes[selectedPaymentMode])"
                PaymentModeID = "\(PaymentModeIDs[selectedPaymentMode])"
                cardViewController.lblPaymentMode.text = "\(PaymentModes[selectedPaymentMode])"

            }
            DispatchQueue.main.async {
                self.removeLoadingPage()
            }
            
        } else {
            DispatchQueue.main.async {
                self.am.saveTRIPID(data: results.tripID ?? "")
                self.removeLoadingPage()
                self.resumeTrip()
            }
        }
    }
    
    func getLocationNameFromKB(currentCoordinate: CLLocationCoordinate2D) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadLocationName),name:NSNotification.Name(rawValue: "GETLOCATIONNAMEJSONData"), object: nil)
        
        let dataToSend = "{\"FormID\":\"GETLOCATIONNAME\"\(commonCallParams()),\"LocationName\":{\"Latitude\":\"\(currentCoordinate.latitude)\",\"Longitude\":\"\(currentCoordinate.longitude)\",\"LocationNameAtLL\":\"\"}}"
        
        hc.makeServerCall(sb: dataToSend, method: "GETLOCATIONNAMEJSONData", switchnum: 0)
        
    }
    
    @objc func loadLocationName(_ notification: NSNotification) {
        
        let data = notification.userInfo?["data"] as? Data
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "GETLOCATIONNAMEJSONData"), object: nil)
        
        if data != nil {
            do {
                let defaultMessage = try JSONDecoder().decode(DefaultMessage.self, from: data!)
                
                if defaultMessage.status == "000" {
                    
                    self.initialPlaceName = defaultMessage.message?.cleanLocationNames()
                    self.currentPlaceName = defaultMessage.message?.cleanLocationNames()
                    DispatchQueue.main.async {
                        self.pickupName = defaultMessage.message ?? ""
                        self.currentPlaceName = defaultMessage.message ?? ""
                        self.am.savePICKUPADDRESS(data: defaultMessage.message?.cleanLocationNames() ?? "")
                        self.cardViewController.btnPickup.layer.removeAllAnimations()
                        self.cardViewController.btnPickup.setTitle(defaultMessage.message?.components(separatedBy: ",")[0].cleanLocationNames(), for: UIControl.State())
                        self.btnPickupInformation.setTitle(defaultMessage.message?.components(separatedBy: ",")[0].cleanLocationNames(), for: UIControl.State())
                        
                        let unique_id = NSUUID().uuidString
                        self.locationsEstimateSet = LocationsEstimateSetSDK(pickupLocation: LocationSetSDK(id: unique_id, name: defaultMessage.message?.cleanLocationNames() ?? "", subname: defaultMessage.message?.cleanLocationNames() ?? "", latitude: "\(self.currentPlaceCoordinates.latitude)", longitude: "\(self.currentPlaceCoordinates.longitude)", phonenumber: "", instructions: ""), dropoffLocations: self.locationsEstimateSet?.dropoffLocations ?? [])
                    }
                    
                    printVal(object: "Location KB")
                    
                    DispatchQueue.main.async {
                        self.getPendingRequests()
                    }
                    
                } else {
                    self.removeLoadingPage()
                }
                
            } catch {
                self.removeLoadingPage()
            }
        } else {
            if self.originCoordinate != nil {
                self.getLocationName(currentCoordinate: self.originCoordinate)
            }
        }
        
    }
    
    func getFareEstimateMultiple() {
        
        var dropOffDetails = ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadFareEstimate(_:)),name:NSNotification.Name(rawValue: "GETESTIMATEJSONData"), object: nil)
        
        let arr = locationsEstimateSet?.dropoffLocations ?? []
        
        for i in (0..<arr.count) {
            dropOffDetails.append("{\"DropOffNumber\":\"\(i+1)\",\"DropoffLL\":\"\(arr[i].latitude),\(arr[i].longitude)\",\"DropoffAddress\":\"\(arr[i].name)\"}")
            if i < arr.count-1 {
                dropOffDetails.append(",")
            }
        }
        
        let dataToSend = "{\"FormID\":\"GETESTIMATE\"\(commonCallParams()),\"GetEstimate\":{\"PickupLL\":\"\(originLL)\",\"PickupAddress\":\"\(pickupName)\",\"DropOffDetails\":[\(dropOffDetails)]}}"
        
        hc.makeServerCall(sb: dataToSend, method: "GETESTIMATEJSONData", switchnum: 0)
        
    }

    @objc func loadFareEstimate(_ notification: NSNotification) {
        
        let data = notification.userInfo?["data"] as? Data
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETESTIMATEJSONData"), object: nil)
        
        if providertimer != nil {
            providertimer.invalidate()
        }
        
        if data == nil {
            DispatchQueue.main.async {
                self.getFareEstimateMultiple()
            }
            return
        }
        
        do {
            
            let jsonDecoder = JSONDecoder()
            let jsonEstimates = try? jsonDecoder.decode([FareEstimate_Base].self, from: data!)
            
            carTypePriceEstimate.removeAll()
            CarTypes.removeAll()
            SubVehicleTypes.removeAll()
            carVTypeTimes.removeAll()
            carMinFares.removeAll()
            carBaseFares.removeAll()
            carPerKms.removeAll()
            carPerMins.removeAll()
            carMaxPasss.removeAll()
            carActiveIcons.removeAll()
            carOldTripCost.removeAll()
            carCostEstimate.removeAll()
            carCurrency.removeAll()
            carVehicleCategory.removeAll()
            driveMeTypes.removeAll()
            carisNew.removeAll()
            carBannerImage.removeAll()
            carBannerText.removeAll()
            
            if jsonEstimates?.count ?? 0 > 0 {
                for each in jsonEstimates! {
                    if each.subVehicleType == "MAIN" {
                        if each.minAmount == each.maxAmount {
                            carTypePriceEstimate.append("\(each.currency?.capitalized ?? am.getGLOBALCURRENCY()!.capitalized). \(Int(each.minAmount ?? 0))")
                        } else {
                            carTypePriceEstimate.append("\(each.currency?.capitalized ?? am.getGLOBALCURRENCY()!.capitalized). \(Int(each.minAmount ?? 0)) - \(Int(each.maxAmount ?? 0))")
                        }
                        carOldTripCost.append("\(each.oldTripCost ?? "0")")
                        
                        carCostEstimate.append(each.costEstimate?.capitalized ?? "")
                        carCurrency.append(each.currency?.capitalized ?? am.getGLOBALCURRENCY()!.capitalized)
                        CarTypes.append(each.vehicleType ?? "")
                        SubVehicleTypes.append(each.subVehicleType ?? "")
                        carVTypeTimes.append(each.textLabels ?? "")
                        carMinFares.append("\(each.minAmount ?? 0.0)")
                        carBaseFares.append("\(each.basePrice ?? 0.0)")
                        carPerKms.append("\(each.costDistance ?? 0.0)")
                        carPerMins.append("\(each.costTime ?? 0.0)")
                        carMaxPasss.append("\(each.maxSize ?? 0)")
                        carVehicleCategory.append("\(each.vehicleCategory ?? "")")
                        carActiveIcons.append(each.vehicleICON ?? "")
                        carisNew.append(each.newitem ?? "")
                        carBannerImage.append(each.bannerImage ?? "")
                        carBannerText.append(each.bannerText ?? "")
                    } else if each.subVehicleType == "DRIVEME" {
                        driveMeTypes.append(each)
                    }
                }
            }
            
            if CarTypes.count > 0 {
                if !mappingCorporate {
                    
                    self.cardViewController.carTypeLoadingView.removeAnimation()
                    
                    var num = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst) - CGFloat((CarTypes.count * 80) - 75)
                    
                    if num < 1 {
                        num = 60
                    } else if num > yPositionDestinationOriginal! {
                        num = yPositionDestinationOriginal!
                    }
                    
                    if CarTypes.count > 3 {
                        yPositionFareOriginal =  view.frame.height - (topSafeAreaConst + bottomSafeAreaConst) - 400
                    } else {
                        yPositionFareOriginal = num
                    }
                    
                    if num > (110 + topSafeAreaConst) {
                        yPositionFareOpen = num
                    } else {
                        yPositionFareOpen = 130
                    }
                    
                    if getPhoneFaceIdType() {
                        yPositionFareOriginal = yPositionFareOriginal! - 25
                        yPositionFareOpen = yPositionFareOpen! - 25
                    }
                    
                    cardViewController.driveMeCarsCollectionView.reloadData()
                    
                    cardViewController.carTypeTableView.isHidden = false
                    
                    if carTypePriceEstimate[0] == "" {
                        carTypePriceEstimate.removeAll()
                        for _ in CarTypes {
                            carTypePriceEstimate.append("  ")
                        }
                        cardViewController.carTypeTableView.reloadData()
                    } else {
                        cardViewController.carTypeTableView.reloadData()
                    }
                    
                    changeStageHeight()
                    
                    if approvedSelected {
                        
                        approvedSelected = false
                        
                        for i in (0..<CarTypes.count) {
                            if carCorporateSelected.uppercased() == CarTypes[i].uppercased() {
                                selectedCarIndex = i
                            }
                        }
                        
                        cardViewController.imgCarToRequest.image = getImage(named: CarTypes[selectedCarIndex].uppercased(), bundle: sdkBundle!)
                        if CarTypes[selectedCarIndex] == "GOODS" {
                            cardViewController.lblCarToRequest.text = "Parcel: Medium"
                        } else if CarTypes[selectedCarIndex] == "PARCELS" {
                            cardViewController.lblCarToRequest.text = "Parcel: Small"
                        } else {
                            cardViewController.lblCarToRequest.text = CarTypes[selectedCarIndex]
                        }
                        cardViewController.lblFareToPay.text = "\(carCostEstimate[selectedCarIndex])"
                        cardViewController.lblMinutesToWait.text = "\(carVTypeTimes[selectedCarIndex])"
                        
                        am.savePreferredDriver(data: "")
                        am.savePreferredDriverImage(data: "")
                        am.savePreferredDriverName(data: "")
                        
                        cardViewController.lblPreferredDriver.text = "Preferred Driver"
                        cardViewController.btnPreferredDriver.setImage(getImage(named: "new_preferred", bundle: sdkBundle!), for: UIControl.State())
                        cardViewController.imgPreferred.image = UIImage()
                        cardViewController.btnPreferredDriver.alpha = 0.6
                        cardViewController.btnPreferredDriver.layer.cornerRadius = 0
                        cardViewController.btnPreferredDriver.clipsToBounds = false
                        preferredDriver = false
                        
                        cardViewController.btnRequest.setTitle("Request \(CarTypes[selectedCarIndex].capitalized) as Corporate", for: UIControl.State())
                        
                        stage = "Confirmation"
                        
                        cardViewController.requestingViewConstraint.constant = 250
                        cardViewController.confirmRequestView.alpha = 0.0
                        cardViewController.confirmRequestView.isHidden = false
                        
                        UIView.animate(withDuration: 0.3) {
                            self.cardViewController.confirmRequestView.alpha = 1.0
                        }
                        
                        changeStageHeight()
                    }
                    
                } else {
                    
                    cardViewController.requestingLoadingView.removeAnimation()
                    cardViewController.requestingLoadingView.isHidden = true
                    
                    cardViewController.imgCarToRequest.image = getImage(named: CarTypes[selectedCarIndex].uppercased(), bundle: sdkBundle!)
                    cardViewController.lblCarToRequest.text = CarTypes[selectedCarIndex]
                    cardViewController.lblFareToPay.text = "\(carCostEstimate[selectedCarIndex])"
                    cardViewController.lblMinutesToWait.text = "\(carVTypeTimes[selectedCarIndex])"
                    
                    paymentsPageReveal(open: false)
                }
            } else {
                
                showAlerts(title: "", message: "Ooops! It looks like Little has encountered an error loading vehicle types. We are however working on it...")
                
                stage = "FareEstimate"
                btnBackStage.sendActions(for: .touchUpInside)
                
            }
            
        } catch {
            printVal(object: "error")
        }
        
    }
    
    @objc func callGetProvider() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadProviders),name:NSNotification.Name(rawValue: "GETPROVIDER"), object: nil)
        
        var vehicleType = ""
        
        if selectedCarIndex < CarTypes.count {
            vehicleType = CarTypes[selectedCarIndex].uppercased()
        }
        
        var dataToSend = "{\"FormID\":\"GETPROVIDER\"\(commonCallParams()),\"PickADriver\":{\"VehicleType\":\"\(vehicleType)\",\"PickupLL\":\"\(currentPlaceCoordinates.latitude),\(currentPlaceCoordinates.longitude)\"}}"
        
        printVal(object: dataToSend)
        
        dataToSend = am.EncryptDataAES(DataToSend: dataToSend) as String
        
        let string = am.DecryptDataKC(DataToSend: cn.link()) as String
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: "Content-Type", value: "application/json; charset=utf-8"),
            HTTPHeader(name: "KeyID", value: "\(am.EncryptDataHeaders(DataToSend: am.getMyKeyID()!))"),
            HTTPHeader(name: "Accounts", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKAccounts()!)"))"),
            HTTPHeader(name: "MobileNumber", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKMobileNumber()!)"))"),
            HTTPHeader(name: "PackageName", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKPackageName()!)"))")
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
                        
                        let dataDict:[String: Data] = ["data": strData]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "GETPROVIDER"), object: nil, userInfo: dataDict)
                        
                        
                    } catch {}
                }
        }
        
    }
    
    @objc func loadProviders(_ notification: Notification) {
        
        let data = notification.userInfo?["data"] as? Data
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "GETPROVIDER"), object: nil)
        
        if data != nil {
            
            do {
                
                let tripProviders = try JSONDecoder().decode(TripProviders.self, from: data!)
                
                let providersArr = tripProviders.providerDriverLocationList ?? []
                
                for i in (0..<providersArr.count) {
                    let driver: LittleDriver = LittleDriver()
                    driver.setDriverId(data: i)
                    driver.setLatitude(data: Double(providersArr[i].latitude ?? "0.0") ?? 0.0)
                    driver.setLongitude(data: Double(providersArr[i].longitude ?? "0.0") ?? 0.0)
                    driver.setBearing(bearing: Double(providersArr[i].bearing ?? "0.0") ?? 0.0)
                    driver.setVehicleTypeId(data: tripProviders.vehicleType ?? "")
                    listDriver.append(driver)
                }
                
                if listDriver.count > 0 {
                    
                    if nearDriverMarker.count > 0 {
                        
                        if nearDriverMarker.count == listDriver.count {
                            DispatchQueue.main.async {
                                self.animateExistingMarkers()
                            }
                        } else if listDriver.count > nearDriverMarker.count {
                            var list = [LittleDriver]()
                            for i in (nearDriverMarker.count..<listDriver.count) {
                                list.append(listDriver[i])
                            }
                            let group = DispatchGroup()
                            group.enter()
                            DispatchQueue.main.async {
                                self.populateMarkers(list: list)
                            }
                            group.notify(queue: .main) {
                                DispatchQueue.main.async {
                                    self.animateExistingMarkers()
                                }
                            }
                            
                        } else if listDriver.count < nearDriverMarker.count {
                            for i in (listDriver.count..<nearDriverMarker.count) {
                                let mark = nearDriverMarker[i]!
                                mark.map = nil
                                nearDriverMarker[i] = nil
                            }
                            DispatchQueue.main.async {
                                self.animateExistingMarkers()
                            }
                        }
                        
                    } else {
                        populateMarkers(list: listDriver)
                    }
                    
                } else {
                    gmsMapView.clear()
                    nearDriverMarker.removeAll()
                }
                
                placeMarkerOnCenter(centerMapCoordinate: currentPlaceCoordinates)
                
            } catch {
                gmsMapView.clear()
                nearDriverMarker.removeAll()

                placeMarkerOnCenter(centerMapCoordinate: currentPlaceCoordinates)
            }
            
        } else {
            gmsMapView.clear()
            nearDriverMarker.removeAll()

            placeMarkerOnCenter(centerMapCoordinate: currentPlaceCoordinates)
        }
    }
    
   
    @objc func loadclosepromo(_ notification: NSNotification) {
        promoPageReveal(open: false)
    }
    
    func verifyPromoCode() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadpromocode),name:NSNotification.Name(rawValue: "VALIDATEPROMOCODE"), object: nil)
        
        am.savePROMOTITLE(data: "")
        am.savePROMOTEXT(data: "")
        am.savePROMOIMAGEURL(data: "")
        
        let datatosend = "FORMID|VALIDATEPROMOCODE_V1|PROMOCODE|\(promoText)|VEHICLETYPE|\(CarTypes[selectedCarIndex].uppercased())|PICKUPLL|\(am.getCurrentLocation()!)|DROPOFFLL|\(destinationLL)|"
        
        // hc.makeServerCall(sb: datatosend, method: "VALIDATEPROMOCODE", switchnum: am.VALIDATEPROMOCODE)
    }
    
    @objc func loadpromocode() {
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "VALIDATEPROMOCODE"), object: nil)
        
        if am.getPROMOTITLE() != "Invalid"  {
            
            cardViewController.promoVerifiedView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.cardViewController.promoVerifiedView.alpha = 1.0
            }
            cardViewController.btnValidatePromo.setTitle("Remove Promo", for: UIControl.State())
            
            // self.view.layoutIfNeeded()
            
            cardViewController.requestingLoadingView.isHidden = true
            cardViewController.requestingLoadingView.removeAnimation()
            
            promoVerified = true
            cardViewController.lblPaymentMode.text = "\(PaymentModes[selectedPaymentMode]) with '\(promoText)' Promo"
            cardViewController.lblPromoVerified.text = "Promo code '\(promoText)' applied successfully."
            cardViewController.txtPromo.text = ""
            
            if am.getPROMOIMAGEURL() != "" {
                
                let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
                view.loadPopup(title: am.getPROMOTITLE() ?? "", message: "\n\(am.getPROMOTEXT() ?? "")\n", image: am.getPROMOIMAGEURL() ?? "", action: "")
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
                
            } else {
                
                cardViewController.requestingLoadingView.isHidden = true
                cardViewController.requestingLoadingView.removeAnimation()
                
                showAlerts(title: "", message: "Your promo has been added.")
                
                self.promoPageReveal(open: false)
                
            }
            
        } else {
            
            cardViewController.promoVerifiedView.isHidden = true
            promoVerified = false
            promoText = ""
            cardViewController.txtPromo.text = ""
            
            cardViewController.lblPromoVerified.text = "Promo code applied successfully."
            
            cardViewController.requestingLoadingView.isHidden = true
            cardViewController.requestingLoadingView.removeAnimation()
            
            self.am.savePROMOTITLE(data: "")
            self.am.savePROMOTEXT(data: "")
            self.am.savePROMOIMAGEURL(data: "")
            self.promoPageReveal(open: true)
            
            if am.getPROMOTEXT() == "" {
                am.savePROMOTEXT(data: "Invalid Promo Code.")
            }
            
            showAlerts(title: "", message: "\(am.getPROMOTEXT()!)")
        }
        
    }
    
    func pickDriver() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPickDriver),name:NSNotification.Name(rawValue: "PICKADRIVERJSONData"), object: nil)
        
        var carType = ""
        
        if CarTypes[selectedCarIndex].lowercased().contains("driveme") {
            carType = (driveMeTypes[selectedDriveMeIndex].vehicleType ?? "").replacingOccurrences(of: "/A", with: "").replacingOccurrences(of: "/M", with: "")
            
            if isManual {
                carType = carType + "/M"
            } else {
                carType = carType + "/A"
            }
        } else {
            carType = CarTypes[selectedCarIndex]
        }
        
        am.saveCarType(data: CarTypes[selectedCarIndex])
        
        let dataToSend = "{\"FormID\":\"PICKADRIVER\"\(commonCallParams()),\"PickADriver\":{\"PickupLL\":\"\(originLL)\",\"PickupAddress\":\"\(pickupName)\",\"VehicleType\":\"\(carType)\"}}"
        
        hc.makeServerCall(sb: dataToSend, method: "PICKADRIVERJSONData", switchnum: 0)
    
    }
    
    @objc func loadPickDriver(_ notification: Notification) {
        
        cardViewController.preferredDriverTableView.removeAnimation()
        
        let data = notification.userInfo?["data"] as? Data
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PICKADRIVERJSONData"), object: nil)
        
        preferredDriversArr.removeAll()
        
        am.savePreferredDriver(data: "")
        am.savePreferredDriverImage(data: "")
        am.savePreferredDriverName(data: "")
        
        if data != nil {
            
            do {
                let preferredDrivers = try JSONDecoder().decode(PreferredDrivers.self, from: data!)
                preferredDriversArr = preferredDrivers.listPreferredDrivers ?? []
                
            } catch {}
            
            finishedLoadingInitialTableCells = false
            cardViewController.preferredDriverTableView.reloadData()
            
        } else {
            finishedLoadingInitialTableCells = false
            cardViewController.preferredDriverTableView.reloadData()
        }
        
        if preferredDriversArr.count == 0 {
            
            showAlerts(title: "", message: "No drivers of \(am.getCarType()!) category are near you at the moment.\nKindly try a different vehicle category as we work on re-routing some to your location.")
            
            if getPhoneFaceIdType() {
                yPositionConfirmOpen = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 425)
            } else {
                yPositionConfirmOpen = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 400)
            }
            
            preferredPageReveal(open: true)
            
        } else {
            if getPhoneFaceIdType() {
                yPositionConfirmOpen = view.frame.height - ((CGFloat(preferredDriversArr.count) * 75.0) + topSafeAreaConst + bottomSafeAreaConst + 325.0)
            } else {
                yPositionConfirmOpen = view.frame.height - ((CGFloat(preferredDriversArr.count) * 75.0) + topSafeAreaConst + bottomSafeAreaConst + 300.0)
            }
            
            if (yPositionConfirmOpen ?? 0.0) < 150.0 {
                yPositionConfirmOpen = 150.0
            }
            
            preferredPageReveal(open: true)
        }
        
    }
    
    @objc func fromNewPickupDropOff(_ notification: Notification) {
        
        let data = notification.userInfo?["LocationsEstimateSet"] as? LocationsEstimateSetSDK
        
        cardViewController.suggestedPlacesCollectionView.reloadData()
        cardViewController.popularDropOffTable.reloadData()
        cardViewController.confirmRequestView.isHidden = true
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: notification.name.rawValue), object: nil)

        if data != nil {
            
            self.locationsEstimateSet = data
            
            locationStopsArr.removeAll()
            locationStopsArr.append((locationsEstimateSet?.pickupLocation)!)
            for each in locationsEstimateSet?.dropoffLocations ?? [] {
                if each.name != "" {
                    locationStopsArr.append(each)
                }
            }
            
            var latitude: Double
            var longitude: Double
            latitude = Double("\(data?.pickupLocation?.latitude ?? "0.0")")!
            longitude = Double("\(data?.pickupLocation?.longitude ?? "0.0")")!
            
            var distanceInMeters: CLLocationDistance = 0.0
            if self.myOrigin != nil {
                distanceInMeters = self.myOrigin.distance(from: CLLocation(latitude: latitude, longitude: longitude))
            } else {
                distanceInMeters = 0.0
            }
            
            if initialPlaceCoordinates == nil {
                reloadLocationsOnBigChange(data: data!)
            } else if (distanceInMeters > 20000) {
                reloadLocationsOnBigChange(data: data!)
            } else {
                myOrigin = CLLocation(latitude: latitude, longitude: longitude)
                originCoordinate = myOrigin.coordinate
                am.saveCurrentLocation(data: "\(originCoordinate.latitude),\(originCoordinate.longitude)")
                currentPlaceCoordinates = originCoordinate
                originLL = "\(latitude),\(longitude)"
                pickupName = data?.pickupLocation?.name ?? ""
                currentPlaceName = data?.pickupLocation?.name ?? ""
                am.savePICKUPADDRESS(data: pickupName)
                cardViewController.btnPickup.setTitle((data?.pickupLocation?.name ?? "").components(separatedBy: ",")[0].cleanLocationNames(), for: UIControl.State())
                btnPickupInformation.setTitle((data?.pickupLocation?.name ?? "").components(separatedBy: ",")[0].cleanLocationNames(), for: UIControl.State())
                
                let dropOffLocations = data?.dropoffLocations?.filter { $0.latitude != "" }
                
                if (dropOffLocations?.count ?? 0) > 0 {
                    
                    var lat: Double
                    var long: Double
                    lat = Double("\(dropOffLocations?.last?.latitude ?? "0.0")")!
                    long = Double("\(dropOffLocations?.last?.longitude ?? "0.0")")!
                    
                    cardViewController.btnDestination.setTitle((dropOffLocations?.last?.name ?? "").components(separatedBy: ",")[0].cleanLocationNames(), for: UIControl.State())
                    btnDestinationInformation.setTitle((dropOffLocations?.last?.name ?? "").components(separatedBy: ",")[0].cleanLocationNames(), for: UIControl.State())
                    myDestination = CLLocation(latitude: lat, longitude: long)
                    destinationCoordinate = myDestination.coordinate
                    destinationLL = "\(lat),\(long)"
                    dropOffName = dropOffLocations?.last?.name ?? ""
                    
                    drawPath()
                    fareEstimateIndex = 0
                    
                }
                
                let group = DispatchGroup()
                group.enter()
                DispatchQueue.main.async {
                    self.gmsMapView.camera = GMSCameraPosition.camera(withTarget: self.currentPlaceCoordinates, zoom: 16.0)
                    group.leave()
                }
                group.notify(queue: .main) {
                    self.placeMarkerOnCenter(centerMapCoordinate: self.currentPlaceCoordinates)
                    if (dropOffLocations?.count ?? 0) > 0 {
                        self.informationTopView.alpha = 0.0
                        self.informationTopView.isHidden = false
                        UIView.animate(withDuration: 0.3) {
                            self.informationTopView.alpha = 1.0
                        }
                        self.menuBtn.isHidden = true
                        self.stage = "FareEstimate"
                        self.cardViewController.carTypeTableView.isHidden = true
                        self.cardViewController.carTypeView.isHidden = false
                        
                        self.carTypePriceEstimate.removeAll()
                        self.cardViewController.carTypeLoadingView.createLoadingNormal()
                        self.getFareEstimateMultiple()
                    }
                }
            }
        }
        
    }
    
    func reloadLocationsOnBigChange(data: LocationsEstimateSetSDK) {
        
        var latitude: Double
        var longitude: Double
        latitude = Double("\(data.pickupLocation?.latitude ?? "0.0")")!
        longitude = Double("\(data.pickupLocation?.longitude ?? "0.0")")!
        
        let loadBackGround = self.createLoadingScreen()
        self.view.addSubview(loadBackGround)
        firstTryCartypes = true
        myOrigin = CLLocation(latitude: latitude, longitude: longitude)
        originCoordinate = myOrigin.coordinate
        initialPlaceName = data.pickupLocation?.name ?? ""
        initialPlaceCoordinates = myOrigin.coordinate
        currentPlaceCoordinates = myOrigin.coordinate
        am.saveInitialLocation(data: "\(initialPlaceCoordinates.latitude),\(initialPlaceCoordinates.longitude)")
        am.saveCurrentLocation(data: "\(initialPlaceCoordinates.latitude),\(initialPlaceCoordinates.longitude)")
        originLL = "\(latitude),\(longitude)"
        pickupName = data.pickupLocation?.name ?? ""
        currentPlaceName = data.pickupLocation?.name ?? ""
        am.savePICKUPADDRESS(data: pickupName)
        
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.main.async {
            self.gmsMapView.camera = GMSCameraPosition.camera(withTarget: self.originCoordinate, zoom: 16.0)
            group.leave()
        }
        group.notify(queue: .main) {
            DispatchQueue.main.async {
                self.placeMarkerOnCenter(centerMapCoordinate: self.originCoordinate)
                self.getLocationName(currentCoordinate: self.originCoordinate)
            }
        }
    }
    
    @objc func fromPickup() {
        
        cardViewController.suggestedPlacesCollectionView.reloadData()
        cardViewController.popularDropOffTable.reloadData()
        
        cardViewController.confirmRequestView.isHidden = true
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "PICKUP"), object: nil)
        
        let index = am.getSelectedLocIndex()!
        var latitude: Double
        var longitude: Double
        
        printVal(object: am.getRecentPlacesNames()[index])
        printVal(object: am.getRecentPlacesFormattedAddress()[index])
        printVal(object: am.getRecentPlacesCoords()[index])
        
        latitude = Double(am.getRecentPlacesCoords()[index].components(separatedBy: ",")[0])!
        longitude = Double(am.getRecentPlacesCoords()[index].components(separatedBy: ",")[1])!
        
        var distanceInMeters: CLLocationDistance = 0.0
        if self.myOrigin != nil {
            distanceInMeters = self.myOrigin.distance(from: CLLocation(latitude: latitude, longitude: longitude))
        } else {
            distanceInMeters = 0.0
        }
        
        if initialPlaceCoordinates == nil {
            
            let loadBackGround = self.createLoadingScreen()
            self.view.addSubview(loadBackGround)
            firstTryCartypes = true
            myOrigin = CLLocation(latitude: latitude, longitude: longitude)
            originCoordinate = myOrigin.coordinate
            initialPlaceName = am.getRecentPlacesNames()[index].cleanLocationNames()
            initialPlaceCoordinates = myOrigin.coordinate
            currentPlaceCoordinates = myOrigin.coordinate
            originLL = am.getRecentPlacesCoords()[index]
            pickupName = am.getRecentPlacesNames()[index].cleanLocationNames()
            currentPlaceName = am.getRecentPlacesNames()[index].cleanLocationNames()
            am.savePICKUPADDRESS(data: pickupName)
            am.saveInitialLocation(data: "\(initialPlaceCoordinates.latitude),\(initialPlaceCoordinates.longitude)")
            am.saveCurrentLocation(data: "\(initialPlaceCoordinates.latitude),\(initialPlaceCoordinates.longitude)")
            
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async {
                self.gmsMapView.camera = GMSCameraPosition.camera(withTarget: self.originCoordinate, zoom: 16.0)
                group.leave()
            }
            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.placeMarkerOnCenter(centerMapCoordinate: self.originCoordinate)
                    self.getLocationName(currentCoordinate: self.originCoordinate)
                }
            }
        } else if (distanceInMeters > 20000) {
            
            let loadBackGround = self.createLoadingScreen()
            self.view.addSubview(loadBackGround)
            firstTryCartypes = true
            myOrigin = CLLocation(latitude: latitude, longitude: longitude)
            originCoordinate = myOrigin.coordinate
            initialPlaceName = am.getRecentPlacesNames()[index].cleanLocationNames()
            initialPlaceCoordinates = myOrigin.coordinate
            currentPlaceCoordinates = myOrigin.coordinate
            originLL = am.getRecentPlacesCoords()[index]
            pickupName = am.getRecentPlacesNames()[index].cleanLocationNames()
            currentPlaceName = am.getRecentPlacesNames()[index].cleanLocationNames()
            am.savePICKUPADDRESS(data: pickupName)
            am.saveInitialLocation(data: "\(initialPlaceCoordinates.latitude),\(initialPlaceCoordinates.longitude)")
            am.saveCurrentLocation(data: "\(initialPlaceCoordinates.latitude),\(initialPlaceCoordinates.longitude)")
            
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async {
                self.gmsMapView.camera = GMSCameraPosition.camera(withTarget: self.originCoordinate, zoom: 16.0)
                group.leave()
            }
            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.placeMarkerOnCenter(centerMapCoordinate: self.originCoordinate)
                    self.getLocationName(currentCoordinate: self.originCoordinate)
                }
            }
        } else {
            
            let unique_id = NSUUID().uuidString
            
            myOrigin = CLLocation(latitude: latitude, longitude: longitude)
            originCoordinate = myOrigin.coordinate
            am.saveCurrentLocation(data: "\(originCoordinate.latitude),\(originCoordinate.longitude)")
            currentPlaceCoordinates = originCoordinate
            originLL = am.getRecentPlacesCoords()[index]
            pickupName = am.getRecentPlacesNames()[index].cleanLocationNames()
            currentPlaceName = am.getRecentPlacesNames()[index].cleanLocationNames()
            am.savePICKUPADDRESS(data: pickupName)
            
            locationsEstimateSet = LocationsEstimateSetSDK(pickupLocation: LocationSetSDK(id: unique_id, name: pickupName, subname: pickupName, latitude: "\(latitude)", longitude: "\(longitude)", phonenumber: "", instructions: ""), dropoffLocations: locationsEstimateSet?.dropoffLocations ?? [])
            
            cardViewController.btnPickup.setTitle(am.getRecentPlacesNames()[index].components(separatedBy: ",")[0].cleanLocationNames(), for: UIControl.State())
            btnPickupInformation.setTitle(am.getRecentPlacesNames()[index].components(separatedBy: ",")[0].cleanLocationNames(), for: UIControl.State())
            
            
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async {
                self.gmsMapView.camera = GMSCameraPosition.camera(withTarget: self.currentPlaceCoordinates, zoom: 16.0)
                group.leave()
            }
            group.notify(queue: .main) {
                self.placeMarkerOnCenter(centerMapCoordinate: self.currentPlaceCoordinates)
                if !(self.cardViewController.btnDestination.title(for: UIControl.State())?.contains("Where do "))! {
                    
                    var distanceFromDestinationInMeters: CLLocationDistance = 0.0
                    if self.myDestination != nil {
                        distanceFromDestinationInMeters = self.myDestination.distance(from: CLLocation(latitude: latitude, longitude: longitude))
                    } else {
                        distanceFromDestinationInMeters = 0.0
                    }
                    
                    self.drawPath()
                    self.fareEstimateIndex = 0
                    
                    if (distanceFromDestinationInMeters > 100000) {
                        // Destination is far, could not get fare estimate
                        
                        self.approxMinsLbl.text = "Destination is far, could not get fare estimate"
                        
                        self.showAlerts(title: "", message: "The destination selected is too far. Could not get the fare estimate.")
                        
                    } else {
                        
                        self.informationTopView.alpha = 0.0
                        self.informationTopView.isHidden = false
                        
                        UIView.animate(withDuration: 0.3) {
                            self.informationTopView.alpha = 1.0
                        }
                        
                        self.menuBtn.isHidden = true
                        
                        self.stage = "FareEstimate"
                        
                        self.cardViewController.carTypeTableView.isHidden = true
                        self.cardViewController.carTypeView.isHidden = false
                        
                        self.carTypePriceEstimate.removeAll()
                        self.cardViewController.carTypeLoadingView.createLoadingNormal()
                        self.getFareEstimateMultiple()
                    }
                    
                }
            }
        }
    }
    
    @objc func fromDropoff() {
        
        cardViewController.suggestedPlacesCollectionView.reloadData()
        cardViewController.popularDropOffTable.reloadData()
        
        cardViewController.confirmRequestView.isHidden = true
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "DROPOFF"), object: nil)
        
        let index = am.getSelectedLocIndex()!
        var latitude: Double
        var longitude: Double
        latitude = Double(am.getRecentPlacesCoords()[index].components(separatedBy: ",")[0])!
        longitude = Double(am.getRecentPlacesCoords()[index].components(separatedBy: ",")[1])!
        
       
        cardViewController.btnDestination.setTitle(am.getRecentPlacesNames()[index].cleanLocationNames(), for: UIControl.State())
        btnDestinationInformation.setTitle(am.getRecentPlacesNames()[index].components(separatedBy: ",")[0].cleanLocationNames(), for: UIControl.State())
        myDestination = CLLocation(latitude: latitude, longitude: longitude)
        destinationCoordinate = myDestination.coordinate
        destinationLL = am.getRecentPlacesCoords()[index]
        dropOffName = am.getRecentPlacesNames()[index].cleanLocationNames()
        drawPath()
        fareEstimateIndex = 0
        
        var distanceInMeters: CLLocationDistance = 0.0
        if self.myOrigin != nil {
            distanceInMeters = self.myOrigin.distance(from: CLLocation(latitude: latitude, longitude: longitude))
        } else {
            distanceInMeters = 0.0
        }
        
        if (distanceInMeters > 100000) {
            // Destination is far, could not get fare estimate
            
            self.approxMinsLbl.text = "Destination is far, could not get fare estimate"
            
            self.showAlerts(title: "", message: "The destination selected is too far. Could not get the fare estimate.")
            
        } else {
            
            informationTopView.alpha = 0.0
            informationTopView.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.informationTopView.alpha = 1.0
            }
            
            menuBtn.isHidden = true
            
            stage = "FareEstimate"
            
            cardViewController.carTypeTableView.isHidden = true
            cardViewController.carTypeView.isHidden = false
            
            self.carTypePriceEstimate.removeAll()
            self.cardViewController.carTypeLoadingView.createLoadingNormal()
            self.getFareEstimateMultiple()
            
        }
    }
    
    
    func removeAllKeysAndLogout() {
        let _ = LittleSDKKCWrapper.standard.removeAllKeys()
        let domain = sdkBundle!.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    func adjustSiteAccordingToButton(val: Int) {
        switch val {
        case 0:
            if getPhoneFaceIdType() {
                yPositionConfirmOpen = view.frame.height - ((CGFloat(PaymentModes.count) * 40.0) + topSafeAreaConst + bottomSafeAreaConst + 325.0)
            } else {
                yPositionConfirmOpen = view.frame.height - ((CGFloat(PaymentModes.count) * 40.0) + topSafeAreaConst + bottomSafeAreaConst + 300.0)
            }
        case 1:
            if getPhoneFaceIdType() {
                yPositionConfirmOpen = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 425)
            } else {
                yPositionConfirmOpen = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 400)
            }
        case 2:
            if getPhoneFaceIdType() {
                if (view.frame.height - ((CGFloat(preferredDriversArr.count) * 75.0) + topSafeAreaConst + bottomSafeAreaConst + 325.0)) < view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 425) {
                    yPositionConfirmOpen = view.frame.height - ((CGFloat(preferredDriversArr.count) * 75.0) + topSafeAreaConst + bottomSafeAreaConst + 325.0)
                } else {
                    yPositionConfirmOpen = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 425)
                }
            } else {
                if (view.frame.height - ((CGFloat(preferredDriversArr.count) * 75.0) + topSafeAreaConst + bottomSafeAreaConst + 300.0)) < view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 400) {
                    yPositionConfirmOpen = view.frame.height - ((CGFloat(preferredDriversArr.count) * 75.0) + topSafeAreaConst + bottomSafeAreaConst + 300.0)
                } else {
                    yPositionConfirmOpen = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 400)
                }
            }
        default:
            if getPhoneFaceIdType() {
                yPositionConfirmOpen = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 425)
            } else {
                yPositionConfirmOpen = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 400)
            }
        }
    }
    
    func animateExistingMarkers() {
        
        if self.listDriver.count == self.nearDriverMarker.count {
            for i in (0..<self.listDriver.count) {
                let mark = self.nearDriverMarker[i]!
                let group = DispatchGroup()
                group.enter()
                DispatchQueue.main.async {
                    
                    let oldCoordinate: CLLocationCoordinate2D? = mark.position
                    let newCoordinate: CLLocationCoordinate2D? = CLLocationCoordinate2DMake(self.listDriver[i].getLatitude(),self.listDriver[i].getLongitude())
                    
                    if let oldCoodinate = oldCoordinate {
                        if let newCoodinate = newCoordinate {
                            mark.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
                            mark.rotation = CLLocationDegrees(self.getHeadingForDirection(fromCoordinate: oldCoodinate, toCoordinate: newCoodinate))
                            mark.position = oldCoodinate
                            CATransaction.begin()
                            CATransaction.setValue(Int(2.0), forKey: kCATransactionAnimationDuration)
                            CATransaction.setCompletionBlock({() -> Void in
                                mark.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
                                mark.rotation = CDouble(self.listDriver[i].bearing)
                            })
                            mark.position = newCoodinate
                            mark.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
                            mark.rotation = CLLocationDegrees(self.getHeadingForDirection(fromCoordinate: oldCoodinate, toCoordinate: newCoodinate))
                        }
                    }
                }
                group.notify(queue: .main) {
                    DispatchQueue.main.async {
                        CATransaction.commit()
                    }
                }
            }
        }
        
    }
    
    func resetViewAfterRequest() {
        
        cardViewController.lblRequestingText.text = ""
        makeRequestDefaultMessage = ""
        cardViewController.requestingLoadingView.isUserInteractionEnabled = false
        cardViewController.lblRequestingText.textColor = littleBlue
        cardViewController.requestingLoadingView.isHidden = true
        cardViewController.requestingLoadingView.removeAnimation()
        cardViewController.lblRequestingText.isHidden = true
        
    }
    
    func makeRideRequestNew() {
        
        if cardViewController.requestingLoadingView.isHidden {
            cardViewController.requestingLoadingView.isUserInteractionEnabled = false
            cardViewController.lblRequestingText.text = ""
            cardViewController.lblRequestingText.textColor = littleBlue
            cardViewController.requestingLoadingView.isHidden = false
            cardViewController.requestingLoadingView.createLoadingNormal()
            cardViewController.lblRequestingText.isHidden = false
            cardViewController.requestingLoadingView.bringSubviewToFront(cardViewController.lblRequestingText)
        }
        
        if forwardCount != 0 {
            
            var preferredDriver = ""
            var pmodeID = ""
            var pmode = ""
            var promoText = ""
            var promoType = ""
            var place = ""
            var parcelString = ""
            let carType = CarTypes[selectedCarIndex].uppercased()
            
            pmodeID = PaymentModeIDs[selectedPaymentMode]
            pmode = PaymentModes[selectedPaymentMode]
            
            if self.preferredDriver == true {
                forwardCount = 1
                preferredDriver = "\(am.getPreferredDriver()!)"
            } else {
                forwardCount -= 1
            }
            
            if self.isUAT {
                preferredDriver = "jgashu@yahoo.com"
            }
            
            if (CarTypes[selectedCarIndex].lowercased().contains("parcel") || CarTypes[selectedCarIndex].lowercased().contains("goods")) {
                
                if cardViewController.homeOfficeSeg.selectedSegmentIndex == 0 {
                    place = "HOME"
                } else if cardViewController.homeOfficeSeg.selectedSegmentIndex == 1 {
                    place = "WORK"
                }
                
                parcelString = ",\"Parceldetails\":{\"ItemCarried\":\"\(cardViewController.txtParcelName.text!)\",\"Size\":\"\(parcelSize)\",\"RecipientName\":\"\(cardViewController.txtReceiversName.text!)\",\"RecipientMobile\":\"\(cardViewController.txtReceiversNumber.text!)\",\"RecipientAddress\":\"\(cardViewController.txtReceiversAddress.text!)\",\"ContactPerson\":\"\(am.getPhoneNumber()!)\",\"DeliveryNotes\":\"\(cardViewController.txtReceiversAddress.text!)\",\"TypeOfAddress\":\"\(place)\"}"
            }
            
            
            am.savePaymentMode(data: PaymentModes[selectedPaymentMode])
            am.savePaymentModeID(data: PaymentModeIDs[selectedPaymentMode])
            
            cardViewController.lblRequestingText.textColor = littleBlue
            
            cardViewController.requestingLoadingView.isUserInteractionEnabled = true
            
            if self.preferredDriver == true {
                cardViewController.lblRequestingText.text = "Requesting \(am.getPreferredDriverName()!.capitalized) on \(CarTypes[selectedCarIndex])\n(Tap here to cancel request)"
                makeRequestDefaultMessage = "Requesting \(am.getPreferredDriverName()!.capitalized) on \(CarTypes[selectedCarIndex])\n(Tap here to cancel request)"
            } else {
                cardViewController.lblRequestingText.text = "Requesting a \(CarTypes[selectedCarIndex]) ride\n(Tap here to cancel request)"
                makeRequestDefaultMessage = "Requesting a \(CarTypes[selectedCarIndex]) ride\n(Tap here to cancel request)"
            }
            if self.promoVerified == true {
                promoText = self.promoText
                promoType = "TRIP"
            }
            
            am.saveDROPOFFADDRESS(data: dropOffName)
            am.savePICKUPADDRESS(data: pickupName)
            
            if pmode == "" {
                pmode = "Cash"
                pmodeID = "CASH"
            }
            
            var dropOffDetails = ""
            
            let arr = locationsEstimateSet?.dropoffLocations ?? []
            
            for i in (0..<arr.count) {
                dropOffDetails.append("{\"DropOffNumber\":\"\(i+1)\",\"DropoffLL\":\"\(arr[i].latitude),\(arr[i].longitude)\",\"DropoffAddress\":\"\(arr[i].name)\",\"ContactMobileNumber\":\"\(arr[i].phonenumber)\",\"ContactName\":\"\",\"Notes\":\"\(arr[i].instructions)\"}")
                if i < arr.count-1 {
                    dropOffDetails.append(",")
                }
            }
            
            NotificationCenter.default.addObserver(self, selector: #selector(loadMakeRequest(_:)),name:NSNotification.Name(rawValue: "MAKEJSONREQUESTJSONData"), object: nil)
            
            let dataToSend = "{\"FormID\":\"MAKEJSONREQUEST\"\(commonCallParams()),\"TripDetails\":{\"VehicleType\":\"\(carType)\",\"TripType\":\"TRIP\",\"PaymentMode\":\"\(pmode)\",\"WalletUniqueID\":\"\(pmodeID)\",\"CorporateID\":\"\(CC)\",\"CorporateRef\":\"\(reasonTest)\",\"CorporateTripID\":\"\(CorporateTripID)\",\"SkipDrivers\":\"\(forwardSkipDrivers)\",\"FavouriteDriver\":\"\(preferredDriver)\",\"PromoCode\":\"\(promoText)\",\"PromoType\":\"\(promoType)\",\"PickupAddress\":\"\(pickupName)\",\"PickupLL\":\"\(originLL)\",\"DropOffAddress\":\"\(dropOffName)\",\"DropOffLL\":\"\(destinationLL)\",\"DropOffDetails\":[\(dropOffDetails)]\(parcelString)\(flySaveDetails)}}"
            
            hc.makeServerCall(sb: dataToSend, method: "MAKEJSONREQUESTJSONData", switchnum: 0)
            
        } else {
            
            resetViewAfterRequest()
            
            forwardCount = Int(am.getFORWARDCOUNT()!)!
            forwardSkipDrivers = ""
            flySaveDetails = ""
            
            paymentsPageReveal(open: false)
            
            var string = ""
            
            if preferredDriver == false {
                string = "No drivers around. Kindly try a different vehicle category."
            } else {
                string = "\(am.getPreferredDriverName()!) did not respond to request."
            }
            
            showAlerts(title: "", message: "\(string)")
            
        }
        
    }
    
    @objc func loadMakeRequest(_ notification: Notification) {
        
        let data = notification.userInfo?["data"] as? Data
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "MAKEJSONREQUESTJSONData"), object: nil)
        
        if isCancellingRequest {
            return
        }
        
        am.saveTRIPID(data: "")
        am.saveLASTSERVED(data: "")
        am.saveTIMEDISTANCE(data: "")
        am.saveROADDISTANCE(data: "")
        am.saveVIEWID(data: "")
        am.saveDRIVERNAME(data: "")
        am.saveDRIVERMOBILE(data: "")
        am.saveDRIVEREMAIL(data: "")
        am.saveDRIVERPICTURE(data: "")
        am.saveDRIVERLATITUDE(data: "")
        am.saveDRIVERLONGITUDE(data: "")
        am.saveNUMBER(data: "")
        am.saveMODEL(data: "")
        am.saveCOLOR(data: "")
        am.saveRATING(data: "")
        
        
        func successCracked(trip: TripResponseElement) {
            
            am.saveMESSAGE(data: trip.message ?? "")
            am.saveTRIPID(data: trip.tripID ?? "")
            am.saveLASTSERVED(data: "")
            am.saveTIMEDISTANCE(data: trip.timeDistance ?? "")
            am.saveROADDISTANCE(data: trip.roadDistance ?? "")
            am.saveVIEWID(data: trip.socialMediaID ?? "")
            am.saveDRIVERNAME(data: trip.driverName ?? "")
            am.saveDRIVERMOBILE(data: trip.driverMobileNumber ?? "")
            am.saveDRIVEREMAIL(data: "")
            am.saveDRIVERPICTURE(data: trip.driverPIC ?? "")
            am.saveDRIVERLATITUDE(data: trip.driverLatitude ?? "")
            am.saveDRIVERLONGITUDE(data: trip.driverLongitude ?? "")
            am.saveNUMBER(data: trip.carNumber ?? "")
            am.saveMODEL(data: trip.carModel ?? "")
            am.saveCOLOR(data: trip.carColor ?? "")
            am.saveRATING(data: trip.driverRating ?? "")
            
            if am.getTRIPID() != "" {
                
                if forwardSkipDrivers == "" {
                    forwardSkipDrivers = am.getDRIVEREMAIL()!
                } else {
                    if !forwardSkipDrivers.contains(am.getDRIVEREMAIL()!) {
                        forwardSkipDrivers = forwardSkipDrivers + ";" + am.getDRIVEREMAIL()!
                    }
                }
                
                getMakeRequestStatus()
                startMakeRequestStatusUpdate()
                
            } else {
                
                informationTopView.isUserInteractionEnabled = true
                
                forwardSkipDrivers = ""
                
                stopMakeRequestStatusUpdate()
                
                cardViewController.lblRequestingText.text = ""
                makeRequestDefaultMessage = ""
                cardViewController.requestingLoadingView.isUserInteractionEnabled = false
                cardViewController.lblRequestingText.textColor = littleBlue
                cardViewController.requestingLoadingView.isHidden = true
                cardViewController.requestingLoadingView.removeAnimation()
                cardViewController.lblRequestingText.isHidden = true
                
                paymentsPageReveal(open: false)
                
                var string = ""
                
                if am.getMESSAGE() != "" {
                    showAlerts(title: "", message: am.getMESSAGE()!)
                } else {
                    
                    if preferredDriver == false {
                        string = "No drivers around. Kindly try a different vehicle category."
                    } else {
                        string = "\(am.getPreferredDriverName()!) did not respond to request."
                    }
                    showAlerts(title: "", message: "\(string)")
                }
            }
            
        }
        
        
        do {
            let tripResponse = try JSONDecoder().decode(TripResponseElement.self, from: data!)
            
            let trip = tripResponse
            
            printVal(object: tripResponse)
            
            successCracked(trip: trip)
            
        } catch {
            do {
                
                let tripResponse = try JSONDecoder().decode(TripResponse.self, from: data!)
                
                let trip = tripResponse[0]
                
                printVal(object: tripResponse)
                
                successCracked(trip: trip)
                
            } catch {
                
                do {
                    let defaultResponse = try JSONDecoder().decode(DefaultMessages.self, from: data!)
                    
                    if defaultResponse[0].status == "091" {
                        showAlerts(title: "", message: defaultResponse[0].message ?? "An error has been encountered trying to create a ride request for you. Kindly retry and if this persistes feel free to contuct us directly to help you with your Little experience.")
                    }
                    
                    informationTopView.isUserInteractionEnabled = true
                    
                    forwardSkipDrivers = ""
                    
                    am.saveTRIPID(data: "")
                    
                    stopMakeRequestStatusUpdate()
                    
                    cardViewController.lblRequestingText.text = ""
                    makeRequestDefaultMessage = ""
                    cardViewController.requestingLoadingView.isUserInteractionEnabled = false
                    cardViewController.lblRequestingText.textColor = littleBlue
                    cardViewController.requestingLoadingView.isHidden = true
                    cardViewController.requestingLoadingView.removeAnimation()
                    cardViewController.lblRequestingText.isHidden = true
                    
                    paymentsPageReveal(open: false)
                } catch {}
            }
            
        }
        
    }
    
    
    func startMakeRequestStatusUpdate() {
        stopMakeRequestStatusUpdate()
        isContinueRequest=true
        let timerdelay=Double(4.0)
        timer = Timer.scheduledTimer(timeInterval: timerdelay, target: self, selector: #selector(MakeRequestStatus), userInfo: nil, repeats: true)
        
    }
    
    func stopMakeRequestStatusUpdate() {
        isContinueRequest=false
        if timer != nil {
            timer.invalidate()
        }
    }
    
    @objc func MakeRequestStatus() {
        if isContinueRequest {
            getMakeRequestStatus()
        }
    }
    
    func getMakeRequestStatus() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMakeRequestStatusJSON(_:)),name:NSNotification.Name(rawValue: "GETREQUESTSTATUSJSONData"), object: nil)
        
        am.saveStillRequesting(data: false)
        
        let dataToSend = "{\"FormID\":\"GETREQUESTSTATUS\"\(commonCallParams()),\"GetRequestStatus\":{\"TripID\":\"\(am.getTRIPID()!)\"}}"
        
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
            
            do {
                let requestStatusResponse = try JSONDecoder().decode(RequestStatusResponse.self, from: data!)
                let response = requestStatusResponse[0]
                
                printVal(object: response)
                
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
                
                if STATUS != "000" {
                    am.saveTRIPSTATUS(data: "")
                }
                
                loadMakeRequestStatus()
                
            } catch {}
        }
        
    }
    
    @objc func loadMakeRequestStatus() {
        
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name(rawValue: "MAKEREQUESTSTATUS"), object: nil)
        
        if am.getTRIPSTATUS() == "" {
            stopMakeRequestStatusUpdate()
            if CarTypes.count > selectedCarIndex {
                makeRideRequestNew()
            }
        } else {
            if am.getTRIPSTATUS() != "" {
                if let intVal: Int = Int(am.getTRIPSTATUS()!) {
                    if intVal >= 2 {
                        
                        isContinueRequest=false
                        if timer != nil {
                            timer.invalidate()
                        }
                        
                        if carActiveIcons.count > selectedCarIndex {
                            am.saveVEHICLEIMAGE(data: carActiveIcons[selectedCarIndex])
                        }
                        
                        informationTopView.isUserInteractionEnabled = true
                        
                        cardViewController.lblRequestingText.text = ""
                        makeRequestDefaultMessage = ""
                        cardViewController.requestingLoadingView.isUserInteractionEnabled = false
                        cardViewController.lblRequestingText.textColor = littleBlue
                        cardViewController.requestingLoadingView.isHidden = true
                        cardViewController.requestingLoadingView.removeAnimation()
                        cardViewController.lblRequestingText.isHidden = true
                        
                        forwardSkipDrivers = ""
                        stopMakeRequestStatusUpdate()
                        am.savePaymentMode(data: PaymentMode)
                        am.savePaymentModeID(data: PaymentModeID)
                        
                        if let viewController = UIStoryboard(name: "Trip", bundle: sdkBundle!).instantiateViewController(withIdentifier: "TripVC") as? TripVC {
                            if let navigator = self.navigationController {
                                viewController.popToRestorationID = popToRestorationID
                                viewController.navShown = navShown
                                viewController.paymentVC = paymentVC
                                navigator.pushViewController(viewController, animated: true)
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    
    func resumeTrip() {
        
        if cardViewController.requestingLoadingView.isHidden {
            
            // requestingLoadingView.isUserInteractionEnabled = true
            cardViewController.lblRequestingText.text = "Loading trip details...\n(Tap here to cancel request)"
            cardViewController.requestingLoadingView.isHidden = false
            cardViewController.requestingLoadingView.createLoadingNormal()
            cardViewController.lblRequestingText.isHidden = false
            cardViewController.requestingLoadingView.bringSubviewToFront(cardViewController.lblRequestingText)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMakeRequest(_:)),name:NSNotification.Name(rawValue: "MAKEJSONREQUESTJSONData"), object: nil)
        
        am.saveStillRequesting(data: false)
        
        let dataToSend = "{\"FormID\":\"RESUME\"\(commonCallParams())}"
        
        hc.makeServerCall(sb: dataToSend, method: "MAKEJSONREQUESTJSONData", switchnum: 0)
        
        
    }
    
    @objc func loadCreateRequest() {
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "CREATEREQUEST_NEW"), object: nil)
        
        if am.getTRIPID() != "" {
            
            isContinueRequest=false
            if timer != nil {
                timer.invalidate()
            }
            
            if carActiveIcons.count > 0 {
                am.saveVEHICLEIMAGE(data: carActiveIcons[selectedCarIndex])
            }
            
            informationTopView.isUserInteractionEnabled = true
            
            cardViewController.lblRequestingText.text = ""
            cardViewController.requestingLoadingView.isUserInteractionEnabled = false
            cardViewController.lblRequestingText.textColor = littleBlue
            cardViewController.requestingLoadingView.isHidden = true
            cardViewController.requestingLoadingView.removeAnimation()
            cardViewController.lblRequestingText.isHidden = true
            
            forwardSkipDrivers = ""
            stopMakeRequestStatusUpdate()
            am.savePaymentMode(data: PaymentMode)
            am.savePaymentModeID(data: PaymentModeID)
            
            if let viewController = UIStoryboard(name: "Trip", bundle: sdkBundle!).instantiateViewController(withIdentifier: "TripVC") as? TripVC {
                if let navigator = self.navigationController {
                    viewController.popToRestorationID = popToRestorationID
                    viewController.navShown = navShown
                    viewController.paymentVC = paymentVC
                    navigator.pushViewController(viewController, animated: true)
                }
            }
            
            
        } else {
            
            cardViewController.lblRequestingText.text = ""
            cardViewController.requestingLoadingView.isUserInteractionEnabled = false
            cardViewController.lblRequestingText.textColor = littleBlue
            cardViewController.requestingLoadingView.isHidden = true
            cardViewController.requestingLoadingView.removeAnimation()
            cardViewController.lblRequestingText.isHidden = true
            
            forwardCount = Int(am.getFORWARDCOUNT()!)!
            forwardSkipDrivers = ""
            
            var string = ""
            
            if preferredDriver == false {
                string = "No drivers around. Kindly try a different vehicle category."
            } else {
                string = "\(am.getPreferredDriverName()!) did not respond to request."
            }
            
            self.paymentsPageReveal(open: false)
            
            showAlerts(title: "", message: string)
            
        }
    }
    
    func cancelRequest() {
        
        isCancellingRequest = true
        
        var dataToSend = "{\"FormID\":\"CANCELREQUEST\"\(commonCallParams()),\"CancelTrip\":{\"TripID\":\"\(am.getTRIPID()!)\",\"Reason\":\"CANCELALL\"}}"
        
        printVal(object: dataToSend)
        
        dataToSend = am.EncryptDataAES(DataToSend: dataToSend) as String
        
        let string = am.DecryptDataKC(DataToSend: cn.link()) as String
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: "Content-Type", value: "application/json; charset=utf-8"),
            HTTPHeader(name: "KeyID", value: "\(am.EncryptDataHeaders(DataToSend: am.getMyKeyID()!))"),
            HTTPHeader(name: "Accounts", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKAccounts()!)"))"),
            HTTPHeader(name: "MobileNumber", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKMobileNumber()!)"))"),
            HTTPHeader(name: "PackageName", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKPackageName()!)"))")
        ]
        
        AF.request("\(string)",
               method: .post,
               parameters: [:], encoding: dataToSend, headers: headers).response { response in

                self.isCancellingRequest = false
                
                let data = response.data

                if data != nil {
                    do {
                        let sDKData = try JSONDecoder().decode(SDKData.self, from: data!)
                        let stringVal = self.am.DecryptDataAES(DataToSend: sDKData.data ?? "") as String
                        let strData = Data(stringVal.utf8)
                        
                        do {
                            
                            let requestStatusResponse = try JSONDecoder().decode(DefaultMessages.self, from: strData)
                            let response = requestStatusResponse[0]
                            
                            self.showAlerts(title: "", message: response.message ?? "Successfully cancelled")
                            
                            self.forwardSkipDrivers = ""
                            self.stopMakeRequestStatusUpdate()
                            
                        } catch {
                        }
        
                        self.cardViewController.lblRequestingText.text = ""
                        self.cardViewController.requestingLoadingView.isUserInteractionEnabled = false
                        self.cardViewController.lblRequestingText.textColor = self.littleBlue
                        self.cardViewController.requestingLoadingView.isHidden = true
                        self.cardViewController.requestingLoadingView.removeAnimation()
                        self.cardViewController.lblRequestingText.isHidden = true
                        self.paymentsPageReveal(open: false)
                        self.isCancellingRequest = false
                        
                        
                    } catch {}
                }
        }
        
    }
    
    func populateMarkers(list: [LittleDriver]) {
        for i in (0..<list.count) {
            let marker = GMSMarker()
            marker.isFlat = true
            marker.userData = "\(list[i].driverId)"
            marker.groundAnchor=CGPoint(x: 0.5, y: 0.5)
            marker.map = gmsMapView
            marker.rotation=list[i].getBearing()
            let imv = UIImageView(image: scaleImage(image: getImage(named: "ComfortNew1", bundle: sdkBundle!)!, size: 0.08))
            if imv.image == nil {
                imv.image = scaleImage(image: getImage(named: "ComfortNew1", bundle: sdkBundle!)!, size: 0.08)
            }
            marker.iconView = imv
            marker.position = CLLocationCoordinate2DMake(list[i].getLatitude(),list[i].getLongitude())
            nearDriverMarker.updateValue(marker, forKey: list[i].getDriverId())
        }
    }
    
    func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {
        
        let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
        let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
        let tLat: Float = Float((toLoc.latitude).degreesToRadians)
        let tLng: Float = Float((toLoc.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
        if degree >= 0 {
            return degree
        }
        else {
            return 360 + degree
        }
    }
}

extension LittleRideVC: GMSMapViewDelegate {
    func placeMarkerOnCenter(centerMapCoordinate:CLLocationCoordinate2D) {
        let color = cn.littleSDKThemeColor
        if marker == nil {
            marker = GMSMarker()
            marker.icon = GMSMarker.markerImage(with: color)
            marker.accessibilityHint = "Pin"
        }
        marker.position = centerMapCoordinate
        marker.map = self.gmsMapView
    }
    
}

extension LittleRideVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        if manager.location != nil {
            
            let location = locations.last!
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            originCoordinate = location.coordinate
            originLL = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
            am.saveInitialLocation(data: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
            am.saveCurrentLocation(data: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
            initialPlaceCoordinates = center
            currentPlaceCoordinates = center
            myOrigin = location
            let group = DispatchGroup()
            group.enter()
            DispatchQueue.main.async {
                self.gmsMapView.isMyLocationEnabled = true
                self.placeMarkerOnCenter(centerMapCoordinate: center)
                self.gmsMapView.camera = GMSCameraPosition.camera(withTarget: center, zoom: 16.0)
                group.leave()
            }
            group.notify(queue: .main) {
                DispatchQueue.main.async {
                    self.getLocationName(currentCoordinate: center)
                }
            }
            
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
