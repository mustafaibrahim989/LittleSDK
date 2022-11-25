//
//  DeliveryCell.swift
//  Little
//
//  Created by Gabriel John on 04/06/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class DeliveryCell: UITableViewCell {

    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblEvent: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnRate: UIButton!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var overView: UIView!
    @IBOutlet weak var underView: UIView!
    @IBOutlet weak var imgSelected: UIImageView!
    
    @IBOutlet weak var btnCallWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnRateWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTopSuperConstraint: NSLayoutConstraint!
    @IBOutlet weak var eventTopConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
