import UIKit

class MyCustomCell2: UITableViewCell {
    
    @IBOutlet weak var AnimalSelectedImages: UIImageView!
    @IBOutlet weak var ResultSelectedLabel: UILabel!
    @IBOutlet weak var ReadMoreSelectedButton: UIButton!
    @IBOutlet weak var HeartSelectedImages: UIImageView!
    @IBOutlet weak var HeartSelectedButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ResultSelectedLabel.numberOfLines = 3
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
