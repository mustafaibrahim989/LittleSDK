//
//  InitializeSDKVC.swift
//  LittleSDK
//
//  Created by Gabriel John on 11/05/2021.
//

import UIKit
import Alamofire
import SwiftMessages
import NVActivityIndicatorView

public class InitializeSDKVC: UIViewController {
    
    // MARK: - Properties
    
    var popToRestorationID: UIViewController?
    
    var mobileNumber: String?
    var packageName: String?
    var accounts: String?
    
    var toWhere: ToWhere?
    var navShown: Bool?
    var deliveryType: deliveryTypes?
    
    var paymentVC: UIViewController?
    
    var isUAT = false
    
    // MARK: - Init
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Visual Setup
    
    func configureUI() {
        
        view.backgroundColor = SDKConstants.littleSDKThemeColor
        
        let bottomView = UIView()
        
        view.addSubview(bottomView)
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        view.layoutIfNeeded()
        
        let activityView: NVActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(origin: CGPoint(x: 0, y: 0),size: CGSize(width: 40, height: 40)), type: NVActivityIndicatorType.ballScaleRippleMultiple, color: .white)
        activityView.center = CGPoint(x: CGFloat(bottomView.bounds.midX - 40), y: CGFloat(bottomView.bounds.maxY - 60))
        activityView.startAnimating()
        
        bottomView.addSubview(activityView)
        
        let label = UILabel()
        label.text = "Initializing..."
        label.textAlignment = .left
        label.textColor = .white
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 16.0)
        
        bottomView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: activityView.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: activityView.rightAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(equalTo: bottomView.rightAnchor, constant: -10).isActive = true
        
        setGradientBackground(view: bottomView)
        
        initializeSDK()
    }
    
    // MARK: - Handlers
    
    func checkThatAllParamsAreAvailable() {
        if mobileNumber == nil {
            
            showMissingParameter(param: "Mobile Number")
            
        } else if packageName == nil {
            
            showMissingParameter(param: "Package Name")
            
        } else if accounts == nil {
            
            showMissingParameter(param: "Accounts")
            
        } else {
            initializeSDK()
        }
    }
    
    func setGradientBackground(view: UIView) {
        let colorTop =  SDKConstants.littleSDKThemeColor.cgColor
        let colorBottom = SDKConstants.littleSDKDarkThemeColor.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        
        view.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func showMissingParameter(param: String) {
        
        let bundle = Bundle.module
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: bundle)
        view.loadPopup(title: "", message: "\nError encountered accessing Little SDK. You are missing a required parameter '\(param)'\n", image: "", action: "")
        view.proceedAction = {
            SwiftMessages.hide()
            self.navigationController?.popViewController(animated: true)
        }
        view.btnDismiss.isHidden = true
        view.btnProceed.setTitle("Exit SDK", for: .normal)
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func initializeSDK() {
        
        let string = am.DecryptDataKC(DataToSend: cn.link()) as String
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: "Content-Type", value: "application/json"),
            HTTPHeader(name: "KeyID", value: "\(am.EncryptDataHeaders(DataToSend: am.getSDKAPIKey()))"),
            HTTPHeader(name: "Accounts", value: "\(am.EncryptDataHeaders(DataToSend: am.getSDKAccounts() ?? ""))"),
            HTTPHeader(name: "MobileNumber", value: "\(am.EncryptDataHeaders(DataToSend: am.getSDKMobileNumber() ?? ""))"),
            HTTPHeader(name: "PackageName", value: "\(am.EncryptDataHeaders(DataToSend: am.getSDKPackageName() ?? ""))")
        ]

        let parameters = [String: String]()

        AF.request("\(string)",
                   method: .post,
                   parameters: parameters,
                   headers: headers
        ).response { response in
            
            let data = response.data
            
            
            if data != nil {
                do {
                                        
                    let sdkData = try JSONDecoder().decode(SDKData.self, from: data!)
                    
                    if let dataStr = sdkData.data, let data = am.DecryptDataHeaders(DataToSend: dataStr).data(using: .zero), let sDKConfirm = try? JSONDecoder().decode(SDKConfirm.self, from: data), let theData = sDKConfirm.first {
                        
                        am.saveMyUniqueID(data: theData.uniqueID ?? "")
                        am.saveMyKeyID(data: theData.keyID ?? "")
                        am.saveMyEncryptionKey(data: theData.encryptionKey ?? "")
                        am.saveMyEncryptionIV(data: theData.encryptionIV ?? "")
                        am.saveMyUserName(data: theData.userName ?? "")
                        am.saveMyPlatform(data: theData.platform ?? "")
                        am.saveMyCodeBase(data: theData.codeBase ?? "")
                        
                        let sdkBundle = Bundle.module
                        
                        let bundleURL = sdkBundle.resourceURL?.appendingPathComponent("LittleSDK.bundle")
                        var resourceBundle: Bundle? = nil
                        if let bundleURL = bundleURL {
                            resourceBundle = Bundle(url: bundleURL)
                        }
                        
                        switch self.toWhere {
                        case .rides:
                            if let viewController = UIStoryboard(name: "Trip", bundle: sdkBundle).instantiateViewController(withIdentifier: "LittleRideVC") as? LittleRideVC {
                                viewController.isUAT = self.isUAT
                                viewController.popToRestorationID = self.popToRestorationID
                                viewController.navShown = self.navShown
                                viewController.paymentVC = self.paymentVC
                                if let navigator = self.navigationController {
                                    navigator.pushViewController(viewController, animated: true)
                                }
                            }
                        case .umi:
                            if let viewController = UIStoryboard(name: "UMI", bundle: sdkBundle).instantiateViewController(withIdentifier: "UMIController") as? UMIController {
                                viewController.popToRestorationID = self.popToRestorationID
                                viewController.navShown = self.navShown
                                viewController.paymentVC = self.paymentVC
                                if let navigator = self.navigationController {
                                    navigator.pushViewController(viewController, animated: true)
                                }
                            }
                        case .deliveries:
                            if let viewController = UIStoryboard(name: "Deliveries", bundle: sdkBundle).instantiateViewController(withIdentifier: "DeliveriesController") as? DeliveriesController {
                                viewController.popToRestorationID = self.popToRestorationID
                                viewController.navShown = self.navShown
                                viewController.paymentVC = self.paymentVC
                                viewController.category = self.deliveryType?.rawValue ?? ""
                                viewController.title = "\((self.deliveryType?.rawValue ?? "").replacingOccurrences(of: "ORDER", with: "").capitalized) Delivery"
                                if let navigator = self.navigationController {
                                    navigator.pushViewController(viewController, animated: true)
                                }
                            }
                        case .rideHistory:
                            if let viewController = UIStoryboard(name: "Trip", bundle: sdkBundle).instantiateViewController(withIdentifier: "MyRidesViewController") as? MyRidesViewController {
                                viewController.popToRestorationID = self.popToRestorationID
                                viewController.navShown = self.navShown
                                if let navigator = self.navigationController {
                                    navigator.pushViewController(viewController, animated: true)
                                }
                            }
                        default:
                            self.backHome()
                        }
                    } else {
                        self.showError()
                    }
                    
                    
                } catch let error {
                    
                    printVal(object: "initializeMySDK error: \(error.localizedDescription)")
                    
                    self.showError()
                    
                }
                
            }
        }
    }
    
    private func showError() {
        let bundle = Bundle.module
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: bundle)
        view.loadPopup(title: "", message: "\nError encountered accessing Little SDK\n", image: "", action: "")
        view.proceedAction = {
            SwiftMessages.hide()
            self.navigationController?.popViewController(animated: true)
        }
        view.btnDismiss.isHidden = true
        view.btnProceed.setTitle("Exit SDK", for: .normal)
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
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
    
    // MARK: - Server Calls
    
}
