import UIKit

class MySecondCustomCell: UITableViewCell {
    
    @IBOutlet weak var ConstWidthScrollView: NSLayoutConstraint!
    @IBOutlet weak var ConstWidthView: NSLayoutConstraint!
    @IBOutlet weak var AlignView: UIView!
    @IBOutlet weak var ImagesScrollView: UIScrollView!
    @IBOutlet weak var ScrollPageControl: UIPageControl!
    @IBOutlet weak var CoverView: UIView!
    @IBOutlet weak var HotelNameLabel: UILabel!
    @IBOutlet weak var HotelAddressLabel: UILabel!
    @IBOutlet weak var MinPriceButton: UIButton!
    @IBOutlet var StarRatingImageViewArr: [UIImageView]!
    @IBAction func ScrollPageControlAction(_ sender: UIPageControl) {
        
        PageChange(x: ScrollPageControl.currentPage)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        MinPriceButton.layer.cornerRadius = 10
        ImagesScrollView.bounces = false
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        ImagesScrollView.delegate = self

    }
    
    func PageChange(x: Int){
        
        let CurrentPage = x
        
        ImagesScrollView.setContentOffset(CGPoint(x: CGFloat(CurrentPage) * 388, y: 0), animated: true)
        
    }
    
}

extension MySecondCustomCell: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        ScrollPageControl.currentPage = Int(floorf((Float(ImagesScrollView.contentOffset.x)  + (Float(ImagesScrollView.frame.size.width) / 2)) / Float(ImagesScrollView.frame.size.width)))
        
    }
}
