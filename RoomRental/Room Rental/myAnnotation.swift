import MapKit

class myAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let loationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title:String, loationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        
        self.title = title
        self.loationName = loationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
        
    }
    
    var markerTintColor: UIColor{
        
        return .systemGreen
    }
    
    var imageName: String?
    {
        return "Z"
    }
    
}
