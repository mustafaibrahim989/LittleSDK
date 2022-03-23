//
//  ExtraItemsController.swift
//  Little
//
//  Created by Gabriel John on 19/06/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import UIView_Shimmer

class ExtraItemsCell: UITableViewCell {
    
    @IBOutlet weak var imgExtra: UIImageView!
    @IBOutlet weak var lblExtraName: UILabel!
    @IBOutlet weak var lblExtraPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

public class ExtraItemsController: UIViewController {
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    var sdkBundle: Bundle?
    
    var selectedRestaurant: Restaurant?
    var selectedFood: FoodMenu?
    var extraItemsArr: ExtraMenuItems = [ExtraMenuItem(status: "***", message: "***", groupTitle: "", typeOfSelection: "***", finalNotes: "***", extraMenuItemRequired: false, groupDetails: [GroupDetail(extraItemID: "***", extraItemName: "***", extraItemDescription: "***", specialPrice: 0.0)])]
    var extraTotalPrices: Double = 0.0
    var proceed: String = ""
    var observerName: String = ""
    var currency: String?
    var selectedExtraItems: [GroupDetail] = []
    
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noProducts: UIView!
    @IBOutlet weak var lblProducts: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle.module
        
        let nib = UINib.init(nibName: "ExtraItemsCell", bundle: sdkBundle!)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        tableView.reloadData()
        view.layoutIfNeeded()
        
        view.setTemplateWithSubviews(true, viewBackgroundColor: .white)
        
        lblTitle.text = "\(selectedFood?.foodName ?? "") Details"
        btnProceed.setTitle("Proceed (\(currency ?? am.getGLOBALCURRENCY()!) \(formatCurrency("\(selectedFood?.specialPrice ?? 0.0)")))", for: .normal)
        
        lblProducts.text = "\(selectedFood?.foodName ?? "") does not appear to have any addons. Please select a different product from the menu."
        
        btnProceed.backgroundColor = .lightGray
        btnProceed.isEnabled = false
        
        view.setTemplateWithSubviews(true, viewBackgroundColor: .white)
        
        showAnimate()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.tableView.sectionHeaderHeight = 70
        am.saveMESSAGE(data: "")
        getMenuAddons()
    }

    @IBAction func btnClosePressed(_ sender: UIButton) {
        let dic = ["SelectedItems": "NONE"]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: observerName), object: nil, userInfo: dic)
        removeAnimate()
    }
    
    @IBAction func btnProceedPressed(_ sender: UIButton) {
        am.saveMESSAGE(data: "\(extraItemsArr[0].finalNotes ?? ""):::\(proceed)")
        let dic = ["SelectedItems": selectedExtraItems]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: observerName), object: nil, userInfo: dic)
        removeAnimate()
    }
    
    func checkToProceed() {
        
        let theTotal = (selectedFood?.specialPrice ?? 0.0) + extraTotalPrices
        
        btnProceed.setTitle("Proceed (\(currency ?? am.getGLOBALCURRENCY()!) \(formatCurrency("\(theTotal)")))", for: .normal)
        
        if extraItemsArr.contains(where: { $0.typeOfSelection == "ONE" }) {
            for each in extraItemsArr {
                if each.typeOfSelection == "ONE" {
                    if selectedExtraItems.count > 0 {
                        for item in selectedExtraItems {
                            if each.groupDetails?.contains(where: { $0.extraItemID == item.extraItemID}) ?? false {
                                self.btnProceed.isEnabled = true
                                self.btnProceed.backgroundColor = SDKConstants.littleSDKThemeColor
                                self.proceed = "PROCEED"
                                break
                            } else {
                                self.proceed = ""
                                self.btnProceed.isEnabled = false
                                self.btnProceed.backgroundColor = .lightGray
                            }
                        }
                    } else {
                        self.proceed = ""
                        self.btnProceed.isEnabled = false
                        self.btnProceed.backgroundColor = .lightGray
                    }
                }
            }
        } else {
            self.proceed = "PROCEED"
            self.btnProceed.isEnabled = true
            self.btnProceed.backgroundColor = SDKConstants.littleSDKThemeColor
        }
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
        });
    }
    
    @objc func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.view.alpha = 0.0
        }, completion: {(finished: Bool) in if (finished)
        {
            self.view.removeFromSuperview()
            }
        });
    }

}

extension ExtraItemsController {
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID()!)\",\"MobileNumber\":\"\(am.getSDKMobileNumber()!)\",\"IMEI\":\"\(am.getIMEI()!)\",\"CodeBase\":\"\(am.getMyCodeBase()!)\",\"PackageName\":\"\(am.getSDKPackageName()!)\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation()!)\",\"LatLong\":\"\(am.getCurrentLocation()!)\",\"TripID\":\"\",\"City\":\"\(am.getCity()!)\",\"RegisteredCountry\":\"\(am.getCountry()!)\",\"Country\":\"\(am.getCountry()!)\",\"UniqueID\":\"\(am.getMyUniqueID()!)\",\"CarrierName\":\"\(getCarrierName()!)\""
        
        return str
    }
    
    func getMenuAddons() {
        
        view.setTemplateWithSubviews(true, viewBackgroundColor: .white)
        
        noProducts.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMenuAddons),name:NSNotification.Name(rawValue: "GETDELIVERYEXTRADETAILSFoodDelivery"), object: nil)
        
        let restaurantID = selectedRestaurant?.restaurantID ?? ""
        
        let dataToSend = "{\"FormID\":\"GETDELIVERYEXTRADETAILS\"\(commonCallParams()),\"RestaurantDeliveryExtraItemDetail\":{\"RestaurantID\":\"\(restaurantID)\",\"MenuID\":\"\(selectedFood?.menuID ?? "")\"}}"
        
        hc.makeServerCall(sb: dataToSend, method: "GETDELIVERYEXTRADETAILSFoodDelivery", switchnum: 0)
        
    }
    
    @objc func loadMenuAddons(_ notification: NSNotification) {
        
        self.view.setTemplateWithSubviews(false)
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETDELIVERYEXTRADETAILSFoodDelivery"), object: nil)
        if data != nil {
            do {
                let extraMenuItems = try JSONDecoder().decode(ExtraMenuItems.self, from: data!)
                extraItemsArr = extraMenuItems
                tableView.reloadData()
            } catch {
                extraItemsArr.removeAll()
            }
        }
        
        checkToProceed()
        
        view.setTemplateWithSubviews(false)
        
        if extraItemsArr.count > 0 {
            noProducts.isHidden = true
        } else {
            noProducts.alpha = 0
            noProducts.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.noProducts.alpha = 1
            }
        }
    }
}

extension ExtraItemsController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return extraItemsArr.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extraItemsArr[section].groupDetails?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let color = SDKConstants.littleSDKThemeColor
        
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width-72, height: 30))
        label.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 17.0)
        label.textColor = .darkGray
        label.text = extraItemsArr[section].groupTitle ?? ""
        
        if extraItemsArr[section].extraMenuItemRequired ?? false {
            let label2 = UILabel()
            label2.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 13.0)
            label2.textColor = color
            label2.text = "❊Required"
            label2.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(label2)
            label2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8).isActive = true
            label2.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            label2.heightAnchor.constraint(equalToConstant: 20).isActive = true
            label2.widthAnchor.constraint(equalToConstant: 70).isActive = true
        }
        
        let label3 = UILabel()
        label3.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 13.0)
        label3.textColor = .lightGray
        label3.translatesAutoresizingMaskIntoConstraints = false
        
        if extraItemsArr[section].typeOfSelection == "ONE" {
            label3.text = "Choose 1 Item"
        } else if extraItemsArr[section].typeOfSelection == "MULTIPLE" {
            label3.text = "Choose max of \(extraItemsArr[section].groupDetails?.count ?? 0) items"
        } else {
            label3.text = ""
        }
        
        view.addSubview(label3)
        label3.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        label3.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        label3.heightAnchor.constraint(equalToConstant: 20).isActive = true
        label3.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        view.addSubview(label)

        return view
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let section = extraItemsArr[indexPath.section]
        let item = extraItemsArr[indexPath.section].groupDetails?[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ExtraItemsCell
        cell.lblExtraName.text = item?.extraItemName ?? ""
        if item?.specialPrice == 0.0 {
            cell.lblExtraPrice.text = ""
        } else {
            cell.lblExtraPrice.text = "+\(formatCurrency("\(item?.specialPrice ?? 0.0)"))"
        }
        if section.typeOfSelection == "ONE" {
            if selectedExtraItems.contains(where: { $0.extraItemID == item?.extraItemID }) {
                cell.imgExtra.image = getImage(named: "deliver_check", bundle: sdkBundle!)
            } else {
                cell.imgExtra.image = getImage(named: "deliver_uncheck", bundle: sdkBundle!)
            }
        } else {
            if selectedExtraItems.contains(where: { $0.extraItemID == item?.extraItemID }) {
                cell.imgExtra.image = getImage(named: "deliver_checkbox", bundle: sdkBundle!)
            } else {
                cell.imgExtra.image = getImage(named: "deliver_uncheckbox", bundle: sdkBundle!)
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = extraItemsArr[indexPath.section].groupDetails?[indexPath.row]
        
        if selectedExtraItems.contains(where: { $0.extraItemID == item?.extraItemID }) {
            if item?.specialPrice ?? 0.0 > 0.0 {
                extraTotalPrices -= item?.specialPrice ?? 0.0
            }
            let index = selectedExtraItems.firstIndex(where: { $0.extraItemID == item?.extraItemID })
            if index != nil {
                selectedExtraItems.remove(at: index!)
            }
        } else {
            if extraItemsArr[indexPath.section].typeOfSelection == "ONE" {
                var isFound: Bool = false
                for each in extraItemsArr[indexPath.section].groupDetails ?? [] {
                    let index = selectedExtraItems.firstIndex(where: { $0.extraItemID == each.extraItemID })
                    if index != nil {
                        selectedExtraItems[index!] = item!
                        isFound = true
                    }
                }
                if !isFound {
                    selectedExtraItems.append(item!)
                }
            } else {
                selectedExtraItems.append(item!)
            }
            if item?.specialPrice ?? 0.0 > 0.0 {
                extraTotalPrices += item?.specialPrice ?? 0.0
            }
        }
        checkToProceed()
        printVal(object: selectedExtraItems)
        tableView.reloadData()
    }
}
