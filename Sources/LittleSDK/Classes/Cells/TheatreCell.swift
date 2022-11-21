//
//  TheatreCell.swift
//  
//
//  Created by Little Developers on 21/11/2022.
//

import UIKit

class TheatreCell: UITableViewCell {

    @IBOutlet weak var imgTheatre: UIImageView!
    @IBOutlet weak var lblTheatre: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var theatreView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fadeImage() {
        theatreView.layoutIfNeeded()
        let gradientMaskLayer = CAGradientLayer()
        gradientMaskLayer.frame = theatreView.bounds
        gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.white.cgColor, UIColor.white.cgColor, UIColor.clear.cgColor]
        imgTheatre.layer.mask = gradientMaskLayer
        self.layoutIfNeeded()
    }
    
}
