import UIKit

class FoundHotelsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var DatesLabel: UILabel!
    @IBOutlet weak var GuestsLabel: UILabel!
    @IBOutlet weak var BackView: UIView!
    
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: nil)
        
        if ControlTransitions == 1{
            
            view.alpha = 0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { [self] in
                let next = self.storyboard?.instantiateViewController(withIdentifier: "HotelInfoViewController") as? HotelInfoViewController
                next?.modalPresentationStyle = .overFullScreen
                self.present(next!, animated: true, completion: nil)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                view.alpha = 1
            }
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScrollTopTableView), name: Notification.Name("ScrollTopTableView"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(DataUpdate), name: Notification.Name("DataUpdate"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateTableView), name: Notification.Name("UpdateTableView"), object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        LocationLabel.numberOfLines = 1
    
        let tapBackView = UITapGestureRecognizer(target: self, action: #selector(self.Back))
        BackView.addGestureRecognizer(tapBackView)
        
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
    
    @objc
    func ScrollTopTableView(){
        
        let NumberRows = tableView.numberOfRows(inSection: 0)
        
        if NumberRows > 0{

        let IndexPath:IndexPath = [0,0]
        tableView.scrollToRow(at: IndexPath, at: .top, animated: false)

        }
        
        NotificationCenter.default.post(name: Notification.Name("FirstTransition"), object: nil)
       
    }
    
    @objc
    func DataUpdate(){
        
        LocationLabel.text = SelectedLocation
        let dict = ["Location" : LocationLabel.text!,"Dates" : DatesLabel.text!,"Guests" : GuestsLabel.text!]
        ParametersOfFoundHotels = dict
        
        tableView.reloadData()
        
        NotificationCenter.default.post(name: Notification.Name("TransitionHotelsFound"), object: nil)
    }
    
    @objc
    func UpdateTableView(){
        tableView.reloadData()
        NotificationCenter.default.post(name: Notification.Name("TransitionOldHotels"), object: nil)
    }
    
    @objc
    private func Back(){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        LocationLabel.text = TextProcessing(SourceText: SelectedLocation, TextSize: 18, TextLength: view.frame.width - 40)
        DatesLabel.text = SelectedDates
        GuestsLabel.text = NumberOfGuests
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 345.0
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ShowHotels.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MySecondCustomCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MySecondCustomCell
        
        let item = ShowHotels[indexPath.row]
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
            let xPos = CGFloat(i)*(view.frame.width - 32)
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
        cell.HotelAddressLabel.numberOfLines = 1
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
        cell.ImagesScrollView.showsHorizontalScrollIndicator = false

        return cell
        
    }
    
    @IBAction func MinPriceAction(_ sender: UIButton) {
        
        SelectedHotelNumber = sender.tag
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "HotelInfoViewController") as? HotelInfoViewController
        next?.modalPresentationStyle = .overFullScreen
        self.present(next!, animated: true, completion: nil)
        
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

}
