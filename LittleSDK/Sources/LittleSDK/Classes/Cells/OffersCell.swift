//
//  OffersCell.swift
//  Little
//
//  Created by Gabriel John on 24/07/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit
import UIView_Shimmer

class OffersCell: UICollectionViewCell, ShimmeringViewProtocol {

    @IBOutlet weak var imgShopImage: UIImageView!
    @IBOutlet weak var lblShopName: UILabel!
    @IBOutlet weak var lblShopLocation: UILabel!
    @IBOutlet weak var lblShopDistance: UILabel!
    @IBOutlet weak var lblShopDelivery: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblClosed: UILabel!
    @IBOutlet weak var closedView: UIVisualEffectView!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblAverageTime: UILabel!
    @IBOutlet weak var lblOfferText: UILabel!
    
    @IBOutlet weak var backGround: UIView!
    @IBOutlet weak var foreGround: UIView!
    
    var shimmeringAnimatedItems: [UIView] {
        [
        imgShopImage,
        lblShopName,
        lblShopLocation,
        lblShopDistance,
        lblShopDelivery,
        lblRating,
        lblClosed,
        closedView,
        lblCategory,
        lblAverageTime
        ]
    }

}
