//
//  MovieTicketsController.swift
//  
//
//  Created by Little Developers on 22/11/2022.
//

import UIKit
import UIView_Shimmer

private let cellID = "CellID"

class MovieTicketsController: UIViewController {

    // MARK: - Properties
    
    private let am = SDKAllMethods()
    private let hc = SDKHandleCalls()
    
    var searchTerm = ""
    
    var stackSearch: UIStackView!
    var searchBar: UITextField!
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    var columnCount: Int = 2
    var myCellWidth: CGFloat = 0
    var myCellHeight: CGFloat = 0
    
    @IBOutlet weak var noTicketsView: UIView!
    @IBOutlet weak var lblNoTickets: UILabel!
    @IBOutlet weak var lblSearchResults: UILabel!
    @IBOutlet weak var btnCancelSearch: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBtnHeight: NSLayoutConstraint!
    
    var isPast: Bool = false
    var movieTicketsData: Data?
    
    var movieTicketsArr: [MovieTicket] = []
    
    var sortedMovieTicketsArr: [MovieTicket] = []
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        getMovieTickets()
    }
    
    // MARK: - Visual Setup
    
    func configureUI() {
        
        view.backgroundColor = .littleElevatedViews
        
        let toolbarBG = UIView()
        toolbarBG.backgroundColor = .littleBlue
        
        view.addSubview(toolbarBG)
        
        toolbarBG.translatesAutoresizingMaskIntoConstraints = false
        toolbarBG.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -50).isActive = true
        toolbarBG.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        toolbarBG.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        toolbarBG.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let topImageBG = UIImageView()
        topImageBG.image = getImage(named: "DoctorsCurve", bundle: .module)?.withRenderingMode(.alwaysTemplate)
        view.tintColor = SDKConstants.littleSDKThemeColor
        topImageBG.contentMode = .redraw
        
        view.addSubview(topImageBG)
        
        var imageHeight = view.bounds.width/4
        if imageHeight > 100 {
            imageHeight = 100
        }
        topImageBG.translatesAutoresizingMaskIntoConstraints = false
        topImageBG.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topImageBG.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        topImageBG.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        topImageBG.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
        
        
        let backBtn = UIButton()
        backBtn.setImage(getImage(named: "backios"), for: .normal)
        backBtn.setTitle("", for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnPressed(_:)), for: .touchUpInside)
        
        view.addSubview(backBtn)
        
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        backBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        backBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        backBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let pageTitle = UILabel()
        pageTitle.isUserInteractionEnabled = true
        pageTitle.text = "Movie Tickets".localized
        pageTitle.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 16.0)
        pageTitle.textColor = .white
        pageTitle.numberOfLines = 0
        pageTitle.textAlignment = .center
        
        view.addSubview(pageTitle)
        
        pageTitle.translatesAutoresizingMaskIntoConstraints = false
        pageTitle.centerYAnchor.constraint(equalTo: backBtn.centerYAnchor).isActive = true
        pageTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageTitle.leftAnchor.constraint(greaterThanOrEqualTo: view.leftAnchor, constant: 50).isActive = true
        pageTitle.rightAnchor.constraint(greaterThanOrEqualTo: view.rightAnchor, constant: -50).isActive = true
        
        let searchBoxView = UIView()
        searchBoxView.backgroundColor = .littleElevatedViews
        searchBoxView.tag = 105
        searchBoxView.viewCornerRadius = 25
        searchBoxView.dropShadow()
        
        searchBoxView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let imgSearch = UIImageView()
        imgSearch.image = getImage(named: "search_black")?.withRenderingMode(.alwaysTemplate)
        imgSearch.tintColor = .littleLabelColor
        
        searchBoxView.addSubview(imgSearch)
        imgSearch.translatesAutoresizingMaskIntoConstraints = false
        imgSearch.centerYAnchor.constraint(equalTo: searchBoxView.centerYAnchor).isActive = true
        imgSearch.leftAnchor.constraint(equalTo: searchBoxView.leftAnchor, constant: 16).isActive = true
        imgSearch.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imgSearch.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        searchBar = UITextField()
        searchBar.borderStyle = .none
        searchBar.placeholder = "Search Movie Tickets".localized
        searchBar.autocorrectionType = .no
        searchBar.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15.0)
        searchBar.delegate = self
        searchBar.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        
        searchBoxView.addSubview(searchBar)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.topAnchor.constraint(equalTo: searchBoxView.topAnchor, constant: 5).isActive = true
        searchBar.bottomAnchor.constraint(equalTo: searchBoxView.bottomAnchor, constant: -5).isActive = true
        searchBar.leftAnchor.constraint(equalTo: imgSearch.rightAnchor, constant: 16).isActive = true
        searchBar.rightAnchor.constraint(equalTo: searchBoxView.rightAnchor, constant: -16).isActive = true
        
        stackSearch = UIStackView()
        stackSearch.axis  = NSLayoutConstraint.Axis.horizontal
        stackSearch.distribution  = UIStackView.Distribution.fillProportionally
        stackSearch.alignment = UIStackView.Alignment.fill
        stackSearch.spacing = 10
        stackSearch.backgroundColor = .clear
        
        stackSearch.addArrangedSubview(searchBoxView)
        
        stackSearch.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackSearch)
        
        stackSearch.topAnchor.constraint(equalTo: topImageBG.bottomAnchor, constant: -25).isActive = true
        stackSearch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35).isActive = true
        stackSearch.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 35).isActive = true
        stackSearch.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    func setupDefaults() {
        
        collectionView.register(MyMovieCell.self, forCellWithReuseIdentifier: cellID)
        collectionView.collectionViewLayout = CenterAlignedCVFlowLayout()
                
        collectionView.reloadData()
        
        collectionView.es.addPullToRefresh {
            [unowned self] in
            self.getMovieTickets()
        }
        
        let workableWidth = UIScreen.main.bounds.width
        
        if workableWidth >= 540 {
            columnCount = Int(workableWidth/180)
        }
        
        myCellWidth = UIScreen.main.bounds.width/CGFloat(columnCount)
        
        if myCellWidth > 180 {
            myCellWidth = 180
        }
        myCellHeight = myCellWidth * (3/2)
        
        collectionView.es.startPullToRefresh()
        
    }
    
    func closeSearch() {
        
        searchBtnHeight.constant = 115
        
        searchBar.text = ""
        lblSearchResults.text = ""
        btnCancelSearch.isHidden = true
        
        sortedMovieTicketsArr = movieTicketsArr
        
        if sortedMovieTicketsArr.count > 0 {
            noTicketsView.isHidden = true
        } else {
            noTicketsView.isHidden = false
        }
        
        collectionView.reloadData()
    }
    
    func searchFromMovies() {
        
        var arr: [MovieTicket] = []
        
        searchBtnHeight.constant = 130
        
        for each in movieTicketsArr {
            if each.movieName?.lowercased().contains(searchTerm.lowercased()) ?? false  {
                arr.append(each)
            }
        }
        sortedMovieTicketsArr = arr
        var period = ""
        isPast ? (period = "upcoming") : (period = "past")
        if sortedMovieTicketsArr.count > 0 {
            noTicketsView.isHidden = true
            lblNoTickets.text = "Oops, seems like there are no movie tickets booked".localized
        } else {
            lblNoTickets.text = "Oops, seems like there are no movie tickets booked".localized + "with the search term".localized + " \"\(searchTerm)\"."
            noTicketsView.alpha = 0
            noTicketsView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.noTicketsView.alpha = 1
            }
        }
        
        collectionView.reloadData()
        
        btnCancelSearch.isHidden = false
        lblSearchResults.text = "Search results for".localized + " \"\(searchTerm)\""
        
    }
    
    // MARK: - Handlers
    
    @IBAction func ticketTypeChanged(_ sender: UISegmentedControl) {
        isPast = !isPast
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        let formatter1 = DateFormatter()
        formatter1.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        sortedMovieTicketsArr.removeAll()
        
        switch sender.selectedSegmentIndex {
        case 0:
            for each in movieTicketsArr {
                if let date = formatter.date(from: each.showDate ?? "") {
                    if let today = formatter1.date(from: each.currentDate ?? "") {
                        if date >= today {
                            sortedMovieTicketsArr.append(each)
                        }
                    }
                }
            }
            lblNoTickets.text = "Oops, seems like there are no upcoming movie tickets booked.".localized
        default:
            for each in movieTicketsArr {
                if let date = formatter.date(from: each.showDate ?? "") {
                    if let today = formatter1.date(from: each.currentDate ?? "") {
                        if date < today {
                            sortedMovieTicketsArr.append(each)
                        }
                    }
                }
            }
            lblNoTickets.text = "Oops, seems like there are no past movie tickets to show.".localized
        }
        collectionView.reloadData()
        showHideNoTicketsView()
    }
    
    // MARK: - Server Calls
    
    func getMovieTickets() {
        
        noTicketsView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMovies),name:NSNotification.Name(rawValue: "MYTICKETSMovies"), object: nil)
        
        let params = SDKUtils.commonJsonTags(formId: "MYTICKETS")
        
        let dataToSend = (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
       
        hc.makeServerCall(sb: dataToSend, method: "MYTICKETSMovies", switchnum: 0)
        
    }
    
    fileprivate func showHideNoTicketsView() {
        if sortedMovieTicketsArr.count > 0 {
            noTicketsView.isHidden = true
        } else {
            noTicketsView.alpha = 0
            noTicketsView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.noTicketsView.alpha = 1
            }
        }
    }
    
    @objc func loadMovies(_ notification: Notification) {
        
        collectionView.es.stopPullToRefresh()
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "MYTICKETSMovies"), object: nil)
        
        if let data = data {
            do {
                if movieTicketsData != data {
                    movieTicketsData = data
                    movieTicketsArr.removeAll()
                    sortedMovieTicketsArr.removeAll()
                    let movieTheatres = try JSONDecoder().decode(MovieTickets.self, from: data)
                    movieTicketsArr = movieTheatres
                    let formatter = DateFormatter()
                    formatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
                    formatter.dateFormat = "dd MMM yyyy HH:mm"
                    let formatter1 = DateFormatter()
                    formatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                    formatter1.locale = Locale(identifier: Locale.current.languageCode ?? "en")
                    
                    for each in movieTicketsArr {
                        if let date = formatter.date(from: each.showDate ?? "") {
                            if let today = formatter1.date(from: each.currentDate ?? "") {
                                if date >= today {
                                    sortedMovieTicketsArr.append(each)
                                }
                            }
                        }
                    }
                }
            } catch {
                movieTicketsArr.removeAll()
                sortedMovieTicketsArr.removeAll()
            }
            collectionView.reloadData()
        }
        
        showHideNoTicketsView()
    }

}

extension MovieTicketsController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let movieTicket = sortedMovieTicketsArr[indexPath.item]
        
        if (movieTicket.restaurantMenu?.count ?? 0) > 0 {
            return UITableView.automaticDimension
        } else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sortedMovieTicketsArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movieTicket = sortedMovieTicketsArr[indexPath.item]
        
        if (movieTicket.restaurantMenu?.count ?? 0) > 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellAddon") as! MovieTicketCell
            cell.lblMovieName.text = movieTicket.movieName ?? ""
            if movieTicket.totalSeats == "1" {
                cell.lblTicketNo.text = "\(movieTicket.totalSeats ?? "0") " + "Ticket".localized
            } else {
                cell.lblTicketNo.text = "\(movieTicket.totalSeats ?? "0") " + "Tickets".localized
            }
            cell.lblTheatreName.text = movieTicket.movieProvider?[0].name ?? ""
            cell.lblTime.text = movieTicket.showDate ?? ""
            cell.imgMovie.setTemplateWithSubviews(true, color: .littleBlack)
            cell.imgMovie.sd_setImage(with: URL(string: movieTicket.movieImageSmall ?? "")) { (image, error, cahe, url) in
                cell.imgMovie.setTemplateWithSubviews(false)
            }
            cell.itemsArr = movieTicket.restaurantMenu ?? []
            cell.setupTableView()
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MovieTicketCell
            cell.lblMovieName.text = movieTicket.movieName ?? ""
            if movieTicket.totalSeats == "1" {
                cell.lblTicketNo.text = "\(movieTicket.totalSeats ?? "0") " + "Ticket".localized
            } else {
                cell.lblTicketNo.text = "\(movieTicket.totalSeats ?? "0") " + "Tickets".localized
            }
            cell.lblTheatreName.text = movieTicket.movieProvider?[0].name ?? ""
            cell.lblTime.text = movieTicket.showDate ?? ""
            cell.imgMovie.setTemplateWithSubviews(true, color: .littleBlack)
            cell.imgMovie.sd_setImage(with: URL(string: movieTicket.movieImageSmall ?? "")) { (image, error, cahe, url) in
                cell.imgMovie.setTemplateWithSubviews(false)
            }
            cell.selectionStyle = .none
            return cell
        }
        
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let movieTicket = sortedMovieTicketsArr[indexPath.item]
        
        let popOverVC = UIStoryboard(name: "Movies", bundle: .module).instantiateViewController(withIdentifier: "MovieTicketController") as! MovieTicketController
        self.addChild(popOverVC)
        popOverVC.popToRestorationID = self.popToRestorationID
        popOverVC.navShown = self.navShown
        popOverVC.isHistory = true
        popOverVC.selectedTicket = movieTicket
        popOverVC.bookCabAction = {
            
            self.am.saveForeignDropOffName(data: movieTicket.movieProvider?[0].name ?? "")
            self.am.saveForeignDropOffLocation(data: "\(movieTicket.movieProvider?[0].latitude ?? 0.0),\(movieTicket.movieProvider?[0].longitude ?? 0.0)")

            if let viewController = UIStoryboard(name: "Trip", bundle: .module).instantiateViewController(withIdentifier: "LittleRideVC") as? LittleRideVC {
                viewController.isUAT = self.am.getIsUAT()
                viewController.popToRestorationID = self.popToRestorationID
                viewController.navShown = self.navShown
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        
    }
    
}

extension MovieTicketsController: UITextFieldDelegate {
    
    @objc func textChanged(_ sender: UITextField) {
        if sender.text == "" {
            closeSearch()
        } else {
            searchTerm = sender.text ?? ""
            searchFromMovies()
        }
    }
    
}

extension MovieTicketsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: myCellWidth, height: myCellHeight)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedMovieTicketsArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let movieTicket = sortedMovieTicketsArr[indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MyMovieCell
        
        cell.movieTicketsLabel.isHidden = false
        
        cell.movieTitleLabel.text = "\(movieTicket.movieName ?? "")"
        cell.movieRatingLabel.text = "\(movieTicket.showDate ?? "")"
        
        if movieTicket.totalSeats == "1" {
            cell.movieTicketsLabel.text = "\(movieTicket.totalSeats ?? "0") " + "Ticket".localized
        } else {
            cell.movieTicketsLabel.text = "\(movieTicket.totalSeats ?? "0") " + "Tickets".localized
        }
        
        cell.imgMovie.setTemplateWithSubviews(true, color: .littleBlack)
        cell.imgMovie.sd_setImage(with: URL(string: movieTicket.movieImageSmall ?? "")) { (image, error, cahe, url) in
            cell.imgMovie.setTemplateWithSubviews(false)
        }
        
        if (movieTicket.restaurantMenu?.count ?? 0) > 0 {
            cell.movieTimeLabel.text = "✓ Has Snacks".localized
        } else {
            cell.movieTimeLabel.text = "No Snacks".localized
        }
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let movieTicket = sortedMovieTicketsArr[indexPath.item]
        
        let popOverVC = UIStoryboard(name: "Movies", bundle: .module).instantiateViewController(withIdentifier: "MovieTicketController") as! MovieTicketController
        popOverVC.popToRestorationID = self.popToRestorationID
        popOverVC.navShown = self.navShown
        self.addChild(popOverVC)
        popOverVC.isHistory = true
        popOverVC.selectedTicket = movieTicket
        popOverVC.bookCabAction = {
            self.am.saveForeignDropOffName(data: movieTicket.movieProvider?[0].name ?? "")
            self.am.saveForeignDropOffLocation(data: "\(movieTicket.movieProvider?[0].latitude ?? 0.0),\(movieTicket.movieProvider?[0].longitude ?? 0.0)")

            if let viewController = UIStoryboard(name: "Trip", bundle: .module).instantiateViewController(withIdentifier: "LittleRideVC") as? LittleRideVC {
                viewController.isUAT = self.am.getIsUAT()
                viewController.popToRestorationID = self.popToRestorationID
                viewController.navShown = self.navShown
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        
    }
}
