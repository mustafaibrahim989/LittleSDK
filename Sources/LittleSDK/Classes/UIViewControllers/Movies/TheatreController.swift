//
//  TheatreController.swift
//  
//
//  Created by Little Developers on 21/11/2022.
//

import UIKit

private let cellID = "CellID"

class TheatreController: UIViewController {

    private let am = SDKAllMethods()
    private let hc = SDKHandleCalls()

    var paymentModes: [Balance] = []
    var moviePlacesData: Data?
    var selectedTheatre: MovieTheatre?
    var moviesArr: [Movie] = []
    var sortedMoviesArr: [Movie] = []
    
    var searchTerm = ""
    
    var columnCount: Int = 2
    var myCellWidth: CGFloat = 0
    var myCellHeight: CGFloat = 0
    
    var stackSearch: UIStackView!
    var searchBar: UITextField!
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noMoviesView: UIView!
    @IBOutlet weak var lblNoMovies: UILabel!
    @IBOutlet weak var btnSearch: UIBarButtonItem!
    @IBOutlet weak var btnCancelSearch: UIButton!
    @IBOutlet weak var lblSearchResults: UILabel!
    @IBOutlet weak var searchBtnHeight: NSLayoutConstraint!
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        self.collectionView.register(MyMovieCell.self, forCellWithReuseIdentifier: cellID)
        self.collectionView.collectionViewLayout = CenterAlignedCVFlowLayout()
                
        collectionView.reloadData()
        
        collectionView.es.addPullToRefresh {
            [unowned self] in
            self.getMovies()
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
        
        printVal(object: "These are my payment modes: \(paymentModes) \(self.restorationIdentifier)")
    }

    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.title = "\(selectedTheatre?.name ?? "")"
        
        lblNoMovies.text = "Oops, seems like there are no movies at the moment at".localized + " \(selectedTheatre?.name ?? "")"
        
        getMovies()
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
        pageTitle.text = "\(selectedTheatre?.name ?? "")"
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
        searchBar.placeholder = "Search \(selectedTheatre?.name ?? "")"
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

    func getMovies() {
        
        noMoviesView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMovies),name:NSNotification.Name(rawValue: "GETMOVIESMovies"), object: nil)
        
        var params = SDKUtils.commonJsonTags(formId: "GETMOVIES")
        params["GetMovies"] = [
            "MovieProviderID": selectedTheatre?.movieProviderID ?? ""
        ]
        
        let dataToSend = (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
       
        hc.makeServerCall(sb: dataToSend, method: "GETMOVIESMovies", switchnum: 0)
    }
       
    @objc func loadMovies(_ notification: Notification) {
        
        collectionView.es.stopPullToRefresh()
        
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETMOVIESMovies"), object: nil)
        
        if let data = data {
            do {
                if moviePlacesData != data {
                    moviePlacesData = data
                    moviesArr.removeAll()
                    sortedMoviesArr.removeAll()
                    let movieTheatres = try JSONDecoder().decode(Movies.self, from: data)
                    moviesArr = movieTheatres
                    sortedMoviesArr = movieTheatres
                    collectionView.reloadData()
                }
            } catch {
                moviesArr.removeAll()
                sortedMoviesArr.removeAll()
                collectionView.reloadData()
            }
        }
        
        if moviesArr.count > 0 {
            noMoviesView.isHidden = true
        } else {
            noMoviesView.alpha = 0
            noMoviesView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.noMoviesView.alpha = 1
            }
        }
    }
    
    func searchFromMovies() {
        
        var arr: [Movie] = []
        
        searchBtnHeight.constant = 130
        
        for each in moviesArr {
            if each.movieName?.lowercased().contains(searchTerm.lowercased()) ?? false  {
                arr.append(each)
            }
        }
        sortedMoviesArr = arr
        if sortedMoviesArr.count > 0 {
            noMoviesView.isHidden = true
            lblNoMovies.text = "Oops, it seems like there are no movies by \(selectedTheatre?.name ?? "") at the moment."
        } else {
            lblNoMovies.text = "Oops, it seems like there are no movies by \(selectedTheatre?.name ?? "") with the search term \"\(searchTerm)\"."
            noMoviesView.alpha = 0
            noMoviesView.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.noMoviesView.alpha = 1
            }
        }
        
        collectionView.reloadData()
        
        btnCancelSearch.isHidden = false
        lblSearchResults.text = "Search results for".localized + " \"\(searchTerm)\""
        
    }
    
    func closeSearch() {
        
        searchBtnHeight.constant = 126
        
        searchBar.text = ""
        lblSearchResults.text = ""
        btnCancelSearch.isHidden = true
        
        sortedMoviesArr = moviesArr
        
        if sortedMoviesArr.count > 0 {
            noMoviesView.isHidden = true
        } else {
            noMoviesView.isHidden = false
        }
        
        collectionView.reloadData()
    }
    
    @objc func loadFromSearch(_ notification: Notification) {
        
        let data = notification.userInfo?["data"] as? String
        
        if data != nil {
            if data != "" {
                
                searchTerm = data!
                searchFromMovies()
                
            } else {
                closeSearch()
            }
        } else {
            closeSearch()
        }
    }
    
    @IBAction func btnSearchPressed(_ sender: UIBarButtonItem) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadFromSearch),name:NSNotification.Name(rawValue: "FROMSEARCH"), object: nil)
        
        closeSearch()
        
        #warning("check search")
        let popOverVC = UIStoryboard(name: "Order", bundle: .module).instantiateViewController(withIdentifier: "SearchController") as! SearchController
        self.addChild(popOverVC)
        popOverVC.view.frame = UIScreen.main.bounds
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
    @IBAction func btnCloseSearch(_ sender: UIButton) {
        closeSearch()
    }
    
}

extension TheatreController: UITextFieldDelegate {
    
    @objc func textChanged(_ sender: UITextField) {
        if sender.text == "" {
            closeSearch()
        } else {
            searchTerm = sender.text ?? ""
            searchFromMovies()
        }
    }
    
}


extension TheatreController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: myCellWidth, height: myCellHeight)
    }

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedMoviesArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewController = UIStoryboard(name: "Movies", bundle: .module).instantiateViewController(withIdentifier: "TrailerController") as? TrailerController {
            viewController.popToRestorationID = self.popToRestorationID
            viewController.navShown = self.navShown
            viewController.selectedMovie = sortedMoviesArr[indexPath.item]
            viewController.selectedTheatre = selectedTheatre
            viewController.paymentModes = paymentModes
            if let navigator = self.navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }
}
