//
//  MapViewController + MapViewDelegate.swift
//  CobainMaps
//
//  Created by Leee on 27/07/23.
//

import Foundation
import UIKit
import MapKit

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
