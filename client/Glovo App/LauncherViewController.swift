import UIKit
import MapKit
import CoreLocation
import FloatingPanel

final class LauncherViewController: UIViewController, CLLocationManagerDelegate, FloatingPanelControllerDelegate, CityTableViewDelegate {
    private let containerView = UIView()
    private let mapViewController = MapViewController()
    private let citiesViewController = CitiesViewController()
    private let locationManager = CLLocationManager()
    private let logoButton = UIButton()
    private var fpc: FloatingPanelController!
    private var layoutIsSet = false
        private var logoActivatedRightAnchor: NSLayoutConstraint!
    private var logoDeactivatedRightAnchor: NSLayoutConstraint!
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
        self.citiesViewController.citiesDelegate = self
        
        self.setButtonLogo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !self.layoutIsSet else {
            return
        }
        
        self.layoutIsSet = true
        self.setLayoutForLogo()
        self.view.layoutIfNeeded()
    }
    
    //MARK: CityTableViewDelegate Methods
    func didSelect(city: City) {
        self.mapViewController.setVisibleMapArea(with: city)
        self.fpc.move(to: .hidden, animated: true) {
            self.fpc.removePanelFromParent(animated: true) {
                self.showLogoButton()
            }
        }
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
    private func setLayoutForLogo() {
        
        let proportionalTopAnchor = self.view.bounds.height * 0.07
        NSLayoutConstraint.activate([self.view.topAnchor.constraint(equalTo: self.logoButton.topAnchor, constant: -proportionalTopAnchor)])
        self.logoButton.layer.borderColor = UIColor(hex: 0xFEDA54).cgColor
        self.logoButton.layer.borderWidth = 3.0
        self.logoButton.layer.cornerRadius = self.logoButton.bounds.midX
        self.logoButton.layer.masksToBounds = true
    }
    
    @objc func logoButtonTouched(_ button: UIButton) {
        if self.fpc.position == .hidden {
            self.citiesViewController.scrollToTop()
            self.fpc.addPanel(toParent: self)
            self.hideLogoButton() {
                self.fpc.move(to: .half, animated: true)
            }
        }
    }
    
    private func setButtonLogo() {
        guard let image = UIImage(named: "logo") else { return }
        self.logoButton.setBackgroundImage(image, for: .normal)
        
        self.logoButton.addTarget(self, action: #selector(self.logoButtonTouched(_:)), for: .touchUpInside)
        self.view.addSubview(self.logoButton)
        self.logoButton.translatesAutoresizingMaskIntoConstraints = false
        self.logoActivatedRightAnchor = self.logoButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -8.0)
        self.logoDeactivatedRightAnchor = self.logoButton.leftAnchor.constraint(equalTo: self.view.rightAnchor, constant: 8.0)
        
        NSLayoutConstraint.activate( [
            self.logoDeactivatedRightAnchor,
            self.logoButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.18),
            self.logoButton.heightAnchor.constraint(equalTo: self.logoButton.widthAnchor)
            ])
    }
    
    private func showLogoButton(completion: (() -> ())? = nil) {
        self.logoDeactivatedRightAnchor.isActive = false
        self.logoActivatedRightAnchor.isActive = true
        self.view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            completion?()
        }
    }
    
    private func hideLogoButton(completion: (() -> ())? = nil) {
        self.logoActivatedRightAnchor.isActive = false
        self.logoDeactivatedRightAnchor.isActive = true

        self.view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            completion?()
        }
    }
    
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
            
            if let city = city, self.mapViewController.contains(location, in: city) {
                self.mapViewController.setVisibleMapArea(with: city)
                self.showLogoButton()
            } else {
                self.fpc.move(to: .half, animated: true)
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
    func floatingPanelDidEndDragging(_ vc: FloatingPanelController, withVelocity velocity: CGPoint, targetPosition: FloatingPanelPosition) {
        if targetPosition == .tip {
            vc.move(to: .hidden, animated: true) {
                vc.removePanelFromParent(animated: true) {
                    self.showLogoButton()
                }
            }
        }
    }
    
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
            fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
            fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
            return PanelCompactLayout()
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

public class PanelCompactLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .hidden
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return 216.0 // A bottom inset from the safe area
        default: return 0 // Or `case .hidden: return nil`
        }
    }
}
