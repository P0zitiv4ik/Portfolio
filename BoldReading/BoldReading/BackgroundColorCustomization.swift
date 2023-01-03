import UIKit

class BackgroundColorCustomization: UIViewController {
    
    @IBOutlet weak var SampleTextLabel: UILabel!
    @IBOutlet weak var SampleTextView: UIView!
    @IBOutlet weak var SampleScrollView: UIScrollView!
    @IBOutlet weak var SelectedColorView: UIView!
    @IBOutlet weak var BackView: UIView!
    @IBOutlet weak var DefaultBackgroundColorSettingsView: UIView!
    @IBOutlet weak var ConstSampleTextViewWidht: NSLayoutConstraint!
    @IBOutlet weak var ConstSampleTextViewHigth: NSLayoutConstraint!
    @IBOutlet weak var ConstSampleTextLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var ConstSampleTextScrollViewHight: NSLayoutConstraint!
    
    var ButtonTag = 0
    var lastLine = 0
    var CurrentRedBackground = 0.0
    var CurrentGreenBackground = 0.0
    var CurrentBlueBackground = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ConstSampleTextScrollViewHight.constant = view.frame.height - (64 + 110 + (view.frame.width - 40) + 20)
        ConstSampleTextViewWidht.constant = view.frame.width - 40
        ConstSampleTextLabelWidth.constant = view.frame.width - 55
        
        SampleTextView.layer.cornerRadius = 10
        SampleTextLabel.numberOfLines = 0
        SampleScrollView.bounces = false
        
        let TextSize:Int = TextSettings["TextSize"] as! Int
        
        let TextFont:String = TextSettings["TextFont"] as! String
        
        let BackgroundColor:[String:Any] = TextSettings["BackgroundColor"] as! [String : Any]
        let redBackground:Double = BackgroundColor["red"] as! Double
        let greenBackground:Double = BackgroundColor["green"] as! Double
        let blueBackground:Double = BackgroundColor["blue"] as! Double
        CurrentRedBackground = redBackground
        CurrentGreenBackground = greenBackground
        CurrentBlueBackground = blueBackground
        
        let TextColor:[String:Any] = TextSettings["TextColor"] as! [String : Any]
        let redText:Double = TextColor["red"] as! Double
        let greenText:Double = TextColor["green"] as! Double
        let blueText:Double = TextColor["blue"] as! Double
        
        TextModification(TextSize: TextSize, TextFont: TextFont)
        
        SampleTextView.backgroundColor = UIColor(red: redBackground, green: greenBackground, blue: blueBackground, alpha: 1)
        
        SampleTextLabel.textColor = UIColor(red: redText, green: greenText, blue: blueText, alpha: 1)
        
        var buttonFrame = CGRect(
            x: 20,
            y: view.frame.height - (view.frame.width - 40+20),
            width: (view.frame.width - 40) / 12,
            height: (view.frame.width - 40) / 12
        )
        var сolorBrightness:CGFloat = 1.0
        for currentLine in 0..<11{
            if currentLine == 10{
                lastLine = 1
            }
            makeRainbowButtons(buttonFrame: buttonFrame, sat: сolorBrightness ,bright: 1.0)
            сolorBrightness = сolorBrightness - 0.1
            buttonFrame.origin.y = buttonFrame.origin.y + buttonFrame.size.height
            
        }
        
        SelectedColorView.layer.borderWidth = 2
        SelectedColorView.layer.borderColor = UIColor.black.cgColor
        
        let tag:Double = BackgroundColor["tag"] as! Double
        
        let lineNumber = Int(tag) / 12
        let columnNumber = Int(tag) % 12
        let colorButtonSize = (view.frame.width - 40) / 12
        let topDistancePalette = view.frame.height - (view.frame.width - 40+20)
        SelectedColorView.frame = CGRect(x: 20 + colorButtonSize*CGFloat(columnNumber), y: CGFloat(topDistancePalette + CGFloat(colorButtonSize*CGFloat(lineNumber))), width: colorButtonSize, height: colorButtonSize)
        view.addSubview(SelectedColorView)
        
        let tapDefaultBackgroundColorSettingsView = UITapGestureRecognizer(target: self, action: #selector(self.DefaultBackgroundColorSettings))
        DefaultBackgroundColorSettingsView.addGestureRecognizer(tapDefaultBackgroundColorSettingsView)
        
        let tapBackView = UITapGestureRecognizer(target: self, action: #selector(self.Back))
        BackView.addGestureRecognizer(tapBackView)
        
    }
    
    @objc
    private func Back(){
        
        let BackgroundColor:[String:Any] = TextSettings["BackgroundColor"] as! [String : Any]
        let redBackground:Double = BackgroundColor["red"] as! Double
        let greenBackground:Double = BackgroundColor["green"] as! Double
        let blueBackground:Double = BackgroundColor["blue"] as! Double
        
        if ((LastController == "FinishedViewController") && ((redBackground != CurrentRedBackground) || (greenBackground != CurrentGreenBackground) || (blueBackground != CurrentBlueBackground))){
            NotificationCenter.default.post(name: Notification.Name("СhangingTextSettings"), object: nil)
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            dismiss(animated: true,completion: nil)
        }
        
    }
    
    @objc
    private func DefaultBackgroundColorSettings(){
        
        AlertDefaultBackgroundColorSettings()
        
    }
    
    @objc func displayColor(sender:UIButton){
        
        let lineNumber = sender.tag / 12
        let columnNumber = sender.tag % 12
        let colorButtonSize = (view.frame.width - 40) / 12
        let topDistancePalette = view.frame.height - (view.frame.width - 40+20)
        SelectedColorView.frame = CGRect(x: 20 + colorButtonSize*CGFloat(columnNumber), y: CGFloat(topDistancePalette + CGFloat(colorButtonSize*CGFloat(lineNumber))), width: colorButtonSize, height: colorButtonSize)
        view.addSubview(SelectedColorView)
        
        let color = sender.backgroundColor!
        SampleTextView.backgroundColor = color
        
        var r:CGFloat = 0,
            g:CGFloat = 0,
            b:CGFloat = 0,
            a:CGFloat = 0,
            h:CGFloat = 0,
            s:CGFloat = 0,
            l:CGFloat = 0
        if color.getHue(
            &h, saturation: &s,
            brightness: &l,
            alpha: &a)
        {
            if color.getRed(
                &r,
                green: &g,
                blue: &b,
                alpha: &a)
            {
                
                TextSettings["BackgroundColor"] = ["red": Double(r),"green": Double(g),"blue": Double(b),"tag": Double(sender.tag)]
                UserDefaults.standard.setValue(TextSettings, forKey: "TextSettings8")
            }
        }
    }
    
    func makeRainbowButtons(
        buttonFrame:CGRect,
        sat:CGFloat,
        bright:CGFloat)
    {
        var myButtonFrame = buttonFrame
        //populate an array of buttonn
        for currentСolumn in 0..<12{
            let hue:CGFloat = CGFloat(currentСolumn) / 12.0
            var color = UIColor()
            if lastLine == 1{
                let brigthness = 1 - CGFloat(currentСolumn) / 12.0
                color = UIColor(
                    hue: hue,
                    saturation: sat,
                    brightness: brigthness,
                    alpha: 1.0)
            }else{
                color = UIColor(
                    hue: hue,
                    saturation: sat,
                    brightness: bright,
                    alpha: 1.0)
            }
            let aButton = UIButton(frame: myButtonFrame)
            aButton.tag = ButtonTag
            ButtonTag += 1
            myButtonFrame.origin.x = myButtonFrame.size.width + myButtonFrame.origin.x
            aButton.backgroundColor = color
            view.addSubview(aButton)
            aButton.addTarget(
                self,
                action: #selector(displayColor),
                for: UIControl.Event.touchUpInside)
        }
        
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
    
    func AlertDefaultBackgroundColorSettings(){
        
        let alertDefaultBackgroundColorSettings = UIAlertController(title: nil, message: "Are you sure you want to set background color to default?", preferredStyle: UIAlertController.Style.alert)
        
        alertDefaultBackgroundColorSettings.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [self] (action: UIAlertAction!) in
            
            SampleTextView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1)
            
            let colorButtonSize = (view.frame.width - 40) / 12
            let topDistancePalette = view.frame.height - (view.frame.width - 40+20)
            SelectedColorView.frame = CGRect(x: 20, y: topDistancePalette + colorButtonSize*10, width: colorButtonSize, height: colorButtonSize)
            
            TextSettings["BackgroundColor"] = ["red":1.0,"green":1.0,"blue":1.0,"tag":120]
            UserDefaults.standard.setValue(TextSettings, forKey: "TextSettings8")
            
        }))
        
        alertDefaultBackgroundColorSettings.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertDefaultBackgroundColorSettings, animated: true, completion: nil)
        
    }
}
