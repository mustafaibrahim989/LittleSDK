//
//  OrderSummaryCell.swift
//  Little
//
//  Created by Gabriel John on 03/04/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class OrderSummaryCell: UITableViewCell {

    
    @IBOutlet weak var imgMenuImage: UIImageView!
    @IBOutlet weak var lblMenuName: UILabel!
    @IBOutlet weak var lblMenuAmount: UILabel!
    @IBOutlet weak var lblMenuNumber: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
