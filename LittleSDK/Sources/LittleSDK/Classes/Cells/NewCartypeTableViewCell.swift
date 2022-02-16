//
//  NewCartypeTableViewCell.swift
//  Little
//
//  Created by Gabriel John on 08/05/2019.
//  Copyright © 2019 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class NewCartypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgCarType: UIImageView!
    @IBOutlet weak var lblCarName: UILabel!
    @IBOutlet weak var lblCarInitialPrice: UILabel!
    @IBOutlet weak var lblCarFareEstimate: UILabel!
    @IBOutlet weak var lblCarTime: UILabel!
    @IBOutlet weak var lblIsNew: UILabel!
    @IBOutlet weak var btnViewCarDets: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
