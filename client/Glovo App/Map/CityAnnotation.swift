import UIKit
import MapKit

final class CityAnnotation: MKPointAnnotation {
    let image: UIImage? = {
        // Resize image
        let pinImage = UIImage(named: "logo")
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContext(size)
        pinImage!.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }()
    
    var city: City?
}
