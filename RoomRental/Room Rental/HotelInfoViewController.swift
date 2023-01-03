import UIKit
import SafariServices

class HotelInfoViewController: UIViewController{
    
    @IBOutlet weak var CityPhotoImageView: UIImageView!
    @IBOutlet weak var PhotoScrollView: UIScrollView!
    @IBOutlet weak var ConstWidthViewInfo: NSLayoutConstraint!
    @IBOutlet weak var ConstWidthViewImage: NSLayoutConstraint!
    @IBOutlet weak var InfoScrollView: UIScrollView!
    @IBOutlet weak var ImagesScrollView: UIScrollView!
    @IBOutlet weak var ScrollPageControl: UIPageControl!
    @IBOutlet weak var HotelNameLabel: UILabel!
    @IBOutlet weak var ConstWidthViewPhoto: NSLayoutConstraint!
    @IBOutlet weak var NumberHotelsCityLabel: UILabel!
    @IBOutlet weak var PhotoCounterLabel: UILabel!
    @IBOutlet weak var LoadingActIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ChooseAndBookRoomButton: UIButton!
    @IBOutlet var StarRatingImageViewArr: [UIImageView]!
    @IBOutlet weak var BackPhotoImageView: UIImageView!
    @IBOutlet weak var BackPhotoView: UIView!
    @IBOutlet weak var ForwardPhotoImageView: UIImageView!
    @IBOutlet weak var ForwardPhotoView: UIView!
    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var BackControllerView: UIView!
    @IBOutlet weak var ImagesView: UIView!
    @IBOutlet weak var CityNameLabel: UILabel!
    @IBOutlet weak var PhotosView: UIView!
    @IBOutlet weak var HotelAddressLabel: UILabel!
    
    var CurrentPhoto:Int = 1
    
    let cellReuseIdentifier = "cell"
    
    var toastMessage = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirstTransition), name: Notification.Name("FirstTransition"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SecondTransition), name: Notification.Name("SecondTransition"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TransitionHotelsFound), name: Notification.Name("TransitionHotelsFound"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TransitionOldHotels), name: Notification.Name("TransitionOldHotels"), object: nil)
        
        LoadingActIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        LoadingActIndicator.stopAnimating()
        LoadingActIndicator.isHidden = true
        LoadingView.alpha = 0
        
        ImagesScrollView.bounces = false
        InfoScrollView.bounces = false
        
        ChooseAndBookRoomButton.layer.cornerRadius = 10
        
        ConstWidthViewInfo.constant = view.frame.width
        
        let item = ShowHotels[SelectedHotelNumber]
        let HotelPhoto:[Data] = item["HotelPhoto"] as! [Data]
        let StarRating:Int = item["StarRating"] as! Int
        let NameHotel:String = item["NameHotel"] as! String
        let Address:String = item["Address"] as! String
        let CityPhoto:Data = item["CityPhoto"] as! Data
        let CityName:String = item["CityName"] as! String
        let NumberHotelsCity:String = item["NumberHotelsCity"] as! String
        
        PhotoCounterLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        PhotoCounterLabel.textColor = UIColor.white
        PhotoCounterLabel.layer.masksToBounds = true
        PhotoCounterLabel.layer.cornerRadius = 10
        PhotoCounterLabel.text = "1 of 20"
        PhotosView.addSubview(PhotoCounterLabel)
        
        ConstWidthViewImage.constant = view.frame.width * CGFloat(4)
        ConstWidthViewPhoto.constant = view.frame.width * CGFloat(HotelPhoto.count - 2)
        
        ImagesScrollView.delegate = self
        PhotoScrollView.delegate = self
        ScrollPageControl.numberOfPages = 4
        ImagesScrollView.contentSize = CGSize(width: view.frame.size.width*4, height: ImagesScrollView.frame.size.height)
        ImagesScrollView.isPagingEnabled = true
        
        PhotoScrollView.contentSize = CGSize(width: view.frame.size.width*4, height: PhotoScrollView.frame.size.height)
        PhotoScrollView.isPagingEnabled = true
        
        PhotosView.addSubview(BackPhotoImageView)
        PhotosView.addSubview(BackPhotoView)
        PhotosView.addSubview(ForwardPhotoImageView)
        PhotosView.addSubview(ForwardPhotoView)
        
        let HotelPhotoArr = Array(HotelPhoto[HotelPhoto.count - 4...HotelPhoto.count - 1])
        let HotelPhotoReversArr = Array(HotelPhotoArr.reversed())
        
        for i in 0..<4{
            
            let СurrentImage = UIImageView()
            СurrentImage.contentMode = .scaleToFill
            let data:Data = HotelPhotoReversArr[i]
            guard let DataDecoded = try? PropertyListDecoder().decode(Data.self, from: data) else { return }
            let image = UIImage(data: DataDecoded)
            СurrentImage.image = image
            let xPos = CGFloat(i)*(self.view.bounds.size.width)
            СurrentImage.frame = CGRect(x: xPos, y: 0, width: view.frame.size.width, height: ImagesScrollView.frame.size.height)
            ImagesScrollView.contentSize.width = view.frame.size.width*CGFloat(i+1)
            ImagesScrollView.addSubview(СurrentImage)
            
        }
        
        var PhotoNumber:Int = 0
        
        for j in 0..<HotelPhoto.count - 2{
            
            let СurrentImage = UIImageView()
            СurrentImage.contentMode = .scaleToFill
            
            switch j{
            case 0:
                PhotoNumber = 19
            case 1...20:
                PhotoNumber = j - 1
            case 21:
                PhotoNumber = 0
            default:
                print("error")
            }
            
            let data:Data = HotelPhoto[PhotoNumber]
            guard let DataDecoded = try? PropertyListDecoder().decode(Data.self, from: data) else { return }
            let image = UIImage(data: DataDecoded)
            СurrentImage.image = image
            let xPos = CGFloat(j)*(self.view.bounds.size.width)
            СurrentImage.frame = CGRect(x: xPos, y: 0, width: view.frame.size.width, height: PhotoScrollView.frame.size.height)
            PhotoScrollView.contentSize.width = view.frame.size.width*CGFloat(j+1)
            PhotoScrollView.addSubview(СurrentImage)
            
        }
        
        ImagesScrollView.showsHorizontalScrollIndicator = false
        PhotoScrollView.showsHorizontalScrollIndicator = false
        
        HotelNameLabel.numberOfLines = 1
        HotelNameLabel.text = NameHotel
        
        CityNameLabel.text = CityName
        CityNameLabel.numberOfLines = 1
        
        NumberHotelsCityLabel.text = NumberHotelsCity + " hotels in this city"
        
        ScrollPageControl.addTarget(self, action: #selector(PageChange(_:)), for: .valueChanged)
        
        let data:Data = CityPhoto
        guard let DataDecoded = try? PropertyListDecoder().decode(Data.self, from: data) else { return }
        let image = UIImage(data: DataDecoded)
        CityPhotoImageView.image = image
        
        ImagesView.addSubview(ScrollPageControl)
        
        for k in 0...4{ StarRatingImageViewArr[k].alpha = 0 }
        if StarRating > 0{
            for l in 0...(StarRating - 1){ StarRatingImageViewArr[l].alpha = 1 }
        }
        for m in 0...4{ ImagesView.addSubview(StarRatingImageViewArr[m]) }
        
        HotelAddressLabel.text = Address
        HotelAddressLabel.numberOfLines = 1
        
        PhotoScrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0 ), animated: false)
        
        let tapBackPhotoView = UITapGestureRecognizer(target: self, action: #selector(self.BackPhoto))
        BackPhotoView.addGestureRecognizer(tapBackPhotoView)
        
        let tapForwardPhotoView = UITapGestureRecognizer(target: self, action: #selector(self.ForwardPhoto))
        ForwardPhotoView.addGestureRecognizer(tapForwardPhotoView)
        
        let tapBackControllerView = UITapGestureRecognizer(target: self, action: #selector(self.BackController))
        BackControllerView.addGestureRecognizer(tapBackControllerView)
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)

        updateUserInterface()
  
    }
    
    func updateUserInterface(){
        
         switch Network.reachability.status {
         case .unreachable:
             LoadingActIndicator.stopAnimating()
             UserDefaults.standard.setValue(0, forKey: "NetworkStatus")
             noNetwork()
         case .wwan:
             print("wwan")
         case .wifi:
             if UserDefaults.standard.integer(forKey: "NetworkStatus") != 1{
                 noRestart()
             }
         }

     }
        
     @objc func statusManager(_ notification: Notification) {
         updateUserInterface()
     }
        
        func noNetwork(){
            
            let alertController = UIAlertController (title: "Connection error", message: "Unable to connect with the server. Check your internet connection, then restart the application", preferredStyle: .alert)
            
            let TryAgainAction = UIAlertAction(title: "Try again", style: .cancel) { (_) -> Void in
                
                self.updateUserInterface()

            }
            
            alertController.addAction(TryAgainAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
        
        func noRestart(){
            let alertController = UIAlertController (title: "Internet connection restored.", message: "Now restart the application for further operation.", preferredStyle: .alert)
            
            let OkAction = UIAlertAction(title: "Ok", style: .cancel) { (_) -> Void in
                
                self.updateUserInterface()

            }
            
            alertController.addAction(OkAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    
    @objc
    private func BackController(){
        
        if (((ControlTransitions == 1) && (LastRequestController == 0)) || (ShowHotels.isEmpty)){
            
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            
        }else{
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    
    
    @IBAction func ChooseAndBookRoomAction(_ sender: Any) {
        
        if ((SelectedDates != "") && (NumberOfGuests != "")){
            
            var item:[String : Any] = [:]
            
            if !ShowHotels.isEmpty{
                item = ShowHotels[SelectedHotelNumber]
            }else{
                item = DefaultHotels[SelectedHotelNumber]
            }
            
            let NameHotel:String = item["NameHotel"] as! String
            let CityId:Int = item["CityId"] as! Int
            let HotelId:String = item["HotelId"] as! String
            
            let count = (Int(NumberOfChildren) ?? 0) - 1
            
            var children = ""
            if count >= 0{
                children = String(repeating: "17%2C", count: count)
                children += "17"
            }else{
                children += ""
            }
            
            let UpdatedNameHotel = NameHotel.replacingOccurrences(of: ",", with: "")
            let TwiceUpdatedNameHotel = UpdatedNameHotel.replacingOccurrences(of: " ", with: "+")

            let Link = "https://search.hotellook.com/" +
            "hotels?=1" +
            "&adults=" + NumberOfAdults +
            "&checkIn=" + CheckInDate +
            "&checkOut=" + CheckOutDate +
            "&children=" + children +
            "&cityId=" + String(CityId) +
            "&currency=usd" +
            "&destination=" + TwiceUpdatedNameHotel +
            "&hotelId=" + HotelId +
            "&language=en_us" +
            "&marker=google.Zz9d7d709f133841cd90a542d-126017#mds%3Dhotels_proposal"
            
            let UpdatedLink = Link.replacingOccurrences(of: " ", with: "")
            
            if let url = URL(string: UpdatedLink){
                
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: url, configuration: config)
                present(vc, animated: true)
                
            }else{
                
                guard let url = URL(string: "https://search.hotellook.com/hotels?=1&adults=1&checkIn=2022-11-21&checkOut=2022-11-23&children=17&cityId=3683&currency=usd&destination=Hotel+Madrid+Atocha+Affiliated+by+Meli%C3%A1&hotelId=0&language=en_us&marker=google.Zz9d7d709f133841cd90a542d-126017#mds%3Dhotels_proposal") else { return }
                
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                let vc = SFSafariViewController(url: url, configuration: config)
                present(vc, animated: true)
                
            }
            
        }else{
            showToast(message: "Fill in the \"Dates\" and \"Guests\" parameters\n under \"Room Rental\"")
        }
        
    }
    
    @IBAction func OtherOptionsAction(_ sender: Any) {
        
        if ((SelectedDates != "") && (NumberOfGuests != "")){
            
            let dict = ["Location" : CityNameLabel.text!,"Dates" : SelectedDates,"Guests" : NumberOfGuests]
            
            SeeOtherOptionsClick = 1
            
            if ((dict == CityHotelParameters) && (FindHotelClick == 0)){
                
                ShowHotels = HotelsFound
                
                NotificationCenter.default.post(name: Notification.Name("UpdateTableView"), object: nil)
                
            }else{
                
                FindHotelClick = 0
                
                CityHotelParameters = dict
                
                LastRequestController = 1
                
                LoadingView.alpha = 0.7
                view.isUserInteractionEnabled = false
                LoadingActIndicator.isHidden = false
                LoadingActIndicator.startAnimating()
                NotificationCenter.default.post(name: Notification.Name("ScrollTopTableView"), object: nil)
                
            }
            
        }else{
            showToast(message: "Fill in the \"Dates\" and \"Guests\" parameters\n under \"Room Rental\"")
        }
        
    }
    
    @objc
    func FirstTransition(){
        NotificationCenter.default.post(name: Notification.Name("HotelSearch"), object: nil)
    }
    
    @objc func SecondTransition(){
        NotificationCenter.default.post(name: Notification.Name("DataUpdate"), object: nil)
    }
    
    @objc
    func TransitionHotelsFound(){
        
        LoadingActIndicator.stopAnimating()
        LoadingActIndicator.isHidden = true
        view.isUserInteractionEnabled = true
        LoadingView.alpha = 0
        
        if !ShowHotels.isEmpty{
            dismiss(animated: true, completion: nil)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { [self] in
                showToast(message: "No hotels were found. Try changing search\n parameters and try again")
            }
        }
        
    }
    
    @objc
    func TransitionOldHotels(){
        
        if !ShowHotels.isEmpty{
            dismiss(animated: true, completion: nil)
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { [self] in
                showToast(message: "No hotels were found. Try changing search\n parameters and try again")
            }
        }
        
    }
    
    @objc
    private func BackPhoto(){
        
        CurrentPhoto -= 1
        PhotoScrollView.setContentOffset(CGPoint(x: CurrentPhoto * Int(view.frame.width), y: 0 ), animated: true)
        
    }
    
    @objc
    private func ForwardPhoto(){
        
        CurrentPhoto += 1
        PhotoScrollView.setContentOffset(CGPoint(x: CurrentPhoto * Int(view.frame.width), y: 0 ), animated: true)
        
    }
    
    @objc private func PageChange(_ sender: UIPageControl){
        
        let CurrentPage = sender.currentPage
        ImagesScrollView.setContentOffset(CGPoint(x: CGFloat(CurrentPage) * (view.frame.size.width), y: 0), animated: true)
        
    }
    
}

extension HotelInfoViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        ScrollPageControl.currentPage = Int(floorf((Float(ImagesScrollView.contentOffset.x) + (Float(view.frame.width) / 2)) / Float(ImagesScrollView.frame.size.width)))
        
        var PhotoCount = Int(floorf((Float(PhotoScrollView.contentOffset.x) + (Float(view.frame.width) / 2)) / Float(view.frame.width)))
        if PhotoCount == 0{ PhotoCount = 20 }
        if PhotoCount == 21{ PhotoCount = 1 }
        
        PhotoCounterLabel.text = String(PhotoCount) + " of 20"
        
        let ContentOffsetX = Int(floorf(Float(PhotoScrollView.contentOffset.x)))
        let tapeWidth = Int(view.frame.width) * 21
        
        switch (ContentOffsetX, tapeWidth){
        case _ where ContentOffsetX >= tapeWidth :
            
            if PhotoScrollView.contentOffset.x > (view.frame.width * 21){
                PhotoScrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0 ), animated: false)
                PhotoScrollView.setContentOffset(CGPoint(x: (view.frame.width * 2), y: 0 ), animated: true)
                CurrentPhoto = 2
            }else{
                PhotoScrollView.setContentOffset(CGPoint(x: view.frame.width, y: 0 ), animated: false)
                CurrentPhoto = 1
            }
            
        case _ where ContentOffsetX <= 0 :
            
            if PhotoScrollView.contentOffset.x < 0{
                PhotoScrollView.setContentOffset(CGPoint(x: (view.frame.width * 20), y: 0 ), animated: false)
                PhotoScrollView.setContentOffset(CGPoint(x: (view.frame.width * 19), y: 0 ), animated: true)
                CurrentPhoto = 19
            }else{
                PhotoScrollView.setContentOffset(CGPoint(x: (view.frame.width * 20), y: 0 ), animated: false)
                CurrentPhoto = 20
            }
            
        case _ where ((ContentOffsetX > 0) && (ContentOffsetX < tapeWidth)):
            
            CurrentPhoto = Int(floorf((Float(PhotoScrollView.contentOffset.x) + (Float(view.frame.width) / 2)) / Float(view.frame.width)))
            
        default:
            print("error")
        }
        
    }
    
}

extension HotelInfoViewController {
    
    func showToast(message : String) {
        
        toastMessage = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 155, y: self.view.frame.size.height-110, width: 310, height: 55))
        toastMessage.backgroundColor = UIColor.black.withAlphaComponent(1)
        toastMessage.textColor = UIColor.white
        toastMessage.font = .systemFont(ofSize: 14)
        toastMessage.textAlignment = .center;
        toastMessage.numberOfLines = 2
        toastMessage.text =  message
        toastMessage.alpha = 1.0
        toastMessage.layer.cornerRadius = 10;
        toastMessage.clipsToBounds  =  true
        self.view.addSubview(toastMessage)
        UIView.animate(withDuration: 8.0, delay: 5.0, options: .curveEaseOut, animations: { [self] in
            toastMessage.alpha = 0.0
        }, completion: { [self](isCompleted) in
            toastMessage.removeFromSuperview()
        })
    }
}
