import UIKit
import MapKit

public final class CityAnnotation: MKPointAnnotation {
    public let image: UIImage? = {
        // Resize image
        let pinImage = UIImage(named: "logo")
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }()
    
    public var city: City?
}
