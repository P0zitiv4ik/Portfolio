import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var TextSizeButton: UIButton!
    @IBOutlet weak var TextFontButton: UIButton!
    @IBOutlet weak var TextColorButton: UIButton!
    @IBOutlet weak var BaсkgroundColorButton: UIButton!
    @IBOutlet weak var DefaultSettingsButton: UIButton!
    @IBOutlet weak var BaсkgroundColorLabel: UILabel!
    @IBOutlet weak var DefaultSettingsLabel: UILabel!
    @IBOutlet weak var ConstBaсkgroundColorImageCenter: NSLayoutConstraint!
    @IBOutlet weak var ConstBaсkgroundColorButtonCenter: NSLayoutConstraint!
    @IBOutlet weak var ConstDefaultSettingsImageCenter: NSLayoutConstraint!
    @IBOutlet weak var ConstDefaultSettingsButtonCenter: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BaсkgroundColorLabel.text = "Background\ncolor"
        DefaultSettingsLabel.text = "Default\nsettings"
        
        let viewSize = (view.frame.width/2 - 30) - 100
        
        ConstBaсkgroundColorImageCenter.constant = ((viewSize/2) + 26) * (-1)
        ConstBaсkgroundColorButtonCenter.constant = ((viewSize/2) + 26) * (-1)
        ConstDefaultSettingsImageCenter.constant = ((viewSize/2) + 35)
        ConstDefaultSettingsButtonCenter.constant = ((viewSize/2) + 35)
        
        let tapTextSizeButton = UITapGestureRecognizer(target: self, action: #selector(self.TextSize))
        TextSizeButton.addGestureRecognizer(tapTextSizeButton)
        
        let tapTextFontButton = UITapGestureRecognizer(target: self, action: #selector(self.TextFont))
        TextFontButton.addGestureRecognizer(tapTextFontButton)
        
        let tapTextColorButton = UITapGestureRecognizer(target: self, action: #selector(self.TextColor))
        TextColorButton.addGestureRecognizer(tapTextColorButton)
        
        let tapBaсkgroundColorButton = UITapGestureRecognizer(target: self, action: #selector(self.BaсkgroundColor))
        BaсkgroundColorButton.addGestureRecognizer(tapBaсkgroundColorButton)
        
        let tapDefaultSettingsButton = UITapGestureRecognizer(target: self, action: #selector(self.DefaultSettings))
        DefaultSettingsButton.addGestureRecognizer(tapDefaultSettingsButton)
        
    }
    
    @IBAction func CloseButton(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let yIndent = UIScreen.main.bounds.height - 450.0
        self.view.frame = CGRect(x: 0, y: yIndent, width: self.view.bounds.width, height: 450)
        self.view.layer.cornerRadius = 10
        self.view.layer.masksToBounds = true
    }
    
    @objc
    private func TextSize(){
        
        let next = self.storyboard!.instantiateViewController(withIdentifier: "TextSizeCustomization") as! TextSizeCustomization
        next.modalPresentationStyle = .overFullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @objc
    private func TextFont(){
        
        let next = self.storyboard!.instantiateViewController(withIdentifier: "TextFontCustomization") as! TextFontCustomization
        next.modalPresentationStyle = .overFullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @objc
    private func TextColor(){
        
        let next = self.storyboard!.instantiateViewController(withIdentifier: "TextColorCustomization") as! TextColorCustomization
        next.modalPresentationStyle = .overFullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @objc
    private func BaсkgroundColor(){
        
        let next = self.storyboard!.instantiateViewController(withIdentifier: "BackgroundColorCustomization") as! BackgroundColorCustomization
        next.modalPresentationStyle = .overFullScreen
        self.present(next, animated: true, completion: nil)
        
    }
    
    @objc
    private func DefaultSettings(){
        
        AlertDefaultSettings()
        
    }
    
    func AlertDefaultSettings(){
        
        let alertDefaultSettings = UIAlertController(title: nil, message: "Are you sure you want to set all settings to default?", preferredStyle: UIAlertController.Style.alert)
        
        alertDefaultSettings.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            TextSettings = ["TextSize":20,"TextFont":"Helvetica Neue", "TextColor":["red":0.0,"green":0.0,"blue":0.0,"tag":131], "BackgroundColor":["red":1.0,"green":1.0,"blue":1.0,"tag":120]]
            UserDefaults.standard.setValue(TextSettings, forKey: "TextSettings")
            if LastController == "FinishedViewController"{
                NotificationCenter.default.post(name: Notification.Name("СhangingTextSettings"), object: nil)
                self.dismiss(animated: true, completion: nil)
            }
            
        }))
        
        alertDefaultSettings.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertDefaultSettings, animated: true, completion: nil)
        
    }
    
}
