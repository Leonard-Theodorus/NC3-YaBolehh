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
    @IBOutlet weak var recommendationTableView: UITableView!
    @IBOutlet weak var placeSearchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    private var completer : MKLocalSearchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    private var nearbyPlaces = [String]()
    private var mapDataManager = MapKitManager()
    private var overlays = [MKOverlay]()
    private var annotations = [MKPointAnnotation]()
    private var features = [GeoJSONFeature]()
    private var decodedGeoJSON = [MKGeoJSONObject]()
    private var locationManager = LocationManager.shared
    private var closestGate = [String?? : Double]()
    //TODO: Rapihin Parsing GEOJSON (Jadiin generic)
    override func viewDidLoad() {
        super.viewDidLoad()
        completer.delegate = self
        recommendationTableView.delegate = self
        recommendationTableView.dataSource = self
        recommendationTableView.register(UINib(nibName: "RecommendationCell", bundle: nil), forCellReuseIdentifier: "recCell")
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
    //    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
    //        Task{
    //            nearbyPlaces = await mapDataManager.getNearestPlace(from: annotation.coordinate)
    //        }
    //    }
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
        if searchText == ""{
            recommendationTableView.reloadData()
            recommendationTableView.isHidden = true
            
        }
        else{
            recommendationTableView.isHidden = false
            recommendationTableView.reloadData()
            completer.queryFragment = searchText
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        recommendationTableView.reloadData()
        placeSearchBar.resignFirstResponder()
    }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        recommendationTableView.reloadData()
    }
    func calculateClosestDistance(to destinationCoordinate : CLLocationCoordinate2D){
        for pinPoint in annotations{
            let sourceLocation = CLLocation(latitude: pinPoint.coordinate.latitude, longitude: pinPoint.coordinate.longitude)
            let destinationLocation = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
            let distance = sourceLocation.distance(from: destinationLocation)
            closestGate[pinPoint.title] = distance
        }
        guard let min = closestGate.min(by: {$0.value < $1.value}) else {return}
        print(min)
        closestGate = [:]
        
    }
    
    
}

extension MapViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recCell", for: indexPath) as! RecommendationCell
        cell.imageLegend.image = UIImage(systemName: "location")
        cell.placeName.text = searchResults[indexPath.row].title
        cell.placeDescription.text = searchResults[indexPath.row].subtitle
        return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: Perform closest exit gate
        let selectedDestination = searchResults[indexPath.row]
        var closestCoordinate = CLLocationCoordinate2D()
        Task{
            closestCoordinate = await mapDataManager.getNearestPlace(from: selectedDestination)
            calculateClosestDistance(to: closestCoordinate)
        }
    }
}

