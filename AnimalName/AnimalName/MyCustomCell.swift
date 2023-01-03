import UIKit

class MyCustomCell: UITableViewCell {
    
    @IBOutlet weak var AnimalHistoryImages: UIImageView!
    @IBOutlet weak var ResultHistoryLabel: UILabel!
    @IBOutlet weak var ReadMoreHistoryButton: UIButton!
    @IBOutlet weak var DataHistoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ResultHistoryLabel.numberOfLines = 3
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}
