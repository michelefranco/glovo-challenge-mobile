import UIKit
import CoreLocation

public final class LocationServices {
    public static let shared = LocationServices()
    public var location: CLLocation?
    private init() {}
    
    public func getAdress(from location: CLLocation, completion: @escaping (_ address: [AnyHashable: Any]?, _ error: Error?) -> ()) {
        
        self.location = location
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
            if let e = error {
                completion(nil, e)
            } else {
                
                guard let placeArray = placemarks,
                    let placeMark = placeArray.first,
                    let address = placeMark.addressDictionary else {
                        return
                }
                completion(address, nil)
            }
        }
    }
}
