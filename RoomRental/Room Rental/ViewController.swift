import UIKit

var LatitudeСoordinate:Float = 0.0
var LongitudeCoordinate:Float = 0.0

var SelectedHotelNumber = 0

var HotelsFound:[[String:Any]] = []
var ShowHotels:[[String:Any]] = []

var ExactSelectedLocation:String = ""
var SelectedLocation:String = ""
var SelectedDates:String = ""
var NumberOfGuests = ""

var CheckInDate:String = ""
var CheckOutDate:String = ""
var NumberOfAdults:String = "0"
var NumberOfChildren:String = "0"

var ControlTransitions = 0
var LastRequestController = 0

var FindHotelClick = 0
var SeeOtherOptionsClick = 0

var ParametersOfFoundHotels:[String:String] = [:]
var CityHotelParameters:[String:String] = [:]

var ImageWrongCity = Data()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var NumberOfHotels:Int = 0
    var MinPrice = 0
    var StarRating = 0
    var NameHotel = ""
    var NumberHotelsCity = ""
    var HotelPhoto:[Data] = []
    var CityName:String = ""
    var HotelId:String = ""
    var CityId:Int = 0
    var iataCity:String = ""
    var HotelLongitudeCoordinate:Float = 0.0
    var HotelLatitudeCoordinate:Float = 0.0
    var CityPhoto = Data()
    var ValidKey = Keys[0]
    var KeyNum = 0
    var Address:String = ""
    
    let cellReuseIdentifier = "cell"
    
    var toastMessage = UILabel()
    
    @IBOutlet weak var ConstWidthDates: NSLayoutConstraint!
    @IBOutlet weak var ConstWidthGuests: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var DatesLabel: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var GuestsLabel: UILabel!
    @IBOutlet weak var LocationButton: UIButton!
    @IBOutlet weak var DatesButton: UIButton!
    @IBOutlet weak var GuestsButton: UIButton!
    @IBOutlet weak var FindHotelButton: UIButton!
    @IBOutlet weak var LoadingView: UIView!
    @IBOutlet weak var LoadingActIndicator: UIActivityIndicatorView!
    
    var СurrentHotelNumber = 0{
        didSet{
            if СurrentHotelNumber < NumberOfHotels{
                
                if LastRequestController == 0{
                    if ExactSelectedLocation != ""{
                        HotelInfoRequest()
                    }else {
                        SecondRequestHotelInfo()
                    }
                }else {
                    SecondRequestHotelInfo()
                }

            }else{

                
                let NetworkStatus = UserDefaults.standard.integer(forKey: "NetworkStatus")
                if NetworkStatus == 1{
                    
                    СurrentHotelNumber = 0
                    
                    ShowHotels = []
                    ShowHotels = HotelsFound
                    
                    DispatchQueue.main.async { [self] in
                        
                        if LastRequestController == 0{
                            
                            LoadingActIndicator.stopAnimating()
                            LoadingActIndicator.isHidden = true
                            LoadingView.alpha = 0
                            
                            if !ShowHotels.isEmpty{
                                
                                let next = self.storyboard?.instantiateViewController(withIdentifier: "FoundHotelsViewController") as? FoundHotelsViewController
                                next?.modalPresentationStyle = .overFullScreen
                                self.present(next!, animated: true, completion: nil)
                                
                            }else{
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { [self] in
                                    showToast(message: "No hotels were found. Try changing search\n parameters and try again", width: 310, hight: 55, delay: 5.0)
                                }
                            }
                            
                        }else{
                            NotificationCenter.default.post(name: Notification.Name("SecondTransition"), object: nil)
                        }
                        
                    }
                    
                }else{
                    if LastRequestController == 0{
                        DispatchQueue.main.async {
                            self.LoadingActIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
             updateUserInterface()
        }
        
        if UserDefaults.standard.object(forKey: "KeyInfo") != nil{
            let item = UserDefaults.standard.object(forKey: "KeyInfo") as! [String : Any]
            ValidKey = item["ValidKey"] as! String
            KeyNum = item["KeyNum"] as! Int
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(HotelSearch), name: Notification.Name("HotelSearch"), object: nil)
        
        LoadingActIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        LoadingActIndicator.stopAnimating()
        LoadingActIndicator.isHidden = true
        LoadingView.alpha = 0
        
        ConstWidthDates.constant = (view.frame.width-50)/2
        ConstWidthGuests.constant = (view.frame.width-50)/2
        
        tableView.dataSource = self
        tableView.delegate = self
        
        LocationButton .layer.cornerRadius = 10
        DatesButton.layer.cornerRadius = 10
        GuestsButton.layer.cornerRadius = 10
        FindHotelButton.layer.cornerRadius = 10
        
        LocationLabel.numberOfLines = 1
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        
    }
    
    func updateUserInterface(){
        
        switch Network.reachability.status {
        case .unreachable:
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
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 345.0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DefaultHotels.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MyCustomCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MyCustomCell
        
        let item = DefaultHotels[indexPath.row]
        let HotelPhoto:[Data] = item["HotelPhoto"] as! [Data]
        let StarRating:Int = item["StarRating"] as! Int
        let MinPrice:Int = item["MinPrice"] as! Int
        let NameHotel:String = item["NameHotel"] as! String
        let Address:String = item["Address"] as! String
        
        cell.ConstWidthScrollView.constant = view.frame.size.width - 32
        cell.ConstWidthView.constant = (view.frame.width - 32) * 4
        cell.ImagesScrollView.contentSize = CGSize(width: view.frame.width*4, height: cell.ImagesScrollView.frame.size.height)
        cell.ImagesScrollView.isPagingEnabled = true
        
        let HotelPhotoArr = Array(HotelPhoto[HotelPhoto.count - 4...HotelPhoto.count - 1])
        let HotelPhotoReversArr = Array(HotelPhotoArr.reversed())
        
        for i in 0..<4{
            
            let СurrentImage = UIImageView()
            СurrentImage.contentMode = .scaleToFill
            let data:Data = HotelPhotoReversArr[i]
            let DataDecoded = try! PropertyListDecoder().decode(Data.self, from: data)
            let image = UIImage(data: DataDecoded)
            СurrentImage.image = image
            let xPos = CGFloat(i)*(view.frame.width - CGFloat(32))
            СurrentImage.frame = CGRect(x: xPos, y: 0, width: view.frame.size.width - 32, height: cell.ImagesScrollView.frame.size.height)
            cell.ImagesScrollView.contentSize.width = (view.frame.width - 32)*CGFloat(i+1)
            cell.ImagesScrollView.addSubview(СurrentImage)
            
        }
        
        cell.ImagesScrollView.layer.cornerRadius = 10
        cell.CoverView.layer.borderWidth = 0.1
        cell.CoverView.layer.cornerRadius = 10
        cell.ScrollPageControl.numberOfPages = 4
        cell.HotelNameLabel.text = NameHotel
        cell.HotelNameLabel.font = UIFont.systemFont(ofSize: 18)
        cell.HotelNameLabel.numberOfLines = 1
        cell.HotelAddressLabel.text = Address
        cell.HotelAddressLabel.alpha = 0.8
        cell.HotelAddressLabel.font = UIFont.systemFont(ofSize: 12)
        cell.MinPriceButton.tag = indexPath.row
        cell.MinPriceButton.setTitle("From $" + String(MinPrice) + "/night", for: .normal)
        for j in 0...4{ cell.StarRatingImageViewArr[j].alpha = 0 }
        if StarRating > 0{
            for k in 0...(StarRating - 1){ cell.StarRatingImageViewArr[k].alpha = 1 }
        }
        for l in 0...4{ cell.CoverView.addSubview(cell.StarRatingImageViewArr[l]) }
        cell.CoverView.addSubview(cell.MinPriceButton)
        cell.CoverView.addSubview(cell.ScrollPageControl)
        cell.CoverView.addSubview(cell.AlignView)
        cell.selectionStyle = .none
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.bounces = false
        cell.ImagesScrollView.bounces = false
        
        return cell
        
    }
    
    @IBAction func MinPriceAction(_ sender: UIButton) {
        
        ControlTransitions = 1
        LastRequestController = 0
        
        ShowHotels = DefaultHotels
        SelectedHotelNumber = sender.tag
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "FoundHotelsViewController") as? FoundHotelsViewController
        next?.modalPresentationStyle = .overFullScreen
        self.present(next!, animated: false, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            toastMessage.layer.removeAllAnimations()
        }
    }
    
    @IBAction func FindHotelAction(_ sender: UIButton) {
        
        if ((LocationLabel.text != "") && (DatesLabel.text != "") && (GuestsLabel.text != "")){
            
            ControlTransitions = 0
            LastRequestController = 0
            
            let dict = ["Location" : LocationLabel.text!,"Dates" : DatesLabel.text!,"Guests" : GuestsLabel.text!]
            
            FindHotelClick = 1
            
            if ((dict == ParametersOfFoundHotels) && (SeeOtherOptionsClick == 0)){
                
                ShowHotels = HotelsFound
                
                if !ShowHotels.isEmpty{
                    DispatchQueue.main.async {
                        let next = self.storyboard?.instantiateViewController(withIdentifier: "FoundHotelsViewController") as? FoundHotelsViewController
                        next?.modalPresentationStyle = .overFullScreen
                        self.present(next!, animated: true, completion: nil)
                    }
                }else{
                    showToast(message: "No hotels were found. Try changing search\n parameters and try again", width: 310, hight: 55, delay: 5.0)
                }
                
            }else{
                
                SeeOtherOptionsClick = 0
                
                ParametersOfFoundHotels = dict
                
                LoadingView.alpha = 0.7
                LoadingActIndicator.isHidden = false
                LoadingActIndicator.startAnimating()
                
                HotelsFound = []
                if ExactSelectedLocation != ""{
                    HotelInfoRequest()
                }else{
                    SecondRequestHotelInfo()
                }
            }
            
            
            
        }else{
            
            showToast(message: "Fill in all search parameters", width: 210,hight: 35, delay: 2.5)
            
        }
    }
    
    @objc
    func HotelSearch(){
        
        let item = ShowHotels[SelectedHotelNumber]
        let CityName:String = item["CityName"] as! String
        
        
        SelectedLocation = CityName
        
        DispatchQueue.main.async { [self] in
            self.LocationLabel.text = SelectedLocation
        }
        
        HotelsFound = []
        SecondRequestHotelInfo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        LocationLabel.text = TextProcessing(SourceText: SelectedLocation, TextSize: 14, TextLength: view.frame.width - 60)
        if LocationLabel.text == "" { LocationLabel.text = SelectedLocation }
        DatesLabel.text = SelectedDates
        GuestsLabel.text = NumberOfGuests
        
    }
    
    func HotelInfoRequest(){
        
        print("HotelInfoRequest")
        let query = ExactSelectedLocation.replacingOccurrences(of: " ", with: "%20")
        
        guard let url = URL(string: "https://engine.hotellook.com/api/v2/lookup.json?query=" + query + "&lookFor=hotel&limit=10") else { SecondRequestHotelInfo(); return }
        let task = URLSession.shared.dataTask(with: url) { [self](data, response, error) in
            guard let data = data else { SecondRequestHotelInfo(); return }
            
            do{
                
                let HotelAndCityInfo = try JSONDecoder().decode(HotelAndCityInfo.self, from: data)
                DispatchQueue.main.async { [self] in
                    
                    NumberOfHotels = HotelAndCityInfo.results.hotels?.count ?? 0
                    guard NumberOfHotels != 0 else { SecondRequestHotelInfo(); return }
                    HotelLongitudeCoordinate = HotelAndCityInfo.results.hotels?[СurrentHotelNumber].location.lon ?? 1000
                    guard HotelLongitudeCoordinate != 1000 else { SecondRequestHotelInfo(); return }
                    HotelLatitudeCoordinate = HotelAndCityInfo.results.hotels?[СurrentHotelNumber].location.lat ?? 1000
                    guard HotelLatitudeCoordinate != 1000 else { SecondRequestHotelInfo(); return }
                    HotelId = HotelAndCityInfo.results.hotels?[СurrentHotelNumber].id ?? "error"
                    guard HotelId != "error" else { SecondRequestHotelInfo(); return }
                    DispatchQueue.main.async { [self] in
                        let cityName = HotelAndCityInfo.results.hotels?[СurrentHotelNumber].locationName ?? "error"
                        guard cityName != "error" else { SecondRequestHotelInfo(); return }
                        let cityNameArr:[String] = cityName.components(separatedBy: [","])
                        CityName = TextProcessing(SourceText: cityNameArr.first!, TextSize: 24, TextLength: view.frame.width - 16)
                        guard CityName != "" else { SecondRequestHotelInfo(); return}
                    }
                    CityId = HotelAndCityInfo.results.hotels?[СurrentHotelNumber].locationId ?? (-1)
                    guard CityId != (-1) else { SecondRequestHotelInfo(); return }
                    
                    CityInfoRequest()
                    
                }
                
                
                
            }catch{
                print(error.localizedDescription)
                SecondRequestHotelInfo()
            }
            
        }
        
        task.resume()
        
    }
    
    func SecondRequestHotelInfo(){
           
        print("SecondRequestHotelInfo")
           let query = SelectedLocation.replacingOccurrences(of: " ", with: "%20")
           guard let url = URL(string: "https://engine.hotellook.com/api/v2/lookup.json?query=" + query + "&lookFor=hotel&limit=10") else { СurrentHotelNumber += 1; return }
           let task = URLSession.shared.dataTask(with: url) { [self](data, response, error) in
               guard let data = data else { СurrentHotelNumber += 1; return }
               
               
               do{
                   let HotelAndCityInfo = try JSONDecoder().decode(HotelAndCityInfo.self, from: data)
                   DispatchQueue.main.async { [self] in
                       
                   NumberOfHotels = HotelAndCityInfo.results.hotels?.count ?? 0
                   guard NumberOfHotels != 0 else { СurrentHotelNumber += 1; return }
                   HotelLongitudeCoordinate = HotelAndCityInfo.results.hotels?[СurrentHotelNumber].location.lon ?? 1000
                   guard HotelLongitudeCoordinate != 1000 else { СurrentHotelNumber += 1; return }
                   HotelLatitudeCoordinate = HotelAndCityInfo.results.hotels?[СurrentHotelNumber].location.lat ?? 1000
                   guard HotelLatitudeCoordinate != 1000 else { СurrentHotelNumber += 1; return }
                   HotelId = HotelAndCityInfo.results.hotels?[СurrentHotelNumber].id ?? "error"
                   guard HotelId != "error" else { СurrentHotelNumber += 1; return }
                   let cityName = HotelAndCityInfo.results.hotels?[СurrentHotelNumber].locationName ?? "error"
                   guard cityName != "error" else { СurrentHotelNumber += 1; return }
                   let cityNameArr:[String] = cityName.components(separatedBy: [","])
                   CityName = TextProcessing(SourceText: cityNameArr.first!, TextSize: 24, TextLength: view.frame.width - 16)
                   guard CityName != "" else { СurrentHotelNumber += 1; return}
                   if ((LastRequestController == 1) && (SelectedLocation != CityName)){ СurrentHotelNumber += 1; return }
                   
                   CityId = HotelAndCityInfo.results.hotels?[СurrentHotelNumber].locationId ?? (-1)
                   guard CityId != (-1) else { СurrentHotelNumber += 1; return }
                   
                   CityInfoRequest()
                   
                   }
               }catch{
                   
                   print(error.localizedDescription)
                   СurrentHotelNumber += 1
               }
               
           }
           
           task.resume()
           
       }

    
    func CityInfoRequest(){
        
        print("CityInfoRequest")
        guard let url = URL(string: "https://engine.hotellook.com/api/v2/lookup.json?query=" + String(CityId) + "&lookFor=city&limit=1") else { СurrentHotelNumber += 1; return }
        let task = URLSession.shared.dataTask(with: url) { [self](data, response, error) in
            guard let data = data else { СurrentHotelNumber += 1; return }
            
            do{
                let HotelAndCityInfo = try JSONDecoder().decode(HotelAndCityInfo.self, from: data)
                
                DispatchQueue.main.async { [self] in
                    
                    NumberHotelsCity = HotelAndCityInfo.results.locations?.first?.hotelsCount ?? "error"
                    guard NumberHotelsCity != "error" else { СurrentHotelNumber += 1; return }
                    iataCity = HotelAndCityInfo.results.locations?.first?.iata?.first ?? "error"
                    guard iataCity != "error" else { СurrentHotelNumber += 1; return }
                    
                    let CityReference  = "https://photo.hotellook.com/static/cities/960x720/" + iataCity + ".jpg"
                    let СurrentImage = UIImageView()
                    guard let url = URL(string: CityReference) else { СurrentHotelNumber += 1; return }
                    URLSession.shared.dataTask(with: url) { [self] (data, _, _) in
                        
                        guard let data = try? Data(contentsOf: url) else { СurrentHotelNumber += 1; return }
                        
                        DispatchQueue.main.async { [self] in
                            СurrentImage.image = UIImage(data: data)
                            let currentImage = СurrentImage.image
                            let currentData = currentImage?.jpegData(compressionQuality: 0.5)
                            guard let currentDataEncoded = try? PropertyListEncoder().encode(currentData) else { СurrentHotelNumber += 1; return }
                            CityPhoto = currentDataEncoded
                            guard CityPhoto != ImageWrongCity else { СurrentHotelNumber += 1; return }
                            
                            if LastRequestController == 1{
                                LatitudeСoordinate = Float(HotelAndCityInfo.results.locations?.first?.location.lat ?? "1000.0") ?? 1000.0
                                guard LatitudeСoordinate != 1000.0 else { СurrentHotelNumber += 1 ; return}
                                LongitudeCoordinate = Float((HotelAndCityInfo.results.locations?.first?.location.lon ?? "1000.0")) ?? 1000.0
                                guard LongitudeCoordinate != 1000.0 else { СurrentHotelNumber += 1 ; return}
                            }
                            
                            ThirdRequestHotelInfo()
                        }
                    }.resume()
                }
                
                
            }catch{
                
                print(error.localizedDescription)
                СurrentHotelNumber += 1
                
            }
            
        }
        
        task.resume()
        
        
    }
    
    func ThirdRequestHotelInfo(){
        print("ThirdRequestHotelInfo")
        guard let url = URL(string: "https://engine.hotellook.com/api/v2/cache.json?locationId=" + String(CityId) + "&hotelId=" + HotelId + "&checkIn=" + CheckInDate + "&checkOut=" + CheckOutDate + "&limit=1&adults=" + NumberOfAdults) else { СurrentHotelNumber += 1; return }
        let task = URLSession.shared.dataTask(with: url) { [self](data, response, error) in
            guard let data = data else { СurrentHotelNumber += 1; return }
            
            do{
                let HotelInfo = try JSONDecoder().decode(HotelInfo.self, from: data)
                DispatchQueue.main.async { [self] in
                    MinPrice = HotelInfo.priceFrom
                    StarRating = HotelInfo.stars

                        NameHotel = TextProcessing(SourceText: HotelInfo.hotelName, TextSize: 24, TextLength: view.frame.width - 16)
                        guard NameHotel != "" else { СurrentHotelNumber += 1; return}
                    
                    
                    FourthRequestHotelInfo()
                }

            }catch{
                
                print(error.localizedDescription)
                СurrentHotelNumber += 1
                
            }
            
            
        }
        
        task.resume()
        
        
        
    }
    
    func FourthRequestHotelInfo(){
        
        print("FourthRequestHotelInfo")
        guard let url = URL(string: "https://yasen.hotellook.com/photos/hotel_photos?id=" + HotelId) else { СurrentHotelNumber += 1; return }
        let task = URLSession.shared.dataTask(with: url) { [self](data, response, error) in
            guard let data = data else { СurrentHotelNumber += 1; return }
            
            let dataStr = String(data: data, encoding: .utf8)
            let dataDict = convertStringToDictionary(dataStr: dataStr ?? "error")
            guard dataStr != "error" else { СurrentHotelNumber += 1; return }
            let dataArr = dataDict?[HotelId] as! [Int]
            if dataArr.count != 24{ СurrentHotelNumber += 1; return }
            
            DispatchQueue.main.async { [self] in
                
                HotelPhoto = []
                var ImagesLinks:[String] = []
                
                for dataIndex in 0..<dataArr.count{
                    
                    let ImageId = "\(dataArr[dataIndex])"
                    let urlImage:String = "https://photo.hotellook.com/image_v2/limit/" + ImageId + "/800/520.auto"
                    ImagesLinks.append(urlImage)
                    
                    
                }
                
                for ImageIndex in 0..<ImagesLinks.count{
                    
                    let СurrentImage = UIImageView()
                    guard let url = URL(string: ImagesLinks[ImageIndex]) else { СurrentHotelNumber += 1; return }
                    URLSession.shared.dataTask(with: url) { [self] (data, _, _) in
                        
                        guard let data = try? Data(contentsOf: url) else { СurrentHotelNumber += 1; return }
                        
                        DispatchQueue.main.async { [self] in
                            СurrentImage.image = UIImage(data:  data)
                            let currentImage = СurrentImage.image
                            let currentData = currentImage?.jpegData(compressionQuality: 0.5)
                            guard let currentDataEncoded = try? PropertyListEncoder().encode(currentData) else { СurrentHotelNumber += 1; return }
                            HotelPhoto.append(currentDataEncoded)
                            
                            if ImageIndex == (ImagesLinks.count - 1){
                                HotelAddressRequest()
                            }
                        }
                    }.resume()
                    
                }
            }
        }
        
        task.resume()
        
    }
    
    func HotelAddressRequest(){
        print("HotelAddressRequest")

        let headers = [
            "X-RapidAPI-Key": ValidKey,
            "X-RapidAPI-Host": "address-from-to-latitude-longitude.p.rapidapi.com"
        ]
        
        let url = "https://address-from-to-latitude-longitude.p.rapidapi.com/geolocationapi?lat=" + String(HotelLatitudeCoordinate) + "&lng=" + String(HotelLongitudeCoordinate)
        guard let URL = NSURL(string: url) else { СurrentHotelNumber += 1; return }
        
        let request = NSMutableURLRequest(url: URL as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [self] (data, response, error) -> Void in
            if (error != nil) {
                self.СurrentHotelNumber += 1
            } else {
                
                do{
                    guard let data = data else { СurrentHotelNumber += 1; return }
                    
                    let HotelAddress = try JSONDecoder().decode(HotelAddress.self, from: data)
                    DispatchQueue.main.async { [self] in
                        
                    let address = HotelAddress.Results?.first?.address
                    
                    if address != nil{
                        
                        
                            Address = TextProcessing(SourceText: address!, TextSize: 16, TextLength: view.frame.width - 16)
                            guard Address != "" else { СurrentHotelNumber += 1; return}
                            
                            let dict = ["HotelPhoto" : HotelPhoto, "StarRating" : StarRating, "MinPrice" : MinPrice, "NameHotel" : NameHotel, "Address" : Address, "CityPhoto" : CityPhoto, "CityName" : CityName, "NumberHotelsCity" : NumberHotelsCity, "HotelId" : HotelId, "CityId" : CityId] as [String : Any]
                            
                            HotelsFound.append(dict)
                            
                            СurrentHotelNumber += 1
                            
                        }else{
                            
                            if KeyNum < (Keys.count - 1){
                                ValidKey = Keys[KeyNum + 1]
                                KeyNum += 1
                            }else{
                                ValidKey = Keys[0]
                                KeyNum = 0
                            }
                            
                            UserDefaults.standard.setValue(["ValidKey" : ValidKey, "KeyNum" : KeyNum], forKey: "KeyInfo")
                            
                            HotelAddressRequest()
                        }
                    }
                    
                }catch{
                    print(error.localizedDescription)
                    СurrentHotelNumber += 1
                    
                }
                
            }
        })
        
        dataTask.resume()
        
    }
    
    func TextProcessing(SourceText: String, TextSize: CGFloat, TextLength: CGFloat)->String{
        
        var SourceTextArr = SourceText.components(separatedBy:",")
        var Separator = ","
        
        if (SourceTextArr.count - 1) > 0{
            print("Ok")
        }else{
            SourceTextArr = SourceText.components(separatedBy:" ")
            Separator = " "
        }
        
        var NewText = ""
        var InterimText = ""
        
        for item in SourceTextArr{
            
            InterimText += item
            let Size = InterimText.size(withAttributes:[.font: UIFont.systemFont(ofSize: TextSize)])
            InterimText += Separator
            
            if Size.width <= TextLength{
                NewText += item + Separator
            }else{
                break
            }
        }
        
        if NewText != ""{
            NewText.removeLast()
        }
        
        return NewText
        
    }
    
    func convertStringToDictionary(dataStr: String) -> [String:AnyObject]? {
        if let data = dataStr.data(using: .utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
}

extension ViewController {
    
    func showToast(message : String, width: Int, hight:Int, delay: Float) {
        
        toastMessage.layer.removeAllAnimations()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [self] in
            toastMessage = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - CGFloat(width / 2), y: self.view.frame.size.height-110, width: CGFloat(width), height: CGFloat(hight)))
            toastMessage.backgroundColor = UIColor.black.withAlphaComponent(1)
            toastMessage.textColor = UIColor.white
            toastMessage.font = .systemFont(ofSize: 14)
            toastMessage.textAlignment = .center;
            toastMessage.numberOfLines = 2
            toastMessage.text = message
            toastMessage.alpha = 1.0
            toastMessage.layer.cornerRadius = 10;
            toastMessage.clipsToBounds  =  true
            self.view.addSubview(toastMessage)
            UIView.animate(withDuration: Double(delay) + 3.0, delay: TimeInterval(delay), options: .curveEaseOut, animations: { [self] in
                toastMessage.alpha = 0.0
            }, completion: { [self](isCompleted) in
                toastMessage.removeFromSuperview()
            })
        }
        
    }
    
}
