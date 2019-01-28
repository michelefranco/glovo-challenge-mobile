import UIKit
import MapKit
import CoreLocation

final class LauncherViewController: UIViewController, CLLocationManagerDelegate {
    private let containerView = UIView()
    private let mapViewController = MapViewController()
    private let locationManager = CLLocationManager()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UIViewController's life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.containerView)
        self.containerView.fillConstraintsToSuperview()
        self.addChild(self.mapViewController, in: self.containerView)
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.enableLocationServices()
    }
    
    //MARK: CLLocationManagerDelegate methods
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            // Disable your app's location features
            self.disableMyLocationBasedFeatures()
        case .authorizedWhenInUse:
            // Enable only your app's when-in-use features.
            self.enableMyWhenInUseFeatures()
        case .authorizedAlways:
            // Enable any of your app's location services.
            enableMyAlwaysFeatures()
            break
            
        case .notDetermined:
            print("not Determined Location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        
        guard let location = locations.first
            else {
                print("LauncherViewController - There is no location in didUpdateLocations")
                return
        }
        
        let centerCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                      longitude: location.coordinate.longitude)
        let spanCoordinate = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: centerCoordinate, span: spanCoordinate)
        
        //Update the map with the current location
        self.mapViewController.update(with: region)
    }
    
    
    // MARK: private function for supporting the Location
    private func enableLocationServices() {
        self.locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            self.locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            self.disableMyLocationBasedFeatures()
            
        case .authorizedWhenInUse:
            // Enable basic location features
            self.escalateLocationServiceAuthorization()
            self.enableMyWhenInUseFeatures()
        case .authorizedAlways:
            // Enable any of your app's location features
            self.enableMyAlwaysFeatures()
            break
        }
    }
    
    private func disableMyLocationBasedFeatures() {}
    
    private func enableMyWhenInUseFeatures() {
        self.locationManager.startUpdatingLocation()
    }
    
    private func enableMyAlwaysFeatures() {
        self.locationManager.startUpdatingLocation()
    }
    
    // Escalate only when the authorization is set to when-in-use
    private func escalateLocationServiceAuthorization() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}
