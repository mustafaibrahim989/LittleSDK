//
//  MyMovieCell.swift
//  
//
//  Created by Little Developers on 21/11/2022.
//

import UIKit

class MyMovieCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    let shadowView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .littleElevatedViews
        view.dropShadowSubtle()
        return view
    }()
    
    let myContentsView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .littleCellBackgrounds
        return view
    }()
    
    let imgMovie: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.clipsToBounds = true
        return imv
    }()
    
    let gradientView: UIView = {
        let view = GradientViewBottom(backgroundColor: .clear)
        view.clipsToBounds = true
        return view
    }()
    
    let movieTitleLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.numberOfLines = 2
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 15, weight: .bold)
        return lbl
    }()
    
    let movieRatingLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        return lbl
    }()
    
    let movieTimeLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .left
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        return lbl
    }()
    
    let movieTicketsLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.isHidden = true
        lbl.textAlignment = .right
        lbl.font = .systemFont(ofSize: 13, weight: .regular)
        return lbl
    }()

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Handlers
    
    fileprivate func addViews() {
        
        backgroundColor = .clear
        
        addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        shadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        shadowView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        shadowView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        
        addSubview(myContentsView)
        myContentsView.translatesAutoresizingMaskIntoConstraints = false
        myContentsView.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        myContentsView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5).isActive = true
        myContentsView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        myContentsView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        
        myContentsView.addSubview(imgMovie)
        imgMovie.translatesAutoresizingMaskIntoConstraints = false
        imgMovie.topAnchor.constraint(equalTo: myContentsView.topAnchor).isActive = true
        imgMovie.bottomAnchor.constraint(equalTo: myContentsView.bottomAnchor).isActive = true
        imgMovie.leftAnchor.constraint(equalTo: myContentsView.leftAnchor).isActive = true
        imgMovie.rightAnchor.constraint(equalTo: myContentsView.rightAnchor).isActive = true
        
        myContentsView.addSubview(gradientView)
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        gradientView.topAnchor.constraint(equalTo: myContentsView.topAnchor).isActive = true
        gradientView.bottomAnchor.constraint(equalTo: myContentsView.bottomAnchor).isActive = true
        gradientView.leftAnchor.constraint(equalTo: myContentsView.leftAnchor).isActive = true
        gradientView.rightAnchor.constraint(equalTo: myContentsView.rightAnchor).isActive = true
        
        myContentsView.addSubview(movieTimeLabel)
        movieTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        movieTimeLabel.bottomAnchor.constraint(equalTo: myContentsView.bottomAnchor, constant: -5).isActive = true
        movieTimeLabel.leftAnchor.constraint(equalTo: myContentsView.leftAnchor, constant: 5).isActive = true
        movieTimeLabel.rightAnchor.constraint(equalTo: myContentsView.rightAnchor, constant: -5).isActive = true
        
        myContentsView.addSubview(movieRatingLabel)
        movieRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        movieRatingLabel.bottomAnchor.constraint(equalTo: movieTimeLabel.topAnchor, constant: -5).isActive = true
        movieRatingLabel.leftAnchor.constraint(equalTo: myContentsView.leftAnchor, constant: 5).isActive = true
        movieRatingLabel.rightAnchor.constraint(equalTo: myContentsView.rightAnchor, constant: -5).isActive = true
        
        myContentsView.addSubview(movieTitleLabel)
        movieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        movieTitleLabel.bottomAnchor.constraint(equalTo: movieRatingLabel.topAnchor, constant: -5).isActive = true
        movieTitleLabel.leftAnchor.constraint(equalTo: myContentsView.leftAnchor, constant: 5).isActive = true
        movieTitleLabel.rightAnchor.constraint(equalTo: myContentsView.rightAnchor, constant: -5).isActive = true
        
        myContentsView.addSubview(movieTicketsLabel)
        movieTicketsLabel.translatesAutoresizingMaskIntoConstraints = false
        movieTicketsLabel.bottomAnchor.constraint(equalTo: myContentsView.bottomAnchor, constant: -5).isActive = true
        movieTicketsLabel.rightAnchor.constraint(equalTo: myContentsView.rightAnchor, constant: -5).isActive = true
    }

}
