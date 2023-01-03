import UIKit

class GuestsChoiceViewController: UIViewController {
    
    @IBOutlet weak var DecreaseNumberAdultsButton: UIButton!
    @IBOutlet weak var IncreaseNumberAdultsButton: UIButton!
    @IBOutlet weak var NumberOfAdultsLabel: UILabel!
    @IBOutlet weak var DecreaseNumberChildrenButton: UIButton!
    @IBOutlet weak var IncreasingNumberChildrenButton: UIButton!
    @IBOutlet weak var NumberOfChildrenLabel: UILabel!
    @IBOutlet weak var ApplyButton: UIButton!
    @IBOutlet weak var BackView: UIView!
    
    var numberOfAdults = Int(NumberOfAdults) ?? 0
    var numberOfChildren = Int(NumberOfChildren) ?? 0
    
    var toastMessage = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: nil)
        
        NumberOfAdultsLabel.text = NumberOfAdults
        NumberOfChildrenLabel.text = NumberOfChildren
        
        DecreaseNumberAdultsButton.layer.cornerRadius = 10
        IncreaseNumberAdultsButton.layer.cornerRadius = 10
        DecreaseNumberChildrenButton.layer.cornerRadius = 10
        IncreasingNumberChildrenButton.layer.cornerRadius = 10
        ApplyButton.layer.cornerRadius = 10
        
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
    private func Back(){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func СhangeNumberGuestsAction(_ sender: UIButton) {
        
        switch sender.tag{
        case 0:
            if numberOfAdults > 0{
                numberOfAdults -= 1
                NumberOfAdultsLabel.text = String(numberOfAdults)
            }
            
        case 1:
            if numberOfAdults < 4{
                numberOfAdults += 1
                NumberOfAdultsLabel.text = String(numberOfAdults)
            }
            
        case 2:
            if numberOfChildren > 0{
                numberOfChildren -= 1
                NumberOfChildrenLabel.text = String(numberOfChildren)
            }
            
        case 3:
            if numberOfChildren < 3{
                numberOfChildren += 1
                NumberOfChildrenLabel.text = String(numberOfChildren)
            }
            
        default:
            print("error")
        }
        
    }
    
    @IBAction func ApplyAction(_ sender: Any) {
        
        switch(numberOfAdults, numberOfChildren){
        case (0,0):
            showToast(message: "Select guests", width: 120, delay: 1.5)
            
        case (1...4,0):
            NumberOfGuests = String(numberOfAdults) + " adults"
            NumberOfAdults = String(numberOfAdults)
            NumberOfChildren = String(numberOfChildren)
            dismiss(animated: true, completion: nil)
            
        case (0,1...3):
            showToast(message: "At least one adult must be present among the guests", width: 370, delay: 4.0)
            
        case (1...4,1...3):
            NumberOfGuests = String(numberOfAdults) + " adults, " + String(numberOfChildren) + " kids"
            NumberOfAdults = String(numberOfAdults)
            NumberOfChildren = String(numberOfChildren)
            dismiss(animated: true, completion: nil)
            
        case (_, _):
            print("error")
            
        }
        
    }
    
}

extension  GuestsChoiceViewController{
    
    func showToast(message : String, width: Int, delay: Float) {
        
        toastMessage.layer.removeAllAnimations()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [self] in
            toastMessage = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - CGFloat((width / 2)), y: self.view.frame.size.height-200, width: CGFloat(width), height: 35))
            toastMessage.alpha = 0
            toastMessage.backgroundColor = UIColor.black.withAlphaComponent(1)
            toastMessage.textColor = UIColor.white
            toastMessage.font = .systemFont(ofSize: 14)
            toastMessage.textAlignment = .center;
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
