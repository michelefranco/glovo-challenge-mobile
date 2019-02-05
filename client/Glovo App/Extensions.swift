import UIKit
import MapKit

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

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat(UInt8(hex >> 16 & 0xFF)) / 255,
            green: CGFloat(UInt8(hex >> 8 & 0xFF)) / 255,
            blue: CGFloat(UInt8(hex & 0xff)) / 255,
            alpha: alpha
        )
    }
    
    func getRGBA() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
}


extension String {
    var unescaped: String {
        let entities = ["\0": "\\0",
                        "\t": "\\t",
                        "\n": "\\n",
                        "\r": "\\r",
                        "\"": "\\\"",
                        "\'": "\\'",
                        ]
        
        return entities
            .reduce(self) { (string, entity) in
                string.replacingOccurrences(of: entity.value, with: entity.key)
        }
    }
}

extension MKPolygon {
    
    var points: [MKMapPoint] {
        let polygonPoints = self.points()
        
        var result = [MKMapPoint]()
        for index in 0..<self.pointCount {
            let point = polygonPoints[index]
            result.append(point)
        }
        
        return result
    }
}
