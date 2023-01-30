//
//  File.swift
//  
//
//  Created by Boaz James on 30/01/2023.
//

import UIKit

@IBDesignable
class PickerView: UIView {
    
    private(set) var lbl: UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.textColor = .littleLabelColor
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    private(set) var lblValue: PaddingLabel = {
        let lbl = PaddingLabel()
        lbl.font = .systemFont(ofSize: 16, weight: .medium)
        lbl.textColor = .littleSecondaryLabelColor
        lbl.numberOfLines = 1
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.leftInset = 10
        lbl.rightInset = 50
        lbl.labelCornerRadius = 10
        lbl.isUserInteractionEnabled = true
        lbl.labelBorderWidth = 1
        lbl.backgroundColor = .littleElevatedViews
        lbl.labelBorderColor = .lightGray
        return lbl
    }()
    
    private(set) var chevron: UIImageView = {
        let view = UIImageView()
        view.image = getImage(named: "drop_down")
//        view.tintColor = .primary
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    @IBInspectable
    private(set) var title: String = ""
    
    @IBInspectable
    private(set) var value: String = ""
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lbl)
        self.addSubview(lblValue)
        self.addSubview(chevron)
        
        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lbl.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            lbl.topAnchor.constraint(equalTo: self.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            lblValue.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lblValue.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            lblValue.topAnchor.constraint(equalTo: lbl.bottomAnchor, constant: 5),
            lblValue.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            lblValue.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        NSLayoutConstraint.activate([
            chevron.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15),
            chevron.centerYAnchor.constraint(equalTo: lblValue.centerYAnchor),
            chevron.heightAnchor.constraint(equalToConstant: 13),
            chevron.widthAnchor.constraint(equalToConstant: 13)
        ])
    }
    
    func setText(_ text: String, value: String) {
        lblValue.text = text.isEmpty ? lbl.text : text
        self.value = value
        self.title = text
        
        lblValue.textColor = text.isEmpty ? .littleSecondaryLabelColor : .littleLabelColor
    }
}
