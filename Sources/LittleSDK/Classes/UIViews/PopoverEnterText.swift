//
//  PopoverEnterText.swift
//  Little
//
//  Created by Gabriel John on 13/07/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import SwiftMessages

class PopoverEnterText: MessageView {
    
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var txtPopupText: UITextField!
    
    var isFromStaff: Bool?
    
    var proceedAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    func loadPopup(title: String, message: String, image: String, placeholderText: String, type: String) {
        lblTitle.text = title
        lblMessage.text = message
        txtPopupText.placeholder = placeholderText
        self.layoutIfNeeded()
        switch type {
        case "N":
            txtPopupText.keyboardType = .numberPad
        default:
            txtPopupText.keyboardType = .default
        }
        if !(isFromStaff ?? false) {
            txtPopupText.becomeFirstResponder()
        }
        btnDismiss.titleLabel?.lineBreakMode = .byWordWrapping
        btnDismiss.titleLabel?.textAlignment = .center
        btnProceed.titleLabel?.lineBreakMode = .byWordWrapping
        btnProceed.titleLabel?.textAlignment = .center
    }
    
    @IBAction func proceed() {
        txtPopupText.resignFirstResponder()
        proceedAction?()
    }

    @IBAction func dismiss() {
        txtPopupText.resignFirstResponder()
        cancelAction?()
    }
    
}
