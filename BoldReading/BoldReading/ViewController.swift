import UIKit

var data: [[String : String]] = []
var filteredData:[[String : String]] = []
var TextSettings:[String:Any] = [:]
var LastController = "ViewController"

protocol OkDelegate:NSObject {
    func Ok(_ Ok:String)
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ApplicationNameLabel: UILabel!
    @IBOutlet var filteredDataButtonArr: [UIButton]!
    @IBOutlet weak var AddButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var SliderView: UIView!
    @IBOutlet weak var addFirstTextLabel: UILabel!
    @IBOutlet weak var locationView: UIButton!
    
    var СurrentTextType = "all"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "data") != nil{
            data = UserDefaults.standard.object(forKey: "data") as! [[String : String]]
        }
        
        if UserDefaults.standard.object(forKey: "TextSettings") != nil{
            TextSettings = UserDefaults.standard.object(forKey: "TextSettings") as! [String : Any]
        }else{
            TextSettings = ["TextSize":20,"TextFont":"Helvetica Neue", "TextColor":["red":0.0,"green":0.0,"blue":0.0,"tag":131], "BackgroundColor":["red":1.0,"green":1.0,"blue":1.0,"tag":120]]
            UserDefaults.standard.setValue(TextSettings, forKey: "TextSettings")
        }
        
        TextModification()
        
        SliderView.layer.shadowColor = UIColor.systemGray2.cgColor
        SliderView.layer.shadowOpacity = 1
        SliderView.layer.shadowOffset = .zero
        SliderView.layer.shadowRadius = 10
        SliderView.layer.cornerRadius = 7
        
        filteredData = data
        
        datаType()
        
        addFirstTextLabel.numberOfLines = 0
        addFirstTextLabel.text = "Don't have any entries with the bold reading technique yet?\n\nThen click the \"+\" button in the upper right corner to add your first entry. You can also customize your text to your liking. All you have to do is click the Settings icon in the upper left corner and choose what you want.\n\nGood luck!!!"
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        
        SliderView.frame = CGRect(x: Int(allButton.frame.origin.x) - ObjectDistance(Text: (allButton.titleLabel?.text)!), y: Int(locationView.frame.origin.y), width: 50, height: 31)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddVC"{
            if let navVC = segue.destination as? UINavigationController, let newVC = navVC.topViewController as? AddViewController{
                newVC.delegate = self
            }
        }
    }
    
    func TextModification(){
        
        let BoldLettersArray:[String] = ["Bol", "Readi"]
        let Text = "Bold Reading"
        let attributedText = NSMutableAttributedString.init(string: Text)
        for BoldLetters in BoldLettersArray{
            let indicies = Text.indicesOf(string: BoldLetters)
            
            for index in indicies{
                
                let strIndexStart = Text.index(Text.startIndex, offsetBy: index)
                let strIndexEnd = Text.index(Text.startIndex, offsetBy: index + BoldLetters.count)
                let range = strIndexStart..<strIndexEnd
                
                attributedText.addAttribute(NSAttributedString.Key.font, value:  UIFont(name: "Helvetica Neue Bold", size: 32)!, range: NSRange(range, in: Text))
                
            }
        }
        
        DispatchQueue.main.async { [self] in
            
            ApplicationNameLabel.font = UIFont(name: "Helvetica Neue", size: 32)
            ApplicationNameLabel.attributedText = attributedText
            
        }
    }
    
    func datаType(){
        
        var dateTypeArr :[String] = []
        
        for dict in data{
            let type:String = dict["type"]!
            if !dateTypeArr.contains(type){
                dateTypeArr.append(type)
            }
        }
        
        for i in 0..<5{
            if i < dateTypeArr.count{
                filteredDataButtonArr[i].isHidden = false
                filteredDataButtonArr[i].setTitle(dateTypeArr[i], for: .normal)
            }else{
                filteredDataButtonArr[i].isHidden = true
            }
            
        }
        
    }
    
    @IBAction func dataTypeButtonArray(_ sender: UIButton) {
        
        UIView.animate(withDuration: 0.3) { [self] in
            SliderView.frame.origin.x = (sender.frame.origin.x - CGFloat(ObjectDistance(Text: (sender.titleLabel?.text)!)))
        } completion: { [self] _ in
            СurrentTextType = (sender.titleLabel?.text)!
            if СurrentTextType == "all"{
                filteredData = data
            }else{
                filteredData = data.filter{
                    ($0["type"]) == СurrentTextType
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func ObjectDistance(Text:String)->Int{
        
        switch Text{
        case "image":
            return 3
        case "html":
            return 9
        case "all","pdf","text":
            return 10
        case "txt":
            return 11
        default:
            return 10
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !data.isEmpty{
            addFirstTextLabel.isHidden = true
            SliderView.isHidden = false
            allButton.isHidden = false
            tableView.isHidden = false
            return filteredData.count
        }else{
            SliderView.isHidden = true
            allButton.isHidden = true
            tableView.isHidden = true
            addFirstTextLabel.isHidden = false
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let item = filteredData[indexPath.row]
        let title:String = item["title"]!
        let type:String = item["type"]!
        
        tableView.bounces = false
        cell.separatorInset = UIEdgeInsets(top: 0, left: 13, bottom: 0, right: 26)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = type
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let next = self.storyboard!.instantiateViewController(withIdentifier: "FinishedViewController") as! FinishedViewController
        next.modalPresentationStyle = .overFullScreen
        next.glossaryIndex = indexPath.row
        self.present(next, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            var dataNew = data
            for index in data.indices{
                if filteredData[indexPath.row] == data[index]{
                    dataNew.remove(at: index)
                }
                
            }
            data = dataNew
            UserDefaults.standard.setValue(data, forKey: "data")
            
            filteredData.remove(at: indexPath.row)
            
            datаType()
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            if filteredData.isEmpty{
                
                UIView.animate(withDuration: 0.3) { [self] in
                    SliderView.frame = CGRect(x: Int(allButton.frame.origin.x) - 10, y: Int(locationView.frame.origin.y), width: 50, height: 31)
                } completion: { _ in
                    filteredData = data
                    self.tableView.reloadData()
                }
            }
        }
    }
    
}

extension ViewController: OkDelegate{
    func Ok(_ Ok: String) {
        
        if СurrentTextType == "all"{
            filteredData = data
            
        }else{
            filteredData = data.filter{
                ($0["type"]) == СurrentTextType
            }
            
        }
        datаType()
        tableView.reloadData()
        
    }
    
}
