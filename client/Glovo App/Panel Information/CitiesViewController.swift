import UIKit
import MapKit

public final class CitiesViewController: UIViewController {
    private let visualEffectView: UIVisualEffectView = {
        let fx = UIBlurEffect(style: .extraLight)
       return UIVisualEffectView(effect: fx)
    } ()
    
    private let containerView = UIView()
    private let citiesViewController = CitiesTableViewController()
    public weak var citiesDelegate: CityTableViewDelegate?
    
    public var countriesCount: Int {
        return self.citiesViewController.countries.count
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var scrollView: UIScrollView {
        return self.citiesViewController.tableView
    }
    
    //MARK: View Controller Life Cycle
   public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.view.addSubview(self.visualEffectView)
        self.visualEffectView.fillConstraintsToSuperview()
        self.visualEffectView.contentView.addSubview(self.containerView)
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate( [
            self.containerView.widthAnchor.constraint(equalTo: self.visualEffectView.widthAnchor),
            self.containerView.centerXAnchor.constraint(equalTo: self.visualEffectView.centerXAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.visualEffectView.bottomAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.visualEffectView.topAnchor, constant: 8.0)
            ])
        
        self.addChild(citiesViewController, in: self.containerView)
        self.citiesViewController.delegate = self.citiesDelegate
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.visualEffectView.layer.cornerRadius = 9.0
        self.visualEffectView.clipsToBounds = true
    }

    //MARK: Methods
    func locationIsInRange(countryName: String, cityName: String) -> City? {
       return self.citiesViewController.locationIsInRange(countryName: countryName, cityName: cityName)
    }
    
    func reloadData(with countries: [Country], and cities: [City]) {
        self.citiesViewController.reloadData(with: countries, and: cities)
    }
    
    func scrollToTop() {
        self.citiesViewController.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
}
