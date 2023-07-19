//
//  MapVc.swift
//  CobainMaps
//
//  Created by Leee on 19/07/23.
//

import UIKit
import MapKit
import CoreLocation
class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var MapDataManager = MapKitManager()
    var overlays = [MKOverlay]()
    var annotations = [MKPointAnnotation]()
    var features = [GeoJSONFeature]()
    var decodedGeoJSON = [MKGeoJSONObject]()
    var locationManager = LocationManager.shared
    //TODO: Rapihin Parsing GEOJSON (Jadiin generic)
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            features = try MapDataManager.getGeoJSONFeatures()
            decodedGeoJSON = try MapDataManager.parseGeoJSON()
        } catch let error {
            print(error.localizedDescription)
        }
        overlays = MapDataManager.getPolygonOverlays()
        annotations = MapDataManager.createMapAnnotations(from: features)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.addOverlays(overlays)
        mapView.addAnnotations(annotations)
    }
    
}
extension MapViewController : MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var renderer = MKPolygonRenderer()
        if let polygon = overlay as? MKPolygon{
            renderer = MKPolygonRenderer(polygon: polygon)
            renderer.strokeColor = .red
            renderer.lineWidth = 0.7
        }
        
        return renderer
    }
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        //TODO: Munculin nearby places?
    }
    //TODO: Picker buat legend?
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        guard let userLocation = LocationManager.shared.location else {return}
        let userMapPoint = MKMapPoint(userLocation.coordinate)
        for item in decodedGeoJSON{
            if let feature = item as? MKGeoJSONFeature{
                for geo in feature.geometry{
                    guard let overlay = geo as? MKOverlay else {continue}
                    if overlay.boundingMapRect.contains(userMapPoint){
                        MapDataManager.userInStation = true
                        break
                    }
                    
                }
            }
        }
    }
    
    
}
