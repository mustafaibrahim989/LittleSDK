//
//  DestinationCell.swift
//  Little
//
//  Created by Gabriel John on 17/07/2019.
//  Copyright © 2019 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class DestinationCell: UITableViewCell {
    
    @IBOutlet weak var imgFavorite: UIImageView!
    @IBOutlet weak var lblDestination: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
