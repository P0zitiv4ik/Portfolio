import UIKit
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var BackBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var ApplyButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var MyLocationView: UIView!
    
    var resultearchController: UISearchController? = nil
    let locationManager = CLLocationManager()
    var MyLocationArr:[CLLocationDegrees] = []
    var CurrentLocation = ""
    var CurrentCoordinate = CLLocationCoordinate2D()
    var toastMessage = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: nil)
        
        BackBarButtonItem.customView?.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        BackBarButtonItem.customView?.tintColor = .black
        
        NotificationCenter.default.addObserver(self, selector: #selector(Dismiss), name: Notification.Name("Dismiss"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MakeTitleViewWhite), name: Notification.Name("MakeTitleViewWhite"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MakeTitleViewTransparent), name: Notification.Name("MakeTitleViewTransparent"), object: nil)
        
        MyLocationView.layer.cornerRadius = 30
        MyLocationView.alpha = 0.75
        ApplyButton.layer.cornerRadius = 10
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.global().async { [self] in
            if CLLocationManager.locationServicesEnabled() {
                
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
                
            }
        }
        
        mapView.delegate = self
        mapView.register( MyAnnotationView.self , forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "LocationSearch") as? LocationSearchViewController
        resultearchController = UISearchController(searchResultsController: locationSearchTable)
        resultearchController?.searchResultsUpdater = locationSearchTable
        locationSearchTable?.mapView = mapView
        locationSearchTable?.hundleMapSearchDelegate = self
        
        let searchBar = resultearchController?.searchBar
        searchBar?.sizeToFit()
        searchBar?.showsCancelButton = false
        searchBar?.placeholder = "Location"
        navigationItem.titleView = resultearchController?.searchBar
        
        resultearchController?.hidesNavigationBarDuringPresentation = false
        resultearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        let tapMyLocationView = UITapGestureRecognizer(target: self, action: #selector(self.MyLocation))
        MyLocationView.addGestureRecognizer(tapMyLocationView)
        
        
        if ((LatitudeСoordinate != 0.0) && (LongitudeCoordinate != 0.0)){
            CurrentLocation = SelectedLocation
            CurrentCoordinate.latitude = CLLocationDegrees(LatitudeСoordinate)
            CurrentCoordinate.longitude = CLLocationDegrees(LongitudeCoordinate)
            LocationUpdate()
        }
        
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
    func Dismiss(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func MakeTitleViewWhite(){
        navigationItem.titleView?.backgroundColor = .white
    }
    
    @objc
    func MakeTitleViewTransparent(){
        navigationItem.titleView?.backgroundColor = .clear
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let localValue: CLLocationCoordinate2D = manager.location?.coordinate else { return  }
        MyLocationArr = [localValue.latitude,localValue.longitude]
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        MyLocationArr = []
    }
    
    @objc
    private func MyLocation(){
        
        guard MyLocationArr != [] else {Settings(); return}
        let latitude = MyLocationArr[0]
        let longitude = MyLocationArr[1]
        let placemark = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.0035, longitudeDelta: 0.0035)
        let region = MKCoordinateRegion(center: placemark, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func ApplyAction(_ sender: Any) {
        
        if !CurrentLocation.isEmpty{
            
            SelectedLocation = CurrentLocation
            LatitudeСoordinate = Float(CurrentCoordinate.latitude)
            LongitudeCoordinate = Float(CurrentCoordinate.longitude)
            
            dismiss(animated: true, completion: nil)
            
        }else{
            showToast()
        }
        
    }
    
    func Settings(){
        
        let alertController = UIAlertController (title: "Attention!", message: "In order to see your current location, you must allow the app to use your geo-position ", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "No, thank you", style: .default, handler: nil)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "App-prefs:Privacy&path=LOCATION/\(bundleId)")
            {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
        
    }
}

extension MapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
        
        switch annotation.title{
        case "My Location":
            annotationView.markerTintColor = UIColor.systemRed
        default:
            annotationView.markerTintColor = UIColor.green
        }
        
        return annotationView
        
    }
    
    func LocationUpdate(){
        
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = CurrentCoordinate
        annotation.title = CurrentLocation
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
        
        mapView.addSubview(annotationView)
        mapView.addAnnotation(annotation)
        
        var span = MKCoordinateSpan()
        if ExactSelectedLocation != ""{
            span = MKCoordinateSpan(latitudeDelta: 0.0035, longitudeDelta: 0.0035)
        }else{
            span = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
        }
        
        let region = MKCoordinateRegion(center: CurrentCoordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
}

protocol HandleMapSearch{
    func dropPinZoomIN(placemark: MKPlacemark)
}

extension MapViewController : HandleMapSearch{
    func dropPinZoomIN(placemark: MKPlacemark) {
        
        CurrentCoordinate = placemark.coordinate
        
        CurrentLocation = placemark.name ?? "error"
        guard CurrentLocation != "error" else { return }
        
        let title = placemark.title ?? "error"
        guard title != "error" else { return }
        let titleArr = title.components(separatedBy: ",")
        
        if CurrentLocation != titleArr.first{
            if titleArr.count >= 3{
                ExactSelectedLocation = CurrentLocation + "," + titleArr[titleArr.count - 3]
            }else{
                ExactSelectedLocation = ""
            }
        }else{
            ExactSelectedLocation = ""
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
        mapView.addSubview(annotationView)
        mapView.addAnnotation(annotation)
        
        var span = MKCoordinateSpan()
        if ExactSelectedLocation != ""{
            span = MKCoordinateSpan(latitudeDelta: 0.0035, longitudeDelta: 0.0035)
        }else{
            span = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
        }
        
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
    }
}

extension  MapViewController{
    
    func showToast() {
        
        toastMessage = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 95, y: self.view.frame.size.height-200, width: 190, height: 35))
        toastMessage.backgroundColor = UIColor.black.withAlphaComponent(1)
        toastMessage.textColor = UIColor.white
        toastMessage.font = .systemFont(ofSize: 14)
        toastMessage.textAlignment = .center;
        toastMessage.text = "Choose a hotel location"
        toastMessage.alpha = 1.0
        toastMessage.layer.cornerRadius = 10;
        toastMessage.clipsToBounds  =  true
        self.view.addSubview(toastMessage)
        UIView.animate(withDuration: 5.0, delay: 2.0, options: .curveEaseOut, animations: { [self] in
            toastMessage.alpha = 0.0
        }, completion: { [self](isCompleted) in
            toastMessage.removeFromSuperview()
        })
    }
    
}
