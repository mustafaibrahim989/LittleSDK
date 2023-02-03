//
//  File.swift
//  
//
//  Created by Little Developers on 17/11/2022.
//

import UIKit

class NewRatingViewController: UIViewController, UITextViewDelegate, FloatRatingViewDelegate {
    
    var driverImage: String?
    var driverName: String?
    
    var isMerchant: Bool = false
    var showRating = true
    
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var imgDriverImage: UIImageView!
    
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var txtCommentsShared: UITextView!
    
    @IBOutlet weak var floatRatingView: FloatRatingView!
    
    @IBOutlet weak var ratingViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.littleElevatedViews.withAlphaComponent(0.75)
        
        if !showRating {
            ratingViewHeightConstraint.constant = 0
        }
        
        
        let color = UIColor(hex: "#FFCC01")
        
        if showRating {
            lblDriverName.text = "Rate".localized + " \((driverName ?? "").capitalized)"
        } else {
            lblDriverName.text = "Report trip issue".localized
        }
        imgDriverImage.sd_setImage(with: URL(string: driverImage ?? ""), placeholderImage: UIImage(named: "default"))
        lblPlaceHolder.text = "Share your experience you had with your driver to help us serve you better and improve our services".localized
        
        // Required float rating view params
        self.floatRatingView.emptyImage = getImage(named: "Star_Empty", bundle: Bundle.module)
        self.floatRatingView.fullImage = getImage(named: "Star_Full", bundle: Bundle.module)
        // Optional params
        self.floatRatingView.tintColor = color
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIView.ContentMode.scaleAspectFit
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 1
        self.floatRatingView.rating = 0
        self.floatRatingView.editable = true
        self.floatRatingView.halfRatings = true
        self.floatRatingView.floatRatings = false
        
        showAnimate()
    }
    
    @IBAction func btnSubmitRating(_ sender: UIButton) {
        let text = txtCommentsShared.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if showRating  {
            if self.floatRatingView.rating > 0 {
                let dic = ["data": "\(NSString(format: "%.1f", self.floatRatingView.rating)):::\(txtCommentsShared.text!)"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RATECANCEL"), object: nil, userInfo: dic)
                removeAnimate()
            } else {
                showAlerts(title: "", message: "Kindly ensure you rate \((driverName ?? "").capitalized) to proceed.")
            }
        } else {
            if text.isEmpty {
                showAlerts(title: "", message: "Please enter your comment".localized)
            } else {
                let dic = ["data": ":::\(txtCommentsShared.text ?? "")"]
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RATECANCEL"), object: nil, userInfo: dic)
                removeAnimate()
            }
        }
    }
    
    @IBAction func btnCancel(_ sender: UIButton) {
        let dic = ["data": ""]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RATECANCEL"), object: nil, userInfo: dic)
        removeAnimate()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        lblPlaceHolder.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text != "" {
            lblPlaceHolder.isHidden = true
        } else {
            lblPlaceHolder.isHidden = false
        }
    }
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        printVal(object: NSString(format: "%.1f", self.floatRatingView.rating) as String)
    }
    
    func showAnimate(){
        self.view.alpha = 0.25
        self.view.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        CATransaction.begin()
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
              self.view.transform = CGAffineTransform.identity
        }, completion: nil)
        UIView.animate(withDuration: 0.3 * 0.5, delay: 0, options: [.beginFromCurrentState, .curveLinear, .allowUserInteraction], animations: {
            self.view.alpha = 1
        }, completion: nil)
        CATransaction.commit()
    }

    @objc func removeAnimate() {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.view.alpha = 1
            self.view.transform = CGAffineTransform.identity
        }
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: nil)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseIn, .allowUserInteraction], animations: {
            self.view.alpha = 0
        }, completion: {(finished: Bool) in if (finished) {
            NotificationCenter.default.removeObserver(self, name:NSNotification.Name(rawValue: "CloseCreate"), object: nil)
            self.view.removeFromSuperview()
        }
        })
        CATransaction.commit()
    }
}
