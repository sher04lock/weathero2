import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var coords: Coords!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    func updateView() {
        let cityCoords = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: cityCoords, span: span)
 
        let annotation = MKPointAnnotation()
        annotation.subtitle = "When you are here, weather should be like that"
        annotation.coordinate = cityCoords
        
        mapView.setCenter(cityCoords, animated: true)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
    
}
