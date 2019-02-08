import UIKit

public final class OnBoardingCollectionViewController: UICollectionViewController {
    private let reuseIdentifier = "OnBoarding"
    private var model = [OnBoardingModel]()
    private var isSet = false
    weak var pagerControlDelegate: PagerControlDelegate?
    
    //MARK: VIEW CONTROLLER LIFE CYCLE
    public override func viewDidLoad() {
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
    
    public override func viewDidLayoutSubviews() {
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
    
    
    //MARK: COLLECTION VIEW DATA SOURCE & DELEGATE 
    public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.model.count
    }
    
    public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as? OnBoardingCell else {
            return UICollectionViewCell()
        }
        
        let item = self.model[indexPath.item]
        cell.set(images: item.images, topText: item.topText, bottomText: item.bottomText)
        
        return cell
    }
    
    public override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    public override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let page = self.currentPage(currentPoint: scrollView.contentOffset)
            self.pagerControlDelegate?.setNewPage(page)
        }
    }
    
    public override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = self.currentPage(currentPoint: scrollView.contentOffset)
        self.pagerControlDelegate?.setNewPage(page)
    }
    
    //MARK: PRIVATE METHODS
    
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
    private func currentPage(currentPoint: CGPoint) -> Int {
        return Int(currentPoint.x / self.collectionView.bounds.width)
    }
}
