//
//  MenuAddonsCell.swift
//  Little
//
//  Created by Gabriel John on 27/06/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class MenuAddonsCell: UITableViewCell {
    
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var lblMenuName: UILabel!
    @IBOutlet weak var lblExtrasWithOrder: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var stepperMenu: UIStepper!
    @IBOutlet weak var lblTotalAmount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
