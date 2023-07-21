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
    weak var mapDelegate : MapViewControllerDelegate?
    @IBOutlet weak var mapView: MKMapView!
    private var mapDataManager = MapKitManager()
    private var overlays = [MKOverlay]()
    private var annotations = [MKPointAnnotation]()
    private var features = [GeoJSONFeature]()
    private var decodedGeoJSON = [MKGeoJSONObject]()
    private var locationManager = LocationManager.shared
    //TODO: Rapihin Parsing GEOJSON (Jadiin generic)
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            features = try mapDataManager.getGeoJSONFeatures()
            decodedGeoJSON = try mapDataManager.parseGeoJSON()
        } catch let error {
            print(error.localizedDescription)
        }
        setupMapView()
    }
    override func viewDidAppear(_ animated: Bool) {
        prepareSheet()
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
    func prepareSheet(){
        let vcToBePresented = SheetPresentationController()
        self.mapDelegate = vcToBePresented
        mapDelegate?.getAnnotations(annotations: annotations)
        let navigationController = UINavigationController(rootViewController: vcToBePresented)
        navigationController.isModalInPresentation = true
        if let sheet = navigationController.sheetPresentationController{
            let smallDetentIdentifier = UISheetPresentationController.Detent.Identifier("small")
            let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentIdentifier) { context in
                return 0.2 * context.maximumDetentValue
            }
            sheet.detents = [smallDetent ,.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.selectedDetentIdentifier = smallDetentIdentifier
            sheet.largestUndimmedDetentIdentifier = smallDetentIdentifier
            
        }
        present(navigationController, animated: true)
    }
    
    func prepareDetailSheet(){
        let vcToBePresented = SheetPresentationController()
        let navigationController = UINavigationController(rootViewController: vcToBePresented)
        navigationController.isModalInPresentation = true
        if let sheet = navigationController.sheetPresentationController{
            let smallDetentIdentifier = UISheetPresentationController.Detent.Identifier("small")
            let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallDetentIdentifier) { context in
                return 0.2 * context.maximumDetentValue
            }
            sheet.detents = [smallDetent ,.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.selectedDetentIdentifier = smallDetentIdentifier
            sheet.largestUndimmedDetentIdentifier = smallDetentIdentifier
            
        }
        present(navigationController, animated: true)
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

extension MapViewController : SheetPresentationControllerDelegate{
    func closestGateDetail(closestGate: [String : Double]) {
        //TODO: Pindahin ini ke VC navigator

    }
    
}

protocol MapViewControllerDelegate : AnyObject{
    func getAnnotations(annotations : [MKPointAnnotation])
}
