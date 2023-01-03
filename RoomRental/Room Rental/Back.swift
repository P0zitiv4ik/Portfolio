import UIKit

class Back: UINavigationItem {

    @IBAction func BackAction(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name("ScrollTopTableView"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("Dismiss"), object: nil)
    
    }
}
