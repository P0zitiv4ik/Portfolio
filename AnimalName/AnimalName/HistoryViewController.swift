import UIKit
import SafariServices

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var ClearHistoryButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let tapBackButton = UITapGestureRecognizer(target: self, action: #selector(self.Back))
        BackButton.addGestureRecognizer(tapBackButton)
        
        let tapClearHistoryButton = UITapGestureRecognizer(target: self, action: #selector(self.ClearHistory))
        ClearHistoryButton.addGestureRecognizer(tapClearHistoryButton)
        
    }
    
    @objc
    private func Back(){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc func ClearHistory(){
        
        AlertClearHistory()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 149;
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if AnimalHistoryArr.count == 0{
            tableView.alpha = 0
            return 0
        }else{
            tableView.alpha = 1
            return AnimalHistoryArr.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MyCustomCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MyCustomCell
        cell.selectionStyle = .none
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        let item = AnimalHistoryArr[indexPath.row]
        let Image:Data = item["Image"] as! Data
        let Name:String = item["Name"] as! String
        let date:String = item["date"] as! String
        
        cell.ReadMoreHistoryButton.tag = indexPath.row
        cell.ResultHistoryLabel.text = Name
        let decoded = try! PropertyListDecoder().decode(Data.self, from: Image)
        let image = UIImage(data: decoded)
        cell.AnimalHistoryImages.image = image
        cell.DataHistoryLabel.text = date
        tableView.bounces = false
        
        return cell
        
    }
    
    @IBAction func ReadMoreButton(_ sender: UIButton) {
        
        let item = AnimalHistoryArr[sender.tag]
        let Link:String = item["Link"] as! String
        
        if let url = URL(string: Link) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
        
    }
    
    func AlertClearHistory(){
        
        let alertClearHistory = UIAlertController(title: nil, message: "Are you sure you want to clear the history?", preferredStyle: UIAlertController.Style.alert)
        
        alertClearHistory.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
            UserDefaults.standard.setValue(nil, forKey: "AnimalHistoryArr")
            AnimalHistoryArr = []
            self.tableView.reloadData()
        }))
        
        alertClearHistory.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertClearHistory, animated: true, completion: nil)
        
    }
}
