//
//  MovieTicketController.swift
//  
//
//  Created by Little Developers on 22/11/2022.
//

import UIKit
import UIView_Shimmer

class MovieTicketController: UIViewController {

    // MARK: - Properties
    
    var selectedTime: Int = 0
    var selectedTicket: MovieTicket?
    var selectedTheatre: MovieTheatre?
    var selectedMovie: Movie?
    
    var isHistory: Bool = false
    var action: String = ""
    
    var dismissAction: (() -> Void)?
    var skipAction: (() -> Void)?
    var openAction: (() -> Void)?
    var bookCabAction: (() -> Void)?
    
    var myPromoCode: String = ""
    var myPromoAmount: Double = 0.0
    var myPromoType: String = ""
    var myMaxPromoAmount: Double = 0.0
    
    var seatTotalPrice: Double = 0
    
    @IBOutlet weak var imgMovie: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblBookingRef: UILabel!
    @IBOutlet weak var lblMovieProvider: UILabel!
    @IBOutlet weak var lblMovieTime: UILabel!
    @IBOutlet weak var lblMovieTickets: UILabel!
    @IBOutlet weak var lblSeatsBooked: UILabel!
    @IBOutlet weak var lblSeatsBookedBy: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    @IBOutlet weak var totalViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblMoviePrice: UILabel!
    @IBOutlet weak var lblTotalPrice: UILabel!
    @IBOutlet weak var lblMovieOldPrice: UILabel!
    @IBOutlet weak var lblTotalOldPrice: UILabel!
    @IBOutlet weak var lblSnackPrice: UILabel!
    
    @IBOutlet weak var btnSkipSnacks: UIButton!
    @IBOutlet weak var btnOpenMenu: UIButton!
    @IBOutlet weak var btnBookCab: UIButton!
    
    @IBOutlet weak var lblPurchaseDisclaimer: UILabel!
    @IBOutlet weak var btnsStack: UIStackView!
    @IBOutlet weak var snackStack: UIStackView!
    @IBOutlet weak var movieStack: UIStackView!
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Visual Setup
    
    func configureUI() {
        
        let nib = UINib.init(nibName: "OrderSummaryCell", bundle: .module)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        imgMovie.setTemplateWithSubviews(true)
        imgMovie.sd_setImage(with: URL(string: selectedTicket?.movieImageSmall ?? "")) { [self] (image, error, cahe, url) in
            imgMovie.setTemplateWithSubviews(true)
        }
        
        lblName.text = selectedTicket?.movieName ?? ""
        lblMovieProvider.text = selectedTicket?.movieProvider?[0].name ?? ""
        lblMovieTime.text = selectedTicket?.showDate ?? ""
        if selectedTicket?.totalSeats == "1" {
            lblMovieTickets.text = "\(selectedTicket?.totalSeats ?? "1") " + "Ticket".localized
        } else {
            lblMovieTickets.text = "\(selectedTicket?.totalSeats ?? "0") " + "Tickets".localized
        }
        
        var str = ""
        for i in (0..<(selectedTicket?.seats ?? []).count) {
            let each = selectedTicket?.seats?[i]
            if each?.seatNumber == "00" {
                str = str + "0\(i)" + ", "
            } else {
                str = str + (each?.seatNumber ?? "") + ", "
            }
        }
        str = String(str.dropLast())
        str = String(str.dropLast())
        lblSeatsBooked.text = str
        
        tableView.reloadData()
        
        adjustAllHeight()
        
        if isHistory {
            
            lblSeatsBookedBy.text = "Seats booked by \(selectedTicket?.fullName ?? ""):"
            
            lblBookingRef.text = (selectedTicket?.bookingID != nil && selectedTicket?.bookingID != "") ? "Booking Ref: #\(selectedTicket?.bookingID ?? "")" : ""
            lblTotalPrice.text = "\(am.getGLOBALCURRENCY()!) \(formatCurrency(String(selectedTicket?.amount ?? 0.0)))"
            
            bottomViewHeight.constant = 110
            snackStack.isHidden = true
            movieStack.isHidden = true
            lblPurchaseDisclaimer.isHidden = true
            
            btnBookCab.isHidden = false
            btnSkipSnacks.isHidden = true
            btnOpenMenu.isHidden = true
            
        } else {
            
            var price = 0.0
            let totalSeats = Double(selectedTicket?.totalSeats ?? "0")!
            
            if selectedMovie?.movieTimeings != nil {
                price = selectedMovie?.movieTimeings?[selectedTime].ticketPrice ?? 0.0
            } else {
                price = selectedMovie?.showTimes?[selectedTime].ticketPrice ?? 0.0
            }
            
            var discount = 0.00
            var total = seatTotalPrice //price*totalSeats
            var singlediscount = 0.00
            
            if myPromoCode != "" && myPromoAmount != 0.0 {
                var myDiscount = myPromoAmount
                if myPromoType == "P" {
                    myDiscount = (myPromoAmount*price*totalSeats)/100
                    singlediscount = (myPromoAmount*price)/100
                    discount = discount + myDiscount
                } else {
                    discount = myPromoAmount
                    singlediscount = myPromoAmount
                }
            }
            
            if myPromoType == "P" && singlediscount > myMaxPromoAmount {
                singlediscount = myMaxPromoAmount
            }
            
            if myPromoType == "P" && discount > myMaxPromoAmount {
                discount = myMaxPromoAmount
            }
            
            if discount > 0.0 {
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(am.getGLOBALCURRENCY()!) \(price)")
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                lblMovieOldPrice.attributedText = attributeString
                let attributeString1: NSMutableAttributedString =  NSMutableAttributedString(string: "\(am.getGLOBALCURRENCY()!) \(total)")
                attributeString1.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString1.length))
                lblTotalOldPrice.attributedText = attributeString1
                
                price = price - singlediscount
                total = total - discount
                if price < 0 {
                    price = 0
                }
                if total < 0 {
                    total = 0
                }
                
                lblMoviePrice.text = "\(am.getGLOBALCURRENCY()!) \(formatCurrency(String(price)))"
                lblTotalPrice.text = "\(am.getGLOBALCURRENCY()!) \(formatCurrency(String(total)))"
                
            } else {
                lblMovieOldPrice.text = ""
                lblTotalOldPrice.text = ""
                lblMoviePrice.text = "\(am.getGLOBALCURRENCY()!) \(formatCurrency(String(price)))"
                lblTotalPrice.text = "\(am.getGLOBALCURRENCY()!) \(formatCurrency(String(price*totalSeats)))"
            }
            
            
            
            lblSeatsBookedBy.text = "These are the seats you are about to book:".localized
            
            lblPurchaseDisclaimer.text = "You are about to make a purchase of \(lblMovieTickets.text ?? "") to watch \(selectedMovie?.movieName ?? ""). Would you like to add some snacks to enhance your experience?"
            
            bottomViewHeight.constant = 220
            snackStack.isHidden = true
            movieStack.isHidden = false
            lblPurchaseDisclaimer.isHidden = false
            
            btnBookCab.isHidden = true
            btnSkipSnacks.isHidden = false
            btnOpenMenu.isHidden = false
            
            removeNavBar()
        }
        
        showAnimate()
    }
    
    // MARK: - Handlers
    
    func removeNavBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func adjustAllHeight() {
        
        var totalHeight = CGFloat(0)
        for i in (0..<(selectedTicket?.restaurantMenu?.count ?? 0)) {
            let frame = tableView.rectForRow(at: IndexPath(item: i, section: 0))
            totalHeight = totalHeight + (frame.size.height)
        }
        tableViewHeight.constant = totalHeight
        totalViewHeight.constant = 242 + totalHeight + lblName.bounds.height + lblSeatsBooked.bounds.height
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            
        });
    }
    
    @objc func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.view.alpha = 0.0
        }, completion: {(finished: Bool) in if (finished)
            {
            switch self.action {
            case "BOOKCAB":
                self.bookCabAction?();
            case "SKIP":
                self.skipAction?();
            case "OPEN":
                self.openAction?();
            case "DISMISS":
                self.dismissAction?();
            default:
                self.dismissAction?();
            }
                self.view.removeFromSuperview()
            }
        });
    }
    
    @IBAction func btnBookCab(_ sender: UIButton) {
        action = "BOOKCAB"
        removeAnimate()
    }
    
    @IBAction func btnClosePressed(_ sender: UIButton) {
        action = "DISMISS"
        removeAnimate()
    }
    
    @IBAction func btnSkipPressed(_ sender: UIButton) {
        action = "SKIP"
        removeAnimate()
    }
    
    @IBAction func btnOpenPressed(_ sender: UIButton) {
        action = "OPEN"
        removeAnimate()
    }
    
}

extension MovieTicketController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedTicket?.restaurantMenu?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let menuItem = selectedTicket?.restaurantMenu?[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! OrderSummaryCell
        cell.imgMenuImage.setTemplateWithSubviews(true)
        cell.imgMenuImage.sd_setImage(with: URL(string: menuItem?.foodImage ?? "")) { (image, error, cahe, url) in
            cell.imgMenuImage.setTemplateWithSubviews(false)
            if image == nil {
                cell.imgMenuImage.image = UIImage()
                cell.imgMenuImage.isHidden = true
                #warning("imageWidth ")
//                cell.imageWidth.constant = 0
            } else {
                cell.imgMenuImage.isHidden = false
                #warning("imageWidth ")
//                cell.imageWidth.constant = 64
            }
        }
        cell.lblMenuName.text = "\(menuItem?.foodName ?? "")"
        cell.lblMenuAmount.text = "x \(menuItem?.quantity ?? 0)"
        cell.lblMenuNumber.text = ""
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    
}
