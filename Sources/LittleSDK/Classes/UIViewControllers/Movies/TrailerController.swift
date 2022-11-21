//
//  TrailerController.swift
//  
//
//  Created by Little Developers on 21/11/2022.
//

import UIKit
import AVKit
import AVFoundation

class TrailerController: UIViewController {
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.startAnimating()
        aiv.translatesAutoresizingMaskIntoConstraints = false
        return aiv
    }()
    
    lazy var pauseButton: UIButton = {
        let button = UIButton(type: .system)
        let image = getImage(named: "pause")
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pausePressed), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    lazy var controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.frame = trailerView.bounds
        return view
    }()
    
    let videoLengthLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    let videoCurrentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    lazy var videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setThumbImage(getImage(named: "track"), for: .normal)
        slider.maximumTrackTintColor = .white
        slider.minimumTrackTintColor = .littleBlue
        slider.addTarget(self, action: #selector(sliderValChanged), for: .valueChanged)
        return slider
    }()
    
    private let am = SDKAllMethods()
    private let hc = SDKHandleCalls()
    
    var paymentModes: [Balance] = []
    
    var selectedMovie: Movie?
    var selectedTheatre: MovieTheatre?
    var movieTimeingsArr: [MovieTimeing] = []
    var movieDatesArr: [MovieDateMovieDate] = []
    
    var player: AVPlayer?
    var isPlaying: Bool = false
    var selectedTime: Int?
    var selectedDate: Int = 0
    
    var myPromoCode: String = ""
    var myPromoAmount: Double = 0.0
    var myPromoType: String = ""
    var myMaxPromoAmount: Double = 0.0
    
    var myDisclaimerMessage: String = ""

    @IBOutlet weak var trailerView: UIView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblPlay: UILabel!
    @IBOutlet weak var imgPlay: UIImageView!
    @IBOutlet weak var imgPlayIcon: UIImageView!
    @IBOutlet weak var playView: UIView!
    
    @IBOutlet weak var dateCollection: UICollectionView!
    @IBOutlet weak var timeCollection: UICollectionView!
    
    @IBOutlet weak var lblMovieName: UILabel!
    @IBOutlet weak var lblMovieRating: UILabel!
    @IBOutlet weak var lblMovieCast: UILabel!
    @IBOutlet weak var lblDirector: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblTicketPrice: UILabel!
    @IBOutlet weak var lblFixedPrice: UILabel!
    @IBOutlet weak var lblNoMovies: UILabel!
    @IBOutlet weak var imgMovie: UIImageView!
    @IBOutlet weak var btnBuyTickets: UIButton!
    @IBOutlet weak var lblScreenDescription: UILabel!
    
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dateScrollHeight: NSLayoutConstraint!
    
    var popToRestorationID: UIViewController?
    var navShown: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let movie = selectedMovie!
        
        let nib = UINib.init(nibName: "MenuCategoryCell", bundle: .module)
        self.timeCollection.register(nib, forCellWithReuseIdentifier: "cell")
        
        let nib1 = UINib.init(nibName: "MenuCategoryCell", bundle: .module)
        self.dateCollection.register(nib1, forCellWithReuseIdentifier: "cell")
        
        lblMovieName.text = movie.movieName ?? ""
        lblMovieRating.text = "Rated".localized + ": \(movie.censorRating ?? "")"
        lblMovieCast.text = "Cast".localized + ": \(movie.actors ?? "")"
        lblDirector.text = "Director".localized + ": \(movie.director ?? "")"
        lblDuration.text = "\(Int(movie.duration ?? 0.0)) mins"
        lblDescription.text = "\(movie.movieDescription ?? "")"
        
        lblTicketPrice.text = "Select Screen".localized
        lblFixedPrice.text = ""
        lblScreenDescription.text = ""
        
        imgMovie.layoutIfNeeded()
        imgPlay.layoutIfNeeded()
        
        imgMovie.setTemplateWithSubviews(true)
        imgPlay.setTemplateWithSubviews(true)
        
        imgMovie.sd_setImage(with: URL(string: movie.movieImageSmall ?? "")) { (image, error, cahe, url) in
            self.imgMovie.setTemplateWithSubviews(false)
        }
        imgPlay.sd_setImage(with: URL(string: movie.movieImageBig ?? "")) { (image, error, cahe, url) in
            self.imgPlay.setTemplateWithSubviews(false)
        }

        btnBuyTickets.setTitle("Buy tickets".localized, for: .normal)
        btnBuyTickets.backgroundColor = .lightGray
        btnBuyTickets.setTitleColor(.darkGray, for: .normal)
        
        printVal(object: "These are my payment modes".localized + ": \(paymentModes) \(String(describing: self.restorationIdentifier))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "\(selectedTheatre?.name ?? selectedMovie?.movieName ?? "")"
        getMovies()
    }

    override func viewWillDisappear(_ animated: Bool) {
        player?.pause()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "currentItem.loadedTimeRanges" {
            activityIndicatorView.stopAnimating()
            controlsContainerView.backgroundColor = .clear
            pauseButton.isHidden = false
            isPlaying = true
            if let duration = player?.currentItem?.duration {
                let seconds = CMTimeGetSeconds(duration)
                let secondsText = Int(seconds) % 60
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                videoLengthLabel.text = "\(minutesText):\(secondsText)"
            }
            if self.isPlaying && !self.controlsContainerView.isHidden && self.controlsContainerView.alpha == 1.0 && self.pauseButton.image(for: .normal) == getImage(named: "pause") {
                trailerView.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.5, animations: {
                   self.controlsContainerView.alpha = 0
                }) { (completed) in
                    self.controlsContainerView.isHidden = true
                    self.trailerView.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    func getNextDate(index: Int) -> Date {
        let increament = index + 1
        let gregorian = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        let offsetComponents = NSDateComponents()
        offsetComponents.day = +increament
        let plusDate = gregorian!.date(byAdding: offsetComponents as DateComponents, to: Date(), options: [])!
        return plusDate
    }
    
    @objc func pausePressed() {
        if isPlaying {
            player?.pause()
            pauseButton.setImage(getImage(named: "play"), for: .normal)
        } else {
            player?.play()
            pauseButton.setImage(getImage(named: "pause"), for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    private func setupGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = controlsContainerView.bounds
        gradientLayer.colors = [UIColor.clear,UIColor.black]
        gradientLayer.locations = [0.7,1.2]
        controlsContainerView.layer.addSublayer(gradientLayer)
    }
    
    func playSetupActions() {
        
        trailerView.layoutIfNeeded()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showControls))
        trailerView.addGestureRecognizer(tap)
        
        func stop() {
            playView.isHidden = false
        }

        let urlStr = selectedMovie!.movieTrailer ?? ""
        
        if urlStr != "" {
            
            let url = URL(string: urlStr)
            
            if urlStr.contains("youtu") {
                
                let youtubeId = "\(urlStr.components(separatedBy: "/").last ?? "")"
                
                if let url = URL(string: "youtube://\(youtubeId)") {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
            } else {
                
                imgPlayIcon.isHidden = true
                
                player = AVPlayer(url: url!)
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.frame = trailerView.bounds
                trailerView.layer.addSublayer(playerLayer)
                player?.allowsExternalPlayback = true
                player?.volume = 1
                player?.play()
                player?.addObserver(self, forKeyPath: "currentItem.loadedTimeRanges", options: .new, context: nil)
                let interval = CMTime(value: 1, timescale: 2)
                player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { (progressTime) in
                    let seconds = CMTimeGetSeconds(progressTime)
                    let secondsString = String(format: "%02d", Int(seconds) % 60)
                    let minutesString = String(format: "%02d", Int(seconds) / 60)
                    self.videoCurrentTimeLabel.text = "\(minutesString):\(secondsString)"
                    
                    if let duration = self.player?.currentItem?.duration {
                        let totalSeconds = CMTimeGetSeconds(duration)
                        self.videoSlider.value = Float(seconds / totalSeconds)
                    }
                    
                })
                playView.isHidden = true
                
                controlsContainerView.frame = trailerView.bounds
                trailerView.addSubview(controlsContainerView)

                // setupGradient()
                
                controlsContainerView.addSubview(activityIndicatorView)
                activityIndicatorView.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor).isActive = true
                activityIndicatorView.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor).isActive = true

                controlsContainerView.addSubview(pauseButton)
                pauseButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor).isActive = true
                pauseButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor).isActive = true
                pauseButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
                pauseButton.widthAnchor.constraint(equalToConstant: 50).isActive = true

                controlsContainerView.addSubview(videoLengthLabel)
                videoLengthLabel.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor, constant: -8).isActive = true
                videoLengthLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor).isActive = true
                videoLengthLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
                videoLengthLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
                
                controlsContainerView.addSubview(videoCurrentTimeLabel)
                videoCurrentTimeLabel.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: 8).isActive = true
                videoCurrentTimeLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor).isActive = true
                videoCurrentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
                videoCurrentTimeLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
                
                controlsContainerView.addSubview(videoSlider)
                videoSlider.leftAnchor.constraint(equalTo: videoCurrentTimeLabel.rightAnchor).isActive = true
                videoSlider.rightAnchor.constraint(equalTo: videoLengthLabel.leftAnchor).isActive = true
                videoSlider.heightAnchor.constraint(equalToConstant: 24).isActive = true
                videoSlider.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor).isActive = true
            
            }
        }
        
    }
    
    @objc func showControls(_ sender: UITapGestureRecognizer) {
        if controlsContainerView.isHidden {
            controlsContainerView.alpha = 0
            controlsContainerView.isHidden = false
            trailerView.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.3, animations: {
                self.controlsContainerView.alpha = 1
            }) { (completed) in
                self.trailerView.isUserInteractionEnabled = true
            }
        }
    }
    
    @objc func sliderValChanged(_ sender: UISlider) {
        if let duration = player?.currentItem?.duration {
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float64(sender.value) * totalSeconds
            let seekTime = CMTime(value: Int64(value), timescale: 1)
            player?.seek(to: seekTime, completionHandler: { (completedSeek) in
                let seconds = CMTimeGetSeconds(seekTime)
                let secondsText = String(format: "%02d", Int(seconds) % 60)
                let minutesText = String(format: "%02d", Int(seconds) / 60)
                self.videoCurrentTimeLabel.text = "\(minutesText):\(secondsText)"
            })
        }
    }
    
    @IBAction func btnPlayTrailer(_ sender: UIButton) {
        playSetupActions()
    }
    
    @IBAction func btnBuyTicketsPressed(_ sender: UIButton) {
        
        if selectedTime == nil {
            
            showAlerts(title: "", message: "Please select sreening time before proceeding.".localized)
            
        } else {
            if selectedTheatre == nil {
                selectedTheatre = MovieTheatre(movieProviderID: selectedMovie?.showTimes?[selectedTime ?? 0].movieProviderID ?? "", name: selectedMovie?.showTimes?[selectedTime ?? 0].movieProviderID ?? "", logo: "", restaurantID: selectedMovie?.showTimes?[selectedTime ?? 0].restaurantID ?? "", locationName: "", latitude: 0.0, longitude: 0.0, rating: 0.0, distance: 0.0, rideCost: 0.0, mobileNumber: "", wallet: paymentModes)
            }
            
            
            if let viewController = UIStoryboard(name: "Movies", bundle: .module).instantiateViewController(withIdentifier: "ScreenController") as? ScreenController {
                viewController.popToRestorationID = self.popToRestorationID
                viewController.navShown = self.navShown
                selectedMovie?.movieTimeings = movieTimeingsArr
                viewController.paymentModes = paymentModes
                viewController.selectedMovie = selectedMovie
                viewController.selectedTheatre = selectedTheatre
                viewController.selectedTime = selectedTime ?? 0
                viewController.selectedDate = movieDatesArr[selectedDate].showDates ?? ""
                
                viewController.myPromoCode = myPromoCode
                viewController.myPromoAmount = myPromoAmount
                viewController.myPromoType = myPromoType
                viewController.myMaxPromoAmount = myMaxPromoAmount
                viewController.myDisclaimerMessage = myDisclaimerMessage
                
                if let navigator = self.navigationController {
                    navigator.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    func getMovies() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMovies),name:NSNotification.Name(rawValue: "GETMOVIESDETAILSMovies"), object: nil)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Locale.current.languageCode ?? "en")
        dateFormatter.dateFormat = "dd MMM"
        let date = dateFormatter.string(from: Date()) //"15 Aug"// dateFormatter.string(from: Date()) // "15 Aug 2021" //
        
        var params = SDKUtils.commonJsonTags(formId: "GETMOVIESDETAILS")
        params["GetMovies"] = [
            "MovieProviderID": selectedTheatre?.movieProviderID ?? "",
            "MovieID": selectedMovie?.movieID ?? "",
            "ShowDate": date
        ]
        
        let dataToSend = (try? SDKUtils.dictionaryToJson(from: params)) ?? ""
       
        hc.makeServerCall(sb: dataToSend, method: "GETMOVIESDETAILSMovies", switchnum: 0)
    }
    
    func reloadTimeCollectionHeights() {
        view.layoutIfNeeded()
        
        scrollViewHeight.constant = timeCollection.contentSize.height
        
        viewHeight.constant = 380 + lblDescription.bounds.height + timeCollection.contentSize.height
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func loadMovies(_ notification: Notification) {
        let data = notification.userInfo?["data"] as? Data
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "GETMOVIESDETAILSMovies"), object: nil)
        
        if let data = data {
            do {
                self.movieTimeingsArr.removeAll()
                let movies = try JSONDecoder().decode([PurpleMovieDate].self, from: data)
                myPromoCode = movies.first?.promoCode ?? ""
                myPromoAmount = movies.first?.promoAmount ?? 0.0
                myPromoType = movies.first?.promoType ?? ""
                myMaxPromoAmount = movies.first?.maxPromoAmount ?? 0.0
                myDisclaimerMessage = movies.first?.message ?? ""
                self.movieTimeingsArr = movies.first?.movieDates?[0].showDetails ?? []
                self.movieDatesArr = movies.first?.movieDates ?? []
            } catch(let error) {
                printVal(object: "err: \(error.localizedDescription)")
            }
            
            printVal(object: "Array: \(self.movieTimeingsArr)")
            
            if movieTimeingsArr.count > 0 {
                lblNoMovies.isHidden = true
            } else {
                lblNoMovies.text = "\(self.title ?? "This movie".localized) " + "is not currently screening".localized
                lblNoMovies.isHidden = false
            }
            
            dateCollection.reloadData()
            timeCollection.reloadData()
            
            reloadTimeCollectionHeights()
        }
    }
}

extension TrailerController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - CollectionView DataSource & Delegates
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let font = UIFont.systemFont(ofSize: 15)

        let varia = CGFloat(50.0)

        var text = ""
        
        if collectionView.tag == 20 {
            text = movieDatesArr[indexPath.item].showDates ?? ""
        } else {
            text = "\(movieTimeingsArr[indexPath.item].showTime ?? "") at \(movieTimeingsArr[indexPath.item].screenName ?? "")"
        }
        let size = CGSize(width: ((text.width(withConstrainedHeight: 30.0, font: font)) ) + varia, height: 40.0)

        return size
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 20 {
            return movieDatesArr.count
        } else {
            return movieTimeingsArr.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath) as! MenuCategoryCell
        if collectionView.tag == 20 {
            
            if selectedDate == indexPath.item {
                cell.categoryView.backgroundColor = SDKConstants.littleGreen
                cell.lblCategory.textColor = .littleWhite
            } else {
                cell.categoryView.backgroundColor = .littleCellBackgrounds
                cell.lblCategory.textColor = .littleLabelColor
            }
            
            cell.lblCategory.text = movieDatesArr[indexPath.item].showDates ?? ""
            
        } else {
            if selectedTime == indexPath.item {
                cell.categoryView.backgroundColor = .littleBlue
                cell.lblCategory.textColor = .littleWhite
            } else {
                cell.categoryView.backgroundColor = .littleCellBackgrounds
                cell.lblCategory.textColor = .littleLabelColor
            }
            
            var text = ""
            text = "\(movieTimeingsArr[indexPath.item].showTime ?? "") at \(movieTimeingsArr[indexPath.item].screenName ?? "")"

            cell.lblCategory.text = text
        }

        return cell
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 20 {
            
//            dateCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            
            if selectedDate != indexPath.item {
                selectedTime = nil
                lblTicketPrice.text = "Select Screen".localized
                lblFixedPrice.text = ""
                lblScreenDescription.text = ""
                
                btnBuyTickets.setTitle("Buy tickets".localized, for: .normal)
                btnBuyTickets.backgroundColor = .lightGray
                btnBuyTickets.setTitleColor(.darkGray, for: .normal)
                
            }
            selectedDate = indexPath.item
            dateCollection.reloadData()
            movieTimeingsArr = movieDatesArr[indexPath.item].showDetails ?? []
            timeCollection.reloadData()
            
            reloadTimeCollectionHeights()
            
        } else {
            selectedTime = indexPath.item
            
            if movieTimeingsArr.count > 0  {
                
                var discount = 0.00
                var total = (movieTimeingsArr[selectedTime ?? 0].ticketPrice ?? 0.0)
                
                if myPromoCode != "" && myPromoAmount != 0.0 {
                    var myDiscount = myPromoAmount
                    if myPromoType == "P" {
                        myDiscount = myPromoAmount*(total)/100
                        discount = discount + myDiscount
                    } else {
                        discount = myPromoAmount
                    }
                }
                
                if myPromoType == "P" && discount > myMaxPromoAmount {
                    discount = myMaxPromoAmount
                }
                
                if discount > 0.0 {
                    let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: "\(am.getGLOBALCURRENCY()!) \(total)")
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                    lblFixedPrice.attributedText = attributeString
                    total = total - Double(Int(discount))
                    if total < 0 {
                        total = 0
                    }
                    lblTicketPrice.text = "\(am.getGLOBALCURRENCY()!) \(total)"
                    btnBuyTickets.setTitle("Buy tickets @ \(am.getGLOBALCURRENCY()!) \(total) each", for: .normal)
                    
                } else {
                    lblFixedPrice.text = ""
                    lblTicketPrice.text = "\(am.getGLOBALCURRENCY()!) \(movieTimeingsArr[selectedTime ?? 0].ticketPrice ?? 0.0)"
                    btnBuyTickets.setTitle("Buy tickets @ \(am.getGLOBALCURRENCY()!) \(Int(movieTimeingsArr[selectedTime ?? 0].ticketPrice ?? 0.0)) each", for: .normal)
                }
                
                lblScreenDescription.text = "\(movieTimeingsArr[selectedTime ?? 0].screenDescription ?? "")"
                
                btnBuyTickets.backgroundColor = .littleBlue
                btnBuyTickets.setTitleColor(.littleWhite, for: .normal)
                
            } else {
                
                lblTicketPrice.text = "Select Screen".localized
                lblFixedPrice.text = ""
                lblScreenDescription.text = ""
                
                btnBuyTickets.setTitle("Buy tickets".localized, for: .normal)
                btnBuyTickets.backgroundColor = .lightGray
                btnBuyTickets.setTitleColor(.darkGray, for: .normal)
                
            }
            timeCollection.reloadData()
        }
        
        
        
    }
}
