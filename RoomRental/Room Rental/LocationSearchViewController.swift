import UIKit
import MapKit

class LocationSearchViewController: UITableViewController {
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView? = nil
    var hundleMapSearchDelegate: HandleMapSearch? = nil
    var ControllerStatus = ""
    var SearchText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ScrollTopTableView), name: Notification.Name("ScrollTopTableView"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)

        ControllerStatus = "viewDidAppear"
        DefineTitleViewColor()
  
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        
        ControllerStatus = "viewWillDisappear"
        DefineTitleViewColor()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var yIndent:CGFloat = 0.0
        
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            yIndent = window!.safeAreaInsets.top
        }else{
            let window = UIApplication.shared.keyWindow
            yIndent = (window?.safeAreaInsets.top)!
        }
        
        self.view.frame = CGRect(x: 0, y: yIndent, width: self.view.bounds.width, height: self.view.frame.height)
        self.view.layer.masksToBounds = true

    }
    
    @objc
    func ScrollTopTableView(){
        
        let NumberRows = tableView.numberOfRows(inSection: 0)
        
        if NumberRows > 0{

            let IndexPath:IndexPath = [0,0]
            tableView.scrollToRow(at: IndexPath, at: .top, animated: false)
        }
    }
    
    func purceAdress(selectedItem: MKPlacemark) -> String{
        
        var adressLine = ""
        
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " ": ""
        
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", ": ""
        
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? ", ": ""
        
        if selectedItem.locality == selectedItem.administrativeArea {
            
            adressLine = String(
                format: "%@%@%@%@%@",
                selectedItem.thoroughfare ?? "",
                firstSpace,
                selectedItem.subThoroughfare ?? "",
                comma,
                selectedItem.locality ?? ""
            )
            
        }else{
            
            adressLine = String(
                format: "%@%@%@%@%@%@%@",
                selectedItem.thoroughfare ?? "",
                firstSpace,
                selectedItem.subThoroughfare ?? "",
                comma,
                selectedItem.locality ?? "",
                secondSpace,
                selectedItem.administrativeArea ?? ""
            )
        }
        
        return adressLine
        
    }
    
    func DefineTitleViewColor(){
        
        if ((SearchText != "") && (ControllerStatus == "viewDidAppear")){
            NotificationCenter.default.post(name: Notification.Name("MakeTitleViewWhite"), object: nil)
        }
        
        if ((SearchText == "") || (ControllerStatus == "viewWillDisappear")){
            NotificationCenter.default.post(name: Notification.Name("MakeTitleViewTransparent"), object: nil)
        }
        
    }
}


extension LocationSearchViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController){
    
        SearchText = searchController.searchBar.text ?? "error"
        guard SearchText != "error" else { return }
        
        DefineTitleViewColor()
        
        guard let mapView = mapView, let searchText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()

        request.naturalLanguageQuery = searchText
        request.region = mapView.region

        let search = MKLocalSearch(request: request)

        search.start { (response, error) in
            guard let response = response else { return }

            self.matchingItems = response.mapItems
            self.tableView.reloadData()

        }

    }

}

extension LocationSearchViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        tableView.contentSize.height = CGFloat((matchingItems.count * 44) + 40)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let selectedItem = matchingItems[indexPath.row].placemark
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 29, bottom: 0, right: 18)
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = purceAdress(selectedItem: selectedItem)
        
        tableView.bounces = false
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        ScrollTopTableView()
        
        let selectedItem = matchingItems[indexPath.row].placemark
        hundleMapSearchDelegate?.dropPinZoomIN(placemark: selectedItem)
        
        dismiss(animated: true, completion: nil)
        
    }
    
}
