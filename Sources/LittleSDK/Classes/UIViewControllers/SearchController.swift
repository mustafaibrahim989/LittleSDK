//
//  SearchController.swift
//  Little
//
//  Created by Gabriel John on 08/05/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit

public class SearchController: UIViewController, UITextFieldDelegate {

    let am = SDKAllMethods()
    let hc = SDKHandleCalls()
    
    var selectedRestaurant: Restaurant?
    
    @IBOutlet weak var lblMenu: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtSearch.becomeFirstResponder()
        
        self.view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(removeAnimate))
        view.addGestureRecognizer(tap)
        
        showAnimate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        if selectedRestaurant != nil {
            if selectedRestaurant?.restaurantName?.last == "s" {
                lblMenu.text = "Search \(selectedRestaurant?.restaurantName ?? "")' Menu"
                txtSearch.placeholder = "Search \(selectedRestaurant?.restaurantName ?? "")' Menu"
            } else {
                lblMenu.text = "Search \(selectedRestaurant?.restaurantName ?? "")'s Menu"
                txtSearch.placeholder = "Search \(selectedRestaurant?.restaurantName ?? "")'s Menu"
            }
        } else {
            lblMenu.text = "Search restaurants"
            txtSearch.placeholder = "Search restaurants"
        }
        
    }
    
    func showAnimate()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(removeAnimate),name:NSNotification.Name(rawValue: "REMOVESEARCH"), object: nil)
        self.mainView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.mainView.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.mainView.alpha = 1.0
            self.mainView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        });
    }
    
    @objc func removeAnimate(){
        UIView.animate(withDuration: 0.25, animations: {
            self.mainView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.mainView.alpha = 0.0
        }, completion: {(finished: Bool) in if (finished) {
            NotificationCenter.default.removeObserver(self,name:NSNotification.Name(rawValue: "REMOVESEARCH"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "FROMSEARCH"), object: nil)
            self.endEditSDK()
            self.view.removeFromSuperview()
            }
        });
    }
    
    @IBAction func btnDismissPressed(_ sender: UIButton) {
        removeAnimate()
    }
    
    @IBAction func txtSearchChanged(_ sender: UITextField) {
        if sender.text != "" {
            let dic = ["data": "\(sender.text!)"]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FROMSEARCH"), object: nil, userInfo: dic)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "FROMSEARCH"), object: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       removeAnimate()
       return true
    }
    
    @IBAction func searchMenuEnded(_ sender: UITextField) {
        removeAnimate()
    }
    
    /*
     
     // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
