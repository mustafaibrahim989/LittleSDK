//
//  OrderHistoryController.swift
//  Little
//
//  Created by Gabriel John on 03/04/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import UIView_Shimmer

public class OrderHistoryController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    var sdkBundle: Bundle?
    
    var historyData: Data?
    
    var historyArr: [ListTrip] = [ListTrip(orderedOn: "         ", deliveryTripID: "                   ", serviceTripID: "", requestSendToDriver: "", tripStatus: "      ", restaurantName: "        ", currencyID: "   ", orderAmount: 0.0, deliveryCharges: 0, totalCharges: 0.0, promo: 0.0, driverName: "       ", driverProfile: "      ")]
    
    private var finishedLoadingInitialTableCells = false
    
    @IBOutlet weak var histTable: UITableView!
    @IBOutlet weak var noOrdersView: UIView!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle(for: Self.self)
        
        let nib = UINib.init(nibName: "OrderHistoryCell", bundle: sdkBundle!)
        histTable.register(nib, forCellReuseIdentifier: "cell")
        
        histTable.reloadData()
        histTable.layoutIfNeeded()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        getOrderHistory()
    }
    
    
    // MARK: - Server Calls and Responses
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID()!)\",\"MobileNumber\":\"\(am.getSDKMobileNumber()!)\",\"IMEI\":\"\(am.getIMEI()!)\",\"CodeBase\":\"\(am.getMyCodeBase()!)\",\"PackageName\":\"\(am.getSDKPackageName()!)\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation()!)\",\"LatLong\":\"\(am.getCurrentLocation()!)\",\"TripID\":\"\",\"City\":\"\(am.getCity()!)\",\"RegisteredCountry\":\"\(am.getCountry()!)\",\"Country\":\"\(am.getCountry()!)\",\"UniqueID\":\"\(am.getMyUniqueID()!)\",\"CarrierName\":\"\(getCarrierName()!)\""
        
        return str
    }
    
    func getOrderHistory() {
        
        noOrdersView.isHidden = true
        view.setTemplateWithSubviews(true, viewBackgroundColor: .white)
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadOrderHistory),name:NSNotification.Name(rawValue: "LISTDELIVERIESFoodDelivery"), object: nil)
        
        let dataToSend = "{\"FormID\":\"LISTDELIVERIES\"\(commonCallParams())}"
        
        hc.makeServerCall(sb: dataToSend, method: "LISTDELIVERIESFoodDelivery", switchnum: 0)
        
    }
    
    @objc func loadOrderHistory(_ notification: NSNotification) {
        
        view.setTemplateWithSubviews(false)
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "LISTDELIVERIESFoodDelivery"), object: nil)
        
        if data != nil {
            
            do {
                if historyData != data {
                    historyData = data!
                    historyArr.removeAll()
                    let orderHistory = try JSONDecoder().decode(OrderHistory.self, from: data!)
                    historyArr = orderHistory[0].listTrips ?? []
                }
                
            } catch {
                historyArr.removeAll()
            }
            
            histTable.reloadData()
            
        } else {
            historyArr.removeAll()
            histTable.reloadData()
        }
        
        if historyArr.count > 0 {
            noOrdersView.isHidden = true
        } else {
            noOrdersView.alpha = 0
            noOrdersView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.noOrdersView.alpha = 1
            }
        }
    }
    
    // MARK: - TableView DataSource & Delegates
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyArr.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let histItem = historyArr[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OrderHistoryCell
        
        cell.lblOrderName.text = histItem.restaurantName ?? ""
        cell.lblOrderStatus.text = histItem.tripStatus ?? ""
        cell.lblOrderID.text = "Order #\(histItem.deliveryTripID?.components(separatedBy: "-")[0] ?? "") -"
        cell.lblOrderAmount.text = "\(histItem.currencyID ?? am.getGLOBALCURRENCY()!) \(formatCurrency(String(histItem.totalCharges ?? 0.0)))"
        cell.lblOrderTime.text = histItem.orderedOn ?? ""

        cell.selectionStyle = .none
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "OrderSummaryController") as? OrderSummaryController {
            viewController.deliveryID = historyArr[indexPath.item].deliveryTripID ?? ""
            viewController.orderAmount = historyArr[indexPath.item].orderAmount ?? 0.0
            viewController.tripStatus = historyArr[indexPath.item].tripStatus ?? ""
            viewController.deliveryCharges = Double(historyArr[indexPath.item].deliveryCharges ?? 0)
            viewController.totalCharges = historyArr[indexPath.item].totalCharges ?? 0.0
            viewController.serviceTripID = historyArr[indexPath.item].serviceTripID ?? ""
            viewController.promo = historyArr[indexPath.item].promo ?? 0.0
            viewController.currency = historyArr[indexPath.item].currencyID ?? ""
            viewController.restaurantName = historyArr[indexPath.item].restaurantName ?? ""
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if historyArr.count > 0 && !finishedLoadingInitialTableCells {
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
}
