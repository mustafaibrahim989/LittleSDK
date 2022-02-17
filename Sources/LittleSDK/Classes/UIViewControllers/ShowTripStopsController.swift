//
//  ShowTripStopsController.swift
//  Little
//
//  Created by Gabriel John on 18/11/2020.
//  Copyright © 2020 Craft Silicon Ltd. All rights reserved.
//

import UIKit

private let reuseId = "stopsCell"

public class ShowTripStopsController: UIViewController {

    // MARK: - Properties
    
//    var sdkBundle: Bundle?
    
    var tableView: UITableView!
    
    var tripDropOffDetails: [TripDropOffDetail] = []
    
    // MARK: - Init
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        sdkBundle = Bundle(for: Self.self)
        
        let doneStopsArr = tripDropOffDetails.filter({ $0.endedOn == "Y"})
        
        configureUI(pageTitle: "Trip Stops (\(doneStopsArr.count)/\(tripDropOffDetails.count))")
        configureTableView()
    }
    
    // MARK: - Handlers
    
    @objc func btnCallPressed(_ sender: UIButton) {
        let stop = tripDropOffDetails[sender.tag]
        if let url = URL(string: "tel://\(stop.contactMobileNumber ?? "")"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil
        )}
    }
    
    func configureUI(pageTitle: String) {
        
        view.backgroundColor = .white
        
        navigationItem.title = pageTitle
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: getImage(named: "icon_close", bundle: nil)!.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(handleDismiss))
    }
    
    func configureTableView() {
        
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib.init(nibName: "StopsCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: reuseId)
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        
        tableView.reloadData()
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Server Calls

}

extension ShowTripStopsController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tripDropOffDetails.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let stop = tripDropOffDetails[indexPath.item]
        
        let color = cn.littleSDKThemeColor
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as! StopsCell
        
        if tripDropOffDetails.count == 1 {
            cell.overView.isHidden = true
            cell.underView.isHidden = true
        } else if indexPath.item == 0 {
            cell.overView.isHidden = true
            cell.underView.isHidden = false
        } else if indexPath.item == (tripDropOffDetails.count - 1) {
            cell.overView.isHidden = false
            cell.underView.isHidden = true
        } else {
            cell.overView.isHidden = false
            cell.underView.isHidden = false
        }
        if stop.endedOn == "Y" {
            cell.overView.backgroundColor = color
            cell.imgSelected.image = getImage(named: "deliver_check", bundle: nil)
            if indexPath.item < tripDropOffDetails.count-1 {
                let nextStop = tripDropOffDetails[indexPath.item+1]
                if nextStop.endedOn == "Y" {
                    cell.underView.backgroundColor = color
                } else {
                    cell.underView.backgroundColor = .lightGray
                }
            }
        } else {
            cell.overView.backgroundColor = .lightGray
            cell.underView.backgroundColor = .lightGray
            cell.imgSelected.image = getImage(named: "deliver_uncheck", bundle: nil)
        }
        
        cell.btnCall1.isHidden = true
        cell.btnCall2.isHidden = true
        
        cell.btnCall1.tag = indexPath.item
        cell.btnCall2.tag = indexPath.item
        
        cell.btnCall1.addTarget(self, action: #selector(btnCallPressed(_:)), for: .touchUpInside)
        cell.btnCall2.addTarget(self, action: #selector(btnCallPressed(_:)), for: .touchUpInside)
        
        if stop.contactName != "" {
            if stop.contactMobileNumber != "" {
                cell.btnCall2.setTitle("Call (\((stop.contactName ?? "").capitalized))", for: .normal)
                
                cell.btnCall1.isHidden = false
                cell.btnCall2.isHidden = false
                
            }
        } else if stop.contactMobileNumber != "" {
            cell.btnCall2.setTitle("Call (\((stop.contactMobileNumber ?? "").capitalized))", for: .normal)
            
            cell.btnCall1.isHidden = false
            cell.btnCall2.isHidden = false
        }
        
        cell.lblEvent.text = stop.dropOffAddress ?? ""
        cell.lblInstructions.text = stop.notes ?? ""
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
}
