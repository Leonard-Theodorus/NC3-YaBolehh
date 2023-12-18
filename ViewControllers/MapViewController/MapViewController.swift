//
//  MapVc.swift
//  CobainMaps
//
//  Created by Leee on 19/07/23.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit

class MapViewController: UIViewController {
    weak var mapDelegate : MapViewControllerDelegate?
    weak var detailDelegate : DetailViewControllerDelegate?
    var mapDataManager = MapKitManager()
    var decodedGeoJSON = [MKGeoJSONObject]()
    var sheetNavController = UINavigationController()
    @IBOutlet weak var mapView: MKMapView!
    fileprivate let sheetViewController = SheetPresentationController()
    private var overlays = [MKOverlay]()
    private var lineOverlay : MKOverlay?
    private var annotations = [MKPointAnnotation]()
    private var features = [GeoJSONFeature]()
    private var locationManager = LocationManager.shared
    //TODO: Rapihin Parsing GEOJSON (Jadiin generic)
    override func viewDidLoad() {
        super.viewDidLoad()
        sheetNavController = UINavigationController(rootViewController: sheetViewController)
        do {
            features = try mapDataManager.getGeoJSONFeatures()
            decodedGeoJSON = try mapDataManager.parseGeoJSON()
        } catch let error {
            print(error.localizedDescription)
        }
        setupMapView()
        drawRoutes()
    }
    override func viewDidAppear(_ animated: Bool) {
        if !sheetNavController.isModalInPresentation{
            prepareSheet()
        }
    }
    func setupMapView(){
        overlays = mapDataManager.getPolygonOverlays()
        annotations = mapDataManager.createMapAnnotations(from: features)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.addOverlays(overlays)
        mapView.addAnnotations(annotations)
        setupMapViewConstraints()
        mapDataManager.shortestPath()
    }
    
    func prepareSheet(){
        self.mapDelegate = sheetViewController
        mapDelegate?.getAnnotations(annotations: annotations)
        mapDelegate?.getSender(sender: self)
        sheetNavController.isModalInPresentation = true
        if let sheet = sheetNavController.sheetPresentationController{
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
        present(sheetNavController, animated: true)
    }
    
    func drawRoutes(){
        if mapDataManager.routeCoordinates.count == 0{
            print("No Route Data")
        }
        DispatchQueue.main.async {
            self.lineOverlay = MKPolyline(coordinates: self.mapDataManager.routeCoordinates, count: self.mapDataManager.routeCoordinates.count)
            self.mapView.addOverlay(self.lineOverlay!, level: .aboveLabels)
        }
    }
    
}
extension MapViewController{
    func setupMapViewConstraints(){
        mapView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

protocol MapViewControllerDelegate : AnyObject{
    func getAnnotations(annotations : [MKPointAnnotation])
    func getSender(sender : UIViewController)
}

protocol DetailViewControllerDelegate : AnyObject{
    func getDetails(exitGate : String, destination : String)
}
