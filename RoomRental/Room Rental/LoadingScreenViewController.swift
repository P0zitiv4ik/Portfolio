import UIKit

class LoadingScreenViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.setValue(1, forKey: "NetworkStatus")
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: nil)
        
        ConvertLinkToPhoto()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
            updateUserInterface()
        }
        
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
    
    func ConvertLinkToPhoto(){
        
        var numberOfHotel = 0
        
        for i in 0..<DefaultHotels.count{
            
            var item = DefaultHotels[i]
            
            let CityPhoto:String = item["CityPhoto"] as! String
            
            let СurrentImage = UIImageView()
            guard let url = URL(string: CityPhoto) else { return }
            
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                guard let data = try? Data(contentsOf: url) else { return }
                DispatchQueue.main.async {
                    СurrentImage.image = UIImage(data: data)
                    let currentImage = СurrentImage.image
                    let currentData = currentImage?.jpegData(compressionQuality: 0.5)
                    guard let currentDataEncoded = try? PropertyListEncoder().encode(currentData) else { return }
                    
                    item["CityPhoto"] = currentDataEncoded
                    DefaultHotels[i] = item
                    
                    numberOfHotel += 1
                    
                    if numberOfHotel == 10{
                        self.ConvertLinkToPhoto2()
                    }
                }
            }.resume()
        }
    }
    
    func ConvertLinkToPhoto2(){
        
        var numberOfHotel2 = 0
        
        for i in 0..<DefaultHotels.count{
            
            var item = DefaultHotels[i]
            
            let HotelPhoto:[String] = item["HotelPhoto"] as! [String]
            var HotelPhotoDataArr:[Data] = []
            
            for j in 0..<HotelPhoto.count{
                
                let СurrentImage = UIImageView()
                guard let url = URL(string: HotelPhoto[j]) else { return }
                
                URLSession.shared.dataTask(with: url) { (data, _, _) in
                    guard let data = try? Data(contentsOf: url) else { return }
                    DispatchQueue.main.async {
                        СurrentImage.image = UIImage(data: data)
                        let currentImage = СurrentImage.image
                        let currentData = currentImage?.jpegData(compressionQuality: 0.5)
                        guard let currentDataEncoded = try? PropertyListEncoder().encode(currentData) else { return }
                        
                        let HotelPhotoData = currentDataEncoded
                        
                        HotelPhotoDataArr.append(HotelPhotoData)
                        
                        if j == (HotelPhoto.count - 1){
                            
                            item["HotelPhoto"] = HotelPhotoDataArr
                            DefaultHotels[i] = item
                            
                            numberOfHotel2 += 1
                            
                            if numberOfHotel2 == 1{
                                self.ConvertLinkToPhoto3()
                            }
                        }
                    }
                }.resume()
            }
        }
    }
    
    func ConvertLinkToPhoto3(){
        
        let СurrentImage = UIImageView()
        guard let url = URL(string: "https://photo.hotellook.com/static/cities/960x720/HIJ.jpg") else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            guard let data = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                СurrentImage.image = UIImage(data: data)
                let currentImage = СurrentImage.image
                let currentData = currentImage?.jpegData(compressionQuality: 0.5)
                guard let currentDataEncoded = try? PropertyListEncoder().encode(currentData) else { return }
                
                ImageWrongCity = currentDataEncoded
                
                let next = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
                next?.modalPresentationStyle = .overFullScreen
                self.present(next!, animated: false, completion: nil)
                
            }
        }.resume()
    }
}
