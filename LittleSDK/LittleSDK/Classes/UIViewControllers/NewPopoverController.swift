//
//  NewPopoverController.swift
//  Little
//
//  Created by Gabriel John on 28/11/2019.
//  Copyright © 2019 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class NewPopoverController: UIViewController {
    
    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    var popLink: String = ""
    var popTitle: String = ""
    var popDesc: String = ""
    
    var emailOn: Bool = false
    var pushOn: Bool = false
    var smsOn: Bool = false
    var insuranceOn: Bool = false
    var dundaOn: Bool = false
    var type: String = ""
    var choice: String = ""
    
    @IBOutlet weak var imgPopover: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    @IBOutlet weak var imageConst: NSLayoutConstraint!
    
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var btnClose: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        if type != "" {
            showAnimate()
        } else {
            loadContents()
        }
    }
    
    func loadContents() {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        lblTitle.text = popTitle
        lblDescription.text = popDesc
        
        lblTitle.sizeToFit()
        lblDescription.sizeToFit()
        
        if choice == "" {
            btnClose.setTitle("Close", for: UIControl.State())
            btnDismiss.isHidden = true
            btnClose.isHidden = false
        } else if choice == "BRITAM" {
            getNotificationSettings()
            btnClose.setTitle("Subscribe", for: UIControl.State())
            btnDismiss.isHidden = false
            btnClose.isHidden = false
        } else if choice == "DUNDA" {
            getNotificationSettings()
            btnClose.setTitle("Join", for: UIControl.State())
            btnDismiss.isHidden = false
            btnClose.isHidden = false
        } else if choice == "OTPPROCEED" || choice == "OFFERPROCEED" {
            btnClose.setTitle("Proceed", for: UIControl.State())
            btnDismiss.isHidden = true
            btnClose.isHidden = false
        }
        
        if let urlImage = URL(string: popLink) {
            URLSession.shared.dataTask(with: urlImage, completionHandler: { (data, response, error) -> Void in
                guard
                    let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                    let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                    let data = data, error == nil,
                    let image = UIImage(data: data)
                    else {
                        DispatchQueue.main.async {
                            self.imageConst.constant = 10
                            UIView.animate(withDuration: 0.3) {
                                self.imgPopover.layoutIfNeeded()
                            }
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                        return
                }
                DispatchQueue.main.async() { () -> Void in
                    UIView.transition(with: self.imgPopover, duration: 0.4, options: .transitionCrossDissolve, animations: {
                        let ratio = (image as UIImage).size.height/(image as UIImage).size.width
                        let width = self.view.bounds.width - 40
                        self.imageConst.constant = CGFloat(Float(ratio) * Float(width))
                         UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        UIView.animate(withDuration: 0.3) {
                            self.imgPopover.layoutIfNeeded()
                        }
                        self.imgPopover.image = image
                    }, completion: { finished in
                        if self.imgPopover.image == nil {
                            self.imageConst.constant = 10
                            UIView.animate(withDuration: 0.3) {
                                self.imgPopover.layoutIfNeeded()
                            }
                        }
                    })
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
                
            }).resume()
        } else {
            self.imageConst.constant = 10
            UIView.animate(withDuration: 0.3) {
                self.imgPopover.layoutIfNeeded()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        self.view.layoutIfNeeded()
    }
    
    func showAnimate(){
        self.view.alpha = 0.25
        self.view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        CATransaction.begin()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
              self.view.transform = CGAffineTransform.identity
        }, completion: nil)
        UIView.animate(withDuration: 0.3 * 0.5, delay: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            self.view.alpha = 1
        }, completion: {(finished: Bool) in if (finished) {
            self.loadContents()
            };
        })
        CATransaction.commit()
    }

    @objc func removeAnimate() {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform.identity
        }
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], animations: {
            self.view.alpha = 0
        }, completion: {(finished: Bool) in if (finished) {
            self.view.removeFromSuperview()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: self.choice), object: nil)
        }
        })
        CATransaction.commit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @IBAction func btnClose(_ sender: UIButton) {
        if choice == "" {
           if type != "" {
               removeAnimate()
           } else {
               dismissSwiftAlert()
           }
        } else if choice == "BRITAM" {
            setNotificationSettings()
        } else if choice == "DUNDA" {
            setNotificationSettings()
        } else if choice == "OTPPROCEED" || choice == "OFFERPROCEED" {
            removeAnimate()
        }
    }
    
    @IBAction func btnDismiss(_ sender: UIButton) {
        if type != "" {
            removeAnimate()
        } else {
            dismissSwiftAlert()
        }
    }
    
    func getNotificationSettings() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadNotifications),name:NSNotification.Name(rawValue: "MYNOTIFICATIONS"), object: nil)
        
        self.view.createLoadingNormal()
        
        let datatosend = "FORMID|SETTINGS|ACTION|GET|"
        
        hc.makeServerCall(sb: datatosend, method: "MYNOTIFICATIONS", switchnum: 0)
    }
    
    @objc func loadNotifications(_ notification: NSNotification) {
        
        self.view.removeAnimation()
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "MYNOTIFICATIONS"), object: nil)
        
        var SETTINGS = ""
        var ALLSETTINGS = ""
        
        if notification.userInfo?["ReturnData"] != nil {
            let ReturnData = notification.userInfo?["ReturnData"] as! String
            let howlong = ReturnData.components(separatedBy: "|")
            for i in (0..<howlong.count) {
                if howlong[i] == "SETTINGS" {
                    SETTINGS = howlong[i+1]
                }
            }
            for i in (0..<howlong.count) {
                if howlong[i] == "ALLSETTINGS" {
                    ALLSETTINGS = howlong[i+1]
                }
            }
        }
        
        if !ALLSETTINGS.contains("I") {
            btnClose.setTitle("Close", for: UIControl.State())
            btnDismiss.isHidden = true
            btnClose.isHidden = false
        }
        
        if SETTINGS.contains("E") {
            emailOn = true
        } else {
            emailOn = false
        }
        
        if SETTINGS.contains("A") {
            pushOn = true
        } else {
            pushOn = false
        }
        
        if SETTINGS.contains("S") {
            smsOn = true
        } else {
            smsOn = false
        }
        
        if SETTINGS.contains("D") {
            dundaOn = true
        } else {
            dundaOn = false
        }
        
        if SETTINGS.contains("I") {
            insuranceOn = true
        } else {
            insuranceOn = false
        }
        
        if choice == "BRITAM" {
            if SETTINGS.contains("I") {
                self.view.removeAnimation()
                btnClose.setTitle("Close", for: UIControl.State())
                btnDismiss.isHidden = true
                btnClose.isHidden = false
                choice = ""
                
                lblDescription.text = lblDescription.text! + "\n\nThe insurance subscription is already active. Head to Profile, then Settings if you need to change this."
                
                // showAlerts(title: "", message: "The insurance subscription is already active. Head to Profile, then Settings if you need to change this.")
            } else {
                insuranceOn = true
            }
            
        }
        
    }
    
    func setNotificationSettings() {
        
        self.view.createLoadingNormal()
        
        var settings = ""
        
        if emailOn {
            settings = "E"
        }
        
        if pushOn {
            settings = settings + "A"
        }
        
        if smsOn {
            settings = settings + "S"
        }
        
        if insuranceOn {
            settings = settings + "I"
        }
        
        if dundaOn {
            settings = settings + "D"
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadSetNotifications),name:NSNotification.Name(rawValue: "SETNOTIFICATIONS"), object: nil)
        
        let datatosend = "FORMID|SETTINGS|ACTION|SET|SETTINGS|\(settings)|"
        
        hc.makeServerCall(sb: datatosend, method: "SETNOTIFICATIONS", switchnum: 0)
    }
    
    @objc func loadSetNotifications(_ notification: NSNotification) {
        
        NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "SETNOTIFICATIONS"), object: nil)
        
        self.view.removeAnimation()
        
        var STATUS = ""
        
        if notification.userInfo?["ReturnData"] != nil {
            let ReturnData = notification.userInfo?["ReturnData"] as! String
            let howlong = ReturnData.components(separatedBy: "|")
            for i in (0..<howlong.count) {
                if howlong[i] == "STATUS" {
                    STATUS = howlong[i+1]
                }
            }
        }
        
        if STATUS == "000" {
            if type != "" {
                removeAnimate()
            } else {
                dismissSwiftAlert()
            }
            if choice == "BRITAM" {
                showAlerts(title: "", message: "Insurance subscription successfully submitted.")
            } else {
                showAlerts(title: "", message: "Thank you for pledging not to Drink and Drive #DundaSmart")
            }
            
        } else {
            showAlerts(title: "", message: "Error updating settings.")
        }
        
    }
}
