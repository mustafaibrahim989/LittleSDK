//
//  ScreenController.swift
//  
//
//  Created by Little Developers on 21/11/2022.
//

import UIKit
import Alamofire
import SwiftMessages

class ScreenController: UIViewController {

    private let am = SDKAllMethods()
    private let hc = SDKHandleCalls()
    
    var selectedTime: Int = 0
    var selectedDate: String = ""
    
    var paymentModes: [Balance] = []
    var seatRowArr: [SeatRow] = []
    var seatsArr: [String] = []
    var priceArr: [String] = []
    var codeArr: [String] = []
    var selectedSeatArr: [Int] = []
    var selectedManualArr: [Int] = []
    var highestArr: String = ""
    var highestIndex: Int = 0
    var selectedMovie: Movie?
    var selectedTheatre: MovieTheatre?
    var selectedSeats: [SelectedSeat] = []
    var allocatedSeats: [AllocatedSeat] = []
    var markup: Int = 0
    
    var seatTotalPrice: Double = 0
    var isPopAction: Bool = false
    
    var myPromoCode: String = ""
    var myPromoAmount: Double = 0.0
    var myPromoType: String = ""
    var myMaxPromoAmount: Double = 0.0
    
    var myDisclaimerMessage: String = ""
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    lazy var seatCollection: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: 25, height: 20)
        let collectionView:UICollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.tag = 0
        collectionView.backgroundColor = .littleElevatedViews
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    @IBOutlet weak var timeCollection: UICollectionView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ticketsView: UIView!
    @IBOutlet weak var lblTicketsSelected: UILabel!
    @IBOutlet weak var lblMovieTheatre: UILabel!
    @IBOutlet weak var btnPayBtn: UIButton!
    @IBOutlet weak var lblSeatsMessage: UILabel!
    @IBOutlet weak var lblSeatsAmount: UILabel!
    
    @IBOutlet weak var lblSeatsBookedLabel: UILabel!
    @IBOutlet weak var lblSeatsBooked: UILabel!
    @IBOutlet weak var autoBookView: UIView!
    
    @IBOutlet weak var seatsStepper: UIStepper!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewBottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customBackButton = UIBarButtonItem(image: getImage(named: "backios")?.withRenderingMode(.alwaysTemplate) , style: .plain, target: self, action: #selector(backAction(_:)))
        customBackButton.imageInsets = UIEdgeInsets(top: 2, left: -8, bottom: 0, right: 0)
        navigationItem.leftBarButtonItem = customBackButton

        let nib = UINib.init(nibName: "MenuCategoryCell", bundle: .module)
        self.timeCollection.register(nib, forCellWithReuseIdentifier: "cell")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(proceedPressed))
        ticketsView.isUserInteractionEnabled = true
        ticketsView.addGestureRecognizer(tap)
        
        #warning("check shimmer")
        scrollView.setTemplateWithSubviews(true)
        getSeating()
        
        seatCollection.delegate = self
        
        seatsStepper.maximumValue = 1
        
        lblMovieTheatre.text = "\(selectedTheatre?.name ?? ""), \(selectedDate)"
        title = selectedMovie?.movieName ?? ""
        
        printVal(object: "These are my payment modes: \(paymentModes) \(String(describing: self.restorationIdentifier))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func backAction(_ sender: UIButton) {
        removeAnyReservationsBack()
        printVal(object: "Back Button pressed.")
    }
    
    @objc func proceedPressed() {
        
        var totalSeats = selectedSeatArr.count
        if totalSeats == 0 {
            totalSeats = selectedManualArr.count
        }
        
        if totalSeats > 0 {
            if selectedTheatre?.restaurantID != nil && selectedTheatre?.restaurantID != "" {
                var showDate = ""
                var showProvider = ""
                var mySeats: [Seat] = []
                
                if selectedMovie?.movieTimeings != nil {
                    showDate = selectedMovie?.movieTimeings?[selectedTime].showTime ?? ""
                    showProvider = selectedTheatre?.name ?? ""
                } else {
                    showDate = selectedMovie?.showTimes?[selectedTime].showTime ?? ""
                    showProvider = selectedTheatre?.name ?? ""
                }
                
                if selectedManualArr.count == 0 {
                    for each in selectedSeatArr {
                        mySeats.append(Seat(seatNumber: "\(seatsArr[each])", movieTransactionsID: ""))
                    }
                } else {
                    for _ in selectedManualArr {
                        mySeats.append(Seat(seatNumber: "00", movieTransactionsID: ""))
                    }
                }
                
                let movieTicket = MovieTicket(uniqueID: "", showDate: showDate, movieProvider: [MovieProvider(name: showProvider, latitude: 0.0, longitude: 0.0)], movieName: selectedMovie?.movieName ?? "", movieImageSmall: selectedMovie?.movieImageSmall ?? "", totalSeats: "\(mySeats.count)", mobileNumber: "", fullName: "", seats: mySeats, restaurantMenu: [])
                
                printVal(object: "SelectedSeatArr: \(movieTicket)")
                
                #warning("check MovieTicketController")
                /*let popOverVC = UIStoryboard(name: "Movies", bundle: nil).instantiateViewController(withIdentifier: "MovieTicketController") as! MovieTicketController
                self.addChild(popOverVC)
                popOverVC.openAction = {
                    self.addToOrder()
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                }
                popOverVC.skipAction = {
                    self.confirmOrder()
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                }
                popOverVC.dismissAction = {
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                }
                popOverVC.myPromoCode = myPromoCode
                popOverVC.myPromoAmount = myPromoAmount
                popOverVC.myPromoType = myPromoType
                popOverVC.myMaxPromoAmount = myMaxPromoAmount
                popOverVC.seatTotalPrice = seatTotalPrice
                popOverVC.isHistory = false
                popOverVC.selectedTicket = movieTicket
                popOverVC.selectedTime = selectedTime
                popOverVC.selectedTheatre = selectedTheatre
                popOverVC.selectedMovie = selectedMovie
                popOverVC.view.frame = UIScreen.main.bounds
                self.view.addSubview(popOverVC.view)
                popOverVC.didMove(toParent: self)*/
                
            } else {
                self.confirmOrder()
            }
        } else {
            showAlerts(title: "", message: "Kindly add at least one seat before proceeding.")
        }
    }
    
    func addToOrder() {
        #warning("check ProductController")
        /*if let viewController = UIStoryboard(name: "Order", bundle: .module).instantiateViewController(withIdentifier: "ProductController") as? ProductController {
            var mySeats: [SelectedSeat] = []
            if selectedManualArr.count == 0 {
                for each in selectedSeatArr {
                    let seat = SelectedSeat(seatNumber: seatsArr[each], seatPrice: Int(priceArr[each])!, ticketCode: codeArr[each])
                    mySeats.append(seat)
                }
            } else {
                for _ in selectedManualArr {
                    let seat = SelectedSeat(seatNumber: "00", seatPrice: Int("0")!, ticketCode: "")
                    mySeats.append(seat)
                }
            }
            viewController.seatTotalPrice = seatTotalPrice
            viewController.selectedTheatre = selectedTheatre
            viewController.selectedMovie = selectedMovie
            viewController.selectedTicketNo = selectedSeatArr.count == 0 ? selectedManualArr.count : selectedSeatArr.count
            viewController.selectedTime = selectedTime
            viewController.selectedSeats = mySeats
            viewController.markup = markup
            viewController.paymentSourceArr = paymentModes
            viewController.myPromoCode = myPromoCode
            viewController.myDisclaimerMessage = myDisclaimerMessage
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }*/
    }
    
    func confirmOrder() {
        #warning("check ConfirmOrderController")
        if let viewController = UIStoryboard(name: "Deliveries", bundle: .module).instantiateViewController(withIdentifier: "ConfirmOrderController") as? ConfirmOrderController {
            var mySeats: [SelectedSeat] = []
            if selectedManualArr.count == 0 {
                for each in selectedSeatArr {
                    let seat = SelectedSeat(seatNumber: seatsArr[each], seatPrice: Int(priceArr[each])!, ticketCode: codeArr[each])
                    mySeats.append(seat)
                }
            } else {
                for _ in selectedManualArr {
                    let seat = SelectedSeat(seatNumber: "00", seatPrice: Int("0")!, ticketCode: "")
                    mySeats.append(seat)
                }
            }
            viewController.seatTotalPrice = seatTotalPrice
            viewController.selectedTheatre = selectedTheatre
            viewController.selectedMovie = selectedMovie
            viewController.selectedTime = selectedTime
            viewController.selectedTicketNo = selectedSeatArr.count == 0 ? selectedManualArr.count : selectedSeatArr.count
            viewController.selectedSeats = mySeats
            viewController.markup = markup
            viewController.paymentSourceArr = paymentModes
            viewController.myPromoCode = myPromoCode
            #warning("check myDisclaimerMessage")
//            viewController.myDisclaimerMessage = myDisclaimerMessage
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
    
    /*func bookSeatsAF() {
        
        self.view.createLoadingNormal()
        
        let id = selectedMovie?.movieTimeings?[selectedTime].showID ?? ""
        let theatreID = selectedTheatre?.movieProviderID ?? ""
        let screenId = selectedMovie?.movieTimeings?[selectedTime].screenID ?? ""
        let screenDate = selectedMovie?.movieTimeings?[selectedTime].showTime ?? ""
        let screenTime = selectedMovie?.movieTimeings?[selectedTime].showID ?? ""
        
        let selectedTicketNo = selectedSeatArr.count == 0 ? selectedManualArr.count : selectedSeatArr.count
        
        var seatsArray: [[String: Any]] = []
        
        if !isPopAction {
            for each in selectedSeats {
                seatsArray.append(["SeatNumber":"\(each.seatNumber ?? "")","SeatPrice":"\(each.seatPrice ?? 0)","TicketCode":"\(each.ticketCode ?? "")"])
            }
        }
        
        let movieTicketsDict: [String: Any] = [
            "MovieTickets":[
                "GetPrice":"Y",
                "ShowDate":"\(screenDate)",
                "ShowID":"\(screenTime)",
                "MovieDetails":[
                    "MovieProviderID":"\(theatreID)",
                    "MovieID":"\(id)",
                    "Quantity":selectedTicketNo,
                    "ScreenID":"\(screenId)",
                    "Seats":seatsArray
                ]
            ]
        ]
        
        let parametersDict: [String: Any] = [
            "FormID": "RESERVETICKETS"
        ]
        
        let parametersDictWithTickets = parametersDict.merging(movieTicketsDict) { (current, _) in current }
        let myParams = parametersDictWithTickets.merging(getCommonLLParameters()) { (current, _) in current }
        
        var data: Data? = nil
        
        do {
            data = try JSONSerialization.data(withJSONObject: myParams, options: [])
            var parametersString = String(data: data!, encoding: .utf8) ?? ""
            printVal(object: "Data being sent: \(parametersString)")
            parametersString = am.EncryptDataAES(DataToSend: <#T##String#>) as String
            parametersString = am.EncryptDataBase64(DataToSend: parametersString) as String
            
            let fullParameters: [String:Any] = [
                "DATA" : am.EncryptDataAES(DataToSend: "FORMID|MOVIES|MOBILENUMBER|\(am.getPhoneNumber()!)|"),
                "JSONData": am.EncryptDataAES(DataToSend: parametersString)
            ]
            
            let dataURL = am.DecryptDataKeyChain(DataToSend: Constants().link()) as String
            
            AF.request(dataURL, method: .post, parameters: fullParameters, encoding: URLEncoding.httpBody).responseString { [weak self] response in
                self?.view.removeAnimation()
                switch response.result {
                case .success(let data):
                    printVal(object: "AF Encrypted Data: \(data)")
                    let decryptData = self?.am.DecryptDataAES(DataToSend: data)
                    let decryptedDataNS = self?.am.DecryptDataBase64(DataToSend: (decryptData ?? "") as String)
                    printVal(object: "AF Decrypted Data: \(decryptedDataNS ?? "")")
                    
                    if decryptedDataNS != nil {
                        
                        var decryptedData = decryptedDataNS! as String
                        if decryptedData.starts(with: "[") {
                            decryptedData.removeFirst()
                            decryptedData.removeLast()
                        }
                        
                        let myData = decryptedData.data(using: .utf8)
                        if myData != nil {
                            do {
                                
                                let defaultResponse = try JSONDecoder().decode(DefaultMessage.self, from: myData!)
                                if defaultResponse.status != "000" {
                                    self?.showAlerts(title: "", message: defaultResponse.message ?? "")
                                    self?.clearLastSeat()
                                }
                                
                            } catch {
                                self?.showAlerts(title: "", message: "Error reserving seat")
                                self?.clearLastSeat()
                            }
                            
                        }
                    }
                    
                    
                case .failure(let error):
                    printVal(object: "An unexpected error occured.\n\n\(error.localizedDescription)")
                }
                
                if self?.isPopAction ?? false {
                    self?.navigationController?.pop(animated: true)
                }
            }
            
        } catch let error {
            view.removeAnimation()
            if isPopAction {
                self.navigationController?.popViewController(animated: true)
            }
            printVal(object: error.localizedDescription)
        }

    }*/
    
    func clearLastSeat() {
        
        printVal(object: selectedSeatArr)
        printVal(object: selectedSeats)
        
        selectedSeatArr.removeLast()
        selectedSeats.removeLast()
        
        printVal(object: selectedSeatArr)
        printVal(object: selectedSeats)
        
        seatCollection.reloadData()
    }

    
    func bookSeats() {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadBookSeats),name:NSNotification.Name(rawValue: "RESERVETICKETSMovies"), object: nil)
        
        /*var seatsArr = ""
        for each in selectedSeats {
            seatsArr = seatsArr + "{\"SeatNumber\":\"\(each.seatNumber ?? "")\",\"SeatPrice\":\"\(each.seatPrice ?? 0)\",\"TicketCode\":\"\(each.ticketCode ?? "")\"},"
        }
        seatsArr = String(seatsArr.dropLast())*/
        
        var seatsArr = [[String: Any]]()
        for each in selectedSeats {
            seatsArr.append([
                "SeatNumber": each.seatNumber ?? "",
                "SeatPrice": each.seatPrice ?? 0,
                "TicketCode": each.ticketCode ?? ""
            ])
        }
        
        let movieID = selectedMovie?.movieTimeings?[selectedTime].showID ?? ""
        let theatreID = selectedTheatre?.movieProviderID ?? ""
        let screenId = selectedMovie?.movieTimeings?[selectedTime].screenID ?? ""
        let screenDate = selectedMovie?.movieTimeings?[selectedTime].showTime ?? ""
        let screenTime = selectedMovie?.movieTimeings?[selectedTime].showID ?? ""
        
        let selectedTicketNo = selectedSeatArr.count == 0 ? selectedManualArr.count : selectedSeatArr.count
        
        var params = SDKUtils.commonJsonTags(formId: "RESERVETICKETS")
        params["MovieTickets"] = [
            "GetPrice": "Y",
            "ShowDate": screenDate,
            "ShowID": screenTime,
            "MovieDetails": [
                "MovieProviderID": theatreID,
                "MovieID": movieID,
                "Quantity": selectedTicketNo,
                "ScreenID": screenId,
                "Seats": seatsArr
            ]
        ]
        
        let dataToSend = (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
       
        hc.makeServerCall(sb: dataToSend, method: "RESERVETICKETSMovies", switchnum: 0)
        
    }
    
    @objc func loadBookSeats(_ notification: Notification) {
        
        self.view.removeAnimation()
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RESERVETICKETSMovies"), object: nil)
        
        if let data = data {
            do {
                
                let defaultResponse = try JSONDecoder().decode(DefaultMessage.self, from: data)
                if defaultResponse.status != "000" {
                    showAlerts(title: "", message: defaultResponse.message ?? "")
                }
                
            } catch {}
            
        }
    }
    
    func getSeating() {
        
        self.view.createLoadingNormal()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadSeating),name:NSNotification.Name(rawValue: "GETSCREENLAYOUTMovies"), object: nil)
        
        let showID = selectedMovie?.movieTimeings?[selectedTime].showID ?? ""
        let theatreID = selectedTheatre?.movieProviderID ?? ""
        let screenID = selectedMovie?.movieTimeings?[selectedTime].screenID ?? ""
        var params = SDKUtils.commonJsonTags(formId: "GETSCREENLAYOUT_V1")
        params["GetMovies"] = [
            "MovieProviderID": theatreID,
            "ScreenID": screenID,
            "ShowID": showID
        ]
        
        let dataToSend = (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
       
        hc.makeServerCall(sb: dataToSend, method: "GETSCREENLAYOUTMovies", switchnum: 0)
    }
       
    @objc func loadSeating(_ notification: Notification) {
        
        self.view.removeAnimation()
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETSCREENLAYOUTMovies"), object: nil)
        
        if let data = data {
            do {
                
                let seatRows = try JSONDecoder().decode([ScreenLayout].self, from: data)
                
//                guard let statesJsonArray = AllMethods.readLocalJSONFile(forName: "seats") else { return }
//                let decoder = JSONDecoder()
//                let seatRows = try decoder.decode(ScreenLayout.self, from: statesJsonArray)
                
                seatRowArr = seatRows.first?.seatLayout ?? []
                lblSeatsMessage.text = seatRows.first?.message ?? ""
                markup = seatRows.first?.markup ?? 0
                seatsStepper.minimumValue = 0
                seatsStepper.maximumValue = Double(seatRows.first?.maxManualSeats ?? 0)
                
                if (seatRows.first?.maxManualSeats ?? 0) != 0 {
                    lblSeatsBookedLabel.isHidden = false
                    lblSeatsBooked.isHidden = false
                    autoBookView.isHidden = true
                    scrollViewBottom.constant = 60
                } else {
                    lblSeatsBookedLabel.isHidden = false
                    lblSeatsBooked.isHidden = false
                    autoBookView.isHidden = false
                    scrollViewBottom.constant = 200
                }
                
                var count = 0
                allocatedSeats.removeAll()
                for i in (0..<seatRowArr.count) {
                    var arr = (seatRowArr[i].rowLayout ?? "").components(separatedBy: ",")
                    arr = arr.filter { $0 != "" }
                    let myPriceArr = (seatRowArr[i].seatPrice ?? "").components(separatedBy: ",")
                    let myCodeArr = (seatRowArr[i].ticketCode ?? "").components(separatedBy: ",")
                    var seatNo = 0
                    for j in (0..<arr.count) {
                        if arr[j] == "w" {
                            seatsArr.append("w")
                        } else {
                            seatsArr.append("\(seatRowArr[i].rowName ?? "")\(seatNo+1)")
                            seatNo += 1
                        }
                        priceArr.append("\(myPriceArr[j])")
                        codeArr.append("\(myCodeArr[j])")
                    }
                    count = arr.count
                    printVal(object: count)
                    allocatedSeats.append(contentsOf: seatRowArr[i].allocatedSeats ?? [])
                }
                
                seatCollection.dataSource = self
                seatCollection.delegate = self
                
                scrollView.addSubview(seatCollection)
                
                seatCollection.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
                seatCollection.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
                seatCollection.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
                seatCollection.rightAnchor.constraint(equalTo: scrollView.rightAnchor).isActive = true
                
                seatCollection.widthAnchor.constraint(equalToConstant: CGFloat(35*count)).isActive = true
                seatCollection.heightAnchor.constraint(equalToConstant: CGFloat(35*seatRowArr.count)).isActive = true
                
                let nib = UINib.init(nibName: "SeatCell", bundle: .module)
                seatCollection.register(nib, forCellWithReuseIdentifier: "cell")
                
                seatCollection.reloadData()
                
                
            } catch {
                printVal(object: "serialization issue")
                seatsArr.removeAll()
                seatCollection.reloadData()
            }
        }
        
        printVal(object: "selectedMovie: \(selectedMovie?.movieTimeings)")
        
        #warning("check scrollview shimmer")
        scrollView.setTemplateWithSubviews(false)
        
        self.timeCollection.reloadData()
        self.scrollViewHeight.constant = 60
    }
    
    func calculatePrices() {
        
        var price = 0.0
        var totalSeats = Double(selectedSeatArr.count)
        if totalSeats == 0 {
            totalSeats = Double(selectedManualArr.count)
        }
        
        for each in selectedSeatArr {
            price += (Double(priceArr[each])! + Double(markup))
        }
        
//        if selectedMovie?.movieTimeings != nil {
//            price = selectedMovie?.movieTimeings?[selectedTime].ticketPrice ?? 0.0
//        } else {
//            price = selectedMovie?.showTimes?[selectedTime].ticketPrice ?? 0.0
//        }
        
        var discount = 0.00
        var total = price//*totalSeats
        seatTotalPrice = total
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
            price = price - singlediscount
            total = total - discount
            if price < 0 {
                price = 0
            }
            if total < 0 {
                total = 0
            }
            lblSeatsAmount.text = "\(am.getGLOBALCURRENCY()!) \(formatCurrency(String(total)))"
        } else {
            lblSeatsAmount.text = "\(am.getGLOBALCURRENCY()!) \(formatCurrency(String(price)))" // *totalSeats
        }
        
        var mySeats: [Seat] = []
        
        if selectedManualArr.count == 0 {
            for each in selectedSeatArr {
                mySeats.append(Seat(seatNumber: "\(seatsArr[each])", movieTransactionsID: ""))
            }
        } else {
            for i in (0..<selectedManualArr.count) {
                mySeats.append(Seat(seatNumber: "0\(i)", movieTransactionsID: ""))
            }
        }
        
        var str = ""
        for each in mySeats {
            str = str + (each.seatNumber ?? "") + ", "
        }
        str = String(str.dropLast())
        str = String(str.dropLast())
        lblSeatsBooked.text = str
        
    }
    
    func removeAnyReservationsBack() {
        var totalSeats = Double(selectedSeatArr.count)
        if totalSeats == 0 {
            totalSeats = Double(selectedManualArr.count)
        }
        if totalSeats > 0 {
            selectedManualArr.removeAll()
            selectedSeatArr.removeAll()
            isPopAction = true
            bookSeats()
        } else {
            isPopAction = false
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        if selectedSeatArr.count > 0 {
            selectedSeatArr.removeAll()
            seatCollection.reloadData()
            showAlerts(title: "", message: "Previous selection has been cleared in favour of seat auto selection.".localized)
        }
        let val = Int(sender.value)
        selectedManualArr.removeAll()
        for i in (0..<val) {
            selectedManualArr.append(i)
        }
        lblTicketsSelected.text = "\(selectedManualArr.count) " + "tickets selected".localized
        calculatePrices()
    }
}

// MARK: - CollectionView DataSource & Delegates

extension ScreenController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        if collectionView.tag == 1 {
            let font = UIFont.systemFont(ofSize: 15)

            let varia = CGFloat(50.0)

            var text = ""
            text = "\(selectedMovie?.movieTimeings?[indexPath.item].showTime ?? "") on \(selectedMovie?.movieTimeings?[indexPath.item].screenName ?? "")"
            let size = CGSize(width: ((text.width(withConstrainedHeight: 30.0, font: font)) ) + varia, height: 40.0)

            return size
        } else {
            return CGSize(width: 25, height: 25)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 1 {
            return selectedMovie?.movieTimeings?.count ?? 0
        } else {
            return seatsArr.count
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
        if collectionView.tag == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! MenuCategoryCell
            if selectedTime == indexPath.item {
                cell.categoryView.backgroundColor = .littleBlue
                cell.lblCategory.textColor = .littleWhite
            } else {
                cell.categoryView.backgroundColor = .littleCellBackgrounds
                cell.lblCategory.textColor = .littleLabelColor
            }
            
            var text = ""
            text = "\(selectedMovie?.movieTimeings?[indexPath.item].showTime ?? "") at \(selectedMovie?.movieTimeings?[indexPath.item].screenName ?? "")"

            cell.lblCategory.text = text

            return cell
        } else {
            
            let color = UIColor.littleBlue
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! SeatCell
            
            if allocatedSeats.contains(where: { $0.seatNumber == seatsArr[indexPath.item] }) {
                
                cell.borderView.backgroundColor = .littleCellBackgrounds
                cell.borderView.borderColor = .lightGray
                cell.lblSeatNo.textColor = .lightGray
                
                cell.lblSeatNo.text = "\(seatsArr[indexPath.item])"
                cell.borderView.borderWidth = 0.5
                
            } else {
                if selectedSeatArr.contains(indexPath.item) {
                    cell.borderView.backgroundColor = color
                    cell.borderView.borderColor = color
                    cell.lblSeatNo.textColor = .white
                } else {
                    cell.borderView.backgroundColor = .lightText
                    cell.borderView.borderColor = .darkGray
                    cell.lblSeatNo.textColor = .darkGray
                }
                if seatsArr[indexPath.item] != "" && seatsArr[indexPath.item] != "w" {
                    cell.lblSeatNo.text = "\(seatsArr[indexPath.item])"
                    cell.borderView.borderWidth = 0.5
                } else {
                    cell.lblSeatNo.text = ""
                    cell.borderView.borderWidth = 0
                }
            }
            
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 1 {
            selectedTime = indexPath.item
            self.selectedSeatArr.removeAll()
            self.selectedSeats.removeAll()
            self.timeCollection.reloadData()
            getSeating()
        } else {
            if seatsArr[indexPath.item] != "w" {
                if allocatedSeats.contains(where: { $0.seatNumber == seatsArr[indexPath.item] }) {
                    showAlerts(title: "", message: "Seat \(seatsArr[indexPath.item]) has already been booked")
                } else {
                    if selectedManualArr.count > 0 {
                        selectedManualArr.removeAll()
                        seatsStepper.value = 0
                        lblTicketsSelected.text = "Auto Assign".localized
                        showAlerts(title: "", message: "Previous selection has been cleared in favour of seat manual selection.".localized)
                    }
                    if selectedSeatArr.contains(indexPath.item) {
                        printVal(object: selectedSeatArr)
                        printVal(object: selectedSeats)
                        if let index = selectedSeatArr.firstIndex(of: indexPath.item) {
                            selectedSeatArr.remove(at: index)
                            selectedSeats.remove(at: index)
                        }
                        seatCollection.reloadData()
                    } else {
                        printVal(object: priceArr[indexPath.item])
                        let seat = SelectedSeat(seatNumber: seatsArr[indexPath.item], seatPrice: Int(priceArr[indexPath.item]) ?? 0, ticketCode: codeArr[indexPath.item])
                        selectedSeatArr.append(indexPath.item)
                        selectedSeats.append(seat)
                        seatCollection.reloadData()
                        printVal(object: seat)
                    }
                    calculatePrices()
                    bookSeats()
                }
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            printVal(object: "SCROLL scrollViewDidEndDragging \(scrollView.tag)")
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        printVal(object: "SCROLL scrollViewDidEndDecelerating \(scrollView.tag)")
    }
}
