//
//  ExtraFieldsCell.swift
//  Timiza
//
//  Created by Gabriel John on 12/05/2020.
//  Copyright © 2020 Craft Silicon Limited. All rights reserved.
//

import UIKit

class KYCCell: UITableViewCell {

    @IBOutlet weak var lblFieldTitle: UILabel!
    @IBOutlet weak var txtField: UITextField!
    @IBOutlet weak var txtIncentive: UILabel!
    @IBOutlet weak var imgDropDown: UIImageView!
    @IBOutlet weak var btnContacts: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
