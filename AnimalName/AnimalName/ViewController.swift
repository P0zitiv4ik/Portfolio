import UIKit
import AudioToolbox
import SafariServices
import Lottie

var AnimalHistoryArr: [[String : Any]] = []
var SelectedAnimalsArr: [[String : Any]] = []
var HeartAnimation: LottieAnimationView!
var HeartAnimationStatus = 0
var length = 0

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    let imagePredictor = ImagePredictor()
    let PredictionsToShow = 1
    var SelectedDict:[String:Any] = [:]
    
    @IBOutlet weak var SelectedButton: UIButton!
    @IBOutlet weak var InfoButton: UIButton!
    @IBOutlet weak var HistoryButton: UIButton!
    @IBOutlet weak var SelectedImageView: UIImageView!
    @IBOutlet weak var InfoImageView: UIImageView!
    @IBOutlet weak var HistoryImageView: UIImageView!
    @IBOutlet weak var TakePhotoButton: UIButton!
    @IBOutlet weak var ConstTakePhotoWidth: NSLayoutConstraint!
    @IBOutlet weak var UploadPhotoButton: UIButton!
    @IBOutlet weak var ConstUploadPhotoWidth: NSLayoutConstraint!
    @IBOutlet weak var IdentifyButton: UIButton!
    @IBOutlet weak var ReadMoreButton: UIButton!
    @IBOutlet weak var СurrentImage: UIImageView!
    @IBOutlet weak var ResultLabel: UILabel!
    @IBOutlet weak var LoadingProgressView: UIProgressView!
    @IBOutlet weak var CornerImage1: UIImageView!
    @IBOutlet weak var CornerImage2: UIImageView!
    @IBOutlet weak var CornerImage3: UIImageView!
    @IBOutlet weak var CornerImage4: UIImageView!
    @IBOutlet weak var HeartAnimationView: UIView!
    @IBOutlet weak var HeartAnimationButton: UIView!
    @IBOutlet weak var ConstLengthLoadingProgressView: NSLayoutConstraint!
    @IBOutlet weak var ConstTopDistanceResult: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HeartAnimation = .init(name: "Heart")
        HeartAnimation.frame = HeartAnimationView.bounds
        HeartAnimationView.addSubview(HeartAnimation)
        HeartAnimationView.addSubview(HeartAnimationButton)
        
        let tapTakePhotoButton = UITapGestureRecognizer(target: self, action: #selector(self.TakePhoto))
        TakePhotoButton?.addGestureRecognizer(tapTakePhotoButton)
        
        let tapUploadPhotoButton = UITapGestureRecognizer(target: self, action: #selector(self.UploadPhoto))
        UploadPhotoButton?.addGestureRecognizer(tapUploadPhotoButton)
        
        let tapHeartAnimationButton = UITapGestureRecognizer(target: self, action: #selector(self.HeartAnimationFunc))
        HeartAnimationButton.addGestureRecognizer(tapHeartAnimationButton)
        
        if UserDefaults.standard.object(forKey: "CurrentImage") != nil{
            let item = UserDefaults.standard.object(forKey: "CurrentImage") as! [String : Any]
            
            let currentData:Data = item["CurrentEncoded"] as! Data
            let decoded = try! PropertyListDecoder().decode(Data.self, from: currentData)
            let currentImage = UIImage(data: decoded)
            
            length = item["CurrentLength"] as! Int
            
            PrepareImage(currentImage: currentImage!)
        }else{
            let defaultImage = UIImage(named:"panda")
            
            length = 905044
            
            PrepareImage(currentImage: defaultImage!)
        }
        
        LoadingProgressView.isHidden = true
        CornerImage1.alpha = 0
        CornerImage2.alpha = 0
        CornerImage3.alpha = 0
        CornerImage4.alpha = 0
        
        IdentifyButton.layer.cornerRadius = 25
        ResultLabel.numberOfLines = 4
        TakePhotoButton.layer.cornerRadius = 10
        UploadPhotoButton.layer.cornerRadius = 10
        ConstTakePhotoWidth.constant = (view.frame.width-60)/2
        ConstUploadPhotoWidth.constant = (view.frame.width-60)/2
        
        if UserDefaults.standard.object(forKey: "AnimalHistoryArr") != nil{
            AnimalHistoryArr = UserDefaults.standard.object(forKey: "AnimalHistoryArr") as! [[String : Any]]
        }
        
        if UserDefaults.standard.object(forKey: "SelectedAnimalsArr") != nil{
            SelectedAnimalsArr = UserDefaults.standard.object(forKey: "SelectedAnimalsArr") as! [[String : Any]]
        }
        
    }
    
    @IBAction func SelectedAction(_ sender: Any) {
        let next = self.storyboard!.instantiateViewController(withIdentifier: "SelectedViewController") as! SelectedViewController
        next.modalPresentationStyle = .overFullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    @IBAction func InfoAction(_ sender: Any) {
        let next = self.storyboard!.instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
        next.modalPresentationStyle = .overFullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    @IBAction func HistoryAction(_ sender: Any) {
        let next = self.storyboard!.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        next.modalPresentationStyle = .overFullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    @objc private func TakePhoto(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc private func UploadPhoto(){
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let CurrentImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        let imageNSData:NSData = CurrentImage.pngData()! as NSData
        length = imageNSData.length
        PrepareImage(currentImage: CurrentImage)
    }
    
    func PrepareImage(currentImage: UIImage){
        
        СurrentImage.image = currentImage
        
        let currentImage = СurrentImage.image
        guard let currentData = currentImage!.jpegData(compressionQuality: 0.5) else { return }
        let CurrentEncoded = try! PropertyListEncoder().encode(currentData)
        
        let dict = ["CurrentEncoded" : CurrentEncoded, "CurrentLength" : length] as [String : Any]
        UserDefaults.standard.setValue(dict, forKey: "CurrentImage")
        
        let tapIdentifyButton = MyTapGesture(target: self, action: #selector(self.Identify))
        IdentifyButton.addGestureRecognizer(tapIdentifyButton)
        
        ResultLabel.isHidden = true
        ReadMoreButton.isHidden = true
        HeartAnimation.stop()
        HeartAnimation.isHidden = true
        HeartAnimationButton.isHidden = true
        CornerImage1.alpha = 0
        CornerImage2.alpha = 0
        CornerImage3.alpha = 0
        CornerImage4.alpha = 0
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func Identify(sender: MyTapGesture){
        
        let size = СurrentImage.contentClippingRect
        
        CornerImage1.frame = CGRect(x: (СurrentImage.frame.origin.x - 27) + size.origin.x, y: (СurrentImage.frame.origin.y - 26) + size.origin.y, width: 50, height: 50)
        CornerImage2.frame = CGRect(x: (СurrentImage.frame.origin.x - 25) + size.origin.x + size.width, y: (СurrentImage.frame.origin.y - 26) + size.origin.y, width: 50, height: 50)
        CornerImage3.frame = CGRect(x: (СurrentImage.frame.origin.x - 27) + size.origin.x, y: (СurrentImage.frame.origin.y - 24) + size.origin.y + size.height, width: 50, height: 50)
        CornerImage4.frame = CGRect(x: (СurrentImage.frame.origin.x - 25) + size.origin.x + size.width, y: (СurrentImage.frame.origin.y - 24) + size.origin.y + size.height, width: 50, height: 50)
        
        ConstTopDistanceResult.constant = 34 - ((240-size.height) / 2)
        ConstLengthLoadingProgressView.constant = size.width + 28
        
        CornerImage1.alpha = 0
        CornerImage2.alpha = 0
        CornerImage3.alpha = 0
        CornerImage4.alpha = 0
        SelectedImageView.tintColor = .lightGray
        SelectedButton.isEnabled = false
        InfoImageView.tintColor = .lightGray
        InfoButton.isEnabled = false
        HistoryImageView.tintColor = .lightGray
        HistoryButton.isEnabled = false
        TakePhotoButton.backgroundColor = .lightGray
        TakePhotoButton.isEnabled = false
        UploadPhotoButton.backgroundColor = .lightGray
        UploadPhotoButton.isEnabled = false
        IdentifyButton.backgroundColor = .lightGray
        IdentifyButton.isEnabled = false
        LoadingProgressView.setProgress(0, animated: false)
        LoadingProgressView.isHidden = false
        ResultLabel.isHidden = true
        ReadMoreButton.isHidden = true
        HeartAnimation.stop()
        HeartAnimation.isHidden = true
        HeartAnimationButton.isHidden = true
        
        var progress = 0.0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            progress += 0.2
            self.LoadingProgressView.setProgress(Float(progress), animated: true)
            if progress == 1{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [self] in
                    timer.invalidate()
                    self.LoadingProgressView.isHidden = true
                    SelectedImageView.tintColor = .systemGreen
                    SelectedButton.isEnabled = true
                    InfoImageView.tintColor = .systemGreen
                    InfoButton.isEnabled = true
                    HistoryImageView.tintColor = .systemGreen
                    HistoryButton.isEnabled = true
                    TakePhotoButton.backgroundColor = .systemGreen
                    TakePhotoButton.isEnabled = true
                    UploadPhotoButton.backgroundColor = .systemGreen
                    UploadPhotoButton.isEnabled = true
                    IdentifyButton.backgroundColor = .systemGreen
                    IdentifyButton.isEnabled = true
                    return
                }
            }
        }
        
        UIView.animate(withDuration: 5.5) { [self] in
            CornerImage1.alpha = 1
            CornerImage2.alpha = 1
            CornerImage3.alpha = 1
            CornerImage4.alpha = 1
        } completion: { [self] _ in
            
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            
            self.СurrentImage.alpha = 0
            CornerImage1.alpha = 0
            CornerImage2.alpha = 0
            CornerImage3.alpha = 0
            CornerImage4.alpha = 0
            
            UIView.animate(withDuration: 1.0, delay: 0.0) { [self] in
                СurrentImage.alpha = 1
                CornerImage1.alpha = 1
                CornerImage2.alpha = 1
                CornerImage3.alpha = 1
                CornerImage4.alpha = 1
                self.classifyImage(self.СurrentImage.image!)
                
            }
        }
    }
    
    func LinkBuilding()->String{
        
        let result = ResultLabel.text
        
        var ResultArray = result!.split(separator: ",")
        for j in 1..<ResultArray.count{
            ResultArray[j].removeFirst()
        }
        
        var EndLink = ""
        let FirstResult = ResultArray[0]
        let FirstResultSeparation =  FirstResult.components(separatedBy:" ")
        EndLink = FirstResultSeparation[FirstResultSeparation.count-1]
        
        let link = "https://a-z-animals.com/search/" + EndLink
        
        return link
        
    }
    
    @objc private func openLink(sender: MyTapGesture){
        
        let Link = LinkBuilding()
        
        if let url = URL(string: Link) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
        
    }
    
    func RemoveFromFavorites(){
        
        for i in 0..<SelectedAnimalsArr.count{
            let item = SelectedAnimalsArr[i]
            let Length:Int = item["length"] as! Int
            if length == Length{
                SelectedAnimalsArr.remove(at: i)
                UserDefaults.standard.setValue(SelectedAnimalsArr, forKey: "SelectedAnimalsArr")
                break
            }
        }
    }
    
    @objc func HeartAnimationFunc() {
        if HeartAnimationStatus == 0{
            HeartAnimation.play()
            HeartAnimationStatus = 1
            SelectedAnimalsArr.append(SelectedDict)
            UserDefaults.standard.setValue(SelectedAnimalsArr, forKey: "SelectedAnimalsArr")
        }else{
            HeartAnimation.stop()
            HeartAnimationStatus = 0
            RemoveFromFavorites()
        }
    }
}

extension UIImage {
    func resize(_ max_size: CGFloat) -> UIImage {
        // adjust for device pixel density
        let max_size_pixels = max_size / UIScreen.main.scale
        // work out aspect ratio
        let aspectRatio =  size.width/size.height
        // variables for storing calculated data
        var width: CGFloat
        var height: CGFloat
        var newImage: UIImage
        if aspectRatio > 1 {
            // landscape
            width = max_size_pixels
            height = max_size_pixels / aspectRatio
        } else {
            // portrait
            height = max_size_pixels
            width = max_size_pixels * aspectRatio
        }
        // create an image renderer of the correct size
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: UIGraphicsImageRendererFormat.default())
        // render the image
        newImage = renderer.image {
            (context) in
            self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        }
        // return the image
        return newImage
    }
}

class MyTapGesture: UITapGestureRecognizer {
    var data = String()
}

extension UserDefaults {
    static func contains(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

extension ViewController {
    // MARK: Image pre ion methods
    /// Sends a photo to the Image Predictor to get a prediction of its content.
    /// - Parameter image: A photo.
    private func classifyImage(_ image: UIImage) {
        do {
            try self.imagePredictor.makePredictions(for: image,
                                                    completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
    
    /// The method the Image Predictor calls when its image classifier model generates a prediction.
    /// - Parameter predictions: An array of predictions.
    /// - Tag: imagePredictionHandler
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?) {
        guard let predictions = predictions else {
            //updatePredictionLabel("No predictions. (Check console log.)")
            print("No predictions")
            return
        }
        
        let linkClick = MyTapGesture(target: self, action: #selector(self.openLink))
        
        let textResultStr = predictions[0].classification
        linkClick.data = textResultStr
        
        self.ReadMoreButton.addGestureRecognizer(linkClick)
        
        self.ResultLabel.text = textResultStr
        let Link = LinkBuilding()
        
        let dateFormatter = Date()
        let date = dateFormatter.getFormattedDate(format: "yyyy-MM-dd, HH:mm")
        
        let image = СurrentImage.image
        guard let data = image!.jpegData(compressionQuality: 0.5) else { return }
        let encoded = try! PropertyListEncoder().encode(data)
        
        let dict = ["Image": encoded, "Name": textResultStr, "Link": Link, "date": date] as [String : Any]
        AnimalHistoryArr.append(dict)
        UserDefaults.standard.setValue(AnimalHistoryArr, forKey: "AnimalHistoryArr")
        
        SelectedDict = ["Image": encoded, "Name": textResultStr, "Link": Link, "length" : length] as [String : Any]
        
        var CurrentStateHeart = 0
        for SelectedAnimal in SelectedAnimalsArr{
            let Length:Int = SelectedAnimal["length"] as! Int
            if length == Length{
                CurrentStateHeart = 1
                break
            }
        }
        
        if CurrentStateHeart == 0{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) { HeartAnimation.stop() }
            HeartAnimationStatus = 0
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.001){ HeartAnimation.play() }
            HeartAnimationStatus = 1
        }
        
        self.ResultLabel.isHidden = false
        ResultLabel.alpha = 0
        self.ReadMoreButton.isHidden = false
        ReadMoreButton.alpha = 0
        HeartAnimation.stop()
        HeartAnimation.isHidden = false
        HeartAnimation.alpha = 0
        HeartAnimationButton.isHidden = false
        HeartAnimation.alpha = 0
        
        UIView.animate(withDuration: 1.0, delay: 0.0) { [self] in
            ResultLabel.alpha = 1
            ReadMoreButton.alpha = 1
            HeartAnimation.alpha = 1
            HeartAnimationButton.alpha = 1
        }
    }
    
    /// Converts a prediction's observations into human-readable strings.
    /// - Parameter observations: The classification observations from a Vision request.
    /// - Tag: formatPredictions
    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [String] {
        // Vision sorts the classifications in descending confidence order.
        let topPredictions: [String] = predictions.prefix(PredictionsToShow).map { prediction in
            var name = prediction.classification
            
            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }
            
            return "\(name) - \(prediction.confidencePercentage)"
        }
        
        return topPredictions
    }
}

extension Date {
    func getFormattedDate(format: String)->String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}

extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }
        
        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }
        
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0
        
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
