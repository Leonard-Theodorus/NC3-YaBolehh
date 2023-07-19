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
    @IBOutlet weak var placeSearchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    var completer : MKLocalSearchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var nearbyPlaces = [String]()
    var mapDataManager = MapKitManager()
    var overlays = [MKOverlay]()
    var annotations = [MKPointAnnotation]()
    var features = [GeoJSONFeature]()
    var decodedGeoJSON = [MKGeoJSONObject]()
    var locationManager = LocationManager.shared
    //TODO: Rapihin Parsing GEOJSON (Jadiin generic)
    override func viewDidLoad() {
        super.viewDidLoad()
        completer.delegate = self
        setupSearchBar()
        placeSearchBar.delegate = self
        do {
            features = try mapDataManager.getGeoJSONFeatures()
            decodedGeoJSON = try mapDataManager.parseGeoJSON()
        } catch let error {
            print(error.localizedDescription)
        }
        setupMapView()
    }
    func setupSearchBar(){
        NSLayoutConstraint.activate([
            placeSearchBar.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            placeSearchBar.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            placeSearchBar.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            placeSearchBar.bottomAnchor.constraint(equalTo: mapView.bottomAnchor)
        ])
    }
    func setupMapView(){
        overlays = mapDataManager.getPolygonOverlays()
        annotations = mapDataManager.createMapAnnotations(from: features)
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
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //Custom Annotation?
        if annotation is MKUserLocation{
            return nil
        }
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "Anot")
        annotationView.canShowCallout = true
        return annotationView
        
    }
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        //TODO: Munculin nearby places?
        Task{
            nearbyPlaces = await mapDataManager.getNearestPlace(from: annotation.coordinate)
        }
        
        print(nearbyPlaces)
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
                        mapDataManager.userInStation = true
                        break
                    }
                    
                }
            }
        }
    }
    
    
}

extension MapViewController : UISearchBarDelegate, MKLocalSearchCompleterDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        completer.queryFragment = searchText
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //TODO: Perform closest exit gate
        print(searchResults)
        placeSearchBar.resignFirstResponder()
        //TODO: Munculin Rekomendasi Pas dia search
    }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
}
