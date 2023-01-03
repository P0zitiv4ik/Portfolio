import UIKit
import SafariServices

class SelectedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellReuseIdentifier = "cell2"
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let tapBackButton = UITapGestureRecognizer(target: self, action: #selector(self.Back))
        BackButton.addGestureRecognizer(tapBackButton)
        
    }
    
    @objc
    func Back(){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 149;
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if SelectedAnimalsArr.count == 0{
            tableView.alpha = 0
            return 0
        }else{
            tableView.alpha = 1
            return SelectedAnimalsArr.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MyCustomCell2 = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! MyCustomCell2
        cell.selectionStyle = .none
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        let item = SelectedAnimalsArr[indexPath.row]
        let Image:Data = item["Image"] as! Data
        let Name:String = item["Name"] as! String
        
        cell.ReadMoreSelectedButton.tag = indexPath.row
        cell.HeartSelectedButton.tag = indexPath.row
        cell.ResultSelectedLabel.text = Name
        let decoded = try! PropertyListDecoder().decode(Data.self, from: Image)
        let image = UIImage(data: decoded)
        cell.AnimalSelectedImages.image = image
        tableView.bounces = false
        
        return cell
        
    }
    
    @IBAction func ReadMoreButton(_ sender: UIButton) {
        
        let item = SelectedAnimalsArr[sender.tag]
        let Link:String = item["Link"] as! String
        
        if let url = URL(string: Link) {
            let config = SFSafariViewController.Configuration()
            config.entersReaderIfAvailable = true
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
        
    }
    
    @IBAction func HeartButton(_ sender: UIButton) {
        
        let item = SelectedAnimalsArr[sender.tag]
        let Length:Int = item["length"] as! Int
        
        if Length == length{
            HeartAnimation.stop()
            HeartAnimationStatus = 0
        }
        
        SelectedAnimalsArr.remove(at: sender.tag)
        UserDefaults.standard.setValue(SelectedAnimalsArr, forKey: "SelectedAnimalsArr")
        tableView.reloadData()
        
    }
}
