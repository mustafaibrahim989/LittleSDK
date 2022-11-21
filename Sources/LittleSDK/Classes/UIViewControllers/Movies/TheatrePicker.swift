//
//  File.swift
//  
//
//  Created by Little Developers on 21/11/2022.
//

import UIKit
import PanModal

class TheatrePicker: UIViewController {

    // MARK: - Properties
    
    var viewHeight: CGFloat = 0
    
    var itemArray: [ShowTime] = []
    var movieName: String?
    
    var lblDescription: UILabel!
    var choicesStack: UIStackView!
    
    var selectedShowtime: ShowTime?
    
    var proceedAction: (() -> Void)?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Visual Setup
    
    func configureUI() {
        
        view.backgroundColor =  .littleElevatedViews
        
        lblDescription = UILabel()
        lblDescription.text = "Where would you prefer to watch '\((movieName ?? "movie").capitalized)'?"
        lblDescription.font = .systemFont(ofSize: 15, weight: .medium)
        lblDescription.textAlignment = .center
        lblDescription.numberOfLines = 0
        lblDescription.textColor = .darkGray
        lblDescription.numberOfLines = 0
        
        view.addSubview(lblDescription)
        lblDescription.translatesAutoresizingMaskIntoConstraints = false
        lblDescription.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        lblDescription.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        lblDescription.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        
        choicesStack = UIStackView()
        choicesStack.axis  = NSLayoutConstraint.Axis.vertical
        choicesStack.alignment = UIStackView.Alignment.center
        choicesStack.spacing = 10
        
        view.addSubview(choicesStack)
        
        choicesStack.translatesAutoresizingMaskIntoConstraints = false
        choicesStack.topAnchor.constraint(equalTo: lblDescription.bottomAnchor, constant: 20).isActive = true
        choicesStack.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        choicesStack.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        for i in (0..<itemArray.count) {
            
            let each = itemArray[i]
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(btnProceedPressed(_:)))
            tap.accessibilityHint = each.movieProviderID
            
            let optionView = UIView()
            optionView.isUserInteractionEnabled = true
            optionView.addGestureRecognizer(tap)
            optionView.backgroundColor =  .littleElevatedViews
            
            optionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            optionView.widthAnchor.constraint(equalToConstant: self.view.bounds.width).isActive = true
            
            choicesStack.addArrangedSubview(optionView)
            
            let icon = UIImageView()
            icon.image = UIImage(named: "no_movies")
            icon.contentMode = .scaleAspectFit
            
            optionView.addSubview(icon)
            
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.centerYAnchor.constraint(equalTo: optionView.centerYAnchor).isActive = true
            icon.leftAnchor.constraint(equalTo: optionView.leftAnchor, constant: 20).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 25).isActive = true
            icon.widthAnchor.constraint(equalToConstant: 25).isActive = true
            
            let lblPayment = UILabel()
            lblPayment.text = each.name ?? ""
            lblPayment.font = .systemFont(ofSize: 16, weight: .bold)
            lblPayment.textAlignment = .left
            lblPayment.textColor = .littleBlue
            lblPayment.numberOfLines = 0
            
            optionView.addSubview(lblPayment)
            
            lblPayment.translatesAutoresizingMaskIntoConstraints = false
            lblPayment.centerYAnchor.constraint(equalTo: optionView.centerYAnchor).isActive = true
            lblPayment.leftAnchor.constraint(equalTo: icon.rightAnchor, constant: 20).isActive = true
            lblPayment.rightAnchor.constraint(equalTo: optionView.rightAnchor, constant: -20).isActive = true
            
            let img = UIImageView()
            img.image = UIImage(named: "next")
            img.contentMode = .scaleAspectFit
            
            optionView.addSubview(img)
            
            img.translatesAutoresizingMaskIntoConstraints = false
            img.centerYAnchor.constraint(equalTo: optionView.centerYAnchor).isActive = true
            img.rightAnchor.constraint(equalTo: optionView.rightAnchor, constant: -20).isActive = true
            img.heightAnchor.constraint(equalToConstant: 25).isActive = true
            img.widthAnchor.constraint(equalToConstant: 25).isActive = true
            
        }
        
    }
    
    // MARK: - Handlers
    
    @objc func btnProceedPressed(_ sender: UIButton) {
        self.selectedShowtime = itemArray.first(where: { $0.movieProviderID == sender.accessibilityHint})
        self.dismiss(animated: true) {
            self.proceedAction?()
        }
    }
    
    // MARK: - Server Calls

}

extension TheatrePicker: PanModalPresentable {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .maxHeightWithTopInset(UIScreen.main.bounds.height - viewHeight)
    }

    var anchorModalToLongForm: Bool {
        return false
    }
}

