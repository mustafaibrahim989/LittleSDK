//
//  CardViewController.swift
//  CardViewAnimation
//
//  Created by Brian Advent on 26.10.18.
//  Copyright © 2018 Brian Advent. All rights reserved.
//

import UIKit

public class CardViewController: UIViewController {

    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var popularDropOffView: UIView!
    @IBOutlet weak var suggestedPlacesView: UIView!
    @IBOutlet weak var selectDestinationView: UIView!
    @IBOutlet weak var carTypeView: UIView!
    @IBOutlet weak var carTypeLoadingView: UIView!
    @IBOutlet weak var confirmRequestView: UIView!
    @IBOutlet weak var confirmRequestPayments: UIView!
    @IBOutlet weak var confirmRequestPromo: UIView!
    @IBOutlet weak var confirmRequestPreferred: UIView!
    @IBOutlet weak var promoVerifiedView: UIView!
    @IBOutlet weak var corporateView: UIView!
    @IBOutlet weak var requestingLoadingView: UIView!
    @IBOutlet weak var makerCheckerView: UIView!
    @IBOutlet weak var viewCarToRequest: UIView!
    @IBOutlet weak var selectDestinationLoadingView: UIView!
    @IBOutlet weak var parcelTypeView: UIView!
    @IBOutlet weak var smallView: UIView!
    @IBOutlet weak var mediumView: UIView!
    @IBOutlet weak var noInteractionView: UIView!
    @IBOutlet weak var driveMeView: UIView!
    
    @IBOutlet weak var txtPromo: UITextField!
    
    @IBOutlet weak var carTypeTableView: UITableView!
    @IBOutlet weak var paymentOptionsTableView: UITableView!
    @IBOutlet weak var preferredDriverTableView: UITableView!
    @IBOutlet weak var popularDropOffTable: UITableView!
    
    @IBOutlet weak var suggestedPlacesCollectionView: UICollectionView!
    @IBOutlet weak var driveMeCarsCollectionView: UICollectionView!
    
    @IBOutlet weak var btnSearchDestination: UIButton!
    @IBOutlet weak var btnPlacePinOnMap: UIButton!
    @IBOutlet weak var btnSkipDestinationSelect: UIButton!
    @IBOutlet weak var btnCancelDestination: UIButton!
    @IBOutlet weak var btnPayment: UIButton!
    @IBOutlet weak var btnPromoCode: UIButton!
    @IBOutlet weak var btnPreferredDriver: UIButton!
    @IBOutlet weak var btnRequest: UIButton!
    @IBOutlet weak var btnCorporateDepartment: UIButton!
    @IBOutlet weak var btnPickup: UIButton!
    @IBOutlet weak var btnPickupCancel: UIButton!
    @IBOutlet weak var btnDestination: UIButton!
    @IBOutlet weak var btnValidatePromo: UIButton!
    @IBOutlet weak var btnAddPromoText: UIButton!
    @IBOutlet weak var btnSubmitToApprover: UIButton!
    @IBOutlet weak var btnParcelProceedRequest: UIButton!
    @IBOutlet weak var btnParcelSelect: UIButton!
    @IBOutlet weak var btnGoodsSelect: UIButton!
    @IBOutlet weak var btnDriveMeProceedRequest: UIButton!
    
    @IBOutlet weak var indiviCorporateSeg: UISegmentedControl!
    @IBOutlet weak var homeOfficeSeg: UISegmentedControl!
    @IBOutlet weak var transmissionTypeSeg: UISegmentedControl!
    
    @IBOutlet weak var lblPromoVerified: UILabel!
    @IBOutlet weak var lblNoDestinationHistory: UILabel!
    @IBOutlet weak var lblPayments: UILabel!
    @IBOutlet weak var lblPromoCode: UILabel!
    @IBOutlet weak var lblPreferredDriver: UILabel!
    @IBOutlet weak var lblCarToRequest: UILabel!
    @IBOutlet weak var lblFareToPay: UILabel!
    @IBOutlet weak var lblMinutesToWait: UILabel!
    @IBOutlet weak var lblPaymentMode: UILabel!
    @IBOutlet weak var lblRequestingText: UILabel!
    @IBOutlet weak var lblParcelCarTypeCost: UILabel!
    @IBOutlet weak var lblParcelCarTypeName: UILabel!
    @IBOutlet weak var lblGoodsCartypeName: UILabel!
    @IBOutlet weak var lblGoodsCarTypeCost: UILabel!
    @IBOutlet weak var lblDriveMeCarType: UILabel!
    @IBOutlet weak var lblDriveMeDistance: UILabel!
    @IBOutlet weak var lblDriveMeCost: UILabel!
    @IBOutlet weak var lblDriveMeTime: UILabel!
    
    @IBOutlet weak var imgUp: UIImageView!
    @IBOutlet weak var imgDown: UIImageView!
    @IBOutlet weak var imgPreferred: UIImageView!
    @IBOutlet weak var imgCarToRequest: UIImageView!
    @IBOutlet weak var imgParcelCartype: UIImageView!
    @IBOutlet weak var imgGoodsCartype: UIImageView!
    @IBOutlet weak var imgSmallCheck: UIImageView!
    @IBOutlet weak var imgMediumCheck: UIImageView!
    @IBOutlet weak var imgDriveMe: UIImageView!
    
    @IBOutlet weak var corporateViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var carTypesTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var preferredTableConstraint: NSLayoutConstraint!
    @IBOutlet weak var parcelViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var requestingViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var paymentTableConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var txtParcelName: UITextField!
    @IBOutlet weak var txtReceiversName: UITextField!
    @IBOutlet weak var txtReceiversNumber: UITextField!
    @IBOutlet weak var txtReceiversAddress: UITextField!
    
    @IBOutlet weak var parcelScrollView: UIScrollView!
    
    
}
