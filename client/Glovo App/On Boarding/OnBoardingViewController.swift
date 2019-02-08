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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: VIEW CONTROLLER LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.onBoardingViewController.pagerControlDelegate = self
        self.addChild(self.onBoardingViewController, in: self.collectionContainerView)
    }
    
    
    @IBAction func buttonPressed(_ sender: Any) {
        self.delegate?.getStartedPressed()
    }
    
    public func setNewPage(_ page: Int) {
        if page == self.pageControl.numberOfPages - 1 {
            self.showButton()
        } else {
            self.hideButton()
        }
        self.pageControl.currentPage = page
    }
    
    //MARK: PRIVATE METHODS

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
