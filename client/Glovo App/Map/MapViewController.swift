import UIKit
import MapKit
import CoreGraphics

final class MapViewController: UIViewController, MKMapViewDelegate {
    private let mapView = MKMapView()
    private var polygonsCity = [String: [MKPolygon]]()
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.mapView)
        self.mapView.fillConstraintsToSuperview()
        self.mapView.isZoomEnabled = true
        self.mapView.isPitchEnabled = true
        self.mapView.showsUserLocation = true
        
        self.mapView.delegate = self
    }
    
    private func setVisibleMapArea(rect: MKMapRect, edgeInsets: UIEdgeInsets, animated: Bool = false) {
        self.mapView.setVisibleMapRect(rect, edgePadding: edgeInsets, animated: animated)
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let k = MKPolygonRenderer(overlay: overlay)
            k.fillColor = UIColor(hex: 0xFEDA54).withAlphaComponent(0.5)
            return k
        }
        
        return MKPolylineRenderer()
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
}

// MARK: PRIVATE EXTENSION
fileprivate extension City {
    var uniqueKey: String {
        return "\(self.countryCode)\(self.code)"
    }
}
