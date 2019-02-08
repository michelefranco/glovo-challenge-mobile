import UIKit

public struct OnBoardingModel {
    let images: [UIImage]
    let topText: String
    let bottomText: String
}

public final class OnBoardingCell: UICollectionViewCell {
    private var stackView = UIStackView()
    private let topLabel = UILabel()
    private let bottomLabel = UILabel()
    private var isSet = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    // MARK: UICOLLECTIONVIEWCELL LIFE CYCLE
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        self.topLabel.text = nil
        self.bottomLabel.text = nil
        self.stackView.arrangedSubviews.forEach {
            self.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        guard !self.isSet else {
            return
        }
        
        self.isSet = true
        self.setupStackView()
        self.setupTopLabel()
        self.setupBottomLabel()
        self.layoutIfNeeded()
    }
    
    public func set(images: [UIImage], topText: String, bottomText: String) {
        images.forEach {
            let imageView = UIImageView(image: $0)
            self.stackView.addArrangedSubview(imageView)
        }
        
        self.setRatioForStackViewElement()
        self.topLabel.text = topText
        self.bottomLabel.text = bottomText
    }
    
    //MARK: PRIVATE METHODS
    
    private func setup() {
        self.backgroundColor = .clear
        self.isOpaque = false
        self.addSubview(self.stackView)
        self.addSubview(self.topLabel)
        self.addSubview(self.bottomLabel)
    }
   
    private func setupStackView() {
        self.stackView.axis = .horizontal
        self.stackView.distribution = .fillEqually
        self.stackView.spacing = 8.0
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: self.stackView.centerXAnchor),
            self.centerYAnchor.constraint(equalTo: self.stackView.centerYAnchor),
            self.stackView.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.9),
            self.stackView.heightAnchor.constraint(lessThanOrEqualToConstant: 96)
            ])
    }
    
    private func setRatioForStackViewElement() {
        self.stackView.arrangedSubviews.forEach {
            NSLayoutConstraint.activate([
                $0.widthAnchor.constraint(equalTo: $0.heightAnchor)
                ])
        }
        
        self.layoutIfNeeded()
    }
    
    private func setupTopLabel() {
        self.topLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: self.stackView.centerXAnchor),
            self.topLabel.bottomAnchor.constraint(equalTo: self.stackView.topAnchor, constant: -16),
            self.topLabel.widthAnchor.constraint(equalTo: self.widthAnchor)
            ])
        
        self.topLabel.textColor = .white
        self.topLabel.font = UIFont.boldSystemFont(ofSize: self.bounds.height * 0.35)
        self.topLabel.numberOfLines = 1
        self.topLabel.textAlignment = .center
    }
    
    private func setupBottomLabel() {
        self.bottomLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.bottomLabel.centerXAnchor.constraint(equalTo: self.stackView.centerXAnchor),
            self.bottomLabel.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 16),
            self.bottomLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9)
            ])
        
        self.layoutIfNeeded()
        self.bottomLabel.textColor = .white
        self.bottomLabel.font = UIFont.boldSystemFont(ofSize: self.bounds.height * 0.35)
        self.bottomLabel.numberOfLines = 3
        self.bottomLabel.textAlignment = .center
    }
}
