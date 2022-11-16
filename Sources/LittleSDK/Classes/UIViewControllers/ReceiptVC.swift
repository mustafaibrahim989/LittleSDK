//
//  ReceiptVC.swift
//  Little
//
//  Created by Gabriel John on 06/06/2019.
//  Copyright © 2019 Craft Silicon Ltd. All rights reserved.
//

import UIKit

public class ReceiptVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Constants
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    // Variables
    
    var sdkBundle: Bundle?
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    var CCArr: [String] = []
    var CNArr: [String] = []
    var payDescArr: [String] = []
    var payCostArr: [String] = []
    
    var isCorporate: Bool = false
    var corporateIndex: Int = 0
    var tip = "0"
    var TIMESTAMP=""
    
    var paymentMode: String = "Cash"
    var paymentModeID: String = "CASH"
    var paymentModes: [String] = []
    var paymentModeIDs: [String] = []
    var paymentModeCount: Int = 0
    
    var paymentVC: UIViewController?
    
    private var finishedLoadingInitialTableCells = false
    
    @IBOutlet weak var btnPaymentType: UIButton!
    @IBOutlet weak var lblAmountToPay: UILabel!
    
    @IBOutlet weak var lblPickUp: UILabel!
    @IBOutlet weak var lblDropOff: UILabel!
    
    @IBOutlet weak var lblTripType: UILabel!
    
    @IBOutlet weak var extraChargesTable: UITableView!
    @IBOutlet weak var minimumCostsLbl: UILabel!
    @IBOutlet weak var baseFareLbl: UILabel!
    @IBOutlet weak var distanceCostLbl: UILabel!
    @IBOutlet weak var timeCostLbl: UILabel!
    @IBOutlet weak var costPerKmLbl: UILabel!
    @IBOutlet weak var costPerMinLbl: UILabel!
    
    
    @IBOutlet weak var paymentBtn: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle.module
        
        var amount = Double(am.getLIVEFARE())
        lblAmountToPay.text = String(format: "\(am.getGLOBALCURRENCY()?.capitalized ?? "KES"). %.2f", amount!)
        lblPickUp.text = am.getPICKUPADDRESS()
        lblDropOff.text = am.getDROPOFFADDRESS()
        costPerKmLbl.text = "Distance Cost (\(am.getGLOBALCURRENCY()?.capitalized ?? "KES"). \(am.getPERKM() ?? "0")/km)"
        costPerMinLbl.text = "Time Cost (\(am.getGLOBALCURRENCY()?.capitalized ?? "KES"). \(am.getPERMIN() ?? "0")/min)"
        amount = Double(am.getBASEPRICE())
        minimumCostsLbl.text = String(format: "\(am.getGLOBALCURRENCY()?.capitalized ?? "KES"). %.2f", amount!)
        amount = Double(am.getBASEFARE())
        baseFareLbl.text = String(format: "\(am.getGLOBALCURRENCY()?.capitalized ?? "KES"). %.2f", amount!)
        amount = Double(am.getDISTANCETOTALCOST())
        distanceCostLbl.text = String(format: "\(am.getGLOBALCURRENCY()?.capitalized ?? "KES"). %.2f", amount!)
        amount = Double(am.getTIMETOTALCOST())
        timeCostLbl.text = String(format: "\(am.getGLOBALCURRENCY()?.capitalized ?? "KES"). %.2f", amount!)
        
        if am.getCORPORATECODE() != "" {
            paymentMode = "COPORATE"
            paymentModeID = ""
            isCorporate = true
            amount = Double(am.getLIVEFARE())
            btnPaymentType.setTitle("Corporate", for: UIControl.State())
            lblTripType.text = "Corporate"
            paymentBtn.setTitle("Proceed", for: .normal)
        } else {
            if am.getPaymentModes() != "" {
                paymentModes = am.getPaymentModes().components(separatedBy: ";")
                paymentModes = paymentModes.filter { $0 != "" }
                paymentModeIDs = am.getPaymentModeIDs().components(separatedBy: ";")
                paymentModeIDs = paymentModeIDs.filter { $0 != "" }
                btnPaymentType.setTitle("\(am.getPaymentMode()?.capitalized ?? "Cash")", for: UIControl.State())
                paymentMode = am.getPaymentMode()
                paymentModeID = am.getPaymentModeID()
            }
            lblTripType.text = "Individual"
            paymentBtn.setTitle("Proceed", for: .normal)
        }
        
        payDescArr = am.getPAYMENTCODES().components(separatedBy: ";")
        payDescArr = payDescArr.filter { $0 != "" }
        payCostArr = am.getPAYMENTCOSTS().components(separatedBy: ";")
        payCostArr = payCostArr.filter { $0 != "" }
        extraChargesTable.delegate = self
        extraChargesTable.dataSource = self
        finishedLoadingInitialTableCells = false
        extraChargesTable.reloadData()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
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
    
    @objc func paymentResultReceived(_ notification: Notification) {
        
        let success = notification.userInfo?["success"] as? Bool
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PAYMENT_RESULT"), object: nil)
        
        if let success = success {
            if success {
                if let viewController = UIStoryboard(name: "Trip", bundle: self.sdkBundle!).instantiateViewController(withIdentifier: "TripRatingVC") as? TripRatingVC {
                    if let navigator = self.navigationController {
                        viewController.popToRestorationID = self.popToRestorationID
                        viewController.navShown = self.navShown
                        navigator.pushViewController(viewController, animated: true)
                    }
                }
                self.showAlerts(title: "", message: "Payment Confirmed.")
            } else {
                self.showAlerts(title: "", message: "Error occured completing payment. Please retry.")
            }
        } else {
            printVal(object: "Include a success boolean value with the PAYMENT_RESULT Notification Post")
        }
        
        
    }
    
    // MARK: - IBOutlet Actions
    
    @IBAction func makePaymentPressed(_ sender: UIButton) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(paymentResultReceived(_:)),name: NSNotification.Name(rawValue: "PAYMENT_RESULT"), object: nil)
        
        
        let reference = am.getTRIPID() ?? ""
        
        let userInfo = ["amount":Double(am.getLIVEFARE() ?? "0") ?? 0,"reference":reference, "additionalData": am.getSDKAdditionalData()] as [String : Any]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PAYMENT_REQUEST"), object: nil, userInfo: userInfo)
        
        /*if let viewController = UIStoryboard(name: "Trip", bundle: self.sdkBundle!).instantiateViewController(withIdentifier: "TripRatingVC") as? TripRatingVC {
            if let navigator = self.navigationController {
                viewController.popToRestorationID = self.popToRestorationID
                viewController.navShown = self.navShown
                navigator.pushViewController(viewController, animated: true)
            }
        }*/
        
    }
    
    // MARK: - Table Delegates & Data Sources

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return payDescArr.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for:indexPath) as! BreakdownTableViewCell
        if payCostArr[indexPath.item].contains("-") {
            cell.plusMinusImage.image = getImage(named: "minus", bundle: sdkBundle!)
        } else {
            cell.plusMinusImage.image = getImage(named: "add", bundle: sdkBundle!)
        }
        let amount = Double(payCostArr[indexPath.item].replacingOccurrences(of: "-", with: ""))
        cell.payAmountLbl.text = String(format: "\(am.getGLOBALCURRENCY()?.capitalized ?? "KES"). %.2f", amount!)
        cell.payDescLbl.text = payDescArr[indexPath.item]
        return cell
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if payDescArr.count > 0 && !finishedLoadingInitialTableCells {
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
            cell.transform = CGAffineTransform(translationX: 0, y: 10)
            cell.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0.05 * Double(indexPath.row), options: [.curveEaseInOut], animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0)
                cell.alpha = 1
            }, completion: nil)
        }
    }
}
