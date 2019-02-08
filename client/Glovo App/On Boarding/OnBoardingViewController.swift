import UIKit

protocol OnBoardingDelegate: class {
    func getStartedPressed()
}

protocol PagerControlDelegate: class {
    func setNewPage(_ page: Int)
}

final class OnBoardingViewController: UIViewController, PagerControlDelegate {
    static let key = "OnBoardingKey"
    @IBOutlet var buttonBottomConstraint: NSLayoutConstraint!
    @IBOutlet var buttonTopConstraint: NSLayoutConstraint!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var collectionContainerView: UIView!
    weak var delegate: OnBoardingDelegate?
    private let onBoardingViewController = OnBoardingCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    
    public init() {
        super.init(nibName: "OnBoarding", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.onBoardingViewController.pagerControlDelegate = self
        self.addChild(self.onBoardingViewController, in: self.collectionContainerView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        self.delegate?.getStartedPressed()
    }
    
    func setNewPage(_ page: Int) {
        if page == self.pageControl.numberOfPages - 1 {
            self.showButton()
        } else {
            self.hideButton()
        }
        self.pageControl.currentPage = page
    }
    
    private func showButton() {
        self.buttonTopConstraint.isActive = false
        self.buttonBottomConstraint.isActive = true
        self.view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideButton() {
        self.buttonBottomConstraint.isActive = false
        self.buttonTopConstraint.isActive = true
        self.view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}


final class OnBoardingCell: UICollectionViewCell {
    private var stackView = UIStackView()
    private let topLabel = UILabel()
    private let bottomLabel = UILabel()
    private var isSet = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.topLabel.text = nil
        self.bottomLabel.text = nil
        self.stackView.arrangedSubviews.forEach {
            self.stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
    func set(images: [UIImage], topText: String, bottomText: String) {
        images.forEach {
            let imageView = UIImageView(image: $0)
            self.stackView.addArrangedSubview(imageView)
        }
        
        self.setRatioForStackViewElement()
        self.topLabel.text = topText
        self.bottomLabel.text = bottomText
    }
    
    private func setup() {
        self.backgroundColor = .clear
        self.isOpaque = false
        self.addSubview(self.stackView)
        self.addSubview(self.topLabel)
        self.addSubview(self.bottomLabel)
    }
    
    override func layoutSubviews() {
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


struct OnBoardingModel {
    let images: [UIImage]
    let topText: String
    let bottomText: String
}

final class OnBoardingCollectionViewController: UICollectionViewController {
    private let reuseIdentifier = "OnBoarding"
    private var model = [OnBoardingModel]()
    private var isSet = false
    weak var pagerControlDelegate: PagerControlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = self.collectionView,
            let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        self.setModel()
        collectionView.register(OnBoardingCell.self, forCellWithReuseIdentifier: self.reuseIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.isOpaque = false
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !isSet,
            let collectionView = self.collectionView,
            let layout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
                return
        }
        
        
        self.isSet = true
        let contentInsetHorizontal = collectionView.contentInset.left + collectionView.contentInset.right
        let contentInsetVertical = collectionView.contentInset.top + collectionView.contentInset.bottom
        let sectionInsetHorizontal = layout.sectionInset.right + layout.sectionInset.left
        let sectionInsetVertical = layout.sectionInset.top + layout.sectionInset.bottom
        
        layout.itemSize = CGSize(width: collectionView.bounds.width - contentInsetHorizontal - sectionInsetHorizontal,
                                 height: (collectionView.bounds.height - contentInsetVertical - sectionInsetVertical))
        self.view.layoutIfNeeded()
    }
    
    
    private func setModel() {
        let firstScreenImages = [UIImage(named: "cookie")!, UIImage(named: "doctor")!,
                                 UIImage(named: "cigarette")!, UIImage(named: "gift")!]
        let firstScreenTopText = "WELCOME!"
        let firstScreenBottomText = "THIS IS AN OUTSTANDING SERVICE FOR YOU."
        let firstScreen = OnBoardingModel(images: firstScreenImages, topText: firstScreenTopText, bottomText: firstScreenBottomText)
        self.model.append(firstScreen)
        
        let secondScreenImages = [UIImage(named: "map")!]
        let secondScreenTopText = "DISCOVER PLACES!"
        let secondScreenBottomText = "FIND A WORKING AREA IN CITIES AVAILABLE TO START USING OUR SERVICES."
        let secondScreen = OnBoardingModel(images: secondScreenImages, topText: secondScreenTopText, bottomText: secondScreenBottomText)
        self.model.append(secondScreen)
        
        let thirdScreenImages = [UIImage(named: "logo")!]
        let thirdScreenTopText = "WHOA, THAT'S A GLOVO ICON!"
        let thirdScreenBottomText = "YOU HAVE A FRIEND, USE IT WHENEVER YOU WANT TO ACCESS TO OUR WORKING AREA."
        let thirdScreen = OnBoardingModel(images: thirdScreenImages, topText: thirdScreenTopText, bottomText: thirdScreenBottomText)
        self.model.append(thirdScreen)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as? OnBoardingCell else {
            return UICollectionViewCell()
        }
        
        let item = self.model[indexPath.item]
        cell.set(images: item.images, topText: item.topText, bottomText: item.bottomText)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let page = self.currentPage(currentPoint: scrollView.contentOffset)
            self.pagerControlDelegate?.setNewPage(page)
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = self.currentPage(currentPoint: scrollView.contentOffset)
        self.pagerControlDelegate?.setNewPage(page)
    }
    
    private func currentPage(currentPoint: CGPoint) -> Int {
        return Int(currentPoint.x / self.collectionView.bounds.width)
    }
}
