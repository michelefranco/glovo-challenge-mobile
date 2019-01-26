import UIKit

final class LauncherViewController: UIViewController {
    private let containerView = UIView()
    private let mapViewController = MapViewController()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.containerView)
        self.containerView.fillConstraintsToSuperview()
        self.addChild(self.mapViewController, in: self.containerView)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
