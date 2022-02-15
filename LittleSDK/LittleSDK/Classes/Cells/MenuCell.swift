//
//  MenuCell.swift
//  Little
//
//  Created by Gabriel John on 01/04/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var lblMenuName: UILabel!
    @IBOutlet weak var lblMenuAmount: UILabel!
    @IBOutlet weak var lblMenuWasAmount: UILabel!
    @IBOutlet weak var lblExtrasWithOrder: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var stepperMenu: UIStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
