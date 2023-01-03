import UIKit
import PDFKit
import Lottie

var ConnnetedStatus = 0

class FinishedViewController: UIViewController {
    
    @IBOutlet weak var BackView: UIView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var attributedTextView: UIView!
    @IBOutlet weak var attributedTextLabel: UILabel!
    @IBOutlet weak var attributedScrollView: UIScrollView!
    @IBOutlet weak var LoadingActIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ConstAttributedTextViewWidth: NSLayoutConstraint!
    @IBOutlet weak var ConstAttributedTextViewHigth: NSLayoutConstraint!
    @IBOutlet weak var ConstAttributedTextLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var LoadingView: UIView!
    
    var glossaryIndex:Int = 0
    var TextLoadingStatus = false
    var WIFIanimation: LottieAnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(СhangingTextSettings), name: Notification.Name("СhangingTextSettings"), object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            updateUserInterface()
        }
        
        WIFIanimation = .init(name: "WI-FI")
        WIFIanimation.frame = view.bounds
        WIFIanimation.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
        WIFIanimation.loopMode = .loop
        view.addSubview(WIFIanimation)
        WIFIanimation.stop()
        WIFIanimation.isHidden = true
        
        LoadingView.alpha = 0
        LoadingActIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        LoadingActIndicator.isHidden = true
        LoadingActIndicator.stopAnimating()
        
        attributedScrollView.bounces = false
        
        let glossary = filteredData[glossaryIndex]
        let title:String = glossary["title"]!
        TitleLabel.text = title
        
        attributedTextView.layer.cornerRadius = 10
        attributedTextLabel.numberOfLines = 0
        
        ConstAttributedTextViewWidth.constant = view.frame.width - 40
        ConstAttributedTextLabelWidth.constant = view.frame.width - 55
        
        let tapBackView = UITapGestureRecognizer(target: self, action: #selector(self.Back))
        BackView.addGestureRecognizer(tapBackView)
        
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        LastController = "FinishedViewController"
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        
        LastController = "ViewController"
        
    }
    
    func PreparingTextForUploading (){
        
        let glossary = filteredData[glossaryIndex]
        
        let text:String = glossary["text"]!
        let type:String = glossary["type"]!
        let TextSize:Int = TextSettings["TextSize"] as! Int
        let TextFont:String = TextSettings["TextFont"] as! String
        
        switch type{
        case "text":
            
            PostRequest(Text: " " + text, TextSize: TextSize, TextFont: TextFont)
            
        case "txt":
            
            let linkText = try? String(contentsOf: URL(string: text)!, encoding: .utf8)
            PostRequest(Text: " " + linkText!, TextSize: TextSize, TextFont: TextFont)
            
        case "html":
            
            readHTML(Text: text,TextSize: TextSize, TextFont: TextFont)
            
        case "pdf":
            
            readPDF(Text: text,TextSize: TextSize, TextFont: TextFont)
            
        case "image":
            
            PostRequest(Text: " " + text, TextSize: TextSize, TextFont: TextFont)
            
        default:
            
            print("error")
            
        }
        
    }
    
    func updateUserInterface(){
        
        switch Network.reachability.status {
        case .unreachable:
            if !TextLoadingStatus{
                LoadingActIndicator.stopAnimating()
                LoadingActIndicator.isHidden = true
                LoadingView.alpha = 0
                attributedScrollView.isScrollEnabled = false
                WIFIanimation.isHidden = false
                WIFIanimation.play()
                ConnnetedStatus = 0
            }
        case .wwan:
            print("wwan")
        case .wifi:
            if !TextLoadingStatus{
                WIFIanimation.stop()
                WIFIanimation.isHidden = true
                attributedScrollView.isScrollEnabled = true
                LoadingView.alpha = 0.7
                LoadingActIndicator.isHidden = false
                LoadingActIndicator.startAnimating()
                ConnnetedStatus = 1
                PreparingTextForUploading ()
            }
            
        }
        
    }
    
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    @objc
    private func Back(){
        dismiss(animated: true,completion: nil)
    }
    
    @objc
    func СhangingTextSettings(){
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            updateUserInterface()
        }
        
        TextLoadingStatus = false
        
        attributedTextLabel.text = ""
        attributedTextView.backgroundColor = .white
        
        let fixedWidth = ConstAttributedTextLabelWidth.constant
        let newSize = attributedTextLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        if (newSize.height + 15) > attributedScrollView.frame.height{
            ConstAttributedTextViewHigth.constant = newSize.height + 15
        }else{
            ConstAttributedTextViewHigth.constant = attributedScrollView.frame.height
        }
        
        LoadingView.alpha = 0.7
        LoadingActIndicator.isHidden = false
        LoadingActIndicator.startAnimating()
        
        PreparingTextForUploading ()
        
    }
    
    func readHTML(Text:String,TextSize: Int, TextFont: String){
        
        let myURLhtml = Text
        
        let text = try? String(contentsOf: URL(string: myURLhtml)!, encoding: .utf8)
        let data = text!.data(using: .utf8)
        
        do{
            let HTML = try NSMutableAttributedString(data: data!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            
            HTML.enumerateAttributes(in: NSRange(location: 0, length: HTML.length), options: []) { attributes, range, stop in
                HTML.removeAttribute(.link, range: range)
                HTML.removeAttribute(.foregroundColor, range: range)
                HTML.removeAttribute(.underlineStyle, range: range)
                
            }
            
            PostRequest(Text: " " + HTML.string, TextSize: TextSize, TextFont: TextFont)
            
        }catch{
            print("error")
        }
        
    }
    
    func readPDF(Text:String,TextSize: Int, TextFont: String){
        
        let myURLpdf = Text
        
        if let PDF = PDFDocument(url: URL(string: myURLpdf)!) {
            let pageCount = PDF.pageCount
            let documentContent = NSMutableAttributedString()
            
            for page in 0 ..< pageCount {
                guard let Page = PDF.page(at: page) else { continue }
                guard let pageContent = Page.attributedString else { continue }
                documentContent.append(pageContent)
            }
            
            PostRequest(Text: " " + documentContent.string, TextSize: TextSize, TextFont: TextFont)
            
        }
        
    }
    
    func PostRequest(Text:String,TextSize: Int, TextFont: String){
        
        let headers = [
            "content-type": "application/x-www-form-urlencoded",
            "X-RapidAPI-Key": "67a4d292dfmsh04e79e32fd36edbp16aeb7jsnc2946c248d16",
            "X-RapidAPI-Host": "bionic-reading1.p.rapidapi.com"
        ]
        
        let OriginalText = "content=" + Text
        let postData = NSMutableData(data: OriginalText.data(using: String.Encoding.utf8)!)
        postData.append("&response_type=html".data(using: String.Encoding.utf8)!)
        postData.append("&request_type=html".data(using: String.Encoding.utf8)!)
        postData.append("&fixation=1".data(using: String.Encoding.utf8)!)
        postData.append("&saccade=10".data(using: String.Encoding.utf8)!)
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://bionic-reading1.p.rapidapi.com/convert")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [self] (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                
                do{
                    html = try NSAttributedString(data: data!, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
                    
                    let htmlString = "\(html)"
                    var BoldLettersArray:[String] = []
                    let FirstResultSeparation =  htmlString.components(separatedBy:"}")
                    for index in 0..<FirstResultSeparation.count-1{
                        let SecondResultSeparation =  FirstResultSeparation[index].components(separatedBy:"{")
                        BoldLettersArray.append(SecondResultSeparation[0])
                    }
                    
                    var NewbBoldLettersArray = BoldLettersArray
                    BoldLettersArray = []
                    var paragraphs = ""
                    for _ in 0..<100{
                        paragraphs.append("\n")
                        BoldLettersArray = NewbBoldLettersArray.filter {$0 != paragraphs}
                        NewbBoldLettersArray = BoldLettersArray
                        BoldLettersArray = []
                    }
                    BoldLettersArray = NewbBoldLettersArray
                    let BoldLettersDuplicateArray = BoldLettersArray
                    BoldLettersArray = []
                    BoldLettersArray = stride(from: 0, to: BoldLettersDuplicateArray.count - 1, by: 2).map { BoldLettersDuplicateArray[$0] }
                    
                    let PureBoldLettersArray = Array(Set(BoldLettersArray))
                    
                    let attributedText = NSMutableAttributedString.init(string: Text)
                    for BoldLetters in PureBoldLettersArray{
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
                    
                    if ConnnetedStatus == 1{
                        EndOfTextLoading(TextFont: TextFont, TextSize: TextSize, attributedText: attributedText)
                    }
                    
                }catch{
                    print("error")
                }
            }
        })
        
        dataTask.resume()
        
    }
    
    func EndOfTextLoading(TextFont: String, TextSize: Int, attributedText: NSAttributedString){
        
        DispatchQueue.main.async { [self] in
            
            let BackgroundColor:[String:Any] = TextSettings["BackgroundColor"] as! [String : Any]
            let redBackground:Double = BackgroundColor["red"] as! Double
            let greenBackground:Double = BackgroundColor["green"] as! Double
            let blueBackground:Double = BackgroundColor["blue"] as! Double
            
            let TextColor:[String:Any] = TextSettings["TextColor"] as! [String : Any]
            let redText:Double = TextColor["red"] as! Double
            let greenText:Double = TextColor["green"] as! Double
            let blueText:Double = TextColor["blue"] as! Double
            
            LoadingActIndicator.isHidden = true
            LoadingActIndicator.stopAnimating()
            LoadingView.alpha = 0
            
            attributedTextLabel.font = UIFont(name: TextFont, size: CGFloat(TextSize))
            attributedTextLabel.attributedText = attributedText
            
            attributedTextView.backgroundColor = UIColor(red: redBackground, green: greenBackground, blue: blueBackground, alpha: 1)
            attributedTextLabel.textColor = UIColor(red: redText, green: greenText, blue: blueText, alpha: 1)
            
            let fixedWidth = ConstAttributedTextLabelWidth.constant
            let newSize = attributedTextLabel.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
            if (newSize.height + 15) > attributedScrollView.frame.height{
                ConstAttributedTextViewHigth.constant = newSize.height + 15
            }else{
                ConstAttributedTextViewHigth.constant = attributedScrollView.frame.height
            }
        }
        
        TextLoadingStatus = true
        
    }
    
}

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
              let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
              !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}
