//
//  NewImgLblTableViewCell.swift
//  Little
//
//  Created by Gabriel John on 10/05/2019.
//  Copyright © 2019 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class NewImgLblTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgMenuItem: UIImageView!
    @IBOutlet weak var btnMenuItem: UIButton!
    @IBOutlet weak var imgCheckedItem: UIImageView!
    @IBOutlet weak var imgUnverified: UIImageView!
    @IBOutlet weak var btnVerifiedInfo: UIButton!
    @IBOutlet weak var btnConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
