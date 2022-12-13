//
//  OrderSummaryController.swift
//  Little
//
//  Created by Gabriel John on 03/04/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import SwiftMessages
import UIView_Shimmer

public class OrderSummaryController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    var sdkBundle: Bundle?
    
    var cartItems: [DeliveryTripDetail] = []
    var deliveryLogsArr: [DeliveryLog] = []
    
    var currency: String?
    var restaurantName: String?
    var deliveryID: String?
    var tripStatus: String?
    var serviceTripID: String?
    
    var rateMerchant: String?
    var rateMobile: String?
    var rateEmail: String?
    
    var orderAmount: Double?
    var deliveryCharges: Double?
    var totalCharges: Double?
    var promo: Double?
    
    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var trackTable: UITableView!
    
    @IBOutlet weak var menuTableHeight: NSLayoutConstraint!
    @IBOutlet weak var deliveryTableHeight: NSLayoutConstraint!
    @IBOutlet weak var totalViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomButtonHeight: NSLayoutConstraint!
    
    @IBOutlet weak var btnTrackOrder: UIButton!
    @IBOutlet weak var btnCancelOrder: UIButton!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblProductsAmount: UILabel!
    @IBOutlet weak var lblDeliveryFee: UILabel!
    @IBOutlet weak var lblPromoCode: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var lblOrderID: UILabel!
    
    private var shouldCancelOrder = true
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle.module
        
        let nib = UINib.init(nibName: "OrderSummaryCell", bundle: sdkBundle!)
        menuTable.register(nib, forCellReuseIdentifier: "cell")
        
        let nib2 = UINib.init(nibName: "DeliveryCell", bundle: sdkBundle!)
        trackTable.register(nib2, forCellReuseIdentifier: "deliveryCell")
        
        if serviceTripID == "" || serviceTripID == nil {
            btnTrackOrder.backgroundColor = SDKConstants.littleSDKLabelColor
        } else {
            btnTrackOrder.backgroundColor = SDKConstants.littleSDKThemeColor
        }
        
        self.menuTable.estimatedRowHeight = 80
        self.menuTable.rowHeight = UITableView.automaticDimension
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        if restaurantName?.last?.lowercased() == "s" {
            lblTitle.text = "\(restaurantName ?? "")' Order Summary"
        } else {
            lblTitle.text = "\(restaurantName ?? "")'s Order Summary"
        }
        self.bottomButtonHeight.constant = 0
        
        getOrderSummary()
    }
    
    private func setupButtons() {
        var shouldCancel = false
        
        deliveryLogsArr.forEach { item in
            if item.eventName?.equalIgnoreCase("accepted") == true && (item.eventTime == nil || (item.eventTime ?? "").isEmpty) {
                shouldCancel = true
            }
        }
        
        btnCancelOrder.isHidden = !shouldCancel
        
        btnTrackOrder.isHidden = (serviceTripID ?? "").isEmpty
    }
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID() ?? "")\",\"MobileNumber\":\"\(am.getSDKMobileNumber() ?? "")\",\"IMEI\":\"\(am.getIMEI() ?? "")\",\"CodeBase\":\"\(am.getMyCodeBase() ?? "")\",\"PackageName\":\"\(am.getSDKPackageName() ?? "")\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"LatLong\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"TripID\":\"\",\"City\":\"\(am.getCity() ?? "")\",\"RegisteredCountry\":\"\(am.getCountry() ?? "")\",\"Country\":\"\(am.getCountry() ?? "")\",\"UniqueID\":\"\(am.getMyUniqueID() ?? "")\",\"CarrierName\":\"\(getCarrierName() ?? "")\",\"UserAdditionalData\":\(am.getSDKAdditionalData())"
        
        return str
    }
    
    func getOrderSummary() {
        
        loadingScreen()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadOrderSummary),name:NSNotification.Name(rawValue: "GETDELIVERYDETAILSFoodDelivery"), object: nil)
        
        let dataToSend = "{\"FormID\":\"GETDELIVERYDETAILS\"\(commonCallParams()),\"GetRestaurantMenu\":{\"DeliveryTripID\":\"\(deliveryID ?? "")\"}}"
        
        hc.makeServerCall(sb: dataToSend, method: "GETDELIVERYDETAILSFoodDelivery", switchnum: 0)
        
    }
    
    @objc func loadOrderSummary(_ notification: NSNotification) {
        
        stopLoading()
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETDELIVERYDETAILSFoodDelivery"), object: nil)
        
        if data != nil {
            do {
                cartItems.removeAll()
                let orderSummary = try JSONDecoder().decode(OrderSummary.self, from: data!)
                guard let orderSummaryItem = orderSummary.first else { return}
                serviceTripID = orderSummaryItem.serviceTripID
                cartItems = orderSummaryItem.deliveryTripDetails ?? []
                deliveryLogsArr = orderSummaryItem.deliveryLogs ?? []
                rateEmail = orderSummaryItem.driverEMail ?? ""
                
                menuTableHeight.constant = CGFloat((cartItems.count*100))
                deliveryTableHeight.constant = CGFloat((deliveryLogsArr.count*100))
                totalViewHeight.constant = 220 + CGFloat((cartItems.count*100)) + CGFloat((deliveryLogsArr.count*100))
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                
                lblOrderID.text = "Order #\(deliveryID?.components(separatedBy: "-")[safe: 0] ?? "") - \(tripStatus ?? "")"
                lblDeliveryFee.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES"))  \(formatCurrency(String(deliveryCharges ?? 0.0)))"
                lblPromoCode.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) \(formatCurrency(String(promo ?? 0.0)))"
                lblProductsAmount.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) \(formatCurrency(String(orderAmount ?? 0.0)))"
                lblTotalAmount.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) \(formatCurrency(String(totalCharges ?? 0)))"
                
                if let lastItem = deliveryLogsArr.last {
                    if lastItem.eventTime != nil && lastItem.eventTime != "" {
                        bottomButtonHeight.constant = 0
                    } else {
                        bottomButtonHeight.constant = 70
                    }
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                
                menuTable.reloadData()
                trackTable.reloadData()
            } catch {
                menuTable.reloadData()
                trackTable.reloadData()
            } 
        }
        
        setupButtons()
        
    }
    
    @IBAction func btnTrackOrderPressed(_ sender: UIButton) {
        if serviceTripID == "" || serviceTripID == nil {
            showAlerts(title: "", message: "Your order will be picked by our rider shortly. Sit tight.")
        } else {
            if let viewController = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "TrackOrderController") as? TrackOrderController {
                viewController.trackID = serviceTripID!
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    @IBAction func btnCancelOrder(_ sender: UIButton) {
        
        let popOverVC = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "CancelOrderController") as! CancelOrderController
        self.addChild(popOverVC)
        popOverVC.deliveryID = deliveryID ?? ""
        popOverVC.restaurantName = restaurantName ?? ""
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
    @objc func callBtnPressed(_ sender: UIButton) {
        var number = deliveryLogsArr[sender.tag].mobileNumber ?? ""
        if number != "" {
            number="+"+number
            guard let url = URL(string: "telprompt://\(number)") else {
              return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func rateMerchantBtnPressed(_ sender: UIButton) {
        let deliveryItem = deliveryLogsArr[sender.tag]
        
        rateMerchant = deliveryItem.name ?? ""
        rateMobile = deliveryItem.mobileNumber ?? ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadMerchantToRate(_:)),name:NSNotification.Name(rawValue: "RATECANCEL"), object: nil)
        
        let popOverVC = UIStoryboard(name: "Trip", bundle: sdkBundle!).instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
        self.addChild(popOverVC)
        popOverVC.driverName = deliveryItem.name ?? ""
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        
    }
    
    @objc func rateDriverBtnPressed(_ sender: UIButton) {
        let deliveryItem = deliveryLogsArr[sender.tag]
        
        rateMerchant = deliveryItem.name ?? ""
        rateMobile = deliveryItem.mobileNumber ?? ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.loadDriverRate(_:)),name:NSNotification.Name(rawValue: "RATECANCEL"), object: nil)
        
        let popOverVC = UIStoryboard(name: "Trip", bundle: sdkBundle!).instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
        self.addChild(popOverVC)
        popOverVC.driverName = deliveryItem.name ?? ""
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        
    }
    
    @objc func loadMerchantToRate(_ notification: Notification) {
        
        let data = notification.userInfo!["data"] as! String
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "RATECANCEL"), object: nil)
        
        if data.components(separatedBy: ":::").count > 1 {
            let message = data.components(separatedBy: ":::")[1]
            let rating = data.components(separatedBy: ":::")[0]
            submitMerchantRate(message: message, rating: rating)
        }
        
    }
    
    @objc func loadDriverRate(_ notification: Notification) {
        
        let data = notification.userInfo!["data"] as! String
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "RATECANCEL"), object: nil)
        
        if data.components(separatedBy: ":::").count > 1 {
            let message = data.components(separatedBy: ":::")[1]
            let rating = data.components(separatedBy: ":::")[0]
            submitDriverRate(message: message, rating: rating)
        }
        
    }
    
    func submitMerchantRate(message: String, rating: String) {
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMerchantRate),name:NSNotification.Name(rawValue: "MERCHANTRATING"), object: nil)
        
        var params = SDKUtils.commonJsonTags(formId: "MERCHANTRATING")
        params["TrxRating"] = [
            "TrxReference": deliveryID ?? "",
            "Rating": rating,
            "Feedback": message,
            "Comments": message,
            "Name": rateMerchant,
            "MobileNumber": rateMobile
        ]
        
        let dataToSend = (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
                
        hc.makeServerCall(sb: dataToSend, method: "MERCHANTRATING", switchnum: 0)
    }
    
    @objc func loadMerchantRate(_ notification: Notification) {
        self.view.removeAnimation()
        
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name(rawValue: "RATE"), object: nil)
        
        if let userInfo = notification.userInfo, let data = userInfo["data"] as? Data {
            do {
                let response = try JSONDecoder().decode(CommonResponse.self, from: data)
                if let details = response.first {
                    if details.status == "000" {
                        self.showAlerts(title: "", message: "\nMerchant rated successfully.\n")
                    } else {
                        self.showAlerts(title: "", message: details.message ??  "\n\("Ooops, something went wrong.".localized)\n")
                    }
                    
                } else {
                    showGeneralErrorAlert()
                }
                
            } catch (let error) {
                showGeneralErrorAlert()
                printVal(object: "error: \(error.localizedDescription)")
            }
        }
        
    }
    
    func submitDriverRate(message: String, rating: String) {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadRate),name:NSNotification.Name(rawValue: "RATE"), object: nil)
        
        var params = SDKUtils.commonJsonTags(formId: "RATE")
        params["RateAgent"] = [
            "TripID": serviceTripID ?? "",
            "Rating": rating,
            "Comments": message
        ]
        
        let dataToSend = (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
                
        hc.makeServerCall(sb: dataToSend, method: "RATE", switchnum: 0)
    }
    
    @objc func loadRate(_ notification: NSNotification) {
        self.view.removeAnimation()
        
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name(rawValue: "RATE"), object: nil)
        
        if let userInfo = notification.userInfo, let data = userInfo["data"] as? Data {
            do {
                let response = try JSONDecoder().decode(CommonResponse.self, from: data)
                if let details = response.first {
                    if details.status == "000" {
                        self.showAlerts(title: "", message: details.message ?? "\nYour delivery guy has been rated successfully.\n")
                    } else {
                        self.showAlerts(title: "", message: details.message ??  "\n\("Ooops, something went wrong.".localized)\n")
                    }
                    
                } else {
                    showGeneralErrorAlert()
                }
                
            } catch (let error) {
                showGeneralErrorAlert()
                printVal(object: "error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Functions & IBActions
    
    func loadingScreen() {
//        view.layoutIfNeeded()
        view.setTemplateWithSubviews(true)
        
    }
    
    func stopLoading() {
        view.setTemplateWithSubviews(false)
    }
    
    // MARK: - TableView DataSource & Delegates
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.tag == 0 {
            return UITableView.automaticDimension
        } else {
            let deliveryItem = deliveryLogsArr[indexPath.item]
            if deliveryItem.mobileNumber != nil && deliveryItem.mobileNumber != "" {
                return 120
            } else {
                return 80
            }
            
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return cartItems.count
        } else {
            return deliveryLogsArr.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            let menuItem = cartItems[indexPath.item]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OrderSummaryCell
            
            cell.imgMenuImage.image = getImage(named: "default_food", bundle: sdkBundle!)
            cell.lblMenuName.text = "\(menuItem.foodName ?? "")"
            #warning("check price1")
            cell.lblMenuAmount.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "KES")) \(menuItem.price ?? 0)"
            cell.lblMenuNumber.text = "x \(menuItem.quantity ?? 0)"
            cell.selectionStyle = .none
            
            return cell
        } else {
            let deliveryItem = deliveryLogsArr[indexPath.item]
            let cell = tableView.dequeueReusableCell(withIdentifier: "deliveryCell") as! DeliveryCell
            if deliveryLogsArr.count == 1 {
//                cell.overView.isHidden = true
                cell.underView.isHidden = true
            } else if indexPath.item == 0 {
//                cell.overView.isHidden = true
                cell.underView.isHidden = false
            } else if indexPath.item == (deliveryLogsArr.count - 1) {
//                cell.overView.isHidden = false
                cell.underView.isHidden = true
            } else {
//                cell.overView.isHidden = false
                cell.underView.isHidden = false
            }
            cell.lblTime.text = deliveryItem.eventTime ?? nil
            if deliveryItem.eventTime != nil && deliveryItem.eventTime != "" {
                cell.eventTopConstraint.isActive = true
                cell.eventTopSuperConstraint.isActive = false
                let color = SDKConstants.littleSDKThemeColor
//                cell.overView.backgroundColor = color
                cell.imgSelected.image = getImage(named: "checked", bundle: sdkBundle!)
                cell.imgSelected.tintColor = color
                if indexPath.item < deliveryLogsArr.count-1 {
                    let item = deliveryLogsArr[indexPath.item+1].eventTime
                    if item != nil && item != "" {
                        cell.underView.backgroundColor = color
                    } else {
                        cell.underView.backgroundColor = .lightGray
                    }
                } else {
                    cell.underView.backgroundColor = .lightGray
                }
            } else {
                cell.eventTopConstraint.isActive = false
                cell.eventTopSuperConstraint.isActive = true
                cell.eventTopSuperConstraint.constant = 0
//                cell.overView.backgroundColor = .lightGray
                cell.underView.backgroundColor = .lightGray
                cell.imgSelected.tintColor = .lightGray
                cell.imgSelected.image = getImage(named: "circle", bundle: sdkBundle!)
            }
            if deliveryItem.mobileNumber != nil && deliveryItem.mobileNumber != "" {
                let picked  = deliveryItem.eventName?.contains("Picked") ?? false
                cell.btnCall.isHidden = true
                cell.lblDescription.text = !picked ? "Rate \(deliveryItem.name ?? "") to help improve our services" : nil
                cell.btnRate.isHidden = picked
                cell.btnRate.tag = indexPath.item
                if deliveryItem.eventName?.contains("Picked") ?? false {
                    cell.btnRate.addTarget(self, action: #selector(rateDriverBtnPressed(_:)), for: .touchUpInside)
                } else {
                    cell.btnRate.addTarget(self, action: #selector(rateMerchantBtnPressed(_:)), for: .touchUpInside)
                }
            } else {
                cell.lblDescription.text = nil
                cell.btnCall.isHidden = true
                cell.lblDescription.text = ""
                cell.btnRate.isHidden = true
            }
            if deliveryItem.eventName?.contains("Picked") ?? false {
                cell.btnCall.setTitle("Call rider (\((deliveryItem.name ?? "").capitalized))", for: .normal)
            }
            
            cell.btnCallWidthConstraint.constant = cell.btnCall.intrinsicContentSize.width + 10
            cell.btnRateWidthConstraint.constant = cell.btnRate.intrinsicContentSize.width + 10
            
            /*if deliveryItem.eventName?.contains("Accepted") ?? false {
                cell.lblEvent.text = "What do you think of \((deliveryItem.name ?? "").capitalized)?"
            } else if deliveryItem.eventName?.contains("Picked") ?? false {
                cell.lblEvent.text = "What do you think of \((deliveryItem.name ?? "").capitalized)?"
            } else {
                cell.lblEvent.text = deliveryItem.eventName ?? ""
            }*/
            
            cell.lblEvent.text = deliveryItem.eventName ?? ""
            
            cell.selectionStyle = .none
            return cell
        }
        
        
    }
}
