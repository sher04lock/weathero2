import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var coordinate: CLLocationCoordinate2D!

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    func updateView() {
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
 
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        mapView.setCenter(coordinate, animated: true)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(annotation)
    }
}
