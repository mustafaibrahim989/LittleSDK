//
//  LoadCashViewController.swift
//  Little Redo
//
//  Created by Gabriel John on 21/05/2018.
//  Copyright © 2018 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import SwiftMessages

public class LoadCashViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
//    var sdkBundle: Bundle?
    
    var cashsourceArr: [String] = []
    var walletArr: [Wallet] = []
    var toWalletArr: [ToWallet] = []
    var recentTRxs: [TrxWallet] = []
    var kycFieldsArr: [KYCField] = []
    var selectedWalletIndex = 0
    var selectedToWalletIndex = 0
    var Card_Alias = ""
    var couponText = ""
    var CouponID = ""
    var AutoLoad = 0
    var couponVerified = false
    var toWalletID = ""
    var keyID1 = ""
    var keyID2 = ""
    
    let popupDatePickerView = LittleDatePickerView()
    
    @IBOutlet weak var cashSourceBtn: UIButton!
    @IBOutlet weak var txtAmount: UITextField!
    // @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var loadCashBtn: UIButton!
    @IBOutlet weak var btnToWallet: UIButton!
    
    @IBOutlet weak var lblExtraDetails: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var extraTableview: UITableView!
    @IBOutlet weak var couponView: UIView!
    @IBOutlet weak var mpesaLoadView: UIView!
    
    @IBOutlet weak var lblPreviousTransactions: UILabel!
    @IBOutlet weak var lblOfferText: UILabel!
    
    @IBOutlet weak var imgCoupon: UIImageView!
    @IBOutlet weak var lblCouponTitle: UILabel!
    @IBOutlet weak var lblCouponMessage: UILabel!
    @IBOutlet weak var imgCouponHeight: NSLayoutConstraint!
    @IBOutlet weak var mpesaViewConst: NSLayoutConstraint!
    @IBOutlet weak var extraTableHeight: NSLayoutConstraint!
    @IBOutlet weak var extraViewHeight: NSLayoutConstraint!
    @IBOutlet weak var transactionsHeight: NSLayoutConstraint!
    @IBOutlet weak var totalHeight: NSLayoutConstraint!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        sdkBundle = Bundle(for: Self.self)
        
        let cellNib = UINib(nibName: "RecentsCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "cell")
        
        let nib2 = UINib.init(nibName: "KYCCell", bundle: nil)
        extraTableview.register(nib2, forCellReuseIdentifier: "cell")
        
        if am.getAmount() != "" {
            txtAmount.text = "\(am.getAmount() ?? "")"
            if txtAmount.text == "0" {
                txtAmount.text = ""
            }
            am.saveAmount(data: "")
        }
        
        extraTableHeight.constant = 0
        extraViewHeight.constant = 0
        transactionsHeight.constant = 0
        
        view.layoutIfNeeded()
        
        couponView.isHidden = true
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        adjustViewHeight()
        
        getLoadWalletItems()
    }
    
    
    @objc func loadCashDone() {
        
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name(rawValue: "LOADCASH"), object: nil)
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: nil)
        view.loadPopup(title: "", message: "\(am.getMESSAGE()!)", image: "", action: "")
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
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID()!)\",\"MobileNumber\":\"\(am.getSDKMobileNumber()!)\",\"IMEI\":\"\(am.getIMEI()!)\",\"CodeBase\":\"\(am.getMyCodeBase()!)\",\"PackageName\":\"\(am.getSDKPackageName()!)\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation()!)\",\"LatLong\":\"\(am.getCurrentLocation()!)\",\"TripID\":\"\",\"City\":\"\(am.getCity()!)\",\"RegisteredCountry\":\"\(am.getCountry()!)\",\"Country\":\"\(am.getCountry()!)\",\"UniqueID\":\"\(am.getMyUniqueID()!)\",\"CarrierName\":\"\(getCarrierName()!)\""
        
        return str
    }
    
    func getLoadWalletItems() {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadLoadWalletItems),name:NSNotification.Name(rawValue: "GETLOADWALLETJSONData"), object: nil)
        
        let dataToSend = "{\"FormID\": \"GETLOADWALLET\"\(commonCallParams())}"
        
        hc.makeServerCall(sb: dataToSend, method: "GETLOADWALLETJSONData", switchnum: 0)
        
    }
    
    @objc func loadLoadWalletItems(_ notification: NSNotification) {
        
        self.view.removeAnimation()
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETLOADWALLETJSONData"), object: nil)
        if data != nil {
            do {
                let walletsToLoad = try JSONDecoder().decode(WalletsToLoad.self, from: data!)
                walletArr = walletsToLoad[0].wallets ?? []
                cashSourceBtn.setTitle(walletArr[0].walletName, for: .normal)
                recentTRxs = walletsToLoad[0].trx ?? []
                toWalletArr = walletsToLoad[0].toWallets ?? []
                
                if walletsToLoad[0].askID == "Y" {
                    kycFieldsArr = walletsToLoad[0].kycFields ?? []
                    if walletsToLoad[0].kycMessage != nil && walletsToLoad[0].kycMessage != "" {
                        lblExtraDetails.text = walletsToLoad[0].kycMessage ?? ""
                    } else {
                        lblExtraDetails.text = ""
                    }
                    lblExtraDetails.layoutIfNeeded()
                    extraTableHeight.constant = CGFloat(kycFieldsArr.count * 70)
                    extraViewHeight.constant = CGFloat(kycFieldsArr.count * 70) + CGFloat(lblExtraDetails.bounds.height) + 30
                    
                }
                
                transactionsHeight.constant = CGFloat(recentTRxs.count * 70)
                if recentTRxs.count > 0 {
                    lblPreviousTransactions.isHidden = false
                } else {
                    lblPreviousTransactions.isHidden = true
                }
                tableView.reloadData()
                selectedWalletIndex = 0
                selectedToWalletIndex = 0
                extraTableview.reloadData()
                
                if keyID1 != "" {
                    openCoupons()
                    couponView.isHidden = false
                    selectedWalletIndex = walletArr.firstIndex(where: { $0.walletName == keyID1}) ?? 0
                    cashSourceBtn.setTitle(walletArr[selectedWalletIndex].walletName ?? "", for: .normal)
                    printVal(object: selectedWalletIndex)
                }
                
                showHideMpesaInstructions(source: walletArr[selectedWalletIndex].walletName ?? "")
                
            } catch {
                showAlerts(title: "", message: "Error loading your accessible wallets. Kindly retry.")
            }
        }
        
    }
    
    func loadNewWallet() {
        
        var proceed = true
        
        if loadCashBtn.title(for: .normal) == "Load Coupon" {
            proceed = true
        } else if kycFieldsArr.count > 0 {
            for each in kycFieldsArr {
                if each.kycValue == nil || each.kycValue == "" {
                    showAlerts(title: "", message: "\(each.fieldName ?? "") is required.")
                    proceed = false
                    break
                } else if each.fieldType == "DATE" {
                    let regex = try! NSRegularExpression(pattern: "[0-9]{4}-[0-9]{2}-[0-9]{2}")
                    if !(regex.matches(each.kycValue ?? "")) {
                        showAlerts(title: "", message: "Kindly provide \(each.fieldName ?? "") in the format YYYY-MM-DD e.g. 2020-01-01.")
                        proceed = false
                        break
                    }
                }
            }
        }
        
        if proceed {
            loadWalletCall()
        }
        
    }
    
    func loadWalletCall() {
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadLoadNewWallet),name:NSNotification.Name(rawValue: "LOADWALLETJSONData"), object: nil)
        
        var walletID = walletArr[selectedWalletIndex].walletUniqueID ?? ""
        var toWalletName = toWalletArr[selectedToWalletIndex].toWalletName ?? ""
        var string = ""
        var string2 = ","
        if couponVerified {
            toWalletName = ""
            walletID = couponText
            string = ",\"WalletType\":\"\(walletArr[selectedWalletIndex].walletUniqueID ?? "")\""
        } else {
            toWalletID = toWalletArr[selectedToWalletIndex].toWalletID ?? ""
            for each in kycFieldsArr {
                printVal(object: "\"\(each.fieldID ?? "")\":\"\(each.kycValue ?? "")\"")
                let add = "\"\(each.fieldID ?? "")\":\"\(each.kycValue ?? "")\","
                string2.append(add)
            }
        }
        string2 = String(string2.dropLast())
        
        txtAmount.text = txtAmount.text?.replacingOccurrences(of: "-", with: "")
        
        let dataToSend = "{\"FormID\": \"LOADWALLET\"\(commonCallParams()),\"LoadWallet\":{\"WalletUniqueID\":\"\(walletID)\",\"Amount\":\"\(txtAmount.text!)\",\"ToWalletName\":\"\(toWalletName)\",\"ToWalletID\":\"\(toWalletID)\"\(string)\(string2)}}"
        
        hc.makeServerCall(sb: dataToSend, method: "LOADWALLETJSONData", switchnum: 0)
    }
    
    @objc func loadLoadNewWallet(_ notification: NSNotification) {
        self.view.removeAnimation()
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETLOADWALLETJSONData"), object: nil)
        if data != nil {
            do {
                let defaultMessage = try JSONDecoder().decode(DefaultMessage.self, from: data!)
                if defaultMessage.status == "000" {
                    
                    let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: nil)
                    view.loadPopup(title: "", message: "\n\(defaultMessage.message ?? "")\n", image: "", action: "")
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
                    
                } else {
                    showAlerts(title: "", message: defaultMessage.message ?? "Error loading cash. Kindly retry.")
                }
                
            } catch {
                do {
                    let defaultMessage = try JSONDecoder().decode(DefaultMessages.self, from: data!)
                    if defaultMessage[0].status == "000" {
                        
                        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: nil)
                        view.loadPopup(title: "", message: "\n\(defaultMessage[0].message ?? "")\n", image: "", action: "")
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
                        
                    } else {
                        showAlerts(title: "", message: defaultMessage[0].message ?? "Error loading cash. Kindly retry.")
                    }
                } catch {
                    showAlerts(title: "", message: "Error loading cash. Kindly retry.")
                }
            }
        }
    }
    
    func getPaymentOptions() {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPaymentOptions),name:NSNotification.Name(rawValue: "GETPAYMENTOPTIONS"), object: nil)
        
        let datatosend:String = "FORMID|GETACCOUNTS|"
        
        hc.makeServerCall(sb: datatosend, method: "GETPAYMENTOPTIONS", switchnum: 0)
    }
    
    func loadFromOther() {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadFromOtherDone),name:NSNotification.Name(rawValue: "LOADCASH"), object: nil)
        
        let datatosend:String="FORMID|LOADCASH|AMOUNT|\(txtAmount.text!)|PAYMENTMODE|\(cashSourceBtn.title(for: .normal)!)|"
        
        hc.makeServerCall(sb: datatosend, method: "LOADCASH", switchnum: 0)
        
    }
    
    func validateCoupon() {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadValidateCoupon),name:NSNotification.Name(rawValue: "VALIDATECOUPONJSONData"), object: nil)
        
        let version = getAppVersion()
        let unique_id = NSUUID().uuidString
        
        let dataToSend = "{\"FormID\": \"VALIDATECOUPON\"\(commonCallParams()),\"ValidateCoupon\":{\"CouponID\":\"\(CouponID)\"}}"
        
        hc.makeServerCall(sb: dataToSend, method: "VALIDATECOUPONJSONData", switchnum: 0)
    }
    
    @objc func loadValidateCoupon(_ notification: NSNotification) {
        self.view.removeAnimation()
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "VALIDATECOUPONJSONData"), object: nil)
        if data != nil {
            do {
                let couponStatus = try JSONDecoder().decode(CouponStatus.self, from: data!)
                if couponStatus[0].status == "000" {
                    var couponToSend = couponStatus[0]
                    couponToSend = CouponStatusElement(status: couponToSend.status ?? "", message: couponToSend.message ?? "", toWalletID: couponToSend.toWalletID ?? "", couponType: couponToSend.couponType ?? "", couponName: couponToSend.couponName ?? "", couponURL: couponToSend.couponURL ?? "", description: couponToSend.description ?? "",couponText: CouponID, amount: couponToSend.amount ?? 0.0)
                    
                    imgCoupon.sd_setImage(with: URL(string: couponToSend.couponURL ?? "")) { (image, error, cache, url) in
                        let ratio = (image! as UIImage).size.height/(image! as UIImage).size.width
                        let width = self.view.bounds.width - 40
                        self.imgCouponHeight.constant = CGFloat(Float(ratio) * Float(width))
                        UIView.animate(withDuration: 0.3) {
                            self.imgCoupon.layoutIfNeeded()
                        }
                    }
                    lblCouponTitle.text = couponToSend.couponName ?? ""
                    lblCouponMessage.text = "\(couponToSend.description ?? "")"
                    txtAmount.text =  "\(couponToSend.amount ?? 0.0)"
                    loadCashBtn.setTitle("Load Coupon", for: .normal)
                    couponView.isHidden = false
                    couponVerified = true
                    couponText = couponToSend.couponText ?? ""
                    toWalletID = couponToSend.toWalletID ?? ""
                    
                } else {
                    showAlerts(title: "", message: couponStatus[0].message ?? "Coupon code '\(CouponID)' not found.")
                }
            } catch {
                showAlerts(title: "", message: "Error occured validating coupon code.")
            }
        }
        
    }
    
    func openCoupons() {
        
        txtAmount.text = ""
        lblCouponMessage.text = ""
        lblCouponTitle.text = ""
        
        var couponCode = ""
        
        if keyID2 != "" {
            couponCode = keyID2
        }
        
        imgCoupon.image = UIImage()
        
        let view: PopoverEnterText = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: nil)
        view.loadPopup(title: "Validate Coupon Code", message: "\nType the coupon code you wish to validate below.\n", image: "", placeholderText: "Enter coupon code", type: "")
        view.txtPopupText.text = couponCode
        view.proceedAction = {
           SwiftMessages.hide()
            if view.txtPopupText.text != "" {
                self.CouponID = view.txtPopupText.text!
                self.validateCoupon()
           } else {
               self.showAlerts(title: "",message: "Kindly ensure you have typed in the coupon code you are trying to validate.")
           }
        }
        view.cancelAction = {
            SwiftMessages.hide()
        }
        view.btnProceed.setTitle("Validate Coupon", for: .normal)
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func adjustViewHeight() {
        
        var total = 300.0 + mpesaViewConst.constant + extraViewHeight.constant + transactionsHeight.constant
        let window = UIApplication.shared.keyWindow
        let topSafeAreaConst = window?.safeAreaInsets.top ?? 40
        let bottomSafeAreaConst = window?.safeAreaInsets.bottom ?? 50
        let defaultHeight = view.frame.height - (topSafeAreaConst + bottomSafeAreaConst + 70)
        if defaultHeight > total {
            total = defaultHeight
        }
        totalHeight.constant = total
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
        printVal(object: "The height is: \(total)")
        
    }
    
    func showHideMpesaInstructions(source: String) {
        if source.replacingOccurrences(of: "", with: "").uppercased().contains("MPESA") {
            self.mpesaLoadView.alpha = 0
            self.mpesaLoadView.isHidden = false
            self.mpesaViewConst.constant = 230
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.mpesaLoadView.alpha = 1
            } completion: { completed in
                self.adjustViewHeight()
            }
        } else {
            if self.mpesaLoadView.isHidden == false {
                self.mpesaViewConst.constant = 10
                UIView.animate(withDuration: 0.3, animations: {
                    self.mpesaLoadView.alpha = 0
                    self.view.layoutIfNeeded()
                }) { completed in
                    self.mpesaLoadView.isHidden = false
                    self.adjustViewHeight()
                }
            } else {
                adjustViewHeight()
            }
        }
    }
    
    @objc func loadPaymentOptions(_ notification: NSNotification) {
        
        NotificationCenter.default.removeObserver(self,name:NSNotification.Name(rawValue: "GETPAYMENTOPTIONS"), object: nil)
        self.view.removeAnimation()
        let temparr = am.getCARDS().components(separatedBy: ",")
        cashsourceArr.removeAll()
        for i in (0..<temparr.count) {
            let each = temparr[i].components(separatedBy: ";")[1]
            cashsourceArr.append("Card: \(each)")
        }
        
    }
    
    @objc func loadFromOtherDone(_ notification: NSNotification) {
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "LOADFROMCARD"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func cashSourcePressed(_ sender: UIButton) {
        let cashSourceOptions = UIAlertController(title: nil, message: "Select cash source", preferredStyle: .actionSheet)
        
        let normalColor = cn.littleSDKThemeColor
        
        for source in walletArr {
            let reasonBtn = UIAlertAction(title: source.walletName ?? "", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                if source.walletUniqueID == "Coupon" {
                    self.openCoupons()
                    self.couponView.isHidden = false
                } else {
                    self.couponView.isHidden = true
                    if self.loadCashBtn.title(for: .normal) == "Load Coupon" {
                        self.loadCashBtn.setTitle("Load Cash", for: .normal)
                        self.txtAmount.text = ""
                    }
                    self.couponVerified = false
                    self.couponText = ""
                }
                self.cashSourceBtn.setTitle(source.walletName ?? "", for: .normal)
                self.selectedWalletIndex = self.walletArr.firstIndex(where: { $0.walletUniqueID == source.walletUniqueID}) ?? 0
                printVal(object: self.selectedWalletIndex)
                
                self.showHideMpesaInstructions(source: source.walletName ?? "")
                
            })
            reasonBtn.setValue(normalColor, forKey: "titleTextColor")
            cashSourceOptions.addAction(reasonBtn)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        cashSourceOptions.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            cashSourceOptions.popoverPresentationController?.sourceView = self.cashSourceBtn
            cashSourceOptions.popoverPresentationController?.sourceRect = CGRect(x: self.cashSourceBtn.bounds.size.width / 2.0, y: self.cashSourceBtn.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        DispatchQueue.main.async {self.present(cashSourceOptions, animated: true, completion: nil)}
        
    }
    
    @IBAction func btnToWalletPressed(_ sender: UIButton) {
        let cashSourceOptions = UIAlertController(title: nil, message: "Select wallet to load", preferredStyle: .actionSheet)
        
        let normalColor = cn.littleSDKThemeColor
        
        for source in toWalletArr {
            let reasonBtn = UIAlertAction(title: source.toWalletName ?? "", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.btnToWallet.setTitle(source.toWalletName ?? "", for: .normal)
                self.selectedToWalletIndex = self.toWalletArr.firstIndex(where: { $0.toWalletID == source.toWalletID}) ?? 0
                
            })
            reasonBtn.setValue(normalColor, forKey: "titleTextColor")
            cashSourceOptions.addAction(reasonBtn)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        cashSourceOptions.addAction(cancelAction)
        if UIDevice.current.userInterfaceIdiom == .pad {
            cashSourceOptions.popoverPresentationController?.sourceView = self.btnToWallet
            cashSourceOptions.popoverPresentationController?.sourceRect = CGRect(x: self.btnToWallet.bounds.size.width / 2.0, y: self.btnToWallet.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        }
        DispatchQueue.main.async {self.present(cashSourceOptions, animated: true, completion: nil)}
    }
    
    
    @IBAction func loadCashBtnPressed(_ sender: UIButton) {
        
        if cashSourceBtn.title(for: .normal) == "Select cash source" {
            showAlerts(title: "", message: "Cash Source required.")
        } else if btnToWallet.title(for: .normal) == "Select wallet to load" && loadCashBtn.title(for: .normal) != "Load Coupon" {
            showAlerts(title: "", message: "Wallet to load is required.")
        } else if txtAmount.text == "" {
            showAlerts(title: "", message: "Amount required.")
        } else {
            if loadCashBtn.title(for: .normal) == "Load Coupon" {
                if couponVerified {
                    loadNewWallet()
                } else {
                    showAlerts(title: "", message: "Enter a valid coupon to proceed.")
                }
            } else {
                loadNewWallet()
            }
        }
        
    }
    
    func datePicker() {
        
        var dateComponent = DateComponents()
        dateComponent.year = -50
        
        let minDate = Calendar.current.date(byAdding: dateComponent, to: Date())
        let maxDate = Date()
        
        popupDatePickerView.minDate = minDate
        popupDatePickerView.maxDate = maxDate
        
        popupDatePickerView.display(defaultDate: Date(), doneHandler: { date in
            printVal(object: "Date: (\(date))")
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            for i in (0..<self.kycFieldsArr.count) {
                let field = self.kycFieldsArr[i]
                if field.fieldType == "DATE" {
                    self.kycFieldsArr[i] = KYCField(fieldID: field.fieldID ?? "", fieldName: field.fieldName ?? "", fieldType: field.fieldType ?? "", incentiveText: field.incentiveText ?? "", kycValue:  dateFormatter.string(from: date as Date), incentive: field.incentive ?? 0.0)
                    printVal(object: "\n\n\(self.kycFieldsArr)\n\n")
                    self.extraTableview.reloadData()
                    continue
                }
            }
        })
    }
    
    @objc public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        var index = 0
        for i in (0..<self.kycFieldsArr.count) {
            let field = self.kycFieldsArr[i]
            if field.fieldType == "DATE" {
                index = i
                break
            }
        }
        if index != 0 {
            if textField.tag == index {
                datePicker()
                return false
            }
        }
        return true
    }
    
    @IBAction func amountChanged(_ sender: UITextField) {
        
        var typedAmount = 0.0
        
        if sender.text != "" {
            typedAmount = Double(sender.text!)!
        }
        
        if am.getWalletAmount()?.components(separatedBy: ";").count ?? 0 > 3 {
            let amount1 = Double(am.getWalletAmount().components(separatedBy: ";")[0])!
            let amount2 = Double(am.getWalletAmount().components(separatedBy: ";")[1])!
            let amount3 = Double(am.getWalletAmount().components(separatedBy: ";")[2])!
            let amount4 = Double(am.getWalletAmount().components(separatedBy: ";")[3])!
            
            if sender.text == "" || typedAmount < amount1 {
                let str = "\(am.getWalletAmount().components(separatedBy: ";")[0])"
                lblDiscount.text = "Load greater than \(am.getGLOBALCURRENCY()!) \(formatCurrency(str)) for bonus."
            } else if typedAmount < amount2 {
                let difference = Double(am.getWalletDiscount().components(separatedBy: ";")[0])! - Double(am.getWalletAmount().components(separatedBy: ";")[0])!
                let str = "\(difference+typedAmount)"
                lblDiscount.text = "Little Bonus: You get \(am.getGLOBALCURRENCY()!) \(formatCurrency(str))"
            } else if typedAmount < amount3 {
                let difference = Double(am.getWalletDiscount().components(separatedBy: ";")[1])! - Double(am.getWalletAmount().components(separatedBy: ";")[1])!
                let str = "\(difference+typedAmount)"
                lblDiscount.text = "Little Bonus: You get \(am.getGLOBALCURRENCY()!) \(formatCurrency(str))"
            } else if typedAmount < amount4 {
                let difference = Double(am.getWalletDiscount().components(separatedBy: ";")[2])! - Double(am.getWalletAmount().components(separatedBy: ";")[2])!
                let str = "\(difference+typedAmount)"
                lblDiscount.text = "Little Bonus: You get \(am.getGLOBALCURRENCY()!) \(formatCurrency(str))"
            } else if typedAmount >= amount4 {
                let difference = Double(am.getWalletDiscount().components(separatedBy: ";")[3])! - Double(am.getWalletAmount().components(separatedBy: ";")[3])!
                let str = "\(difference+typedAmount)"
                lblDiscount.text = "Little Bonus: You get \(am.getGLOBALCURRENCY()!) \(formatCurrency(str))"
            }
        }
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let field = kycFieldsArr[textField.tag]
        if field.fieldType == "DATE" {
            textField.text = textField.text?.filterDigitsWithHyphenOnly()
        }
        kycFieldsArr[textField.tag] = KYCField(fieldID: field.fieldID ?? "", fieldName: field.fieldName ?? "", fieldType: field.fieldType ?? "", incentiveText: field.incentiveText ?? "", kycValue: textField.text, incentive: field.incentive ?? 0.0)
        printVal(object: "\n\n\(kycFieldsArr)\n\n")
    }
    
    // MARK: - TableView DataSource & Delegates
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 {
            return recentTRxs.count
        } else {
            return kycFieldsArr.count
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView.tag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RecentsCell
            
            cell.selectionStyle = .none
            cell.lblAmount.text = "\(recentTRxs[indexPath.item].amountLoaded ?? 0.0)"
            cell.lblDate.text = recentTRxs[indexPath.item].loadDate ?? ""
            cell.lblAccountNo.text = recentTRxs[indexPath.item].paymentSource ?? ""
            cell.lblReference.text = "\(recentTRxs[indexPath.item].reference ?? "")"
            
            return cell
        } else {
            let field = kycFieldsArr[indexPath.item]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! KYCCell
            
            cell.txtField.tag = 0
            cell.lblFieldTitle.text = field.fieldName ?? ""
            cell.txtField.placeholder = field.fieldName ?? ""
            cell.txtField.text = field.kycValue ?? ""
            cell.txtField.delegate = self
            if field.fieldType == "NUMBER" {
                cell.txtField.keyboardType = .numberPad
            } else if field.fieldType == "TEXT" {
                cell.txtField.keyboardType = .default
                cell.txtField.autocapitalizationType = .words
            } else if field.fieldType == "DATE" {
                cell.txtField.keyboardType = .numbersAndPunctuation
                cell.txtField.tag = 1000
                cell.txtField.placeholder = "\(field.fieldName ?? "")"
            }
            cell.txtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            cell.txtField.tag = indexPath.item
            cell.txtIncentive.text = field.incentiveText ?? ""
            
            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 0 {
            let index = walletArr.firstIndex(where: {($0.walletName?.contains(recentTRxs[indexPath.item].paymentSource ?? "") ?? false)})
            if index != nil {
                cashSourceBtn.setTitle(walletArr[index!].walletName ?? "", for: .normal)
                selectedWalletIndex = index!
            }
            txtAmount.text = "\(recentTRxs[indexPath.item].amountLoaded ?? 0.0)"
        }
        
    }
    
}

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
