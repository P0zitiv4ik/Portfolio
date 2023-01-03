import UIKit

class InfoViewController: UIViewController {
    
    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var AboutTheAppLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AboutTheAppLabel.numberOfLines = 0
        
        let tapBackButton = UITapGestureRecognizer(target: self, action: #selector(self.Back))
        BackButton.addGestureRecognizer(tapBackButton)
        
    }
    
    @objc
    private func Back(){
        
        dismiss(animated: true, completion: nil)
        
    }
}
