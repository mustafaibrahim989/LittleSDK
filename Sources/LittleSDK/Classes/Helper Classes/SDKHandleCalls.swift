//
//  HandleCalls.swift
//  LittleSDK
//
//  Created by Gabriel John on 10/05/2021.
//

import UIKit
import SwiftMessages
import Alamofire

class SDKHandleCalls {
    
    var DataToSend = ""
    var ReturnData = ""
    var callTypeName = ""
    var count = 0
    var currentTask: URLSessionTask?
    var creatingRequest: Bool = false
    let am = SDKAllMethods()
    let cn = SDKConstants()
    var data_requests = [URLSession]()
    
    var keysent = false
    
    func makeServerCall(sb: String, method: String, switchnum: Int) {
        printVal(object: "makeServerCall \(method): \(sb)")
        
        let topController = UIApplication.topViewController()
        
        DataToSend = am.EncryptDataAES(DataToSend: sb) as String
                
        callTypeName = method
        
        if SDKReachability.isConnectedToNetwork() || method == "VERIFYUSSDCODEJSONData" {
             connectToServer(switchnum: switchnum, method: method)
        } else {
            printVal(object: "makeServerCall network issue: \(method)")
            
            topController?.removeLoadingPage()
            topController?.view.removeAnimation()
            
            topController?.dismissSwiftAlert()
            
            let bundle = Bundle.module
            
            let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: bundle)
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
        
    }
    
    func connectToServer(switchnum: Int, method: String){
        
        count += 1
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let string = am.DecryptDataKC(DataToSend: cn.link()) as String
        
        let headers: HTTPHeaders = [
            HTTPHeader(name: "Content-Type", value: "application/json; charset=utf-8"),
            HTTPHeader(name: "KeyID", value: "\(am.EncryptDataHeaders(DataToSend: am.getMyKeyID() ?? ""))"),
            HTTPHeader(name: "Accounts", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKAccounts() ?? "")"))"),
            HTTPHeader(name: "MobileNumber", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKMobileNumber() ?? "")"))"),
            HTTPHeader(name: "PackageName", value: "\(am.EncryptDataHeaders(DataToSend: "\(am.getSDKPackageName() ?? "")"))")
        ]
        
        AF.request("\(string)",
               method: .post,
               parameters: [:], encoding: DataToSend, headers: headers).response { response in

                let data = response.data
            

                if data != nil {
                    do {
                        
                        let sDKData = try JSONDecoder().decode(SDKData.self, from: data!)
                        
                        let stringVal = self.am.DecryptDataAES(DataToSend: sDKData.data ?? "") as String
                        
                        printVal(object: "makeServerCall \(method): \(stringVal)")
                        
                        let strData = Data(stringVal.utf8)
                        
                        let dataDict:[String: Data] = ["data": strData]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.callTypeName), object: nil, userInfo: dataDict)
                        
                        
                    } catch(let error) {
                        printVal(object: "makeServerCall error: \(method): \(error.localizedDescription)")
//                        let topController = UIApplication.topViewController()
//                        topController?.removeLoadingPage()
//                        topController?.view.removeAnimation()
//                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: method), object: nil)
                    }

                }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    func handleTimeouts(switchnum: Int) {
        let topController = UIApplication.topViewController()
        if count < 2 {
            connectToServer(switchnum: switchnum, method: "")
        } else {
            topController?.removeLoadingPage()
            topController?.view.removeAnimation()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: callTypeName), object: nil)
        }
    }
    
}

extension String: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = Data(self.utf8)
        return request
    }
}
