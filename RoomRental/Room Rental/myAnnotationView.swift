import MapKit

class MyAnnotationView: MKMarkerAnnotationView{
    override var annotation: MKAnnotation?{
        willSet{
            guard let _myAnnotation = newValue as? myAnnotation else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

            markerTintColor = _myAnnotation.markerTintColor

            if let imageName = _myAnnotation.imageName{
                glyphImage = UIImage(named: imageName)
            }else{
                glyphImage = nil
            }
        }
    }
}
