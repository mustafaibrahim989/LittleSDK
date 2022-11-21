//
//  File.swift
//  
//
//  Created by Little Developers on 21/11/2022.
//

import UIKit
import ESPullToRefresh
import UIView_Shimmer

private let cellID = "CellID"

class MoviesController: UIViewController {
    
    private let am = SDKAllMethods()
    private let hc = SDKHandleCalls()

    var selectedAccount: Int = 0
    var moviePlacesData: Data?
    var suggestedAccounts: [String] = ["Running Movies","Movie theatres near you"]
    
    var columnCount: Int = 2
    var myCellWidth: CGFloat = 0
    var myCellHeight: CGFloat = 0
    
    var paymentModes: [Balance] = []
    
    var moviesPlacesArr: [MovieTheatre] = []
    var moviesArr: [Movie] = []
    var sortedMoviesPlacesArr: [MovieTheatre] = []
    var sortedMoviesArr: [Movie] = []
    
    var searchTerm = ""
    
    var pageTitle: UILabel!
    var stackSearch: UIStackView!
    var searchBar: UITextField!
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    @IBOutlet weak var btnCancelSearch: UIButton!
    @IBOutlet weak var lblSearchResults: UILabel!
    @IBOutlet weak var noMoviesView: UIView!
    @IBOutlet weak var lblNoMovies: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var runningCollection: UICollectionView!
    @IBOutlet weak var searchBtnHeight: NSLayoutConstraint!
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        let nib2 = UINib.init(nibName: "TheatreCell", bundle: Bundle.module)
        self.tableView.register(nib2, forCellReuseIdentifier: "cellTheatre")
        
        self.runningCollection.register(MyMovieCell.self, forCellWithReuseIdentifier: cellID)
        self.runningCollection.collectionViewLayout = CenterAlignedCVFlowLayout()
        
        let nib = UINib.init(nibName: "MenuCategoryCell", bundle: .module)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
                
        let workableWidth = UIScreen.main.bounds.width
        
        if workableWidth >= 540 {
            columnCount = Int(workableWidth/180)
        }
        
        myCellWidth = UIScreen.main.bounds.width/CGFloat(columnCount)
        
        if myCellWidth > 180 {
            myCellWidth = 180
        }
        myCellHeight = myCellWidth * (3/2)
        
        
        runningCollection.reloadData()
        
        tableView.es.addPullToRefresh {
            [unowned self] in
            self.getMovieProviders()
        }
        
        runningCollection.es.addPullToRefresh {
            [unowned self] in
            self.getLatestMovies()
        }
        
        runningCollection.es.startPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        if am.getMESSAGE() == "FromBookingMovie" {
            am.saveMESSAGE(data: "")
            /*if let viewController = UIStoryboard(name: "Movies", bundle: nil).instantiateViewController(withIdentifier: "MovieTicketsController") as? MovieTicketsController {
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }*/
        } else {
            if selectedAccount == 1 {
                getMovieProviders()
            } else {
                getLatestMovies()
            }
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            let hasUserInterfaceStyleChanged = previousTraitCollection?.hasDifferentColorAppearance(comparedTo: traitCollection) ?? false
            if hasUserInterfaceStyleChanged {
                
            }
        }
        
    }
    
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
        backBtn.setImage(getImage(named: "backios", bundle: .module), for: .normal)
        backBtn.setTitle("", for: .normal)
        backBtn.addTarget(self, action: #selector(backHome), for: .touchUpInside)
        
        view.addSubview(backBtn)
        
        backBtn.translatesAutoresizingMaskIntoConstraints = false
        backBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8).isActive = true
        backBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        backBtn.widthAnchor.constraint(equalToConstant: 40).isActive = true
        backBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        pageTitle = UILabel()
        pageTitle.isUserInteractionEnabled = true
        pageTitle.text = "Movies"
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
        imgSearch.image = getImage(named: "search_black", bundle: .module)
        imgSearch.tintColor = .littleLabelColor
        
        searchBoxView.addSubview(imgSearch)
        imgSearch.translatesAutoresizingMaskIntoConstraints = false
        imgSearch.centerYAnchor.constraint(equalTo: searchBoxView.centerYAnchor).isActive = true
        imgSearch.leftAnchor.constraint(equalTo: searchBoxView.leftAnchor, constant: 16).isActive = true
        imgSearch.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imgSearch.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        searchBar = UITextField()
        searchBar.borderStyle = .none
        searchBar.placeholder = "Search Movies".localized
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
    
    @objc func backHome() {
        var isPopped = true
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller == popToRestorationID {
                if self.navShown ?? false {
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                } else {
                    self.navigationController?.setNavigationBarHidden(true, animated: false)
                }
                self.navigationController!.popToViewController(controller, animated: true)
                break
            } else {
                isPopped = false
            }
        }
        
        if !isPopped {
            printVal(object: "ToRoot")
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func btnBookedTickets(_ sender: UIButton) {
        #warning("check tickets")
        /*if let viewController = UIStoryboard(name: "Movies", bundle: nil).instantiateViewController(withIdentifier: "MovieTicketsController") as? MovieTicketsController {
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }*/
    }
    
    
    func getLatestMovies() {
        
        noMoviesView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMovies),name:NSNotification.Name(rawValue: "RUNNINGMOVIESMovies"), object: nil)
        
        let params = SDKUtils.commonJsonTags(formId: "RUNNINGMOVIES")
        
        let dataToSend = (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
       
        hc.makeServerCall(sb: dataToSend, method: "RUNNINGMOVIESMovies", switchnum: 0)
    }
    
    func getMovieProviders() {
        
        noMoviesView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMovieProviders),name:NSNotification.Name(rawValue: "GETMOVIEPROVIDERSMovies"), object: nil)
       
        let params = SDKUtils.commonJsonTags(formId: "GETMOVIEPROVIDERS")
        
        let dataToSend = (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
       
        hc.makeServerCall(sb: dataToSend, method: "GETMOVIEPROVIDERSMovies", switchnum: 0)
    }
       
    @objc func loadMovieProviders(_ notification: Notification) {
        tableView.es.stopPullToRefresh()
            
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETMOVIEPROVIDERSMovies"), object: nil)
        
        if let data = data {
            do {
                if moviePlacesData != data {
                    moviePlacesData = data
                    moviesPlacesArr.removeAll()
                    sortedMoviesPlacesArr.removeAll()
                    let movieTheatres = try JSONDecoder().decode(MovieTheatres.self, from: data)
                    moviesPlacesArr = movieTheatres
                    sortedMoviesPlacesArr = movieTheatres
                }
            } catch(let error) {
                printVal(object: "serialization failed: \(error.localizedDescription)")
                moviesPlacesArr.removeAll()
                sortedMoviesPlacesArr.removeAll()
            }
        }
        
        printVal(object: "sorted: \(sortedMoviesPlacesArr)")
        
        tableView.reloadData()
        
        if moviesPlacesArr.count > 0 {
            noMoviesView.isHidden = true
        } else {
            noMoviesView.alpha = 0
            noMoviesView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.noMoviesView.alpha = 1
            }
        }
    }
    
    @objc func loadMovies(_ notification: Notification) {
        
        runningCollection.es.stopPullToRefresh()
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "RUNNINGMOVIESMovies"), object: nil)
        
        if let data = data {
            do {
                
                if moviePlacesData != data {
                    moviePlacesData = data
                    moviesArr.removeAll()
                    sortedMoviesArr.removeAll()
                    let movies = try JSONDecoder().decode([MovieRunning].self, from: data)
                    moviesArr = movies.first?.moviesRunning ?? []
                    sortedMoviesArr = movies.first?.moviesRunning ?? []
                    paymentModes = movies.first?.wallet ?? []
                    
                    printVal(object: "These are my payment modes: \(paymentModes) \(String(describing: self.restorationIdentifier))")
                }
            } catch(let error) {
                printVal(object: "serialization failed: \(error.localizedDescription)")
                moviesArr.removeAll()
                sortedMoviesArr.removeAll()
            }
        }
        
        runningCollection.reloadData()
        
        if moviesArr.count > 0 {
            noMoviesView.isHidden = true
        } else {
            noMoviesView.alpha = 0
            noMoviesView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.noMoviesView.isHidden = true
            }
        }
    }
    
    func searchFromMovies() {
        
        var arr: [Movie] = []
        var arr1: [MovieTheatre] = []
        
        searchBtnHeight.constant = 130
        
        if selectedAccount == 1 {
            for each in moviesPlacesArr {
                if each.name?.lowercased().contains(searchTerm.lowercased()) ?? false  {
                    arr1.append(each)
                }
            }
            sortedMoviesPlacesArr = arr1
            
            if sortedMoviesPlacesArr.count > 0 {
                noMoviesView.isHidden = true
                lblNoMovies.text = "Oops, it seems like there are no movie theatres in your area.".localized
            } else {
                lblNoMovies.text = "Oops, it seems like there are no movie theatres in your area with the search term".localized + " \"\(searchTerm)\""
                noMoviesView.alpha = 0
                noMoviesView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.noMoviesView.alpha = 1
                }
            }
            
            tableView.reloadData()
            
        } else {
            for each in moviesArr {
                if each.movieName?.lowercased().contains(searchTerm.lowercased()) ?? false  {
                    arr.append(each)
                }
            }
            sortedMoviesArr = arr
            if sortedMoviesArr.count > 0 {
                noMoviesView.isHidden = true
                lblNoMovies.text = "Oops, it seems like there are no running movies in your area.".localized
            } else {
                lblNoMovies.text = "Oops, it seems like there are no running movies in your area with the search term".localized + " \"\(searchTerm)\""
                noMoviesView.alpha = 0
                noMoviesView.isHidden = false
                UIView.animate(withDuration: 0.3) {
                    self.noMoviesView.alpha = 1
                }
            }
            
            runningCollection.reloadData()
        }
        
        btnCancelSearch.isHidden = false
        lblSearchResults.text = "Search results for".localized + " \"\(searchTerm)\""
        
    }
    
    func closeSearch() {
        
        searchBtnHeight.constant = 126
        
        searchBar.text = ""
        lblSearchResults.text = ""
        btnCancelSearch.isHidden = true
        
        sortedMoviesArr = moviesArr
        sortedMoviesPlacesArr = moviesPlacesArr
        
        if selectedAccount == 1 {
            if sortedMoviesPlacesArr.count > 0 {
                noMoviesView.isHidden = true
            } else {
                noMoviesView.isHidden = false
            }
            tableView.reloadData()
        } else {
            if sortedMoviesArr.count > 0 {
                noMoviesView.isHidden = true
            } else {
                noMoviesView.isHidden = false
            }
            runningCollection.reloadData()
        }
        
        
    }
    
    @IBAction func btnCloseSearch(_ sender: UIButton) {
        closeSearch()
    }
    
}

extension MoviesController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ((UIScreen.main.bounds.width-32)/2)+54
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedMoviesPlacesArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTheatre") as! TheatreCell
        cell.lblTheatre.text = sortedMoviesPlacesArr[indexPath.item].name ?? ""
        cell.imgTheatre.setTemplateWithSubviews(true, viewBackgroundColor: .littleWhite)
        cell.imgTheatre.sd_setImage(with: URL(string: sortedMoviesPlacesArr[indexPath.item].logo ?? "")) { (image, error, cahe, url) in
            cell.imgTheatre.setTemplateWithSubviews(false)
        }
        cell.lblRating.text = "\(sortedMoviesPlacesArr[indexPath.item].rating ?? 5.0)"
        cell.lblLocation.text = sortedMoviesPlacesArr[indexPath.item].locationName ?? ""
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let viewController = UIStoryboard(name: "Movies", bundle: .module).instantiateViewController(withIdentifier: "TheatreController") as? TheatreController {
            viewController.navShown = self.navShown
            viewController.popToRestorationID = self.popToRestorationID
            viewController.selectedTheatre = sortedMoviesPlacesArr[indexPath.item]
            viewController.paymentModes = paymentModes
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
}

extension MoviesController: UITextFieldDelegate {
    
    @objc func textChanged(_ sender: UITextField) {
        if sender.text == "" {
            closeSearch()
        } else {
            searchTerm = sender.text ?? ""
            searchFromMovies()
        }
    }
    
}

// MARK: - CollectionView DataSource & Delegates

extension MoviesController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

       func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
           if collectionView == self.collectionView {
               let font = UIFont.systemFont(ofSize: 15)
               
               let varia = CGFloat(50.0)
               
               let size = CGSize(width: ((suggestedAccounts[indexPath.item].width(withConstrainedHeight: 30.0, font: font)) ) + varia, height: 40.0)
               
               return size
           } else {
               return CGSize(width: myCellWidth, height: myCellHeight)
           }
       }
       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           if collectionView == self.collectionView {
               return suggestedAccounts.count
           } else {
               return sortedMoviesArr.count
           }
       }
       
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
           if collectionView == self.collectionView {
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! MenuCategoryCell
               if selectedAccount == indexPath.item {
                   cell.categoryView.backgroundColor = .littleBlue
                   cell.lblCategory.textColor = .littleWhite
               } else {
                   cell.categoryView.backgroundColor = .littleCellBackgrounds
                   cell.lblCategory.textColor = .littleLabelColor
               }
               cell.lblCategory.text = suggestedAccounts[indexPath.item]
               
               return cell
           } else {
               let movie = sortedMoviesArr[indexPath.item]
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! MyMovieCell
               
               cell.movieTitleLabel.text = movie.movieName ?? ""
               cell.movieRatingLabel.text = "Rated: \(movie.censorRating ?? "")"
               cell.movieTimeLabel.text = "\(Int(movie.duration ?? 0.0)) mins"
               cell.imgMovie.setTemplateWithSubviews(true, viewBackgroundColor: .littleBlack)
               cell.imgMovie.sd_setImage(with: URL(string: movie.movieImageSmall ?? "")) { (image, error, cahe, url) in
                   cell.imgMovie.setTemplateWithSubviews(false)
               }
               
               return cell
           }
       }
       
    func navigateToTrailer(_ movie: Movie, _ dets: ShowTime) {
        if let viewController = UIStoryboard(name: "Movies", bundle: .module).instantiateViewController(withIdentifier: "TrailerController") as? TrailerController {
            viewController.popToRestorationID = self.popToRestorationID
            viewController.navShown = self.navShown
            viewController.selectedMovie = movie
            viewController.paymentModes = paymentModes
            viewController.selectedTheatre = MovieTheatre(movieProviderID: dets.movieProviderID, name: dets.name, logo: "", restaurantID: dets.restaurantID, locationName: nil, latitude: nil, longitude: nil, rating: nil, distance: nil, rideCost: nil, mobileNumber: nil, wallet: [])
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if collectionView == self.collectionView {
                selectedAccount = indexPath.item
                self.collectionView.reloadData()
                if selectedAccount == 1 {
                    tableView.isHidden = false
                    runningCollection.isHidden = true
                    searchBar.placeholder = "Search Movie Theatres".localized
                    pageTitle.text = "Movie Theatres".localized
                    tableView.reloadData()
                    lblNoMovies.text = "Oops, it seems like there are no movie theatres in your area.".localized
                    tableView.es.startPullToRefresh()
                    closeSearch()
                    getMovieProviders()
                } else {
                    tableView.isHidden = true
                    runningCollection.isHidden = false
                    searchBar.placeholder = "Search Movies".localized
                    pageTitle.text = "Movies".localized
                    runningCollection.reloadData()
                    lblNoMovies.text = "Oops, it seems like there are no running movies in your area.".localized
                    runningCollection.es.startPullToRefresh()
                    closeSearch()
                    getLatestMovies()
                }
            } else {
                
                let movie = sortedMoviesArr[indexPath.item]
                
                let arrayAll = movie.showTimes
                var providersArr: [ShowTime] = []
                
                for each in (arrayAll ?? []) {
                    if !(providersArr.contains(where: { $0.movieProviderID == each.movieProviderID })) {
                        providersArr.append(each)
                    }
                }
                
                switch providersArr.count {
                case 0:
                    showAlerts(title: "", message: "No showtimes to show for \(movie.movieName ?? "this movie".localized)")
                case 1:
                    let movie = sortedMoviesArr[indexPath.item]
                    let dets = providersArr[0]
                    navigateToTrailer(movie, dets)
                default:
                    let vc = TheatrePicker()
                    vc.itemArray = providersArr
                    vc.movieName = movie.movieName ?? ""
                    vc.viewHeight = CGFloat(240 + (vc.itemArray.count * 50))
                    vc.proceedAction = {
                        let movie = self.sortedMoviesArr[indexPath.item]
                        let dets = vc.selectedShowtime
                        self.navigateToTrailer(movie, dets!)
                    }
                    presentPanModal(vc)
                }
                
            }
            
        }
}
