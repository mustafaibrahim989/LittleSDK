//
//  NewPreferredTableViewCell.swift
//  Little
//
//  Created by Gabriel John on 10/05/2019.
//  Copyright © 2019 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class NewPreferredTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgDriverPic: UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverDistance: UILabel!
    @IBOutlet weak var lblDriverRating: UILabel!
    
    @IBOutlet weak var lblDriverAboutMe: UILabel!
    @IBOutlet weak var imgAboutMe: UIImageView!
    @IBOutlet weak var driverNameConst: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
