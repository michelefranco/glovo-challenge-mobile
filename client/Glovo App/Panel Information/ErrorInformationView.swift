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
    
    //MARK: UIVIEW LIFE CYCLE
    
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
    
    
    // MARK: PRIVATE METHODS
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
