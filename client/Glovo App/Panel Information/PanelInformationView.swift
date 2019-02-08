import UIKit

public final class PanelInfoErrorView: UIView {
    private let errorLabel = UILabel()
    private let backgroundLayer = CAShapeLayer()
    private var isSet = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !self.isSet else { return }
        self.isSet = true
        
        
        let cornerRadius: CGFloat = 9
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 3.0
        
        self.errorLabel.font = self.errorLabel.font.withSize(self.bounds.height * 0.2)
        self.layoutIfNeeded()
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.isOpaque = false
        self.layer.insertSublayer(backgroundLayer, at: 0)
        self.addErrorLabel()
    }
    
    private func addErrorLabel() {
        self.addSubview(self.errorLabel)
        self.errorLabel.text = "❌ OPS! SERVICE TEMPORARILY UNAVAILABLE"
        self.errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.errorLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            self.errorLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.errorLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            ])
        
        self.errorLabel.textColor = .black
        self.errorLabel.adjustsFontSizeToFitWidth = true
        self.errorLabel.minimumScaleFactor = 0.8
        self.errorLabel.numberOfLines = 2
        self.errorLabel.textAlignment = .center
    }
}

public final class PanelInfoView: UIView {
    private let nameLabel = UILabel()
    private let currencyLabel = UILabel()
    private let enabledLabel = UILabel()
    private let busyLabel = UILabel()
    private let languageCodeLabel = UILabel()
    private let timeZoneLabel = UILabel()
    private let backgroundLayer = CAShapeLayer()
    private var isSet = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !self.isSet else { return }
        self.isSet = true
        
        
        let cornerRadius: CGFloat = 9
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: [.topLeft, .topRight],
                                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = UIColor.white.cgColor
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 3.0
        
        self.nameLabel.font = self.nameLabel.font.withSize(self.bounds.height * 0.22)
        self.layoutIfNeeded()
        self.currencyLabel.font = UIFont.boldSystemFont(ofSize: self.nameLabel.font.pointSize * 0.45)
        self.busyLabel.font = UIFont.boldSystemFont(ofSize: self.nameLabel.font.pointSize * 0.4)
        self.enabledLabel.font = UIFont.boldSystemFont(ofSize: self.nameLabel.font.pointSize * 0.4)
        self.languageCodeLabel.font = UIFont.boldSystemFont(ofSize: self.nameLabel.font.pointSize * 0.45)
        self.currencyLabel.font = UIFont.boldSystemFont(ofSize: self.nameLabel.font.pointSize * 0.45)
        self.timeZoneLabel.font = UIFont.boldSystemFont(ofSize: self.nameLabel.font.pointSize * 0.45)
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.isOpaque = false
        self.layer.insertSublayer(backgroundLayer, at: 0)
        self.addNameLabel()
        self.addTimeZoneLabel()
        self.addCurrencyLabel()
        self.addLanguageCode()
        self.addBusyLabel()
        self.addEnabledLabel()
    }
    
    func reload(with city: City) {
        var cityName = city.name
        if let flag = Country.flag(countryCode: city.countryCode) {
            cityName.append(" \(flag)")
        }
        self.nameLabel.text = cityName
        
        if let currency = city.currency {
            self.currencyLabel.text = "Currency: \(currency)"
        }
        
        if let languageCode = city.languageCode {
            self.languageCodeLabel.text = "Language Code: \(languageCode.uppercased())"
        }
        
        if let enabled = city.enabled {
            self.enabledLabel.text = enabled ? "ENABLED" : "NOT ENABLED"
            self.enabledLabel.textColor = enabled ? UIColor(hex: 0x139779) : .red
        }
        
        if let busy = city.busy {
            self.busyLabel.text = busy ? " BUSY" : "NOT BUSY"
            self.busyLabel.textColor = busy ? .red : UIColor(hex: 0x139779)
        }
        
        self.timeZoneLabel.text = city.timeZone
        self.layoutIfNeeded()
    }
    
    private func addNameLabel() {
        self.addSubview(self.nameLabel)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            self.nameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            self.nameLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            ])
        
        self.nameLabel.textColor = .black
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.nameLabel.minimumScaleFactor = 0.8
        self.nameLabel.numberOfLines = 1
    }
    
    private func addCurrencyLabel() {
        self.addSubview(self.currencyLabel)
        self.currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.currencyLabel.topAnchor.constraint(equalTo: self.timeZoneLabel.bottomAnchor, constant: 4),
            self.currencyLabel.leadingAnchor.constraint(equalTo: self.nameLabel.leadingAnchor)
            ])
        
        self.currencyLabel.textColor = .lightGray
    }
    
    private func addLanguageCode() {
        self.addSubview(self.languageCodeLabel)
        self.languageCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.languageCodeLabel.topAnchor.constraint(equalTo: self.currencyLabel.bottomAnchor, constant: 4),
            self.languageCodeLabel.leadingAnchor.constraint(equalTo: self.nameLabel.leadingAnchor)
            ])
        
        self.languageCodeLabel.textColor = .lightGray
    }
    
    private func addTimeZoneLabel() {
        self.addSubview(self.timeZoneLabel)
        self.timeZoneLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.timeZoneLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 4),
            self.timeZoneLabel.leadingAnchor.constraint(equalTo: self.nameLabel.leadingAnchor)
            ])
        
        self.timeZoneLabel.textColor = .lightGray
    }
    
    private func addBusyLabel() {
        self.addSubview(self.busyLabel)
        self.busyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.busyLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            self.busyLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
            ])
    }
    
    private func addEnabledLabel() {
        self.addSubview(self.enabledLabel)
        self.enabledLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.enabledLabel.bottomAnchor.constraint(equalTo: self.busyLabel.topAnchor),
            self.enabledLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
            ])
    }
}
