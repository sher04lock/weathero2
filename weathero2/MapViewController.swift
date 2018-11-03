import UIKit
import MapKit

class MapViewController: UIViewController {
    
    var cityName: String = ""
    var longitude: String = ""
    var latitude: String = ""
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    func updateView() {
        let aghCoord = CLLocationCoordinate2D(latitude:
            50.064528, longitude: 19.923556)
        mapView.setCenter(aghCoord, animated: true)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: aghCoord, span: span)
        mapView.setRegion(region, animated: true)
        let annotation = MKPointAnnotation()
        annotation.subtitle = "When you are here, weather should be like that"
        //annotation.title = self.cityName
        annotation.coordinate = aghCoord
        mapView.addAnnotation(annotation)
    }
    
}
