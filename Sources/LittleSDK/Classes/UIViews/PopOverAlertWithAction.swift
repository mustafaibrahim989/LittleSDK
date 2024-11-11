//
//  PopOverAlertWithAction.swift
//  Little
//
//  Created by Gabriel John on 10/06/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import SwiftMessages
import SDWebImage

class PopOverAlertWithAction: MessageView {

    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var imgPopUp: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var imgConstraint: NSLayoutConstraint!
    
    var proceedAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    func loadPopup(title: String, message: String, image: String, action: String) {
        self.layoutIfNeeded()
        lblTitle.text = title
        lblMessage.text = message
        
        layoutIfNeeded()

        imgConstraint.constant = 20
        SDWebImageManager.shared.imageCache.removeImage?(forKey: image, cacheType: .all)
        imgPopUp.sd_setImage(with: URL(string: image)) { (image, error, cache, url) in
            if image != nil {
                let ratio = (image!).size.height/(image!).size.width
                self.imgConstraint.constant = ((self.bounds.width-20) * ratio)
                let totalHeight = 85.0 + self.imgConstraint.constant + self.lblTitle.bounds.height + self.lblMessage.bounds.height
                let window = UIApplication.shared.keyWindow
                let topSafeAreaConst = window?.safeAreaInsets.top ?? 40
                let bottomSafeAreaConst = window?.safeAreaInsets.bottom ?? 50
                let screenHeight = UIScreen.main.bounds.height - topSafeAreaConst - bottomSafeAreaConst - 40
                
                if totalHeight > screenHeight {
                    self.imgConstraint.constant = screenHeight - 85 - self.lblTitle.bounds.height + self.lblMessage.bounds.height
                }
                printVal(object: (self.bounds.width * ratio))
                self.layoutIfNeeded()
            }
        }
        
        btnDismiss.titleLabel?.lineBreakMode = .byWordWrapping
        btnDismiss.titleLabel?.textAlignment = .center
        btnProceed.titleLabel?.lineBreakMode = .byWordWrapping
        btnProceed.titleLabel?.textAlignment = .center
        
    }
    
    @IBAction func proceed() {
        proceedAction?()
    }

    @IBAction func dismiss() {
        cancelAction?()
    }
    
}
