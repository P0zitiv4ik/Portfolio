import UIKit

class TextSizeCustomization: UIViewController {
    
    @IBOutlet weak var SampleScrollView: UIScrollView!
    @IBOutlet weak var SampleTextLabel: UILabel!
    @IBOutlet weak var SampleTextView: UIView!
    @IBOutlet weak var TextSizeSlider: UISlider!
    @IBOutlet weak var TextSizeValueLabel: UILabel!
    @IBOutlet weak var BackView: UIView!
    @IBOutlet weak var DefaultTextSizeSettingsView: UIView!
    @IBOutlet weak var ConstSampleTextViewWidht: NSLayoutConstraint!
    @IBOutlet weak var ConstSampleTextViewHigth: NSLayoutConstraint!
    @IBOutlet weak var ConstSampleTextLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var ConstSampleTextScrollViewHight: NSLayoutConstraint!
    
    var CurrentTextSize = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConstSampleTextScrollViewHight.constant = view.frame.height - (64 + 110 + (view.frame.width - 40) + 20)
        ConstSampleTextViewWidht.constant = view.frame.width - 40
        ConstSampleTextLabelWidth.constant = view.frame.width - 55
        
        SampleTextView.layer.cornerRadius = 10
        SampleTextLabel.numberOfLines = 0
        SampleScrollView.bounces = false
        
        let TextSize:Int = TextSettings["TextSize"] as! Int
        CurrentTextSize = TextSize
        
        let TextFont:String = TextSettings["TextFont"] as! String
        
        let BackgroundColor:[String:Any] = TextSettings["BackgroundColor"] as! [String : Any]
        let redBackground:Double = BackgroundColor["red"] as! Double
        let greenBackground:Double = BackgroundColor["green"] as! Double
        let blueBackground:Double = BackgroundColor["blue"] as! Double
        
        let TextColor:[String:Any] = TextSettings["TextColor"] as! [String : Any]
        let redText:Double = TextColor["red"] as! Double
        let greenText:Double = TextColor["green"] as! Double
        let blueText:Double = TextColor["blue"] as! Double
        
        TextModification(TextSize: TextSize, TextFont: TextFont)
        
        SampleTextView.backgroundColor = UIColor(red: redBackground, green: greenBackground, blue: blueBackground, alpha: 1)
        SampleTextLabel.textColor = UIColor(red: redText, green: greenText, blue: blueText, alpha: 1)
        
        TextSizeSlider.value = Float(TextSize)
        TextSizeValueLabel.text = String(TextSize)
        
        let tapBackView = UITapGestureRecognizer(target: self, action: #selector(self.Back))
        BackView.addGestureRecognizer(tapBackView)
        
        let tapDefaultTextSizeSettingsView = UITapGestureRecognizer(target: self, action: #selector(self.DefaultTextSizeSettings))
        DefaultTextSizeSettingsView.addGestureRecognizer(tapDefaultTextSizeSettingsView)
        
    }
    
    @objc
    private func Back(){
        
        let TextSize:Int = TextSettings["TextSize"] as! Int
        
        if ((LastController == "FinishedViewController") && (TextSize != CurrentTextSize)){
            NotificationCenter.default.post(name: Notification.Name("СhangingTextSettings"), object: nil)
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            dismiss(animated: true,completion: nil)
        }
        
    }
    
    @objc
    private func DefaultTextSizeSettings(){
        
        AlertDefaultTextSizeSettings()
        
    }
    
    @IBAction func SliderButton(_ sender: UISlider) {
        
        TextSizeValueLabel.text = String(Int(sender.value))
        
        let TextFont:String = TextSettings["TextFont"] as! String
        
        TextModification(TextSize: Int(sender.value), TextFont: TextFont)
        
        let fixedWidth = ConstSampleTextLabelWidth.constant
        let newSize = SampleTextLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        if (newSize.height + 15) > ConstSampleTextScrollViewHight.constant{
            ConstSampleTextViewHigth.constant = newSize.height + 15
        }else{
            ConstSampleTextViewHigth.constant = ConstSampleTextScrollViewHight.constant
            
        }
        
        TextSettings["TextSize"] = Int(sender.value)
        UserDefaults.standard.setValue(TextSettings, forKey: "TextSettings")
        
    }
    
    func TextModification(TextSize:Int,TextFont: String){
        
        let BoldLettersArray:[String] = ["Bol", "Readi", "i", "a", "ap", "tha", "facilitat", "th", "readi", "proce", "b", "guidi", "th", "eye", "ove", "tex", "wit", "artifici", "fixati", "poin", "A", "resu", "th", "read", "focus", "onl", "o", "th", "highlight", "initi", "lette", "an", "allo", "th", "bra", "cent", "t", "comple", "th", "wor", "I", "digit", "wor", "dominat", "b", "shall", "for", "o", "readi", "Bol", "Readi", "aim", "t", "encoura", "deep", "readi", "an", "understand", "o", "writt", "conte"]
        let Text = "\"Bold Reading\" is an app that facilitates the reading process by guiding the eyes over text with artificial fixation points. As a result, the reader focuses only on the highlighted initial letters and allows the brain center to complete the word. In a digital world dominated by shallow forms of reading, \"Bold Reading\" aims to encourage deeper reading and understanding of written content."
        let attributedText = NSMutableAttributedString.init(string: Text)
        for BoldLetters in BoldLettersArray{
            let NewBoldLetters = " " + BoldLetters
            let FirstRevisedText = Text.replacingOccurrences(of: "\n", with: " ")
            let SecondRevisedText = FirstRevisedText.replacingOccurrences(of: "\"", with: " ")
            
            let indicies = SecondRevisedText.indicesOf(string: NewBoldLetters)
            for index in indicies{
                let indexFirstLetter = SecondRevisedText.index(SecondRevisedText.startIndex, offsetBy: index)
                let indexLastLetter = SecondRevisedText.index(SecondRevisedText.startIndex, offsetBy: index + BoldLetters.count + 1)
                
                if ((SecondRevisedText[indexFirstLetter] == " ") && (SecondRevisedText[indexLastLetter] != " ")){
                    let strIndexStart = SecondRevisedText.index(SecondRevisedText.startIndex, offsetBy: index)
                    let strIndexEnd = SecondRevisedText.index(SecondRevisedText.startIndex, offsetBy: index + NewBoldLetters.count)
                    let range = strIndexStart..<strIndexEnd
                    
                    var name = ""
                    if TextFont == "COPPERPLATE"{
                        name = TextFont + "-Bold"
                    }else{
                        name = TextFont + " Bold"
                    }
                    
                    attributedText.addAttribute(NSAttributedString.Key.font, value:  UIFont(name: name, size: CGFloat(TextSize))!, range: NSRange(range, in: SecondRevisedText))
                }
            }
        }
        
        DispatchQueue.main.async { [self] in
            
            SampleTextLabel.font = UIFont(name: TextFont, size: CGFloat(TextSize))
            SampleTextLabel.attributedText = attributedText
            
            let fixedWidth = ConstSampleTextLabelWidth.constant
            let newSize = SampleTextLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            if (newSize.height + 15) > ConstSampleTextScrollViewHight.constant{
                ConstSampleTextViewHigth.constant = newSize.height + 15
            }else{
                ConstSampleTextViewHigth.constant = ConstSampleTextScrollViewHight.constant
            }
        }
    }
    
    func AlertDefaultTextSizeSettings(){
        
        let alertDefaultTextSizeSettings = UIAlertController(title: nil, message: "Are you sure you want to set text size to default?", preferredStyle: UIAlertController.Style.alert)
        
        alertDefaultTextSizeSettings.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] (action: UIAlertAction!) in
            
            let TextFont:String = TextSettings["TextFont"] as! String
            
            TextModification(TextSize: 20, TextFont: TextFont)
            TextSizeSlider.value = 20
            TextSizeValueLabel.text = String(20)
            
            TextSettings["TextSize"] = 20
            UserDefaults.standard.setValue(TextSettings, forKey: "TextSettings")
            
        }))
        
        alertDefaultTextSizeSettings.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertDefaultTextSizeSettings, animated: true, completion: nil)
        
    }
    
}
