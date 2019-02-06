import UIKit
import MapKit
import CoreGraphics

final class MapViewController: UIViewController, MKMapViewDelegate {
    private let mapView = MKMapView()
    private var polygonsCity = [String: [MKPolygon]]()
    private var annotations = [CityAnnotation]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: View Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.mapView)
        self.mapView.fillConstraintsToSuperview()
        self.mapView.isZoomEnabled = true
        self.mapView.isPitchEnabled = true
        self.mapView.showsUserLocation = true
        
        self.mapView.delegate = self
    }
    
    func contains(_ location: CLLocation, in city: City) -> Bool {
        let polygons = self.polygons(for: city)
        
        guard !polygons.isEmpty else {
            return false
        }
        
        let mapPoint = MKMapPoint(location.coordinate)
        for polygon in polygons {
            if self.contains(mkPoint: mapPoint, in: polygon.points) {
                return true
            }
        }
        
        return false
    }
    
    func update(with region: MKCoordinateRegion) {
        self.mapView.setRegion(region, animated: true)
    }
    
    func setVisibleMapArea(with city: City) {
        let polygons = self.polygons(for: city)
        
        guard !polygons.isEmpty else {
            return
        }
        
        
        polygons.forEach { self.mapView.addOverlay($0) }
        let rect = polygons.reduce(polygons.first!.boundingMapRect) { result, rect in rect.boundingMapRect.union(result) }
        
        self.setVisibleMapArea(rect: rect, edgeInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), animated: true)
        
        let annotation = CityAnnotation()
        annotation.title = "\(city.name) \(city.countryCode)"
        let coordinate = polygons.map {$0.coordinate}.reduce(polygons.first!.coordinate) { result, coordinate in
            if result == coordinate { return result }
            return CLLocationCoordinate2D(latitude: result.latitude + coordinate.latitude, longitude: result.longitude + coordinate.longitude)}
        annotation.city = city
        annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude / Double(polygons.count),
                                                       longitude: coordinate.longitude / Double(polygons.count))
        self.annotations.append(annotation)
    }
    
    //MARK: Private Methods
    private func setVisibleMapArea(rect: MKMapRect, edgeInsets: UIEdgeInsets, animated: Bool = false) {
        self.mapView.setVisibleMapRect(rect, edgePadding: edgeInsets, animated: animated)
    }
    
    private func contains(mkPoint: MKMapPoint, in mkPoints: [MKMapPoint]) -> Bool {
        let path = CGMutablePath()
        
        let point = self.mapView.convert(mkPoint.coordinate, toPointTo: self.mapView)
        let points = mkPoints.map {
            self.mapView.convert($0.coordinate, toPointTo: self.mapView)
        }
        
        for (index, mp) in points.enumerated() {
            if index == 0 {
                path.move(to: mp)
            } else {
                path.addLine(to: mp)
            }
        }
        
        return path.contains(point)
    }
    
    
    private func polygons(for city: City) -> [MKPolygon] {
        let polygons: [MKPolygon]
        if let p = self.polygonsCity[city.uniqueKey] {
            polygons = p
        } else {
            polygons = self.decodePolyline(from: city)
            self.polygonsCity[city.uniqueKey] = polygons
        }
        
        return polygons
    }
    
    private func decodePolyline(from city: City) -> [MKPolygon] {
        var polygons = [MKPolygon]()
        let encodedPolylines = city.workingArea
        for encodedPolyline in encodedPolylines {
            let decodedPolyline = Polyline(encodedPolyline: encodedPolyline)
            
            guard let coord = decodedPolyline.coordinates else {
                return [MKPolygon]()
            }
            var coordinates = coord
            let polygon = MKPolygon(coordinates: &coordinates, count: coordinates.count)
            polygons.append(polygon)
        }
        
        return polygons
    }
    
    //MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "City"
        guard let annotation = annotation as? CityAnnotation else { return nil }
        
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation:annotation, reuseIdentifier:identifier)
        
        annotationView.annotation = annotation
        annotationView.isEnabled = true
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        // set the image to the annotation view
        annotationView.image = annotation.image
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? CityAnnotation, let city = annotation.city, control == view.rightCalloutAccessoryView {
            self.setVisibleMapArea(with: city)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let k = MKPolygonRenderer(overlay: overlay)
            k.fillColor = UIColor(hex: 0xFEDA54).withAlphaComponent(0.5)
            return k
        }
        
        return MKPolylineRenderer()
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        if mapView.region.span.latitudeDelta > 1.2 {
            self.mapView.addAnnotations(annotations)
        } else {
            self.mapView.removeAnnotations(self.annotations)
        }
    }
}

// MARK: PRIVATE EXTENSION
fileprivate extension City {
    var uniqueKey: String {
        return "\(self.countryCode)\(self.code)"
    }
}
