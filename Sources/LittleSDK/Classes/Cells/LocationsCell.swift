//
//  LocationsCell.swift
//  Little
//
//  Created by Gabriel John on 13/01/2021.
//  Copyright © 2021 Craft Silicon Ltd. All rights reserved.
//

import UIKit

class LocationsCell: UITableViewCell {

    // MARK: - Properties
    
    var bundle: Bundle?
    
    let mainView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(named: "littleCellBackgrounds")?.withAlphaComponent(0.1)
        v.layer.cornerRadius = 10
        return v
    }()
    
    let locationIconView: UIImageView = {
        
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    let locationNameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(named: "appBlue")
        lbl.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16.0)
        return lbl
    }()
    
    let locationSubLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = UIColor(named: "appBlue")
        lbl.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14.0)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    let btnFavorite: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.setTitle("", for: .normal)
        return btn
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        bundle = Bundle.module
        
        backgroundColor = .clear
        selectionStyle = .none
        
        layoutIfNeeded()
        
        addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        mainView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        mainView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        mainView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        mainView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        
        mainView.addSubview(locationIconView)
        locationIconView.image = getImage(named: "dropoff_location", bundle: bundle!)
        locationIconView.translatesAutoresizingMaskIntoConstraints = false
        locationIconView.centerYAnchor.constraint(equalTo: mainView.centerYAnchor).isActive = true
        locationIconView.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 10).isActive = true
        locationIconView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        locationIconView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        mainView.addSubview(locationNameLabel)
        locationNameLabel.translatesAutoresizingMaskIntoConstraints = false
        locationNameLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10).isActive = true
        locationNameLabel.leftAnchor.constraint(equalTo: locationIconView.rightAnchor, constant: 10).isActive = true
        locationNameLabel.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -10).isActive = true
        
        mainView.addSubview(locationSubLabel)
        locationSubLabel.translatesAutoresizingMaskIntoConstraints = false
        locationSubLabel.topAnchor.constraint(equalTo: locationNameLabel.bottomAnchor).isActive = true
        locationSubLabel.leftAnchor.constraint(equalTo: locationIconView.rightAnchor, constant: 10).isActive = true
        locationSubLabel.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -10).isActive = true
        locationSubLabel.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: -10).isActive = true
        
        mainView.addSubview(btnFavorite)
        btnFavorite.setImage(getImage(named: "Star_Empty", bundle: bundle!), for: .normal)
        btnFavorite.translatesAutoresizingMaskIntoConstraints = false
        btnFavorite.centerYAnchor.constraint(equalTo: locationNameLabel.centerYAnchor).isActive = true
        btnFavorite.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: -15).isActive = true
        btnFavorite.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btnFavorite.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers

}
