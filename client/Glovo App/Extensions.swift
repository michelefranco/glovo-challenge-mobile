import UIKit

extension UIViewController {
    func addChild(_ controller: UIViewController, in containerView: UIView) {
        self.addChild(controller)
        containerView.addSubview(controller.view)
        controller.view.fillConstraintsToSuperview()
        controller.didMove(toParent: self)
    }
    
    func removeFromParentController() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

extension UIView {
    func fillScreen() {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalTo: superview.heightAnchor),
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            self.widthAnchor.constraint(equalTo: superview.widthAnchor),
            self.centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ])
    }
    
    func fillConstraintsToSuperview(_ multiplier: CGFloat = 1) {
        guard let superview = self.superview else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: 0),
            self.widthAnchor.constraint(equalTo: superview.widthAnchor, multiplier: multiplier),
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: -8)
            ])
    }
}
