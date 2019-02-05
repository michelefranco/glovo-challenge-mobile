import UIKit
import MapKit
import CoreLocation
import FloatingPanel

final class LauncherViewController: UIViewController, CLLocationManagerDelegate, FloatingPanelControllerDelegate {
    private let containerView = UIView()
    private let mapViewController = MapViewController()
    private let citiesViewController = CitiesViewController()
    private let locationManager = CLLocationManager()
    private var fpc: FloatingPanelController!
    
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
        
        self.setModel()
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
        
        LocationServices.shared.location = location
        if self.citiesViewController.countriesCount > 0 {
            DispatchQueue.main.async {
                self.setInterface(for: location)
            }
        }
        
        let centerCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                      longitude: location.coordinate.longitude)
        let spanCoordinate = MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
        let region = MKCoordinateRegion(center: centerCoordinate, span: spanCoordinate)
        
        //Update the map with the current location
        self.mapViewController.update(with: region)
    }
    
    //MARK: private methods
    private func setModel() {
        let group = DispatchGroup()
        
        group.enter()
        group.enter()
        var countries = [Country]()
        var cities = [City]()
        Router.shared.countries { response in
            switch response {
            case .failure(let error):
                print("ERROR \(error.description)")
            case .success(let result):
                countries = result
            }
            
            group.leave()
        }
        
        Router.shared.cities { response in
            switch response {
            case .failure(let error):
                print("ERROR \(error.description)")
            case .success(let result):
                cities = result
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.citiesViewController.reloadData(with: countries, and: cities)
            self.setInterface(with: countries, and: cities)
            
            if let location = LocationServices.shared.location {
               self.setInterface(for: location)
            }
        }
    }
    
    private func setInterface(for location: CLLocation) {
        LocationServices.shared.getAdress(from: location) { address, error in
            guard let address = address,
                let countryName = address["Country"] as? String,
                let cityName = address["City"] as? String else {
                return
            }
            
            let city = self.citiesViewController.locationIsInRange(countryName: countryName, cityName: cityName)
            
            if let city = city {
                // call the map
            } else {
                // no in the area
            }
        }
    }
    
    private func setInterface(with countries: [Country], and cities: [City]) {
        self.citiesViewController.reloadData(with: countries, and: cities)
        fpc = FloatingPanelController()
        fpc.delegate = self
        fpc.surfaceView.backgroundColor = .clear
        fpc.surfaceView.cornerRadius = 9.0
        fpc.surfaceView.shadowHidden = false
        
        // Set a content view controller
        fpc.set(contentViewController: self.citiesViewController)
        fpc.track(scrollView: self.citiesViewController.scrollView)
        fpc.addPanel(toParent: self, animated: true)
    }
    
    // MARK: FloatingPanelControllerDelegate
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        switch newCollection.verticalSizeClass {
        case .compact:
            fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
            fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
            return PanelLandscapeLayout()
        default:
            fpc.surfaceView.borderWidth = 0.0
            fpc.surfaceView.borderColor = nil
            return nil
        }
    }
    
    // MARK: private methods for supporting the Location
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


public class PanelLandscapeLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .tip]
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        return nil
    }
}
