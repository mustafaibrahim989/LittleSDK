//
//  ProductController.swift
//  Little
//
//  Created by Gabriel John on 01/04/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import SwiftMessages
import SDWebImage

public class ProductController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    var sdkBundle: Bundle?
    
    var menuData: Data?
    
    var selectedRestaurant: Restaurant?
    var selectedTicketNo: Int?
    var selectedSeats: [String] = []
    var selectedTime: Int = 0
    var currency: String?
    var selectedCategory: Int?
    var selectedFoodIndex: Int?
    var sortIndex: Int = 0
    var cartItems: [CartItems] = []
    var paymentSourceArr: [Balance] = []
    var searchTerm = ""
    var category: String = ""
    var merchantMessage: String = ""
    var proceed: String = ""
    var observerName: String = ""
    var myMenuID: String = ""
    var myPromoCode: String = ""
    
    var paymentVC: UIViewController?
    
    private var finishedLoadingInitialTableCells = false
    
    var menuArr: [FoodMenu] = [FoodMenu(menuID: "    ", foodCategory: "      ", foodName: "          ", foodDescription: "               ", originalPrice: 1000, specialPrice: 2000, foodImage: "", extraItem: "N", addonID: "", extraItems: [])]
    var sortedArr: [FoodMenu] = [FoodMenu(menuID: "    ", foodCategory: "      ", foodName: "            ", foodDescription: "               ", originalPrice: 1000, specialPrice: 2000, foodImage: "", extraItem: "N", addonID: "", extraItems: [])]
    var categoryArr: [String] = ["All"]
    var sortByArr: [String] = ["None","Price Ascending","Price Descending"]
    
    @IBOutlet weak var categoryCollection: UICollectionView!
    @IBOutlet weak var menuTable: UITableView!
    @IBOutlet weak var orderView: UIView!
    @IBOutlet weak var searchButtonView: UIView!
    @IBOutlet weak var lblOrderAmount: UILabel!
    @IBOutlet weak var lblSortBy: UILabel!
    @IBOutlet weak var btnSortBy: UIButton!
    @IBOutlet weak var btnCancelSearch: UIButton!
    @IBOutlet weak var categoryLoad: UIView!
    @IBOutlet weak var sortConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableBottomConst: NSLayoutConstraint!
    @IBOutlet weak var sortView: UIView!
    @IBOutlet weak var lblSearchResults: UILabel!
    
    @IBOutlet weak var noProductsView: UIView!
    @IBOutlet weak var imgNoProducts: UIImageView!
    @IBOutlet weak var lblNoProducts: UILabel!
    
    @IBOutlet weak var btnNext: UIButton!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle.module
        
        let nib = UINib.init(nibName: "MenuCell", bundle: sdkBundle!)
        menuTable.register(nib, forCellReuseIdentifier: "cell")
        
        let nib2 = UINib.init(nibName: "MenuAddonsCell", bundle: sdkBundle!)
        menuTable.register(nib2, forCellReuseIdentifier: "addonsCell")
        
        let nib1 = UINib.init(nibName: "MenuCategoryCell", bundle: sdkBundle!)
        self.categoryCollection.register(nib1, forCellWithReuseIdentifier: "cell")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(btnSortPressed(_:)))
        lblSortBy.addGestureRecognizer(tap)
        
        menuTable.reloadData()
        categoryCollection.reloadData()
        menuTable.layoutIfNeeded()
        categoryCollection.layoutIfNeeded()
        categoryLoad.layoutIfNeeded()
        
        view.setTemplateWithSubviews(true, viewBackgroundColor: .white)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        let restaurantName = selectedRestaurant?.restaurantName ?? ""
        
        if restaurantName.last == "s" {
            self.title = "\(restaurantName)' Menu"
        } else {
            self.title = "\(restaurantName)'s Menu"
        }
        
        lblNoProducts.text = "\(restaurantName) is working on revamping its menu. Check back soon. You can also check out other restaurants while in here."
        imgNoProducts.image = getImage(named: "no_\(category.replacingOccurrences(of: "ORDER", with: "").lowercased())", bundle: sdkBundle!)
        if imgNoProducts.image == nil {
            imgNoProducts.image = getImage(named: "no_products", bundle: sdkBundle!)
        }
        
        hideCart(total: 0.00)
        
        getRestaurantMenu()
    }
    
    // MARK: - Server Calls and Responses
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID() ?? "")\",\"MobileNumber\":\"\(am.getSDKMobileNumber() ?? "")\",\"IMEI\":\"\(am.getIMEI() ?? "")\",\"CodeBase\":\"\(am.getMyCodeBase() ?? "")\",\"PackageName\":\"\(am.getSDKPackageName() ?? "")\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"LatLong\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"TripID\":\"\",\"City\":\"\(am.getCity() ?? "")\",\"RegisteredCountry\":\"\(am.getCountry() ?? "")\",\"Country\":\"\(am.getCountry() ?? "")\",\"UniqueID\":\"\(am.getMyUniqueID() ?? "")\",\"CarrierName\":\"\(getCarrierName() ?? "")\",\"UserAdditionalData\":\(am.getSDKAdditionalData())"
        
        return str
    }
    
    func getRestaurantMenu() {
        
        view.setTemplateWithSubviews(true, viewBackgroundColor: .white)
        
        noProductsView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadRestaurantMenu),name:NSNotification.Name(rawValue: "GETRESTAURANTMENUFoodDelivery"), object: nil)
        
        let restaurantID = selectedRestaurant?.restaurantID ?? ""
        
        let dataToSend = "{\"FormID\":\"GETRESTAURANTMENU\"\(commonCallParams()),\"GetRestaurantMenu\":{\"RestaurantID\":\"\(restaurantID)\"}}"
        
        hc.makeServerCall(sb: dataToSend, method: "GETRESTAURANTMENUFoodDelivery", switchnum: 0)
        
    }
    
    @objc func loadRestaurantMenu(_ notification: NSNotification) {
        
        self.view.setTemplateWithSubviews(false)
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETRESTAURANTSFoodDelivery"), object: nil)
        
        if data != nil {
            do {
                if menuData != data {
                    menuData = data!
                    menuArr.removeAll()
                    sortedArr.removeAll()
                    categoryArr.removeAll()
                    let getRestaurantMenu = try JSONDecoder().decode(GetRestaurantMenu.self, from: data!)
                    guard let getRestaurant = getRestaurantMenu.first else { return }
                    menuArr = getRestaurant.foodMenu ?? []
                    categoryArr.append("All")
                    for each in menuArr {
                        if !(categoryArr.contains(each.foodCategory!)) {
                            categoryArr.append(each.foodCategory!)
                        }
                        if !(sortedArr.contains(where: { $0.menuID == each.menuID })) {
                            sortedArr.append(each)
                        }
                    }
                    selectedCategory = 0
                    currency = getRestaurant.currency ?? (am.getGLOBALCURRENCY() ?? "KES")
                    finishedLoadingInitialTableCells = false
                    if sortIndex == 0 {
                        menuTable.reloadData()
                    } else {
                        sortByThis(sortParam: sortByArr[sortIndex])
                    }
                    categoryCollection.reloadData()
                    
                    if myMenuID != "" {
                        let index = sortedArr.firstIndex(where: { $0.menuID == myMenuID })
                        if index != nil {
                            if sortedArr[index!].extraItem == "Y" {
                                    dismissSwiftAlert()
                                    popoverExtraItems(index: index!)
                                } else {
                                    myMenuID = ""
                                    cartItems.append(CartItems(itemID: sortedArr[index!].menuID, addonID: nil, number: 1))
                                    changeCartValues()
                                    printVal(object: cartItems)
                            
                                    let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
                                    view.loadPopup(title: "\(sortedArr[index!].foodName ?? "")", message: "\nTap proceed to add \(sortedArr[index!].foodName ?? "") to cart and proceed to checkout.\n", image: sortedArr[index!].foodImage ?? "", action: "")
                                    view.proceedAction = {
                                        SwiftMessages.hide()
                                        self.proceedToCheckout()
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
                        }
                    }
                    
                    sortToLife()
                }
            } catch {
                menuArr = []
                categoryArr = []
                menuTable.reloadData()
                categoryCollection.reloadData()
            }
        }
        
        if menuArr.count > 0 {
            noProductsView.isHidden = true
        } else {
            noProductsView.alpha = 0
            noProductsView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.noProductsView.alpha = 1
            }
        }
    }
    
    // MARK: - Functions & IBActions
    
    func sortToLife() {
        sortView.isHidden = true
        sortConstraint.constant = 10
        view.layoutIfNeeded()
        sortView.alpha = 0
        sortView.isHidden = false
        sortConstraint.constant = 50
        UIView.animate(withDuration: 0.3) {
            self.sortView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }
    
    func filterByCategory(indexPath: IndexPath) {
        sortedArr.removeAll()
        selectedCategory = indexPath.item
        for each in menuArr {
            if categoryArr[indexPath.item] == "All" {
                sortedArr.append(each)
            } else if (each.foodCategory == categoryArr[indexPath.item]) {
                sortedArr.append(each)
            }
        }
        finishedLoadingInitialTableCells = false
        categoryCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        if lblSearchResults.text != "" {
            searchFromMenu()
        } else {
            if sortIndex == 0 {
                menuTable.reloadData()
            } else {
                sortByThis(sortParam: sortByArr[sortIndex])
            }
        }
        categoryCollection.reloadData()
    }
    
    func sortByThis(sortParam: String) {
        switch sortParam {
        case "None":
            lblSortBy.text = "Sort by?"
            btnSortBy.setImage(getImage(named: "sort", bundle: sdkBundle!), for: UIControl.State())
            let indexPath = IndexPath(item: selectedCategory ?? 0, section: 0)
            filterByCategory(indexPath: indexPath)
        case "Price Ascending":
            lblSortBy.text = "\(sortParam.lowercased())"
            btnSortBy.setImage(getImage(named: "sort_ascending", bundle: sdkBundle!), for: UIControl.State())
            sortedArr = sortedArr.sorted { $0.specialPrice ?? 0 < $1.specialPrice  ?? 0}
            finishedLoadingInitialTableCells = false
            menuTable.reloadData()
        case "Price Descending":
            lblSortBy.text = "\(sortParam.lowercased())"
            btnSortBy.setImage(getImage(named: "sort-descending", bundle: sdkBundle!), for: UIControl.State())
            sortedArr = sortedArr.sorted { $0.specialPrice ?? 0 > $1.specialPrice  ?? 0}
            finishedLoadingInitialTableCells = false
            menuTable.reloadData()
        default:
            return
        }
    }
    
    func popoverExtraItems(index: Int) {
        
        selectedFoodIndex = index
        
        observerName = "SELECTEDITEMS\(sortedArr[index].menuID ?? "")\(sortedArr[index].addonID ?? "")"
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadFromExtra(_:)),name:NSNotification.Name(rawValue: observerName), object: nil)
        
        let popOverVC = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "ExtraItemsController") as! ExtraItemsController
        self.addChild(popOverVC)
        popOverVC.selectedRestaurant = selectedRestaurant
        popOverVC.selectedFood = sortedArr[index]
        popOverVC.observerName = observerName
        popOverVC.selectedExtraItems = sortedArr[index].extraItems ?? []
        popOverVC.currency = currency
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
    @objc func btnAddPressed(_ sender: UIButton) {
        popoverExtraItems(index: sender.tag)
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        if sortedArr[sender.tag].extraItem == "Y" {
            let result = cartItems.compactMap { $0 }.contains(where: { $0.addonID == sortedArr[sender.tag].addonID })
            if result {
                guard let index = cartItems.firstIndex(where: { $0.addonID == sortedArr[sender.tag].addonID }) else { return }
                cartItems[index] = CartItems(itemID: sortedArr[sender.tag].menuID, addonID: sortedArr[sender.tag].addonID, number: sender.value)
            } else {
                cartItems.append(CartItems(itemID: sortedArr[sender.tag].menuID, addonID: sortedArr[sender.tag].addonID, number: sender.value))
            }
        } else {
            let result = cartItems.compactMap { $0 }.contains(where: { $0.itemID == sortedArr[sender.tag].menuID })
            if result {
                guard let index = cartItems.firstIndex(where: { $0.itemID == sortedArr[sender.tag].menuID }) else { return }
                cartItems[index] = CartItems(itemID: sortedArr[sender.tag].menuID, addonID: nil, number: sender.value)
            } else {
                cartItems.append(CartItems(itemID: sortedArr[sender.tag].menuID, addonID: nil, number: sender.value))
            }
        }
        changeCartValues()
        printVal(object: cartItems)
        
    }
    
    func changeCartValues() {
        
        if cartItems.count > 0 {
            var total = 0.00
            for item in cartItems {
                if item.number == 0 {
                    if item.addonID != nil {
                        guard let IDindex = sortedArr.firstIndex(where: { $0.addonID == item.addonID }) else { return }
                                guard let menuIDindex = menuArr.firstIndex(where: { $0.addonID == item.addonID }) else { return }
                        sortedArr.remove(at: IDindex)
                        menuArr.remove(at: menuIDindex)
                    }
                }
            }
            cartItems.removeAll(where: { $0.number == 0 })
            var addonItems: Bool = false
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
                        addonItems = true
                    }
                    let math = (result?.specialPrice ?? 0.00)+totalExtras
                    total = total + ((math)*(item.number ?? 0))
                }
            }
            if !addonItems {
                merchantMessage = ""
                proceed = ""
            }
            if total == 0.00 {
                hideCart(total: total)
            } else {
                showCart(total: total)
            }
            
        } else {
            hideCart(total: 0.00)
        }
        menuTable.reloadData()
    }
    
    func showCart(total: Double) {
        
        var grandTotal = 0.00
        
        grandTotal = total
        
        lblOrderAmount.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "")) \(formatCurrency(String(grandTotal)))"
        
        if btnNext.title(for: .normal) != "Next" {
            btnNext.setTitle("Next", for: .normal)
        }
        
        if orderView.isHidden == true {
            lblOrderAmount.alpha = 0
            orderView.alpha = 0
            orderView.isHidden = false
            tableBottomConst.constant = 66
            UIView.animate(withDuration: 0.3) {
                self.orderView.alpha = 1
                self.lblOrderAmount.alpha = 1
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func hideCart(total: Double) {
        lblOrderAmount.text = ""
        tableBottomConst.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.orderView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { completed in
            self.orderView.isHidden = true
        })
    }
    
    func searchFromMenu() {
        sortedArr.removeAll()
        for each in menuArr {
            if categoryArr[selectedCategory ?? 0] == "All" {
                if !(sortedArr.contains(where: { $0.menuID == each.menuID })) {
                    sortedArr.append(each)
                }
            } else if (each.foodCategory == categoryArr[selectedCategory ?? 0]) {
                sortedArr.append(each)
            }
        }
        var arr: [FoodMenu] = []
        for each in sortedArr {
            if each.foodName?.lowercased().contains(searchTerm.lowercased()) ?? false  {
                arr.append(each)
            }
        }
        sortedArr = arr
        menuTable.reloadData()
        btnCancelSearch.isHidden = false
        searchButtonView.isHidden = true
        lblSearchResults.text = "Search results \"\(searchTerm)\""
    }
    
    func proceedToCheckout() {
        
        var arr: [FoodMenu] = []
        
        for item in cartItems {
            for each in menuArr {
                if item.itemID == each.menuID {
                    if !(arr.contains(where: {$0.menuID == each.menuID})) {
                        arr.append(each)
                    }
                }
                if item.itemID == each.menuID {
                    if !(arr.contains(where: {$0.addonID == each.addonID})) {
                        arr.append(each)
                    }
                }
            }
        }
        
        var goAhead = true
        for each in arr {
            if each.extraItem == "Y" {
                goAhead = false
                continue
            }
        }
        dismissSwiftAlert()
        if proceed == "PROCEED" || goAhead {
            if let viewController = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "ConfirmOrderController") as? ConfirmOrderController {
                viewController.selectedRestaurant = selectedRestaurant
                viewController.paymentSourceArr = paymentSourceArr
                viewController.cartItems = cartItems
                viewController.currency = currency
                viewController.merchantMessage = merchantMessage
                viewController.category = category
                viewController.myPromoCode = myPromoCode
                viewController.menuArr = arr
                viewController.selectedTicketNo = selectedTicketNo
                viewController.selectedTime = selectedTime
                viewController.selectedSeats = selectedSeats
                viewController.paymentVC = paymentVC
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        } else {
            for each in arr {
                if each.extraItem == "Y" {
                    let index = sortedArr.firstIndex(where: { $0.menuID == each.menuID })
                    popoverExtraItems(index: index!)
                }
            }
        }
    }
    
    @objc func loadFromExtra(_ notification: Notification) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        if notification.userInfo?["SelectedItems"] != nil {
            let selectedItems = notification.userInfo?["SelectedItems"] as? [GroupDetail]
            if selectedItems != nil {
                
                let addonId = notification.name.rawValue.replacingOccurrences(of: "SELECTEDITEMS\(sortedArr[selectedFoodIndex!].menuID ?? "")", with: "")
                
                var IDindex = 0
                var menuIDindex = 0
                
                var addon_id = NSUUID().uuidString
                var num: CartItems?
                
                if addonId == "" {
                    IDindex = selectedFoodIndex!
                    menuIDindex = menuArr.firstIndex(where: { $0.menuID == sortedArr[selectedFoodIndex!].menuID }) ?? 0
                    
                    num = CartItems(itemID: sortedArr[IDindex].menuID, addonID: addon_id, number: 1)
                    
                    sortedArr.insert(FoodMenu(menuID: sortedArr[IDindex].menuID ?? "", foodCategory: sortedArr[IDindex].foodCategory ?? "", foodName: sortedArr[IDindex].foodName ?? "", foodDescription: sortedArr[IDindex].foodDescription ?? "", originalPrice: sortedArr[IDindex].originalPrice ?? 0.0, specialPrice: sortedArr[IDindex].specialPrice ?? 0.0, foodImage: sortedArr[IDindex].foodImage ?? "", extraItem: sortedArr[IDindex].extraItem ?? "", addonID: addon_id, extraItems: selectedItems!), at: IDindex+1)
                    
                    menuArr.insert(FoodMenu(menuID: sortedArr[IDindex].menuID ?? "", foodCategory: sortedArr[IDindex].foodCategory ?? "", foodName: sortedArr[IDindex].foodName ?? "", foodDescription: sortedArr[IDindex].foodDescription ?? "", originalPrice: sortedArr[IDindex].originalPrice ?? 0.0, specialPrice: sortedArr[IDindex].specialPrice ?? 0.0, foodImage: sortedArr[IDindex].foodImage ?? "", extraItem: sortedArr[IDindex].extraItem ?? "", addonID: addon_id, extraItems: selectedItems!), at: menuIDindex+1)
                    
                    cartItems.append(num!)
                    
                } else {
                    IDindex = sortedArr.firstIndex(where: { $0.addonID == addonId }) ?? 0
                    menuIDindex = menuArr.firstIndex(where: { $0.addonID == addonId }) ?? 0
                    
                    addon_id = sortedArr[IDindex].addonID ?? ""
                    
                    let number = cartItems.first(where: { $0.addonID == sortedArr[IDindex].addonID })?.number
                    let index = cartItems.firstIndex(where: { $0.addonID == sortedArr[IDindex].addonID })
                    
                    num = CartItems(itemID: sortedArr[IDindex].menuID, addonID: addon_id, number: number ?? 0)
                    
                    cartItems[index!] = num!
                    
                    sortedArr[IDindex] = FoodMenu(menuID: sortedArr[IDindex].menuID ?? "", foodCategory: sortedArr[IDindex].foodCategory ?? "", foodName: sortedArr[IDindex].foodName ?? "", foodDescription: sortedArr[IDindex].foodDescription ?? "", originalPrice: sortedArr[IDindex].originalPrice ?? 0.0, specialPrice: sortedArr[IDindex].specialPrice ?? 0.0, foodImage: sortedArr[IDindex].foodImage ?? "", extraItem: sortedArr[IDindex].extraItem ?? "", addonID: addon_id, extraItems: selectedItems!)
                    
                    menuArr[menuIDindex] = FoodMenu(menuID: sortedArr[IDindex].menuID ?? "", foodCategory: sortedArr[IDindex].foodCategory ?? "", foodName: sortedArr[IDindex].foodName ?? "", foodDescription: sortedArr[IDindex].foodDescription ?? "", originalPrice: sortedArr[IDindex].originalPrice ?? 0.0, specialPrice: sortedArr[IDindex].specialPrice ?? 0.0, foodImage: sortedArr[IDindex].foodImage ?? "", extraItem: sortedArr[IDindex].extraItem ?? "", addonID: addon_id, extraItems: selectedItems!)
                }
                
                merchantMessage = (am.getMESSAGE() ?? "").components(separatedBy: ":::")[safe: 0] ?? ""
                proceed = (am.getMESSAGE() ?? "").components(separatedBy: ":::")[safe: 1] ?? ""
                
                printVal(object: sortedArr)
                printVal(object: menuArr)
                
                changeCartValues()
                
                printVal(object: cartItems)
                
                if myMenuID != "" {
                    
                    let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
                    view.loadPopup(title: "\(menuArr[menuIDindex].foodName ?? "")", message: "\nTap proceed to add \(menuArr[menuIDindex].foodName ?? "") to cart and proceed to checkout.\n", image: menuArr[menuIDindex].foodImage ?? "", action: "")
                    view.proceedAction = {
                        SwiftMessages.hide()
                        self.proceedToCheckout()
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
                
            }
        }
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: observerName), object: nil)
        
    }
    
    @objc func loadFromSearch(_ notification: Notification) {
        let data = notification.userInfo?["data"] as? String
        if data != nil {
            if data != "" {
                
                searchTerm = data!
                searchFromMenu()
                
            } else {
                lblSearchResults.text = ""
                btnCancelSearch.isHidden = true
                searchButtonView.isHidden = false
                filterByCategory(indexPath: IndexPath(row: selectedCategory!, section: 0))
            }
        } else {
            lblSearchResults.text = ""
            btnCancelSearch.isHidden = true
            searchButtonView.isHidden = false
            filterByCategory(indexPath: IndexPath(row: selectedCategory!, section: 0))
        }
    }
    
    @IBAction func btnCloseSearch(_ sender: UIButton) {
        lblSearchResults.text = ""
        btnCancelSearch.isHidden = true
        searchButtonView.isHidden = false
        filterByCategory(indexPath: IndexPath(row: selectedCategory!, section: 0))
    }
    
    @IBAction func btnNextPressed(_ sender: UIButton) {
        proceedToCheckout()
    }
    
    @IBAction func btnSortPressed(_ sender: UIButton) {
        let options = UIAlertController(title: nil, message: "Sort by", preferredStyle: .actionSheet)
        let normalColor = SDKConstants.littleSDKThemeColor
        for i in (0..<sortByArr.count) {
            let sourceBtn = UIAlertAction(title: sortByArr[i], style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.sortIndex = i
                self.sortByThis(sortParam: self.sortByArr[i])
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
    
    @IBAction func btnSearchPressed(_ sender: UIButton) {
        NotificationCenter.default.addObserver(self, selector: #selector(loadFromSearch),name:NSNotification.Name(rawValue: "FROMSEARCH"), object: nil)
        lblSearchResults.text = ""
        btnCancelSearch.isHidden = true
        filterByCategory(indexPath: IndexPath(row: selectedCategory!, section: 0))
        
        let popOverVC = UIStoryboard(name: "Deliveries", bundle: sdkBundle!).instantiateViewController(withIdentifier: "SearchController") as! SearchController
        popOverVC.selectedRestaurant = selectedRestaurant
        self.addChild(popOverVC)
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
    // MARK: - TableView DataSource & Delegates
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedArr.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let menuItem = sortedArr[indexPath.item]
        let color = SDKConstants.littleSDKThemeColor
        
        if menuItem.extraItems?.count ?? 0 > 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "addonsCell") as! MenuAddonsCell
            
            cell.lblMenuName.text = "\(menuItem.foodName ?? "")"
            
            if cartItems.contains(where: { $0.itemID == sortedArr[indexPath.item].menuID }) {
                let value = cartItems.first(where: { $0.addonID == sortedArr[indexPath.item].addonID })?.number ?? 0.0
                cell.stepperMenu.value = value
                cell.lblAmount.text = "\(Int(value))"
                cell.selectedView.backgroundColor = color.withAlphaComponent(0.1)
            } else {
                cell.stepperMenu.value = 0
                cell.lblAmount.text = "0"
                cell.selectedView.backgroundColor = UIColor(named: "littleCellBackgrounds")
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
            cell.lblTotalAmount.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "")) \(formatCurrency(String(grandTotal)))"
            cell.lblExtrasWithOrder.text = "\(string)"
            
            cell.selectionStyle = .none
            cell.layoutIfNeeded()
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MenuCell
            
            cell.layoutIfNeeded()
            cell.imgMenu.layoutIfNeeded()
            
            SDWebImageManager.shared.imageCache.removeImage(forKey: menuItem.foodImage ?? "", cacheType: .all)
            cell.imgMenu.sd_setImage(with: URL(string: menuItem.foodImage ?? ""), placeholderImage: getImage(named: "default_food", bundle: sdkBundle!))
            cell.lblMenuName.text = "\(menuItem.foodName ?? "")"
            cell.lblDescription.text = "\(menuItem.foodDescription ?? "")"
            cell.lblMenuAmount.text = "\(currency ?? (am.getGLOBALCURRENCY() ?? "")) \(menuItem.specialPrice ?? 0)"
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(currency ?? (am.getGLOBALCURRENCY() ?? "")) \(menuItem.originalPrice ?? 0)")
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
                cell.btnAdd.isHidden = false
                cell.stepperMenu.isHidden = true
                cell.lblAmount.tag = indexPath.item
                cell.btnAdd.tag = indexPath.item
                
                cell.btnAdd.addTarget(self, action: #selector(btnAddPressed(_:)), for: .touchUpInside)
                
                if !(selectedRestaurant?.offline ?? true) {
                    cell.btnAdd.isHidden = false
                } else {
                    cell.btnAdd.isHidden = true
                }
                
            } else {
                
                cell.lblAmount.isHidden = false
                cell.btnAdd.isHidden = true
                cell.stepperMenu.isHidden = false
                cell.lblAmount.tag = indexPath.item
                cell.stepperMenu.tag = indexPath.item
                
                cell.stepperMenu.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
                
                if !(selectedRestaurant?.offline ?? true) {
                    cell.stepperMenu.isHidden = false
                    cell.lblAmount.isHidden = false
                } else {
                    cell.stepperMenu.isHidden = true
                    cell.lblAmount.isHidden = true
                }
            }
            
            if cartItems.contains(where: { $0.itemID == sortedArr[indexPath.item].menuID }) && sortedArr[indexPath.item].extraItem != "Y" {
                let value = cartItems.first(where: { $0.itemID == sortedArr[indexPath.item].menuID })?.number ?? 0.0
                cell.stepperMenu.value = value
                cell.lblAmount.text = "\(Int(value))"
                cell.selectedView.backgroundColor = color.withAlphaComponent(0.1)
            } else {
                cell.stepperMenu.value = 0
                cell.lblAmount.text = "0"
                cell.selectedView.backgroundColor = UIColor(named: "littleCellBackgrounds")
            }
            
            cell.lblExtrasWithOrder.text = ""
            
            cell.selectionStyle = .none
            cell.layoutIfNeeded()
            
            return cell
        }
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if !(selectedRestaurant?.offline ?? true) {
            let menuItem = sortedArr[indexPath.item]
            if menuItem.extraItem == "Y" {
                popoverExtraItems(index: indexPath.item)
            }
        } else {
            let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
            view.loadPopup(title: selectedRestaurant?.restaurantName ?? "", message: "\nYou cannot add \(sortedArr[indexPath.item].foodName ?? "the selected item") to cart as \(selectedRestaurant?.restaurantName ?? "this restaurant/shop") is closed. Kindly try again later or check out other Restaurants/Shops\n", image: sortedArr[indexPath.item].foodImage ?? "", action: "")
            view.proceedAction = {
                SwiftMessages.hide()
            }
            view.btnProceed.setTitle("Okay", for: .normal)
            view.btnDismiss.isHidden = true
            view.configureDropShadow()
            var config = SwiftMessages.defaultConfig
            config.duration = .forever
            config.presentationStyle = .bottom
            config.dimMode = .gray(interactive: false)
            SwiftMessages.show(config: config, view: view)
        }
        
        
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        var lastInitialDisplayableCell = false
        
        //change flag as soon as last displayable cell is being loaded (which will mean table has initially loaded)
        if sortedArr.count > 0 && !finishedLoadingInitialTableCells {
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
    
    
    // MARK: - CollectionView DataSource & Delegates
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        
        let font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15.0)!
        
        let varia = CGFloat(50.0)
        
        let size = CGSize(width: ((categoryArr[indexPath.item].width(withConstrainedHeight: 30.0, font: font)) ) + varia, height: 40.0)
        
        return size
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! MenuCategoryCell
        if selectedCategory != nil {
            if selectedCategory == indexPath.item {
                cell.categoryView.backgroundColor = SDKConstants.littleSDKThemeColor
                cell.lblCategory.textColor = .white
            } else {
                cell.categoryView.backgroundColor = SDKConstants.littleSDKCellBackgroundColor
                cell.lblCategory.textColor = SDKConstants.littleSDKLabelColor
            }
        } else {
            cell.categoryView.backgroundColor = SDKConstants.littleSDKCellBackgroundColor
            cell.lblCategory.textColor = SDKConstants.littleSDKLabelColor
        }
        cell.lblCategory.text = categoryArr[indexPath.item]
    
        cell.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 5, options: [], animations: {
            cell.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
        
        return cell
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        lblSearchResults.text = ""
        btnCancelSearch.isHidden = true
        searchButtonView.isHidden = false
        filterByCategory(indexPath: indexPath)
    }
}
