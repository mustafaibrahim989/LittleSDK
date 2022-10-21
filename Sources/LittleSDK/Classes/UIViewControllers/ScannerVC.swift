//
//  ScannerVC.swift
//  Little
//
//  Created by Gabriel John on 18/03/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import AVFoundation
import UIKit
import SwiftMessages

public class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    let hc = SDKHandleCalls()
    
    var sdkBundle: Bundle?
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var validate: Bool = true

    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sdkBundle = Bundle.module
        
        view.backgroundColor = .white
        checkCameraSettings()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func checkCameraSettings() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch cameraAuthorizationStatus {
        case .notDetermined: requestCameraPermission()
        case .authorized: presentCamera()
        case .restricted, .denied:
            alertCameraAccessNeeded()
        @unknown default:
            failed()
        }
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: { accessGranted in
            guard accessGranted == true else {
                DispatchQueue.main.async {
                    self.alertCameraAccessNeeded()
                }
                return
            }
            DispatchQueue.main.async {
                self.presentCamera()
            }
        })
    }
    
    func presentCamera() {
        
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
        
    }

    func alertCameraAccessNeeded() {
        
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "Camera access denied/restricted", message: "\nYou won't be able to scan QR Codes on Little unless you allow access to the Camera. Click settings to turn on camera access.\n", image: "", action: "")
        view.proceedAction = {
            SwiftMessages.hide()
            UIApplication.shared.open(url)
        }
        view.cancelAction = {
            SwiftMessages.hide()
            self.navigationController?.popViewController(animated: true)
        }
        view.btnProceed.setTitle("Go to Settings", for: .normal)
        view.configureDropShadow()
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.dimMode = .gray(interactive: false)
        SwiftMessages.show(config: config, view: view)
        
    }
    
    func failed() {
        
        let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
        view.loadPopup(title: "Scanning not supported", message: "\nYour device does not support scanning Little QR Codes. Please use a device with a camera.\n", image: "", action: "")
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

    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }
    
    func commonCallParams() -> String {
        
        let version = getAppVersion()
        
        let str = ",\"SessionID\":\"\(am.getMyUniqueID() ?? "")\",\"MobileNumber\":\"\(am.getSDKMobileNumber() ?? "")\",\"IMEI\":\"\(am.getIMEI() ?? "")\",\"CodeBase\":\"\(am.getMyCodeBase() ?? "")\",\"PackageName\":\"\(am.getSDKPackageName() ?? "")\",\"DeviceName\":\"\(getPhoneType())\",\"SOFTWAREVERSION\":\"\(version)\",\"RiderLL\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"LatLong\":\"\(am.getCurrentLocation() ?? "0.0,0.0")\",\"TripID\":\"\",\"City\":\"\(am.getCity() ?? "")\",\"RegisteredCountry\":\"\(am.getCountry() ?? "")\",\"Country\":\"\(am.getCountry() ?? "")\",\"UniqueID\":\"\(am.getMyUniqueID() ?? "")\",\"CarrierName\":\"\(getCarrierName() ?? "")\""
        
        return str
    }
    
    func validateMerchantCode(code: String) {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNearbyMerchants),name:NSNotification.Name(rawValue: "VALIDATEQRCODEJSONData"), object: nil)
        
        let dataToSend = "{\"FormID\":\"VALIDATEQRCODE\"\(commonCallParams()),\"ValidateQRCode\":{\"QRCode\":\"\(code)\"}}"
        
        
        printVal(object: dataToSend)
        
        hc.makeServerCall(sb: dataToSend, method: "VALIDATEQRCODEJSONData", switchnum: 0)
    }
    
    @objc func loadNearbyMerchants(_ notification: NSNotification) {
        self.view.removeAnimation()
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "VALIDATEQRCODEJSONData"), object: nil)
        if data != nil {
            do {
                let qRData = try JSONDecoder().decode(QRData.self, from: data!)
                if qRData.status == "000" {
                    let dic = ["Message": "\(qRData.merchantID ?? ""),\(qRData.amount ?? ""),\(qRData.reference ?? "")"]
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "QRLISTENING"), object: nil, userInfo: dic)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
                    view.loadPopup(title: "QR Code Error", message: "\n\(qRData.message ?? "Kindly ensure the QR being scanned is a Little Merchants QR Code.")\n", image: "", action: "")
                    view.proceedAction = {
                       SwiftMessages.hide()
                       self.captureSession.startRunning()
                    }
                    view.btnDismiss.isHidden = true
                    view.configureDropShadow()
                    var config = SwiftMessages.defaultConfig
                    config.duration = .forever
                    config.presentationStyle = .bottom
                    config.dimMode = .gray(interactive: false)
                    SwiftMessages.show(config: config, view: view)
                }
                
            } catch {
                
                let view: PopOverAlertWithAction = try! SwiftMessages.viewFromNib(named: "PopOverAlertWithAction", bundle: sdkBundle!)
                view.loadPopup(title: "Invalid QR Code", message: "\nKindly ensure the QR being scanned is a Little Merchants QR Code.\n", image: "", action: "")
                view.proceedAction = {
                   SwiftMessages.hide()
                   self.captureSession.startRunning()
                }
                view.btnDismiss.isHidden = true
                view.configureDropShadow()
                var config = SwiftMessages.defaultConfig
                config.duration = .forever
                config.presentationStyle = .bottom
                config.dimMode = .gray(interactive: false)
                SwiftMessages.show(config: config, view: view)
                
            }
        }
        
    }

    func found(code: String) {
        if validate {
            validateMerchantCode(code: code)
        } else {
            let dic = ["Message": "\(code)"]
            NotificationCenter.default.post(name: Notification.Name(rawValue: "QRLISTENING"), object: nil, userInfo: dic)
            self.navigationController?.popViewController(animated: true)
        }
        
    }

    public override var prefersStatusBarHidden: Bool {
        return true
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
