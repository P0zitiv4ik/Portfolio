import FSCalendar
import UIKit

class CalendarViewController: UIViewController, FSCalendarDelegate{
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var BackView: UIView!
    @IBOutlet weak var ApplyButton: UIButton!
    
    private var firstDate: Date?
    private var lastDate: Date?
    var datesRange: [Date]?
    var toastMessage = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: nil)
        
        calendar.delegate = self
        self.calendar.firstWeekday = 2
        calendar.allowsMultipleSelection = true
        
        ApplyButton.layer.cornerRadius = 10
        
        if ((CheckInDate != "") && (CheckOutDate != "")){
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            firstDate = dateFormatter.date(from: CheckInDate)
            
            lastDate = dateFormatter.date(from: CheckOutDate)
            
            datesRange = datesRange(from: firstDate!, to: lastDate!)
            
            for date in datesRange!{
                calendar.select(date)
            }
            
        }
        
        let tapApplyButton = UITapGestureRecognizer(target: self, action: #selector(self.Apply))
        ApplyButton.addGestureRecognizer(tapApplyButton)
        
        let tapBackView = UITapGestureRecognizer(target: self, action: #selector(self.Back))
        BackView.addGestureRecognizer(tapBackView)
        
    }
    
    func updateUserInterface(){
        
         switch Network.reachability.status {
         case .unreachable:
             UserDefaults.standard.setValue(0, forKey: "NetworkStatus")
             noNetwork()
         case .wwan:
             print("wwan")
         case .wifi:
             if UserDefaults.standard.integer(forKey: "NetworkStatus") != 1{
                 noRestart()
             }
             
         }
        
     }
        
     @objc func statusManager(_ notification: Notification) {
         updateUserInterface()
     }
        
        func noNetwork(){
            
            let alertController = UIAlertController (title: "Connection error", message: "Unable to connect with the server. Check your internet connection, then restart the application", preferredStyle: .alert)
            
            let TryAgainAction = UIAlertAction(title: "Try again", style: .cancel) { (_) -> Void in
                
                self.updateUserInterface()
                
            }
            
            alertController.addAction(TryAgainAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
        
        func noRestart(){
            
            let alertController = UIAlertController (title: "Internet connection restored.", message: "Now restart the application for further operation.", preferredStyle: .alert)
            
            let OkAction = UIAlertAction(title: "Ok", style: .cancel) { (_) -> Void in
                
                self.updateUserInterface()

            }
            
            alertController.addAction(OkAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    
    
    @objc
    private func Back(){
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        let calendarDateStr = ConvertDateToString(Date: date, dateFormat: "yyyy-MM-dd")
        let todayDateStr = ConvertDateToString(Date: Date(), dateFormat: "yyyy-MM-dd")
        
        if calendarDateStr < todayDateStr{
            return UIColor.gray
        }else{
            return nil
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        
        let calendarDateStr = ConvertDateToString(Date: date, dateFormat: "yyyy-MM-dd")
        let todayDateStr = ConvertDateToString(Date: Date(), dateFormat: "yyyy-MM-dd")
        
        if calendarDateStr < todayDateStr{
            return false
        }else{
            return true
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        print("didSelect")
        
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            return
        }
        
        if firstDate != nil && lastDate == nil {
            
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                return
            }
            
            let range = datesRange(from: firstDate!, to: date)
            
            lastDate = range.last
            
            for date in range {
                calendar.select(date)
            }
            
            datesRange = range
            return
        }
        
        if firstDate != nil && lastDate != nil {
            
            for date in calendar.selectedDates {
                calendar.deselect(date)
            }
            
            lastDate = nil
            firstDate = nil
            
            datesRange = []
             
        }
        
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        print("didDeselect")
        
        for date in calendar.selectedDates {
            calendar.deselect(date)
        }
        
        lastDate = nil
        firstDate = nil
        
        datesRange = []
        
    }
    
    func datesRange(from: Date, to: Date) -> [Date] {
        
        if from > to { return [Date]() }
        
        var tempDate = from
        var tempDateArr = [tempDate]
        
        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            tempDateArr.append(tempDate)
        }
        
        return tempDateArr
    }
    
    @objc func Apply(){
        
        if ((datesRange != nil) && ((datesRange?.count ?? 0) >= 2)){
            
            CheckInDate = ConvertDateToString(Date: (datesRange?.first)!, dateFormat: "yyyy-MM-dd")
            CheckOutDate = ConvertDateToString(Date: (datesRange?.last)!, dateFormat: "yyyy-MM-dd")
            
            let FirstDate = ConvertDateToString(Date: (datesRange?.first)!, dateFormat: "MMM. d")
            let LastDate = ConvertDateToString(Date: (datesRange?.last)!, dateFormat: "MMM. d")
            SelectedDates = FirstDate + " - " + LastDate
            
            dismiss(animated: true, completion: nil)
            
        }else{
            showToast()
        }
        
    }
    
    func ConvertDateToString(Date:Date, dateFormat: String)->String{
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        let DateStr = dateFormatter.string(from: Date)
        return DateStr
        
    }
    
}

extension CalendarViewController: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return .systemGreen
    }
}

extension  CalendarViewController{
    
    func showToast() {
        
        toastMessage = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 60, y: self.view.frame.size.height-200, width: 120, height: 35))
        toastMessage.backgroundColor = UIColor.black.withAlphaComponent(1)
        toastMessage.textColor = UIColor.white
        toastMessage.font = .systemFont(ofSize: 14)
        toastMessage.textAlignment = .center;
        toastMessage.text = "Select dates"
        toastMessage.alpha = 1.0
        toastMessage.layer.cornerRadius = 10;
        toastMessage.clipsToBounds  =  true
        self.view.addSubview(toastMessage)
        UIView.animate(withDuration: 4.5, delay: 1.5, options: .curveEaseOut, animations: { [self] in
            toastMessage.alpha = 0.0
        }, completion: { [self](isCompleted) in
            toastMessage.removeFromSuperview()
        })
    }
    
}
