//
//  BreakdownTableViewCell.swift
//  Little Redo
//
//  Created by Gabriel John on 14/05/2018.
//  Copyright © 2018 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class BreakdownTableViewCell: UITableViewCell {
    
    @IBOutlet weak var plusMinusImage: UIImageView!
    @IBOutlet weak var payDescLbl: UILabel!
    @IBOutlet weak var payAmountLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
