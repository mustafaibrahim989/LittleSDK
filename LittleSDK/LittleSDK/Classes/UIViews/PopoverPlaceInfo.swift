//
//  PopoverEnterText.swift
//  Little
//
//  Created by Gabriel John on 13/07/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import SwiftMessages

class PopoverPlaceInfo: MessageView {
    
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var btnProceed: UIButton!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var txtPopupText: UITextField!
    @IBOutlet weak var lblAddInstructions: UILabel!
    @IBOutlet weak var txtAddInstructions: UITextView!
    
    var proceedAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    func loadPopup(placeName: String, image: String) {
        lblTitle.text = placeName
        lblMessage.text = "Contacts for \(placeName) (Optional)"
        lblAddInstructions.text = "Additional information for \(placeName) (Optional)"
        txtPopupText.becomeFirstResponder()
    }
    
    @IBAction func proceed() {
        proceedAction?()
    }

    @IBAction func dismiss() {
        cancelAction?()
    }
    
}
