//
//  StopsCell.swift
//  Little
//
//  Created by Gabriel John on 18/11/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class StopsCell: UITableViewCell {

    @IBOutlet weak var lblEvent: UILabel!
    @IBOutlet weak var lblInstructions: UILabel!
    @IBOutlet weak var btnCall1: UIButton!
    @IBOutlet weak var btnCall2: UIButton!
    @IBOutlet weak var overView: UIView!
    @IBOutlet weak var underView: UIView!
    @IBOutlet weak var imgSelected: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
