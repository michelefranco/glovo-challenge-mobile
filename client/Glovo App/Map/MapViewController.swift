import UIKit
import MapKit

final class MapViewController: UIViewController {
    private let mapView = MKMapView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.mapView)
        self.mapView.fillConstraintsToSuperview()
    }
    
}
