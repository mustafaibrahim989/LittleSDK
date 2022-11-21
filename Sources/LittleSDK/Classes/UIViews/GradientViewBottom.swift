//
//  GradientViewBottom.swift
//  
//
//  Created by Little Developers on 21/11/2022.
//

import UIKit

class GradientViewBottom: UIView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    lazy var gradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.frame = self.bounds
        l.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        l.locations = [0.0, 1.0]
        layer.insertSublayer(l, at: 0)
        return l
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(backgroundColor: UIColor) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
