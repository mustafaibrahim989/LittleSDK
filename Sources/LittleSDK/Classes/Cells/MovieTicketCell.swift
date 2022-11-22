//
//  MovieTicketCell.swift
//  
//
//  Created by Little Developers on 22/11/2022.
//

import UIKit

class MovieTicketCell: UITableViewCell {
    
    var itemsArr: [RestaurantMenu] = []
    
    @IBOutlet weak var lblMovieName: UILabel!
    @IBOutlet weak var lblTicketNo: UILabel!
    @IBOutlet weak var lblTheatreName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    func setupTableView() {
        
        let nib = UINib.init(nibName: "TicketAddonCell", bundle: .module)
        self.tableView.register(nib, forCellReuseIdentifier: "cell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.reloadData()
        
        self.tableHeight.constant = CGFloat(itemsArr.count * 35)
        
        self.layoutIfNeeded()
    }
    
}

extension MovieTicketCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = itemsArr[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TicketAddonCell
        
        cell.lblAddonName.text = "◉  \(item.foodName ?? "")"
        cell.lblQuantity.text = "x \(item.quantity ?? 0)"
        
        cell.selectionStyle = .none
        return cell
        
    }
    
    
}
