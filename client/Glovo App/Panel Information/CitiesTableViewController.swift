import UIKit

public protocol CityTableViewDelegate: class {
    func didSelect(city: City)
}

public final class CitiesTableViewController: UITableViewController {
    private let reuseIdentifier = "CitiesViewControllerIdentifier"
    
    private(set) var countries = [Country]()
    private var model = [String: [City]]()
    public weak var delegate: CityTableViewDelegate?
    
    public init() {
        super.init(style: .grouped)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: self.reuseIdentifier)
    }
    
    //MARK: Methods
    public func reloadData(with countries: [Country], and cities: [City]) {
        self.countries = countries
        self.model.removeAll()
        
        for city in cities {
            let countryCode = city.countryCode
            
            if var countryCities = self.model[countryCode] {
                countryCities.append(city)
                self.model[countryCode] = countryCities
            } else {
                self.model[countryCode] = [city]
            }
        }
        
        self.tableView.reloadData()
    }
    
    func locationIsInRange(countryName: String, cityName: String) -> City? {
        let preprocessing: (String) -> String = { input in
            return input.lowercased().replacingOccurrences(of: " ", with: "")
        }
        
        let countryPreprocessing = preprocessing(countryName)
        for country in self.countries {
            let countryNameStored = preprocessing(country.name)
            if countryNameStored == countryPreprocessing {
                guard let cities = self.model[country.code] else {
                    break
                }
                
                let cityPreprocessing = preprocessing(cityName)
                for city in cities {
                    let cityNameStored = preprocessing(city.name)
                    if cityNameStored == cityPreprocessing {
                        return city
                    }
                }
            }
            
        }
        
        return nil
    }
    
    //MARK: UITableViewDataSource
    
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let country = self.countries[section]
        var result = country.name
        if let flag = Country.flag(countryCode: country.code) {
            result = flag.appending(" \(result)")
        }
        
        return result
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let code = self.countries[section].code
        
        guard let rows = self.model[code] else {
            return 0
        }
        
        return rows.count
    }
    
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return self.countries.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: self.reuseIdentifier, for: indexPath)
        cell.backgroundColor = .clear
        let code = self.countries[indexPath.section].code
        
        guard let cities = self.model[code] else {
            return UITableViewCell()
        }
        
        cell.textLabel?.text = cities[indexPath.item].name
        cell.textLabel?.font = cell.textLabel?.font.withSize(self.tableView.rowHeight * 0.7)
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let code = self.countries[indexPath.section].code
        guard let cities = self.model[code] else {
            return
        }
        
        let city = cities[indexPath.item]
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.didSelect(city: city)
    }
}
