import UIKit
import Lottie

class TextFontCustomization: UIViewController {
    
    @IBOutlet weak var SampleTextLabel: UILabel!
    @IBOutlet weak var BackView: UIView!
    @IBOutlet weak var SampleTextView: UIView!
    @IBOutlet weak var SampleScrollView: UIScrollView!
    @IBOutlet weak var DefaultTextFontSettingsView: UIView!
    @IBOutlet var TextFontButtonArr: [UIButton]!
    @IBOutlet weak var ConstSampleTextViewWidht: NSLayoutConstraint!
    @IBOutlet weak var ConstSampleTextViewHigth: NSLayoutConstraint!
    @IBOutlet weak var ConstSampleTextLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var ConstSampleTextScrollViewHight: NSLayoutConstraint!
    
    var CheckboxAnimation: LottieAnimationView!
    var CurrentTextFont = ""
    let FontArr = ["Helvetica Neue", "American Typewriter", "Avenir Next Condensed", "Chalkboard SE", "COPPERPLATE", "Menlo", "Noteworthy", "Snell Roundhand"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CheckboxAnimation = .init(name: "Checkbox")
        
        ConstSampleTextScrollViewHight.constant = view.frame.height - (64 + 110 + (view.frame.width - 40) + 20)
        ConstSampleTextViewWidht.constant = view.frame.width - 40
        ConstSampleTextLabelWidth.constant = view.frame.width - 55
        
        SampleTextView.layer.cornerRadius = 10
        SampleTextLabel.numberOfLines = 0
        SampleScrollView.bounces = false
        
        let TextSize:Int = TextSettings["TextSize"] as! Int
        
        let TextFont:String = TextSettings["TextFont"] as! String
        CurrentTextFont = TextFont
        
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            AnimationPosition(TextFont: TextFont)
        }
        
        view.addSubview(CheckboxAnimation)
        CheckboxAnimation.play()
        
        let tapDefaultTextFontSettingsView = UITapGestureRecognizer(target: self, action: #selector(self.DefaultTextFontSettings))
        DefaultTextFontSettingsView.addGestureRecognizer(tapDefaultTextFontSettingsView)
        
        let tapBackView = UITapGestureRecognizer(target: self, action: #selector(self.Back))
        BackView.addGestureRecognizer(tapBackView)
        
    }
    
    @objc
    private func Back(){
        
        let TextFont:String = TextSettings["TextFont"] as! String
        
        if ((LastController == "FinishedViewController") && (TextFont != CurrentTextFont)){
            NotificationCenter.default.post(name: Notification.Name("СhangingTextSettings"), object: nil)
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            dismiss(animated: true,completion: nil)
        }
        
    }
    
    @objc
    private func DefaultTextFontSettings(){
        
        AlertDefaultTextFontSettings()
        
    }
    
    @IBAction func TextFontButton(_ sender: UIButton) {
        
        let TextFont = FontArr[sender.tag]
        
        AnimationPosition(TextFont: TextFont)
        
        CheckboxAnimation.isHidden = true
        CheckboxAnimation.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
            CheckboxAnimation.isHidden = false
            let TextSize:Int = TextSettings["TextSize"] as! Int
            TextModification(TextSize: TextSize, TextFont: TextFont)
        }
        
        TextSettings["TextFont"] = TextFont
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
    
    func AnimationPosition(TextFont:String){
        
        switch TextFont{
        case "Helvetica Neue":
            CheckboxAnimation.frame = CGRect(x: TextFontButtonArr.first!.frame.origin.x+60, y: TextFontButtonArr.first!.frame.origin.y-57, width: 150, height: 150)
        case "American Typewriter":
            CheckboxAnimation.frame = CGRect(x: TextFontButtonArr[1].frame.origin.x+60, y: TextFontButtonArr[1].frame.origin.y-59, width: 150, height: 150)
        case "Avenir Next Condensed":
            CheckboxAnimation.frame = CGRect(x: TextFontButtonArr[2].frame.origin.x+60, y: TextFontButtonArr[2].frame.origin.y-53, width: 150, height: 150)
        case "Chalkboard SE":
            CheckboxAnimation.frame = CGRect(x: TextFontButtonArr[3].frame.origin.x+60, y: TextFontButtonArr[3].frame.origin.y-53, width: 150, height: 150)
        case "COPPERPLATE":
            CheckboxAnimation.frame = CGRect(x: TextFontButtonArr[4].frame.origin.x+60, y: TextFontButtonArr[4].frame.origin.y-61, width: 150, height: 150)
        case "Menlo":
            CheckboxAnimation.frame = CGRect(x: TextFontButtonArr[5].frame.origin.x+60, y: TextFontButtonArr[5].frame.origin.y-60, width: 150, height: 150)
        case "Noteworthy":
            CheckboxAnimation.frame = CGRect(x: TextFontButtonArr[6].frame.origin.x+60, y: TextFontButtonArr[6].frame.origin.y-49, width: 150, height: 150)
        case "Snell Roundhand":
            CheckboxAnimation.frame = CGRect(x: TextFontButtonArr[7].frame.origin.x+60, y: TextFontButtonArr[7].frame.origin.y-52, width: 150, height: 150)
        default:
            print("error")
        }
    }
    
    func AlertDefaultTextFontSettings(){
        
        let alertDefaultTextFontSettings = UIAlertController(title: nil, message: "Are you sure you want to set the default text font?", preferredStyle: UIAlertController.Style.alert)
        
        alertDefaultTextFontSettings.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] (action: UIAlertAction!) in
            
            CheckboxAnimation.frame = CGRect(x: TextFontButtonArr.first!.frame.origin.x+60, y: TextFontButtonArr.first!.frame.origin.y-57, width: 150, height: 150)
            
            CheckboxAnimation.isHidden = true
            CheckboxAnimation.play()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [self] in
                CheckboxAnimation.isHidden = false
                let TextSize:Int = TextSettings["TextSize"] as! Int
                TextModification(TextSize: TextSize, TextFont: "Helvetica Neue")
            }
            
            TextSettings["TextFont"] = "Helvetica Neue"
            UserDefaults.standard.setValue(TextSettings, forKey: "TextSettings")
            
        }))
        
        alertDefaultTextFontSettings.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertDefaultTextFontSettings, animated: true, completion: nil)
        
    }
    
}
