//
//  UMIController.swift
//  Little
//
//  Created by Gabriel John on 18/03/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import SwiftMessages

public class UMIController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    var sdkBundle: Bundle?
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    var merchantName = ""
    var merchantImage = ""
    var merchantMinAmount = 0.0
    var merchantMaxAmount = 0.0
    var trxReference = ""
    
    var walletArr: [Balance] = []
    var extraFields: [Field] = []
    var merchantsArr: [NearbyMerchant] = []
    var selectedWalletID = ""
    
    var promoIsValid: Bool = false
    var promoIs: String = ""
    var promoAmount: Double = 0.0
    
    var validated = false
    var isFromQR = false
    
    var reference: String = ""
    
    var selectedMerchant: Int?
    
    var paymentVC: UIViewController?
    

    @IBOutlet weak var txtMerchantCode: UITextField!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtReferenceNo: UITextField!
    
    @IBOutlet weak var imgMerchant: UIImageView!
    @IBOutlet weak var lblMerchantName: UILabel!
    @IBOutlet weak var merchantView: UIView!
    @IBOutlet weak var merchantAroundView: UIView!
    @IBOutlet weak var btnVerify: UIButton!
    @IBOutlet weak var promoView: UIView!
    
    @IBOutlet weak var btnConfirmPromo: UIButton!
    @IBOutlet weak var txtPromoCode: UITextField!
    
    @IBOutlet weak var merchAroundConst: NSLayoutConstraint!
    @IBOutlet weak var merchViewConst: NSLayoutConstraint!
    @IBOutlet weak var txtAmountConst: NSLayoutConstraint!
    @IBOutlet weak var promoConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblMerchantCodeLabel: UILabel!
    
    @IBOutlet weak var extraTableview: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var totalHeight: NSLayoutConstraint!
    
    @IBOutlet weak var nearMerchCollection: UICollectionView!
    
    @IBOutlet weak var btnWallet: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        sdkBundle = Bundle(for: Self.self)
        
        reference = NSUUID().uuidString
        
        let nib = UINib.init(nibName: "MenuCategoryCell", bundle: sdkBundle!)
        self.nearMerchCollection.register(nib, forCellWithReuseIdentifier: "cell")
        
        let nib2 = UINib.init(nibName: "ExtraFieldsCell", bundle: sdkBundle!)
        extraTableview.register(nib2, forCellReuseIdentifier: "cell")
        
        let backButton = UIBarButtonItem(image: getImage(named: "backios", bundle: sdkBundle!)!.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(backHome))
        backButton.imageInsets = UIEdgeInsets(top: 1, left: -8, bottom: 1, right: 10)
        
        
        self.navigationItem.leftBarButtonItem = backButton
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        promoView.isHidden = true
        merchantAroundView.isHidden = true
        promoConstraint.constant = 20
        
        merchAroundConst.constant = 50
        lblMerchantCodeLabel.text = "Enter merchant code:"
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if !isFromQR {
            getNearbyMerchants()
        } else {
            isFromQR = false
        }
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func loadQRListening(_ notification: NSNotification) {
        let message = notification.userInfo?["Message"] as? String
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "QRLISTENING"), object: nil)
        if message?.contains(",") ?? false {
            let arr = message?.components(separatedBy: ",")
            txtMerchantCode.text = arr?[0]
            if arr?.count ?? 0 > 1 {
                txtAmount.text = arr?[1]
                if arr?.count ?? 0 > 2 {
                    txtReferenceNo.text = arr?[2]
                }
            }
        } else {
            txtMerchantCode.text = message ?? ""
        }
        
        if txtMerchantCode.text != "" {
            validateMerchant()
        }
    }
    
    @objc func backHome() {
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
    
    @IBAction func btnScanPressed(_ sender: UIBarButtonItem) {
        
        isFromQR = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadQRListening(_:)),name:NSNotification.Name(rawValue: "QRLISTENING"), object: nil)
        
        if let viewController = UIStoryboard(name: "UMI", bundle: sdkBundle!).instantiateViewController(withIdentifier: "ScannerVC") as? ScannerVC {
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID()!)\",\"MobileNumber\":\"\(am.getSDKMobileNumber()!)\",\"IMEI\":\"\(am.getIMEI()!)\",\"CodeBase\":\"\(am.getMyCodeBase()!)\",\"PackageName\":\"\(am.getSDKPackageName()!)\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation()!)\",\"LatLong\":\"\(am.getCurrentLocation()!)\",\"TripID\":\"\",\"City\":\"\(am.getCity()!)\",\"RegisteredCountry\":\"\(am.getCountry()!)\",\"Country\":\"\(am.getCountry()!)\",\"UniqueID\":\"\(am.getMyUniqueID()!)\",\"CarrierName\":\"\(getCarrierName()!)\""
        
        return str
    }
    
    func getNearbyMerchants() {
        
        merchantsArr.removeAll()
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNearbyMerchants),name:NSNotification.Name(rawValue: "GETNEARBYMERCHANTSJSONData"), object: nil)
        
        let dataToSend = "{\"FormID\":\"GETNEARBYMERCHANTS\"\(commonCallParams()),\"GetMerchantName\":{\"Latitude\":\"\(am.getCurrentLocation()!.components(separatedBy: ",")[0])\",\"Longitude\":\"\(am.getCurrentLocation()!.components(separatedBy: ",")[1])\"}}"
        
        
        printVal(object: dataToSend)
        
        hc.makeServerCall(sb: dataToSend, method: "GETNEARBYMERCHANTSJSONData", switchnum: 0)
    }
    
    @objc func loadNearbyMerchants(_ notification: NSNotification) {
        self.view.removeAnimation()
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETNEARBYMERCHANTSJSONData"), object: nil)
        if data != nil {
            do {
                let nearbyMerchants = try JSONDecoder().decode(NearbyMerchants.self, from: data!)
                merchantsArr = nearbyMerchants
                
                if nearbyMerchants[0].status != "091" {
                    if merchantsArr.count > 0 {
                        merchantAroundView.isHidden = false
                        merchAroundConst.constant = 110
                        lblMerchantCodeLabel.text = "Or enter merchant code:"
                    } else {
                        merchantHide()
                    }
                } else {
                    merchantHide()
                }
                nearMerchCollection.reloadData()
            } catch {
                merchantHide()
                nearMerchCollection.reloadData()
            }
        } else {
            merchantHide()
            nearMerchCollection.reloadData()
        }
    }
    
    func merchantHide() {
        merchantAroundView.isHidden = true
        merchAroundConst.constant = 50
        lblMerchantCodeLabel.text = "Enter merchant code:"
        merchantsArr.removeAll()
    }
    
    func verifyPromoCode(promoText: String) {
        
        endEditSDK()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadpromocode),name:NSNotification.Name(rawValue: "VALIDATEPROMOCODE"), object: nil)
        
        am.savePROMOTITLE(data: "")
        am.savePROMOTEXT(data: "")
        am.savePROMOIMAGEURL(data: "")
        
        let datatosend = "FORMID|VALIDATEPROMOCODE_V1|PROMOCODE|\(promoText)|PICKUPLL|\(am.getCurrentLocation()!)|CATEGORY|UMI|MERCHANTID|\(txtMerchantCode.text!)|"
        
        // hc.makeServerCall(sb: datatosend, method: "VALIDATEPROMOCODE", switchnum: 0)
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
    
    func validateMerchant() {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadValidateMerchant),name:NSNotification.Name(rawValue: "GETUMIMERCHANTSJSONData"), object: nil)
        
        let dataToSend = "{\"FormID\":\"GETUMIMERCHANTS_V1\"\(commonCallParams()),\"GetMerchantName\":{\"MerchantID\":\"\(txtMerchantCode.text!)\"}}"
        
        
        printVal(object: dataToSend)
        
        hc.makeServerCall(sb: dataToSend, method: "GETUMIMERCHANTSJSONData", switchnum: 0)
    }
    
    @objc func loadValidateMerchant(_ notification: NSNotification) {
        self.view.removeAnimation()
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETUMIMERCHANTSJSONData"), object: nil)
        if data != nil {
            do {
                let merchantValidate = try JSONDecoder().decode(MerchantValidate.self, from: data!)
                if merchantValidate[0].status == "000" {
                    lblMerchantName.text = merchantValidate[0].name ?? ""
                    merchantName = merchantValidate[0].name ?? ""
                    merchantMinAmount = merchantValidate[0].minimumAmount ?? 0.0
                    merchantMaxAmount = merchantValidate[0].maximumAmount ?? 0.0
                    merchantImage = merchantValidate[0].logo ?? ""
                    
                    imgMerchant.sd_setImage(with: URL(string: "\( merchantValidate[0].logo ?? "")"), placeholderImage: nil, options: .scaleDownLargeImages)
                    
                    merchViewConst.constant = 140
                    txtAmountConst.constant = 200
                    merchantView.alpha = 0
                    merchantView.isHidden = false
                    promoView.alpha = 0
                    promoView.isHidden = false
                    
                    if merchantValidate[0].balance?.count ?? 0 > 0 {
                        walletArr = merchantValidate[0].balance ?? []
                        btnWallet.setTitle("\(merchantValidate[0].balance?[0].walletName ?? "")", for: UIControl.State())
                        self.selectedWalletID = merchantValidate[0].balance?[0].walletID ?? ""
                    }
                    
                    if merchantValidate[0].fields?.count ?? 0 > 0 {
                        
                        extraFields = merchantValidate[0].fields ?? []
                        
                        self.promoConstraint.constant = 100
                        self.tableHeight.constant = CGFloat(50 * (merchantValidate[0].fields?.count)!)
                        self.totalHeight.constant = 650 + CGFloat(50 * (merchantValidate[0].fields?.count)!) + 110
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            self.merchantView.alpha = 1
                            self.promoView.alpha = 1
                            self.view.layoutIfNeeded()
                        }, completion: { completed in
                            self.validated = true
                        })
                        
                        extraTableview.reloadData()
                        
                    } else {
                        self.promoConstraint.constant = 100
                        self.tableHeight.constant = 0
                        self.totalHeight.constant = 650 + 110
                        UIView.animate(withDuration: 0.3, animations: {
                            self.merchantView.alpha = 1
                            self.promoView.alpha = 1
                            self.view.layoutIfNeeded()
                        }, completion: { completed in
                            self.validated = true
                        })
                        
                        extraTableview.reloadData()
                    }
                } else {
                    showAlerts(title: "", message: merchantValidate[0].message ?? "Error validating Merchant. Please try again.")
                }
            }
            catch {
                do {
                    let defaultMessage = try JSONDecoder().decode(DefaultMessage.self, from: data!)
                    showAlerts(title: "", message: defaultMessage.message ?? "Error validating Merchant. Please try again.")
                } catch {
                    showAlerts(title: "", message: "Error validating Merchant. Please try again.")
                }
            }
        } else {
            showAlerts(title: "", message: "Error validating Merchant. Please try again.")
        }
        
    }
    
    func payMerchant() {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPayMerchant),name:NSNotification.Name(rawValue: "ADDMERCHANTTRXJSONData"), object: nil)
        
        let version = getAppVersion()
        let unique_id = NSUUID().uuidString
        
        var promoStuff = ""
        
        if promoIs != "" {
            promoStuff = ",\"PromoCode\":\"\(promoIs)\""
        }
        
        var extraDetails = ""
        for i in (0..<extraFields.count) {
            let each = extraFields[i]
            if each.fieldType == "T" || each.fieldType == "N" {
                extraDetails = "\(extraDetails)\"\(each.fieldTitle ?? "")\":\"\(each.fieldAnswer ?? "")\","
            } else {
                extraDetails = "\(extraDetails)\"\(each.fieldTitle ?? "")\":\"\(each.fieldValue ?? "")\","
            }
        }
        
        txtAmount.text = txtAmount.text?.replacingOccurrences(of: "-", with: "")
        
        let dataToSend = "{\"FormID\":\"ADDMERCHANTTRX\"\(commonCallParams()),\"MerchantTransactions\":{\"MerchantID\":\"\(txtMerchantCode.text!)\",\"MobileNumber\":\"\(am.getPhoneNumber()!)\",\"Amount\":\"\(txtAmount.text!)\",\(extraDetails)\"ReferenceNumber\":\"\(txtReferenceNo.text ?? "")\",\"WalletID\":\"\(selectedWalletID)\"\(promoStuff)}}"
        
        
        printVal(object: dataToSend)
        
        hc.makeServerCall(sb: dataToSend, method: "ADDMERCHANTTRXJSONData", switchnum: 0)
    }
    
    @objc func loadPayMerchant(_ notification: NSNotification) {
        self.view.removeAnimation()
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PAYMENTJSONData"), object: nil)
        
        if data != nil {
            do {
                
                let response = try JSONDecoder().decode(MerchantPay.self, from: data!)
                if response.status == "000"  {
                    
                    trxReference = response.merchantReference ?? ""
                    var leMessage = ""
                    if response.message == "" || response.message == nil {
                        leMessage = "\(merchantName) payment successfully made. Your reference code is \(response.merchantReference ?? "")"
                    } else {
                        leMessage = response.message ?? ""
                    }
                    
                    let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
                    view.loadPopup(title: "", message: "\n\(leMessage)\n", image: "", action: "")
                    view.proceedAction = {
                        SwiftMessages.hide()
                        NotificationCenter.default.addObserver(self, selector: #selector(self.loadCancelRate(_:)),name:NSNotification.Name(rawValue: "RATECANCEL"), object: nil)
                        
                        let popOverVC = UIStoryboard(name: "Trip", bundle: self.sdkBundle!).instantiateViewController(withIdentifier: "RatingVC") as! RatingVC
                        self.addChild(popOverVC)
                        popOverVC.driverName = self.merchantName
                        popOverVC.driverImage = self.merchantImage
                        popOverVC.view.frame = UIScreen.main.bounds
                        self.view.addSubview(popOverVC.view)
                        popOverVC.didMove(toParent: self)
                    }
                    view.btnDismiss.isHidden = true
                    view.configureDropShadow()
                    var config = SwiftMessages.defaultConfig
                    config.duration = .forever
                    config.presentationStyle = .bottom
                    config.dimMode = .gray(interactive: false)
                    SwiftMessages.show(config: config, view: view)
                    
                } else if response.status == "091" {
                    DispatchQueue.main.async(execute: {
                        self.showAlerts(title: "", message: response.message ?? "Error occured making purchase. Kindly retry.")
                    })
                } else if response.status == "092" {
                    
                    var MESSAGE = ""
                    
                    if response.message == "" {
                        MESSAGE = "Your Little Wallet has insuffecient funds. Do you wish to proceed to load cash?"
                    } else {
                        MESSAGE = response.message ?? ""
                    }
                    
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
                    
                    
                }else {
                    do {
                        let defaultMessage = try JSONDecoder().decode(DefaultMessage.self, from: data!)
                        
                        showAlerts(title: "", message: defaultMessage.message ?? "Error making payment to \(merchantName).")
                        
                    } catch {
                        showAlerts(title: "", message: "Error making payment to \(merchantName).")
                    }
                }
            } catch {
                showAlerts(title: "", message: "Error making payment to \(merchantName).")
            }
        } else {
            showAlerts(title: "", message: "Error making payment to \(merchantName).")
        }
        
    }
    
    func submitMerchantRate(message: String, rating: String) {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMerchantRate),name:NSNotification.Name(rawValue: "MERCHANTRATINGJSONData"), object: nil)
        
        let version = getAppVersion()
        let unique_id = NSUUID().uuidString
        
        let dataToSend = "{\"FormID\":\"MERCHANTRATING\"\(commonCallParams()),\"TrxRating\":{\"TrxReference\":\"\(trxReference)\",\"Rating\":\"\(rating)\",\"Feedback\":\"\(message)\",\"Comments\":\"\(message)\"}}"
        
        
        printVal(object: dataToSend)
        
        hc.makeServerCall(sb: dataToSend, method: "MERCHANTRATINGJSONData", switchnum: 0)
    }
    
    @objc func loadMerchantRate(_ notification: Notification) {
        
        self.view.removeAnimation()
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "MERCHANTRATINGJSONData"), object: nil)
        if data != nil {
            do {
                
                let response = try JSONDecoder().decode(DefaultMessages.self, from: data!)
                
                if response[0].status == "000" {
                    
                    let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
                    view.loadPopup(title: "", message: "\n\(response[0].message ?? "")\n", image: "", action: "")
                    view.proceedAction = {
                        SwiftMessages.hide()
                         self.backHome()
                    }
                    view.btnDismiss.isHidden = true
                    view.configureDropShadow()
                    var config = SwiftMessages.defaultConfig
                    config.duration = .forever
                    config.presentationStyle = .bottom
                    config.dimMode = .gray(interactive: false)
                    SwiftMessages.show(config: config, view: view)
                    
                } else {
                    showAlerts(title: "", message: response[0].message ?? "")
                }
                
            } catch {
                self.backHome()
                showAlerts(title: "", message: "Error rating \(merchantName). Record not saved.")
            }
        }
        
        
    }
    
    @objc func loadCancelRate(_ notification: Notification) {
        
        let data = notification.userInfo!["data"] as! String
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "RATECANCEL"), object: nil)
        
        if data.components(separatedBy: ":::").count > 1 {
            let message = data.components(separatedBy: ":::")[1]
            let rating = data.components(separatedBy: ":::")[0]
            submitMerchantRate(message: message, rating: rating)
        } else {
            self.backHome()
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let field = extraFields[textField.tag]
        extraFields[textField.tag] = Field(fieldTitle: field.fieldTitle ?? "", fieldType: field.fieldType ?? "", fieldValue: field.fieldValue ?? "", fieldCategory: field.fieldCategory ?? "", fieldAnswer: textField.text!)
        print("\n\n\(extraFields)\n\n")
    }
    
    func promoValid() {
        promoIsValid = true
        let color = cn.littleSDKThemeColor
        btnConfirmPromo.backgroundColor = color
        btnConfirmPromo.isEnabled = false
        promoIs = txtPromoCode.text!
    }
    
    func promoInvalid() {
        promoIsValid = false
        let color = cn.littleSDKThemeColor
        btnConfirmPromo.backgroundColor = color
        btnConfirmPromo.isEnabled = true
        promoIs = ""
    }
    
    @objc func paymentResultReceived(_ notification: Notification) {
        
        let success = notification.userInfo?["success"] as? Bool
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "PAYMENT_RESULT"), object: nil)
        if success != nil {
            if success! {
                self.payMerchant()
            } else {
                self.showAlerts(title: "", message: "Error occured completing payment. Please retry.")
            }
        } else {
            printVal(object: "Include a success boolean value with the PAYMENT_RESULT Notification Post")
        }
        
        
    }
    
    @IBAction func btnConfirmPromoPressed(_ sender: UIButton) {
        if txtPromoCode.text == "" {
            dismissSwiftAlert()
            showAlerts(title: "", message: "Kindly ensure you type the promo code first.")
        } else {
            verifyPromoCode(promoText: txtPromoCode.text!)
        }
    }
    
    @IBAction func promoChanged(_ sender: UITextField) {
        if promoIsValid {
            promoInvalid()
            showAlerts(title: "", message: "Kindly re-validate newly typed promo code.")
        }
    }
    
    @IBAction func btnVerifyMerchant(_ sender: UIButton) {
        endEditSDK()
        if txtMerchantCode.text == "" { // || txtMerchantCode.text?.count < 3
            showAlerts(title: "", message: "Kindly ensure you yave a valid merchant code to verify.")
        } else {
            validateMerchant()
        }
    }
    @IBAction func btnPay(_ sender: UIButton) {
        
        var amountError = true
        if txtAmount.text != "" {
            if let amount = Double(txtAmount.text!) {
                if amount >= merchantMinAmount && amount <= merchantMaxAmount {
                    amountError = false
                }
            }
        }
        
        if !validated {
            btnVerify.sendActions(for: UIControl.Event.touchUpInside)
        } else if amountError {
            if merchantMinAmount > 0 && merchantMaxAmount > 0 {
                showAlerts(title: "", message: "Kindly ensure the amount you key in is a minimum of \(merchantMinAmount) and a maximum of \(merchantMaxAmount) as specified by \(merchantName).")
            } else {
                if txtAmount.text == "" {
                    showAlerts(title: "", message: "Kindly ensure you enter a valid amount.")
                } else {
                    validateMerchant()
                }
            }
        } else if btnWallet.title(for: UIControl.State())?.lowercased().contains("select wallet") ?? false {
            showAlerts(title: "", message: "Kindly ensure you select preferred wallet")
        } else {
            var proceed = true
            if extraFields.count > 0 {
                for each in extraFields {
                    if ((each.fieldType == "T" || each.fieldType == "N") && (each.fieldCategory == "M")) && (each.fieldAnswer == "" || each.fieldAnswer == nil) {
                        showAlerts(title: "Timiza Notification", message: "Kindly ensure you have entered the \((each.fieldTitle ?? "").lowercased()).")
                        proceed = false
                        continue
                    }
                }
            }
            if proceed {
                
                NotificationCenter.default.addObserver(self, selector: #selector(paymentResultReceived(_:)),name: NSNotification.Name(rawValue: "PAYMENT_RESULT"), object: nil)
                
                let userInfo = ["amount":Double(txtAmount.text ?? "0")!,"reference":reference] as [String : Any]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PAYMENT_REQUEST"), object: nil, userInfo: userInfo)
                
            }
        }
    }
    
    
    @IBAction func merchantCodeChanged(_ sender: UITextField) {
        if !merchantView.isHidden {
            lblMerchantName.text = ""
            merchantName = ""
            if merchantsArr.count > 0 {
                selectedMerchant = nil
                nearMerchCollection.reloadData()
            }
            merchantMinAmount = 0
            merchantMaxAmount = 0
            imgMerchant.image = UIImage()
            promoConstraint.constant = 20
            merchViewConst.constant = 30
            txtAmountConst.constant = 50
            tableHeight.constant = 0
            totalHeight.constant = 650
            extraFields.removeAll()
            extraTableview.reloadData()
            UIView.animate(withDuration: 0.3, animations: {
                self.merchantView.alpha = 0
                self.promoView.alpha = 0
            }, completion: { completed in
                self.merchantView.isHidden = true
                self.promoView.isHidden = true
            })
        }
    }
    
    @IBAction func btnWalletPressed(_ sender: UIButton) {
        let cashSourceOptions = UIAlertController(title: nil, message: "Select wallet", preferredStyle: .actionSheet)
        let normalColor = cn.littleSDKThemeColor
        for source in walletArr {
            let btn = UIAlertAction(title: "\(source.walletName ?? "")", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                sender.setTitle("\(source.walletName ?? "")", for: UIControl.State())
                self.selectedWalletID = source.walletID ?? ""
            })
            btn.setValue(normalColor, forKey: "titleTextColor")
            cashSourceOptions.addAction(btn)
        }
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        cashSourceOptions.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            cashSourceOptions.popoverPresentationController?.sourceView = sender
            cashSourceOptions.popoverPresentationController?.sourceRect = CGRect(x: sender.bounds.size.width / 2.0, y: sender.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        DispatchQueue.main.async {self.present(cashSourceOptions, animated: true, completion: nil)}
    }
    
    @IBAction func btnCashSourcePressed(_ sender: UIButton) {
        if txtAmount.text != "" {
            am.saveAmount(data: txtAmount.text!)
        } else {
            am.saveAmount(data: "")
        }
        if let viewController = UIStoryboard(name: "UMI", bundle: sdkBundle!).instantiateViewController(withIdentifier: "LoadCashViewController") as? LoadCashViewController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    // MARK: - TableView Delegates and Datasources

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var arr: [Field] = []
        for each in extraFields {
            if each.fieldType != "H" {
                arr.append(each)
            }
        }
        return arr.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let field = extraFields[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! ExtraFieldsCell
        
        if field.fieldType == "L" {
            cell.lblField.text = field.fieldValue ?? ""
            cell.lblField.isHidden = false
            cell.lblFieldTitle.isHidden = true
            cell.txtField.isHidden = true
            cell.fieldUnderline.isHidden = true
        } else {
            
            if field.fieldValue != "Optional" {
                cell.lblFieldTitle.text = "\(field.fieldValue ?? ""):"
            } else {
                cell.lblFieldTitle.text = "\(field.fieldValue ?? "") (Optional):"
            }
            cell.txtField.placeholder = field.fieldValue ?? ""
            
            if field.fieldType == "N" {
                cell.txtField.keyboardType = .numberPad
            } else {
                cell.txtField.keyboardType = .default
            }
            cell.txtField.tag = indexPath.item
            cell.txtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            
            cell.lblField.isHidden = true
            cell.lblFieldTitle.isHidden = false
            cell.txtField.isHidden = false
            cell.fieldUnderline.isHidden = false
        }
        
        return cell
    }
    
    // MARK: - CollectionView DataSource & Delegates
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15.0)!
        
        let varia = CGFloat(50.0)
        
        let size = CGSize(width: ((merchantsArr[indexPath.item].name?.width(withConstrainedHeight: 30.0, font: font) ?? 10.0) ) + varia, height: 40.0)
        
        return size
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return merchantsArr.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! MenuCategoryCell
        if selectedMerchant != nil {
            if selectedMerchant == indexPath.item {
                cell.categoryView.backgroundColor = cn.littleSDKThemeColor
                cell.lblCategory.textColor = .white
            } else {
                cell.categoryView.backgroundColor = cn.littleSDKCellBackgroundColor
                cell.lblCategory.textColor = cn.littleSDKLabelColor
            }
        } else {
            cell.categoryView.backgroundColor = cn.littleSDKCellBackgroundColor
            cell.lblCategory.textColor = cn.littleSDKLabelColor
        }
        cell.lblCategory.text = merchantsArr[indexPath.item].name ?? ""
        
        return cell
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMerchant = indexPath.item
        nearMerchCollection.reloadData()
        txtMerchantCode.text = merchantsArr[indexPath.item].paymentCode ?? ""
        btnVerify.sendActions(for: .touchUpInside)
    }
}

