//
//  File.swift
//  
//
//  Created by Boaz James on 30/01/2023.
//

import UIKit

@IBDesignable class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 7.0
    @IBInspectable var rightInset: CGFloat = 7.0
    @IBInspectable var labelCornerRadius: CGFloat = 0
    @IBInspectable var labelBorderWidth: CGFloat = 0.0
    @IBInspectable var labelBorderColor: UIColor = UIColor.littleSecondaryLabelColor
    @IBInspectable var showTopLeftRadius: Bool = true
    @IBInspectable var showTopRightRadius: Bool = true
    @IBInspectable var showBottomLeftRadius: Bool = true
    @IBInspectable var showBottomRightRadius: Bool = true
    
    override func layoutSubviews() {
        layer.cornerRadius = labelCornerRadius
        layer.masksToBounds = true
        layer.borderWidth = labelBorderWidth
        layer.borderColor = labelBorderColor.cgColor
        var corners: [Corner] = []
        if showTopRightRadius {
            corners.append(.topRight)
        }
        
        if showTopLeftRadius {
            corners.append(.topLeft)
        }
        
        if showBottomLeftRadius {
            corners.append(.bottomLeft)
        }
        
        if showBottomRightRadius {
            corners.append(.bottomRight)
        }
        
        layer.maskedCorners = CACornerMask(rawValue: createMask(corners: corners))
    }

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            // ensures this works within stack views if multi-line
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
    
    private func createMask(corners: [Corner]) -> UInt {
        return corners.reduce(0, { (a, b) -> UInt in
            return a + parseCorner(corner: b).rawValue
        })
    }
    
    enum Corner:Int {
        case bottomRight = 0,
        topRight,
        bottomLeft,
        topLeft
    }
    
    private func parseCorner(corner: Corner) -> CACornerMask.Element {
        let corners: [CACornerMask.Element] = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        return corners[corner.rawValue]
    }
}
