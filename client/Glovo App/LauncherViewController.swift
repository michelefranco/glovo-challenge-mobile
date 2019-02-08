import UIKit
import MapKit
import CoreLocation
import FloatingPanel

final class LauncherViewController: UIViewController, CLLocationManagerDelegate, FloatingPanelControllerDelegate, CityTableViewDelegate, OnBoardingDelegate {
    private let containerView = UIView()
    private var onBoardingContainerView: UIView?
    private let mapViewController = MapViewController()
    private let citiesViewController = CitiesViewController()
    private let locationManager = CLLocationManager()
    private let logoButton = UIButton()
    private var fpc: FloatingPanelController!
    private var layoutIsSet = false
    private var logoActivatedRightAnchor: NSLayoutConstraint!
    private var logoDeactivatedRightAnchor: NSLayoutConstraint!
    private var panelInfoActivatedTopAnchor: NSLayoutConstraint!
    private var panelInfoDeactivatedTopAnchor: NSLayoutConstraint!
    private var errorInfoActivatedTopAnchor: NSLayoutConstraint!
    private var errorInfoDeactivatedTopAnchor: NSLayoutConstraint!
    private let panelInfoView = PanelInfoView()
    private let errorView = PanelInfoErrorView()
    private var onBoardingViewController: OnBoardingViewController?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: VIEW CONTROLLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self

        self.view.addSubview(self.containerView)
        self.containerView.fillConstraintsToSuperview()
        self.addChild(self.mapViewController, in: self.containerView)
        
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.citiesViewController.citiesDelegate = self
       
        self.view.addSubview(self.panelInfoView)
        self.panelInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        self.panelInfoDeactivatedTopAnchor = self.panelInfoView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        self.panelInfoActivatedTopAnchor = self.panelInfoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            self.panelInfoView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.panelInfoView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.2),
            self.panelInfoView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.panelInfoDeactivatedTopAnchor
            ])
        
        self.view.addSubview(self.errorView)
        self.errorView.translatesAutoresizingMaskIntoConstraints = false
        
        self.errorInfoDeactivatedTopAnchor = self.errorView.topAnchor.constraint(equalTo: self.view.bottomAnchor)
        self.errorInfoActivatedTopAnchor = self.errorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            self.errorView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.errorView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.2),
            self.errorView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.errorInfoDeactivatedTopAnchor
            ])
        
        self.setButtonLogo()
        
        if !Configurator.shared.onBoardingIsTerminated {
            let containerOnBoarding = UIView()
            let onBoardingViewController = OnBoardingViewController()
            onBoardingViewController.delegate = self
            self.view.addSubview(containerOnBoarding)
            containerOnBoarding.fillConstraintsToSuperview()
            self.addChild(onBoardingViewController, in: containerOnBoarding)
            self.onBoardingContainerView = containerOnBoarding
            self.onBoardingViewController = onBoardingViewController
        }
        
        self.setModel()
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
                Router.shared.city(cityCode: city.code) { response in
                    switch response {
                    case .failure(let error):
                        print(error.description)
                    case .success(let result):
                        self.showPanelInfoView(with: result)
                        
                    }
                }
            }
        }
    }
    
    //MARK: ONBOARDING DELEGATE
    func getStartedPressed() {
        Configurator.shared.onBoardingIsTerminated = true
        self.enableLocationServices()

    }
    
    //MARK: CORE LOCATION MANAGER METHODS
    
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
            self.hideLogoButton()
            self.hidePanelInfoView() {
                self.fpc.move(to: .half, animated: true)
            }
        } else {
            self.fpc.move(to: .half, animated: true)
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
    
    private func showPanelInfoView(with city: City, completion: (() -> ())? = nil) {
        self.panelInfoView.reload(with: city)
        self.panelInfoDeactivatedTopAnchor.isActive = false
        self.panelInfoActivatedTopAnchor.isActive = true
        self.view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            completion?()
        }
    }
    
    private func showPanelErrorView() {
        self.errorInfoDeactivatedTopAnchor.isActive = false
        self.errorInfoActivatedTopAnchor.isActive = true
        self.view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hidePanelInfoView(completion: (() -> ())? = nil) {
        self.panelInfoActivatedTopAnchor.isActive = false
        self.panelInfoDeactivatedTopAnchor.isActive = true
        
        self.view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            completion?()
        }
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
        
        var countriesSuccess = true
        Router.shared.countries { response in
            switch response {
            case .failure(let error):
                print("ERROR \(error.description)")
                countriesSuccess = false
            case .success(let result):
                countries = result
            }
            
            group.leave()
        }
        
        var citiesSuccess = true
        Router.shared.cities { response in
            switch response {
            case .failure(let error):
                citiesSuccess = false
                print("ERROR \(error.description)")
            case .success(let result):
                cities = result
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            if countriesSuccess && citiesSuccess {
                self.citiesViewController.reloadData(with: countries, and: cities)
                self.setInterface(with: countries, and: cities)
                self.showLogoButton()

                if let location = LocationServices.shared.location {
                    self.setInterface(for: location)
                }
            } else {
                self.showPanelErrorView()
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
                Router.shared.city(cityCode: city.code) { response in
                    switch response {
                    case .failure(let error):
                        print(error.description)
                    case .success(let result):
                        self.showPanelInfoView(with: result)
                    }
                }
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
        self.fpc.surfaceView.borderWidth = 1.0 / traitCollection.displayScale
        self.fpc.surfaceView.borderColor = UIColor.black.withAlphaComponent(0.2)
        return PanelCompactLayout()
    }
    
    // MARK: private methods for supporting the Location
    private func enableLocationServices() {
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
    
    private func eraseOnBoarding() {
        UIView.animate(withDuration: 0.5, animations: {
            self.onBoardingContainerView?.alpha = 0
        }) { _ in
            self.onBoardingViewController?.removeFromParent()
            self.onBoardingContainerView?.removeFromSuperview()
            self.onBoardingViewController = nil
            self.onBoardingContainerView = nil
        }
     }
    
    private func disableMyLocationBasedFeatures() {
        self.eraseOnBoarding()
    }
    
    private func enableMyWhenInUseFeatures() {
        self.locationManager.startUpdatingLocation()
        self.eraseOnBoarding()
    }
    
    private func enableMyAlwaysFeatures() {
        self.locationManager.startUpdatingLocation()
        self.eraseOnBoarding()
    }
    
    // Escalate only when the authorization is set to when-in-use
    private func escalateLocationServiceAuthorization() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
}
