//
//  ConfirmOrderController.swift
//  Little
//
//  Created by Gabriel John on 02/04/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import SwiftMessages
import SDWebImage

public class ConfirmOrderController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate {
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    var sdkBundle: Bundle?
    
    var selectedRestaurant: Restaurant?
    var selectedTicketNo: Int?
    var selectedSeats: [SelectedSeat] = []
    var selectedTime: Int = 0
    var currency: String?
    
    var selectedTheatre: MovieTheatre?
    var selectedMovie: Movie?
    var seatTotalPrice: Double = 0
    var markup: Int = 0
    
    var menuArr: [FoodMenu] = []
    var paymentSourceArr: [Balance] = []
    var cartItems: [CartItems] = []
    
    var paymentIndex = 0
    var deliveryIndex = 0
    
    var promoIsValid: Bool = false
    var promoIs: String = ""
    var promoAmount: Double = 0.0
    var myPromoCode: String = ""
    
    var reference: String = ""
    
    var category: String = ""
    var merchantMessage: String = ""
    
    var paymentVC: UIViewController?
    
    var totalHeight = CGFloat(0)
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var deliverLocationView: UIView!
    @IBOutlet weak var extraDeliveryView: UIView!
    @IBOutlet weak var deliveryModeView: UIView!
    
    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var menuTableHeight: NSLayoutConstraint!
    @IBOutlet weak var extraViewConst: NSLayoutConstraint!
    @IBOutlet weak var deliverLocationConst: NSLayoutConstraint!
    @IBOutlet weak var deliverModeConst: NSLayoutConstraint!
    @IBOutlet weak var totalViewHeight: NSLayoutConstraint!
    @IBOutlet weak var topDelConst: NSLayoutConstraint!
    
    @IBOutlet weak var btnDeliverMode: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    @IBOutlet weak var btnPaymentMode: UIButton!
    @IBOutlet weak var btnConfirmPromo: UIButton!
    @IBOutlet weak var btnConfirmOrder: UIButton!
    
    @IBOutlet weak var txtDeliveryDetails: UITextField!
    @IBOutlet weak var txtPromoCode: UITextField!
    @IBOutlet weak var txtExtraDetails: UITextField!
    
    @IBOutlet weak var lblProductsCash: UILabel!
    @IBOutlet weak var lblDeliveryCash: UILabel!
    @IBOutlet weak var lblPromoCodeCash: UILabel!
    @IBOutlet weak var lblTotalCash: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblExtra: UILabel!
    
    private var orderSuccessMessage = ""
    
    @IBOutlet weak var stkDelivery: UIStackView!
    @IBOutlet weak var stkMovies: UIStackView!
    @IBOutlet weak var lblProductsLabel: UILabel!
    @IBOutlet weak var lblMoviesCash: UILabel!
    @IBOutlet weak var lblPromoCodeLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle.module

        let nib = UINib.init(nibName: "MenuCell", bundle: sdkBundle!)
        menuTable.register(nib, forCellReuseIdentifier: "cell")
        
        let nib2 = UINib.init(nibName: "MenuAddonsCell", bundle: sdkBundle!)
        menuTable.register(nib2, forCellReuseIdentifier: "addonsCell")
        
        if selectedTheatre != nil {
            let moviePrice = seatTotalPrice // getMoviePrice()
            
            #warning("check maximumItemsPerOrder")
            menuArr.insert(FoodMenu(menuID: selectedMovie?.movieID ?? "", foodCategory: "", foodName: selectedMovie?.movieName ?? "", foodDescription: "Rated: \(selectedMovie?.censorRating ?? ""), \(selectedMovie?.duration ?? 0) mins", originalPrice: moviePrice, specialPrice: moviePrice, foodImage: selectedMovie?.movieImageSmall ?? "", extraItem: "N", addonID: "", extraItems: []), at: 0)
        }
        
        menuTable.reloadData()
        
        totalHeight = 0
        menuTable.layoutIfNeeded()
        for i in (0..<menuArr.count) {
            let frame = menuTable.rectForRow(at: IndexPath(item: i, section: 0))
            printVal(object: frame.size.height)
            totalHeight = totalHeight + (frame.size.height)
        }
        
        menuTableHeight.constant = totalHeight
        
        if merchantMessage == "" {
            merchantMessage = "Any special requests?"
        }
        
        reference = NSUUID().uuidString
        
        extraViewConst.constant = 90
        totalHeight = totalHeight + 70
        lblExtra.text = merchantMessage
        txtExtraDetails.placeholder = merchantMessage
        extraDeliveryView.isHidden = false
        
        totalViewHeight.constant = 525 + totalHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        if selectedRestaurant != nil {
            
            deliveryModeView.isHidden = false
            stkDelivery.isHidden = false
            stkMovies.isHidden = true
            
            lblProductsLabel.text = "Products".localized
            lblPromoCodeLabel.text = "Promo Code".localized
            
            lblDeliveryCash.text = "\(currency ?? am.getGLOBALCURRENCY() ?? "KES") \(formatCurrency(String(selectedRestaurant?.deliveryCharges ?? 0)))"
            
            if am.getPICKUPADDRESS() != "" {
                btnLocation.setTitle(am.getPICKUPADDRESS(), for: UIControl.State())
            }
            
            if (selectedRestaurant?.deliveryModes?.count ?? 0) > 0 {
                btnDeliverMode.setTitle("\(selectedRestaurant?.deliveryModes?[0].deliveryModeDescription ?? "")", for: UIControl.State())
                lblDeliveryCash.text = "\(am.getGLOBALCURRENCY() ?? "KES") \(selectedRestaurant?.deliveryModes?[0].deliveryCharges ?? 0)"
            }
            
            if let restaurantDeliveryMode = selectedRestaurant?.deliveryModes?[safe: 0] {
                if restaurantDeliveryMode.deliveryModeDescription?.lowercased().contains("pickup") ?? false {
                    self.txtDeliveryDetails.placeholder = "Add House, Floor No. (Optional)"
                } else {
                    self.txtDeliveryDetails.placeholder = "Add House, Floor No."
                }
            }
            
            if myPromoCode != "" {
                showAlertPreventingInteraction(title: "Loading...".localized, message: "Please wait as we load the selected Promo.".localized)
                txtPromoCode.text = myPromoCode
                myPromoCode = ""
                btnConfirmPromo.sendActions(for: .touchUpInside)
            }
            
            changeCartValues()
        } else if selectedTheatre != nil {
            
            totalViewHeight.constant = 525 + totalHeight
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            
            deliveryModeView.isHidden = true
            stkMovies.isHidden = false
            stkDelivery.isHidden = true
            
            lblProductsLabel.text = "Snacks".localized
            lblPromoCodeLabel.text = "Promo Code (Tickets Only)".localized
            
            lblDeliveryCash.text = "\(currency ?? am.getGLOBALCURRENCY()!) \(formatCurrency(String(0)))"
            
            adjustDeliveryHeight(source: DeliveryMode(deliveryModes: "Pickup".localized, deliveryModeDescription: "Movies".localized, deliveryCharges: 0.0))
            
            changeCartValues()
            
            if myPromoCode != "" {
                showAlertPreventingInteraction(title: "Loading...".localized, message: "Please wait as we load the selected Promo.".localized)
                txtPromoCode.text = myPromoCode
                myPromoCode = ""
                btnConfirmPromo.sendActions(for: .touchUpInside)
            }
            
            
        }
        
        scrollView.setContentOffset(CGPoint(x: 0, y: menuTableHeight.constant + 40), animated: true)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        var restaurantName = ""
        var string = "Order"
        
        if selectedTheatre != nil {
            restaurantName = selectedTheatre?.name ?? ""
            string = "Booking"
        } else {
            restaurantName = selectedRestaurant?.restaurantName ?? ""
        }
        
        if restaurantName.last == "s" {
            self.lblTitle.text = "\(restaurantName)' \(string) Summary"
        } else {
            self.lblTitle.text = "\(restaurantName)'s \(string) Summary"
        }
        
        self.title = "Confirm \(string)"
        
    }
    
    // MARK: - Server Calls & Responses
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID() ?? "")\",\"MobileNumber\":\"\(am.getSDKMobileNumber() ?? "")\",\"IMEI\":\"\(am.getIMEI() ?? "")\",\"CodeBase\":\"\(am.getMyCodeBase() ?? "")\",\"PackageName\":\"\(am.getSDKPackageName() ?? "")\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"APKVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation() ?? "0.0, 0.0")\",\"LatLong\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"City\":\"\(am.getCity() ?? "")\",\"RegisteredCountry\":\"\(am.getCountry() ?? "")\",\"Country\":\"\(am.getCountry() ?? "")\",\"UNIQUEID\":\"\(am.getMyUniqueID() ?? "")\",\"CarrierName\":\"\(getCarrierName() ?? "")\""
        
        return str
    }
    
    func verifyPromoCode(promoText: String) {
        
        endEditSDK()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadpromocode),name:NSNotification.Name(rawValue: "VALIDATEPROMOCODE"), object: nil)
        
        am.savePROMOTITLE(data: "")
        am.savePROMOTEXT(data: "")
        am.savePROMOIMAGEURL(data: "")
        
        var restaurantID = ""
        var checkCategory = ""
        var amount = ""
        
        if selectedTheatre != nil {
            restaurantID = selectedTheatre?.restaurantID ?? ""
            checkCategory = "MOVIES"
            amount = (lblMoviesCash.text ?? "0.0").filterNumbersOnly()
        } else {
            restaurantID = selectedRestaurant?.restaurantID ?? ""
            checkCategory = category
            amount = (lblProductsCash.text ?? "0.0").filterNumbersOnly()
        }
        
        let datatosend = "FORMID|VALIDATEPROMOCODE_V1|PROMOCODE|\(promoText)|PICKUPLL|\(am.getCurrentLocation() ?? "0.0,0.0")|CATEGORY|\(checkCategory)|ModuleID|\(checkCategory))|TRIPCOST|\(amount)|RESTAURANTID|\(restaurantID)|"
        
        hc.makeServerCall(sb: datatosend, method: "VALIDATEPROMOCODE", switchnum: 0)
    }
    
    @objc func loadpromocode() {
        
        dismissSwiftAlert()
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "VALIDATEPROMOCODE"), object: nil)
        
        if am.getPROMOTITLE() != "Invalid"  {
            promoValid()
            
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
            promoInvalid()
            showAlerts(title: "Promo Code Invalid", message: am.getPROMOTEXT())
        }
        
    }
    
    func placeFoodOrder() {
        
        self.view.createLoadingNormal()
        
        var orderString = ""
        
        var restaurantID = ""
        
        if selectedTheatre != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(loadPlaceFoodOrder),name:NSNotification.Name(rawValue: "RESTAURANTDELIVERYITEMSMovies"), object: nil)
            restaurantID = selectedTheatre?.restaurantID ?? ""
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(loadPlaceFoodOrder),name:NSNotification.Name(rawValue: "RESTAURANTDELIVERYITEMSFoodDelivery"), object: nil)
            restaurantID = selectedRestaurant?.restaurantID ?? ""
        }
                
        for _ in cartItems {
            let index = cartItems.firstIndex(where: { $0.number == 0 })
            if index != nil {
                cartItems.remove(at: index!)
            }
        }
        for i in (0..<cartItems.count) {
            let result = menuArr.compactMap { $0 }.first(where: { $0.addonID == cartItems[i].addonID })
            var extraString = ""
            if result != nil {
                if result?.extraItems?.count ?? 0 > 0 {
                    extraString = ",\"ExtraItems\":["
                    for j in (0..<(result?.extraItems ?? []).count) {
                        let each = result?.extraItems?[j]
                        extraString = extraString + "{\"ExtraItemID\":\"\(each?.extraItemID ?? "")\",\"ExtraItemName\":\"\(each?.extraItemName ?? "")\",\"ExtraItemDescription\":\"\(each?.extraItemDescription ?? "")\",\"SpecialPrice\":\"\(each?.specialPrice ?? 0.0)\"}"
                        if j < ((result?.extraItems ?? []).count-1) {
                            extraString = extraString + ","
                        }
                    }
                    extraString = extraString + "]"
                } else {
                    extraString = ",\"ExtraItems\":\"\""
                }
                orderString = orderString + "{\"RestaurantID\":\"\(restaurantID)\",\"MenuID\":\"\(cartItems[i].itemID ?? "")\",\"Quantity\":\(Int(cartItems[i].number ?? 0.0))\(extraString)}"
                if i != (cartItems.count-1) {
                    orderString = orderString + ","
                }
            } else {
                extraString = ",\"ExtraItems\":[]"
            }
        }
        
        let specialRequest = txtExtraDetails.text ?? ""
        let deliveryDetails = txtDeliveryDetails.text ?? ""
        
        
        var deliveryMode = ""
        var moviesString = ""
        var dataToSend = ""
        
        var amountMovies = 0.0
        
        if selectedTheatre != nil {
            deliveryMode = ""
            var screenId = ""
            var screenDate = ""
            var screenTime = ""
            var seatsArr = ""
            for each in selectedSeats {
                seatsArr = seatsArr + "{\"SeatNumber\":\"\(each.seatNumber ?? "")\",\"SeatPrice\":\"\(each.seatPrice ?? 0)\",\"TicketCode\":\"\(each.ticketCode ?? "")\"},"
            }
            seatsArr = String(seatsArr.dropLast())
            
            if selectedMovie?.movieTimeings != nil {
                screenId = selectedMovie?.movieTimeings?[selectedTime].screenID ?? ""
                screenDate = selectedMovie?.movieTimeings?[selectedTime].showTime ?? ""
                screenTime = selectedMovie?.movieTimeings?[selectedTime].showID ?? ""
            } else {
                screenId = selectedMovie?.showTimes?[selectedTime].screenID ?? ""
                screenDate = selectedMovie?.showTimes?[selectedTime].showTime ?? ""
                screenTime = selectedMovie?.showTimes?[selectedTime].showID ?? ""
            }
            
            amountMovies = seatTotalPrice //(getMoviePrice() * Double(selectedTicketNo ?? 0))
            
            moviesString = ",\"GetPrice\":\"Y\",\"ShowDate\": \"\(screenDate)\",\"ShowID\": \"\(screenTime)\",\"MovieDetails\":{\"MovieProviderID\":\"\(selectedTheatre?.movieProviderID ?? "")\",\"MovieID\":\"\(selectedMovie?.movieID ?? "")\",\"Quantity\":\(selectedTicketNo ?? 0),\"ScreenID\": \"\(screenId)\",\"MovieTicketCost\":\"\(amountMovies)\",\"Markup\":\"\(markup)\",\"Amount\":\"\(amountMovies)\",\"PromoCode\":\"\(promoIs)\",\"PromoAmount\":\"\((lblPromoCodeCash.text ?? "").filterNumbersOnly())\",\"Seats\":[\(seatsArr)]}"
            
            let amountRestaurant = Double((lblProductsCash.text ?? "0").filterNumbersOnly())! - amountMovies
            
            var restaurantDeliveryItems = ",\"RestaurantDeliveryItems\":{\"PaymentMode\":\"\(paymentSourceArr[paymentIndex].walletName ?? "")\",\"WalletID\":\"\(paymentSourceArr[paymentIndex].walletID ?? "")\",\"WalletUniqueID\":\"\(paymentSourceArr[paymentIndex].walletID ?? "")\",\"DeliveryName\":\"\(am.getPICKUPADDRESS()!)\",\"DeliveryLL\":\"\(am.getCurrentLocation()!)\",\"Category\":\"\(category)\",\"ModuleID\":\"\(category)\",\"DeliveryDetails\":\"\(txtDeliveryDetails.text ?? "")\",\"DeliveryMode\":\"\(deliveryMode)\",\"FinalNotes\":\"\(specialRequest)\",\"TheirReference\":\(am.getSDKAdditionalData()),\"RestaurantCost\":\"\(amountRestaurant)\",\"RestaurantDeliveryItemDetails\":[\(orderString)]}"
            
            if orderString == "" {
                restaurantDeliveryItems = ""
            }
            
            dataToSend = "{\"FormID\":\"MOVIETICKETS\",\"SessionID\":\"\(am.getMyUniqueID() ?? "")\",\"MobileNumber\":\"\(am.getSDKMobileNumber() ?? "")\",\"IMEI\":\"\(am.getIMEI() ?? "")\",\"CodeBase\":\"Apple\",\"PackageName\":\"\(am.getSDKPackageName() ?? "")\",\"DeviceName\":\"\(SDKUtils.getPhoneType())\",\"SOFTWAREVERSION\":\"\(SDKUtils.getAppVersion())\",\"RiderLL\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"LatLong\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"TripID\":\"\",\"City\":\"\(am.getCity() ?? "")\",\"RegisteredCountry\":\"\(am.getCountry() ?? "")\",\"Country\":\"\(am.getCountry() ?? "")\",\"UniqueID\":\"\(am.getMyUniqueID() ?? "")\",\"NetworkCountry\":\"\(am.getCountry() ?? "")\",\"CarrierName\":\"\(SDKUtils.getCarrierName() ?? "")\",\"MovieTickets\":{\"PaymentMode\":\"\(paymentSourceArr[paymentIndex].walletName ?? "")\",\"WalletID\":\"\(paymentSourceArr[paymentIndex].walletID ?? "")\",\"WalletUniqueID\":\"\(paymentSourceArr[paymentIndex].walletID ?? "")\",\"DeliveryName\":\"\(am.getPICKUPADDRESS()!)\",\"DeliveryLL\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"Category\":\"\(category)\",\"ModuleID\":\"\(category)\",\"PromoCode\":\"\(promoIs)\",\"DeliveryDetails\":\"\(deliveryDetails)\",\"DeliveryMode\":\"\(deliveryMode)\",\"TheirReference\":\(am.getSDKAdditionalData()),\"FinalNotes\":\"\(specialRequest)\"\(moviesString)\(restaurantDeliveryItems)}}"
            
        } else {
            
            deliveryMode = selectedRestaurant?.deliveryModes?[deliveryIndex].deliveryModes ?? ""
            let delivery = Double(lblDeliveryCash.text?.filterNumbersOnly() ?? "0.00") ?? 0.00
            
            let amountRestaurant = Double((lblTotalCash.text ?? "0").filterNumbersOnly())! - amountMovies
            
            dataToSend = "{\"FormID\":\"RESTAURANTDELIVERYITEMS\"\(commonCallParams()),\"RestaurantDeliveryItems\":{\"PaymentMode\":\"\(paymentSourceArr[paymentIndex].walletName ?? "")\",\"WalletID\":\"\(paymentSourceArr[paymentIndex].walletID ?? "")\",\"DeliveryName\":\"\(am.getPICKUPADDRESS() ?? "")\",\"DeliveryLL\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"ModuleID\":\"\(category)\",\"PromoCode\":\"\(promoIs)\",\"DeliveryDetails\":\"\(txtDeliveryDetails.text ?? "")\",\"DeliveryMode\":\"\(deliveryMode)\",\"BalanceAmount\":\"0\",\"BalanceType\":\"COMMON\",\"FinalNotes\":\"\(txtExtraDetails.text ?? "")\",\"TheirReference\":\(am.getSDKAdditionalData()),\"RestaurantDeliveryItemDetails\":[\(orderString)]}}"
            
            printVal(object: "delivery fee: \(delivery), data: \(dataToSend)")
        }
        
        if selectedTheatre != nil {
            hc.makeServerCall(sb: dataToSend, method: "RESTAURANTDELIVERYITEMSMovies", switchnum: 0)
        } else {
            hc.makeServerCall(sb: dataToSend, method: "RESTAURANTDELIVERYITEMSFoodDelivery", switchnum: 0)
        }
        
    }
    
    @objc func loadPlaceFoodOrder(_ notification: NSNotification) {
        
        self.view.removeAnimation()
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RESTAURANTDELIVERYITEMSFoodDelivery"), object: nil)
        
        if data != nil {
            do {
                let orderResponse = try JSONDecoder().decode(OrderResponse.self, from: data!)
                
                if orderResponse.first?.status == "000" {
                    self.orderSuccessMessage = orderResponse.first?.message ?? ""
                    
                    DispatchQueue.main.async(execute: {
                        
                        let restaurantName = self.selectedRestaurant?.restaurantName ?? ""
                        
                        self.view.removeAnimation()
                        
                        /*let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: self.sdkBundle!)
                        view.loadPopup(title: "", message: "\n\(orderResponse[0].message ?? "Your order has been successfully placed.")\n", image: "", action: "")
                        view.proceedAction = {
                            SwiftMessages.hide()
                            self.am.saveFromConfirmOrder(data: true)
                            let desiredViewController = self.navigationController?.viewControllers.filter { $0 is DeliveriesController }.first
                            if desiredViewController != nil {
                                self.navigationController?.popToViewController(desiredViewController!, animated: true)
                            }
                        }
                        view.btnDismiss.isHidden = true
                        view.configureDropShadow()
                        var config = SwiftMessages.defaultConfig
                        config.duration = .forever
                        config.presentationStyle = .bottom
                        config.dimMode = .gray(interactive: false)
                        SwiftMessages.show(config: config, view: view)*/
                        
                    })
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(paymentResultReceived(_:)),name: NSNotification.Name(rawValue: "PAYMENT_RESULT"), object: nil)
                    
                    let userInfo = ["amount":Double(lblTotalCash.text ?? "0") ?? 0,"reference":reference, "additionalData": am.getSDKAdditionalData()] as [String : Any]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PAYMENT_REQUEST"), object: nil, userInfo: userInfo)
                    
                    /*DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        let userInfo = ["success": true] as [String : Any]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PAYMENT_RESULT"), object: nil, userInfo: userInfo)
                    }*/
                } else if orderResponse[0].status == "091" {
                    DispatchQueue.main.async(execute: {
                        self.showAlerts(title: "", message: orderResponse[0].message ?? "Error occured creating your order. Kindly retry.")
                    })
                } else if orderResponse[0].status == "092" {
                    
                    var MESSAGE = ""
                    
                    if orderResponse[0].message == "" {
                        MESSAGE = "Your Little Wallet has insuffecient funds. Do you wish to proceed to load cash?"
                    } else {
                        MESSAGE = orderResponse[0].message ?? ""
                    }
                    
                    let restaurantName = self.selectedRestaurant?.restaurantName ?? ""
                    
                    let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
                    view.loadPopup(title: "", message: "\n\(MESSAGE)\n", image: "", action: "")
                    view.proceedAction = {
                       SwiftMessages.hide()
                        if let viewController = UIStoryboard(name: "UMI", bundle: self.sdkBundle!).instantiateViewController(withIdentifier: "LoadCashViewController") as? LoadCashViewController {
                           if let navigator = self.navigationController {
                               navigator.pushViewController(viewController, animated: true)
                           }
                       }
                    }
                    view.cancelAction = {
                        SwiftMessages.hide()
                    }
                    view.btnProceed.setTitle("Load Cash", for: .normal)
                    view.configureDropShadow()
                    var config = SwiftMessages.defaultConfig
                    config.duration = .forever
                    config.presentationStyle = .bottom
                    config.dimMode = .gray(interactive: false)
                    SwiftMessages.show(config: config, view: view)
                    
                    
                } else {
                    DispatchQueue.main.async(execute: {
                        
                        self.showAlerts(title: "", message: "Error occured creating your order. Kindly retry.")
                    })
                }
                
            } catch {
                do {
                    let defaultMessage = try JSONDecoder().decode(DefaultMessage.self, from: data!)
                    DispatchQueue.main.async(execute: {
                        self.showAlerts(title: "", message: defaultMessage.message ?? "Error occured creating your order. Kindly retry.")
                        
                    })
                } catch {
                    DispatchQueue.main.async(execute: {
                        self.showAlerts(title: "", message: "Error occured creating your order. Kindly retry.")
                    })
                }
                
            }
        }
        
    }
    
    // MARK: - Functions & IBActions
    
    @objc func fromOrderLocation() {
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "LOCATIONORDER"), object: nil)

        let index = am.getSelectedLocIndex() ?? 0
        let coordinate = SDKUtils.extractCoordinate(array: am.getRecentPlacesCoords(), index: index)
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        am.saveCurrentLocation(data: "\(latitude),\(longitude)")
        let pickupName = am.getRecentPlacesNames()[safe: index]?.cleanLocationNames() ?? ""
        am.savePICKUPADDRESS(data: pickupName)
        btnLocation.setTitle(pickupName, for: UIControl.State())
        
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        
        var restaurantID = selectedRestaurant?.restaurantID ?? ""
        if selectedTheatre != nil {
            restaurantID = selectedTheatre?.restaurantID ?? ""
        }
        #warning("check restaurantID")
        
        if menuArr[sender.tag].extraItem == "Y" {
            
            let result = cartItems.compactMap { $0 }.contains(where: { $0.addonID == menuArr[sender.tag].addonID })
            if result {
                let index = cartItems.firstIndex(where: { $0.itemID == menuArr[sender.tag].menuID }) ?? 0
                cartItems[index] = CartItems(itemID: menuArr[sender.tag].menuID, addonID: menuArr[sender.tag].addonID, number: sender.value)
            } else {
                cartItems.append(CartItems(itemID: menuArr[sender.tag].menuID, addonID: menuArr[sender.tag].addonID, number: sender.value))
            }
            
            changeCartValues()
            
            printVal(object: cartItems)
            
        } else {
            let result = cartItems.compactMap { $0 }.contains(where: { $0.itemID == menuArr[sender.tag].menuID })
            if result {
                let index = cartItems.firstIndex(where: { $0.itemID == menuArr[sender.tag].menuID }) ?? 0
                cartItems[index] = CartItems(itemID: menuArr[sender.tag].menuID, addonID: menuArr[sender.tag].addonID, number: sender.value)
            } else {
                cartItems.append(CartItems(itemID: menuArr[sender.tag].menuID, addonID: menuArr[sender.tag].addonID, number: sender.value))
            }
            
            changeCartValues()
            
            printVal(object: cartItems)
        }
    }
    
    func changeCartValues() {
        var movieCost = 0.00
        if selectedTheatre != nil {
            movieCost = seatTotalPrice// (getMoviePrice() * Double(selectedTicketNo ?? 0))
        }
        
        if cartItems.count > 0 {
            var total = 0.00
            for _ in cartItems {
                let index = cartItems.firstIndex(where: { $0.number == 0 })
                if index != nil {
                    cartItems.remove(at: index!)
                }
            }
            for item in cartItems {
                var result = menuArr.compactMap { $0 }.first(where: { $0.menuID == item.itemID })
                if item.addonID != nil {
                    result = menuArr.compactMap { $0 }.first(where: { $0.addonID == item.addonID })
                }
                if result != nil {
                    var totalExtras = 0.0
                    if result?.addonID != nil {
                        for each in result?.extraItems ?? [] {
                            totalExtras = totalExtras + (each.specialPrice ?? 0.0)
                        }
                    }
                    let math = (result?.specialPrice ?? 0.00)+totalExtras
                    total = total + ((math)*(item.number ?? 0))
                }
            }
            
            total = total + movieCost
            
            if total == 0.00 {
                updateOrderValues(total: 0.00)
            } else {
                updateOrderValues(total: total)
            }
            
        } else {
            updateOrderValues(total: 0.00)
        }
        menuTable.reloadData()
    }
    
    func updateOrderValues(total: Double) {
        let val = seatTotalPrice //(getMoviePrice() * Double(selectedTicketNo ?? 0))
        
        if selectedTheatre != nil {
            lblMoviesCash.text = "\(currency ?? am.getGLOBALCURRENCY() ?? "KES") \(formatCurrency(String(val)))"
        }
        
        lblProductsCash.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) \(formatCurrency(String(total)))"
        let delivery = Double(lblDeliveryCash.text?.filterNumbersOnly() ?? "0.00") ?? 0.00
        let promocode = Double(lblPromoCodeCash.text?.filterNumbersOnly() ?? "0.00") ?? 0.00
        var grandTotal = (total - promocode)
        if grandTotal < 0 {
            grandTotal = delivery
        } else {
            grandTotal = grandTotal + delivery
        }
        lblTotalCash.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) \(formatCurrency(String(grandTotal)))"
        
        if total == 0.00 {
            btnConfirmOrder.backgroundColor = .darkGray
        } else if total < 0.00 {
            lblTotalCash.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) 0.00"
        } else {
            let color = SDKConstants.littleSDKThemeColor
            btnConfirmOrder.backgroundColor = SDKConstants.littleSDKThemeColor
        }
    }
    
    func promoValid() {
        promoIsValid = true
        let color = SDKConstants.littleSDKThemeColor
        btnConfirmPromo.backgroundColor = color
        btnConfirmPromo.isEnabled = false
        promoIs = txtPromoCode.text!
        lblPromoCodeCash.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) \(formatCurrency(String(am.getPROMOAMOUNT() ?? "0")))"
        changeCartValues()
    }
    
    func promoInvalid() {
        promoIsValid = false
        let color = SDKConstants.littleSDKThemeColor
        btnConfirmPromo.backgroundColor = color
        btnConfirmPromo.isEnabled = true
        promoIs = ""
        lblPromoCodeCash.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) 0.00"
        changeCartValues()
    }
    
    func adjustDeliveryHeight(source: DeliveryMode) {
        
        if selectedTheatre != nil {
            
            #warning("check deliveryDetailsHeight")
            self.totalViewHeight.constant = ((570.0 + totalHeight) - 120.0)
//            self.deliveryDetailsHeight.constant = 0
            self.deliverLocationConst.constant = 0
            self.deliverModeConst.constant = 0
            printVal(object: "hideDeliveryMode")
            UIView.animate(withDuration: 0.3, animations: {
                self.deliveryModeView.alpha = 0
                self.deliverLocationView.alpha = 0
                self.view.layoutIfNeeded()
            }, completion: { completed in
                self.deliveryModeView.isHidden = true
                self.deliverLocationView.isHidden = true
                self.changeCartValues()
            })
            
        } else {
            if source.deliveryModeDescription?.lowercased().contains("pickup") ?? false  || source.deliveryModeDescription == "1" {
                self.totalViewHeight.constant = ((525.0 + totalHeight) - 120.0)
                self.deliverLocationConst.constant = 0
                self.topDelConst.constant = 60
                UIView.animate(withDuration: 0.3, animations: {
                    self.deliverLocationView.alpha = 0
                    self.view.layoutIfNeeded()
                }, completion: { completed in
                    self.deliverLocationView.isHidden = true
                    self.changeCartValues()
                })
            } else {
                self.totalViewHeight.constant = (525.0 + totalHeight)
                self.deliverLocationConst.constant = 120
                self.topDelConst.constant = 80
                self.deliverLocationView.alpha = 0
                self.deliverLocationView.isHidden = false
                UIView.animate(withDuration: 0.3, animations: {
                    self.deliverLocationView.alpha = 1
                    self.view.layoutIfNeeded()
                }, completion: { completed in
                    self.changeCartValues()
                })
            }
        }
    }
    
    @objc func paymentResultReceived(_ notification: Notification) {
        
        let success = notification.userInfo?["success"] as? Bool
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PAYMENT_RESULT"), object: nil)
        if let success = success {
            if success {
//                self.placeFoodOrder()
                if self.selectedTheatre != nil {
                    self.am.saveMESSAGE(data: "FromBookingMovie")
                    #warning("check removeAndUpdateCart")
//                    self.removeAndUpdateCart()
                    if let desiredViewController = self.navigationController?.viewControllers.filter({ $0 is MoviesController }).first {
                        self.navigationController?.popToViewController(desiredViewController, animated: true)
                    }
                } else {
                    self.showAlerts(title: "", message: orderSuccessMessage)
                    self.am.saveFromConfirmOrder(data: true)
                    if let desiredViewController = self.navigationController?.viewControllers.filter({ $0 is DeliveriesController }).first {
                        self.navigationController?.popToViewController(desiredViewController, animated: true)
                    }
                }
            } else {
                self.showAlerts(title: "", message: "Error occured completing payment. Please retry.")
            }
        } else {
            printVal(object: "Include a success boolean value with the PAYMENT_RESULT Notification Post")
        }
        
        
    }
    
    @IBAction func promoChanged(_ sender: UITextField) {
        if promoIsValid {
            promoInvalid()
            showAlerts(title: "", message: "Kindly re-validate newly typed promo code.")
        }
    }
    
    @IBAction func cashSourcePressed(_ sender: UIButton) {
        let paymentOptions = UIAlertController(title: nil, message: "Choose Payment Mode", preferredStyle: .actionSheet)
        
        let normalColor = SDKConstants.littleSDKThemeColor
        
        for i in (0..<paymentSourceArr.count) {
            let source = paymentSourceArr[i]
            let reasonBtn = UIAlertAction(title: "\(source.walletName ?? "")", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                sender.setTitle("\(source.walletName ?? "")", for: .normal)
                self.paymentIndex = i
            })
            reasonBtn.setValue(normalColor, forKey: "titleTextColor")
            paymentOptions.addAction(reasonBtn)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        paymentOptions.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            paymentOptions.popoverPresentationController?.sourceView = sender
            paymentOptions.popoverPresentationController?.sourceRect = CGRect(x: sender.bounds.size.width / 2.0, y: sender.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        DispatchQueue.main.async {self.present(paymentOptions, animated: true, completion: nil)}
        
    }
    
    @IBAction func btnDeliveryModePressed(_ sender: UIButton) {
        let options = UIAlertController(title: nil, message: "Choose Delivery Mode", preferredStyle: .actionSheet)
        
        let normalColor = SDKConstants.littleSDKThemeColor
        
        for i in (0..<(selectedRestaurant?.deliveryModes?.count ?? 0)) {
            let source = selectedRestaurant?.deliveryModes?[i]
            let sourceBtn = UIAlertAction(title: "\(source?.deliveryModeDescription ?? "") (\(self.am.getGLOBALCURRENCY() ?? "") \(source?.deliveryCharges ?? 0))", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                sender.setTitle("\(source?.deliveryModeDescription ?? "")", for: .normal)
                self.deliveryIndex = i
                self.lblDeliveryCash.text = "\(self.am.getGLOBALCURRENCY() ?? "") \(source?.deliveryCharges ?? 0)"
                self.adjustDeliveryHeight(source: source!)
                
                if source?.deliveryModeDescription?.lowercased().contains("pickup") ?? false {
                    self.txtDeliveryDetails.placeholder = "Add House, Floor No. (Optional)"
                } else {
                    self.txtDeliveryDetails.placeholder = "Add House, Floor No."
                }
                
            })
            sourceBtn.setValue(normalColor, forKey: "titleTextColor")
            options.addAction(sourceBtn)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        options.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            options.popoverPresentationController?.sourceView = sender
            options.popoverPresentationController?.sourceRect = CGRect(x: sender.bounds.size.width / 2.0, y: sender.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        DispatchQueue.main.async {self.present(options, animated: true, completion: nil)}
    }
    
    @IBAction func btnLocationPressed(_ sender: UIButton) {
        
        showAlerts(title: "", message: "Kindly note you cannot change delivery location at this stage. You can however go back to the \(category.capitalized) menu to pick the desired location.")
        
    }
    
    @IBAction func btnConfirmPromoPressed(_ sender: UIButton) {
        if txtPromoCode.text == "" {
            dismissSwiftAlert()
            showAlerts(title: "", message: "Kindly ensure you type the promo code first.")
        } else {
            verifyPromoCode(promoText: txtPromoCode.text!)
        }
    }
    
    @IBAction func btnConfirmOrder(_ sender: UIButton) {
        if btnConfirmOrder.backgroundColor == .darkGray {
            showAlerts(title: "", message: "Kindly ensure you have at least one item in cart.")
        } else if txtDeliveryDetails.text == "" && !(txtDeliveryDetails.placeholder?.lowercased().contains("optional") ?? true) {
            showAlerts(title: "", message: "Kindly ensure you have entered delivery details e.g house name, number, floor etc.")
        } else if btnDeliverMode.title(for: UIControl.State()) == "Choose Delivery Mode" {
            showAlerts(title: "", message: "Kindly ensure you have chosen delivery mode you prefer.")
        } else if btnLocation.title(for: UIControl.State()) == "Choose Location" && deliverLocationView.isHidden == false {
            showAlerts(title: "", message: "Kindly ensure you have chosen delivery location.")
        } else if btnPaymentMode.title(for: UIControl.State()) == "Choose Payment Mode" {
            showAlerts(title: "", message: "Kindly ensure you have chosen preferred payment mode.")
        } else {
            if merchantMessage != "" && merchantMessage != "Any special requests?" {
                if txtExtraDetails.text == "" {
                    showAlerts(title: "", message: "Kindly ensure you have filled in the '\(merchantMessage)' field.")
                } else {
                    self.placeFoodOrder()
                }
            } else {
                self.placeFoodOrder()
            }
        }
    }
    
    @IBAction func btnCashSourcePressed(_ sender: UIButton) {
        if let amount = lblTotalCash.text?.replacingOccurrences(of: "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) ", with: "") {
            if amount != "0.00" {
                am.saveAmount(data: amount)
            } else {
                am.saveAmount(data: "")
            }
        } else {
            am.saveAmount(data: "")
        }
        if let viewController = UIStoryboard(name: "UMI", bundle: sdkBundle!).instantiateViewController(withIdentifier: "LoadCashViewController") as? LoadCashViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    // MARK: - TableView DataSource & Delegates

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuArr.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let menuItem = menuArr[indexPath.item]
        let color = SDKConstants.littleSDKThemeColor
        
        if menuItem.extraItems?.count ?? 0 > 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "addonsCell") as! MenuAddonsCell
            
            cell.lblMenuName.text = "\(menuItem.foodName ?? "")"
            
            if selectedTheatre != nil && indexPath.item == 0 {
                #warning("check stepperStack")
                // cell.stepperStack.isHidden = true
                cell.stepperMenu.isHidden = true
                
                cell.stepperMenu.value = Double(selectedTicketNo ?? 0)
                cell.selectedView.backgroundColor = color.withAlphaComponent(0.1)
                
            } else {
                if cartItems.contains(where: { $0.itemID == menuArr[indexPath.item].menuID }) {
                    let value = cartItems.first(where: { $0.addonID == menuArr[indexPath.item].addonID })?.number ?? 0.0
                    cell.stepperMenu.value = value
                    cell.lblAmount.text = "\(Int(value))"
                    cell.selectedView.backgroundColor = color.withAlphaComponent(0.1)
                } else {
                    cell.stepperMenu.value = 0
                    cell.lblAmount.text = "0"
                    cell.selectedView.backgroundColor = .white
                }
            }
            
            cell.lblAmount.tag = indexPath.item
            cell.stepperMenu.tag = indexPath.item
            
            cell.stepperMenu.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
            
            var totalAmount = 0.0
            var string = ""
            for each in menuItem.extraItems ?? [] {
                if each.specialPrice ?? 0.0 == 0.0 {
                    string = "\(string)● \(each.extraItemName ?? "")"
                } else {
                    string = "\(string)● \(each.extraItemName ?? "") (+\(formatCurrency(String(each.specialPrice ?? 0.0))))"
                }
                if each.extraItemID != menuItem.extraItems?.last?.extraItemID {
                    string = "\(string)\n"
                }
                totalAmount = totalAmount + (each.specialPrice ?? 0.0)
            }
            
            let grandTotal = totalAmount + (menuItem.specialPrice ?? 0.0)
            cell.lblTotalAmount.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) \(formatCurrency(String(grandTotal)))"
            cell.lblExtrasWithOrder.text = "\(string)"
            
            cell.selectionStyle = .none
            cell.layoutIfNeeded()
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MenuCell
            
            cell.layoutIfNeeded()
            cell.imgMenu.layoutIfNeeded()
            
            SDWebImageManager.shared.imageCache.removeImage(forKey: menuItem.foodImage ?? "", cacheType: .all)
            cell.imgMenu.sd_setImage(with: URL(string: menuItem.foodImage ?? ""), placeholderImage:  getImage(named: "default_food", bundle: sdkBundle!))
            cell.imgMenu.alpha = 1
            cell.lblMenuName.text = "\(menuItem.foodName ?? "")"
            cell.lblDescription.text = "\(menuItem.foodDescription ?? "")"
            cell.lblMenuAmount.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) \(menuItem.specialPrice ?? 0.00)"
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) \(menuItem.originalPrice ?? 0.00)")
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.lblMenuWasAmount.attributedText = attributeString
            
            if menuItem.specialPrice ?? 0 < menuItem.originalPrice ?? 0 {
                cell.lblMenuWasAmount.isHidden = false
            } else {
                cell.lblMenuWasAmount.text = ""
                cell.lblMenuWasAmount.isHidden = true
            }
            
            if menuItem.extraItem == "Y" {
                
                cell.lblAmount.isHidden = true
                cell.btnAdd.isHidden = true
                cell.stepperMenu.isHidden = true
                cell.lblAmount.tag = indexPath.item
                cell.btnAdd.tag = indexPath.item
                
            } else {
                
                cell.lblAmount.isHidden = false
                cell.btnAdd.isHidden = true
                cell.stepperMenu.isHidden = false
                cell.lblAmount.tag = indexPath.item
                cell.stepperMenu.tag = indexPath.item
                
                cell.stepperMenu.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
            }
            
            if selectedTheatre != nil && indexPath.item == 0 {
                
                #warning("check stepperStack")
                // cell.stepperStack.isHidden = true
                cell.stepperMenu.isHidden = true
                
                cell.stepperMenu.value = Double(selectedTicketNo ?? 0)
                cell.selectedView.backgroundColor = color.withAlphaComponent(0.1)
                
            } else {
                if cartItems.contains(where: { $0.itemID == menuArr[indexPath.item].menuID }) && menuArr[indexPath.item].extraItem != "Y" {
                    let value = cartItems.first(where: { $0.itemID == menuArr[indexPath.item].menuID })?.number ?? 0.0
                    cell.stepperMenu.value = value
                    cell.lblAmount.text = "\(Int(value))"
                    cell.selectedView.backgroundColor = color.withAlphaComponent(0.1)
                } else {
                    cell.stepperMenu.value = 0
                    cell.lblAmount.text = "0"
                    cell.selectedView.backgroundColor = .white
                }
            }
            
            cell.lblExtrasWithOrder.text = ""
            
            cell.selectionStyle = .none
            cell.layoutIfNeeded()
            
            return cell
        }
    }
}
