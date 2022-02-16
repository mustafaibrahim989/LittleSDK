//
//  ChatCell.swift
//  Little
//
//  Created by Gabriel John on 11/09/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class ChatFromCell: UITableViewCell {
    
    var sdkBundle: Bundle?
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var imgBubble: UIImageView!
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    func changeImage(_ name: String) {
        sdkBundle = Bundle(for: Self.self)
        guard let image = getImage(named: name, bundle: sdkBundle!) else { return }
        imgBubble.image = image
            .resizableImage(withCapInsets:
                UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21),
                                    resizingMode: .stretch)
            .withRenderingMode(.alwaysTemplate)
    }
}
