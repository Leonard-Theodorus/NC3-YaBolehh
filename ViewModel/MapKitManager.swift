//
//  GeoJSONModel.swift
//  CobainMaps
//
//  Created by Leee on 17/07/23.
//

import Foundation
import MapKit

struct MapKitManager{
    var userInStation : Bool = false
    func getGeoJSONData() -> Data{
        guard let url = Bundle.main.url(forResource: "HI", withExtension: "geojson") else {
            fatalError("No File")
        }
        do{
            let data = try Data(contentsOf: url)
            return data
        }
        catch let error{
            fatalError("\(error.localizedDescription)")
        }
    }
    func parseGeoJSON() throws -> [MKGeoJSONObject]{
        let data = getGeoJSONData()
        var decoded = [MKGeoJSONObject]()
        do{
            decoded = try MKGeoJSONDecoder().decode(data)
        }
        catch let error{
            throw error
        }
        return decoded
    }
    
    func getPolygonOverlays() -> [MKOverlay]{
        var overlays = [MKOverlay]()
        guard let url = Bundle.main.url(forResource: "HI", withExtension: "geojson") else {
            fatalError("No File")
        }
        var decodedGeoJSON = [MKGeoJSONObject]()
        do{
            let data = try Data(contentsOf: url)
            decodedGeoJSON = try MKGeoJSONDecoder().decode(data)
        }
        catch let error{
            fatalError("\(error.localizedDescription)")
        }
        for item in decodedGeoJSON{
            if let feature = item as? MKGeoJSONFeature{
                for geo in feature.geometry{
                    if let polygon = geo as? MKPolygon{
                        overlays.append(polygon)
                    }
                }
            }
        }
        return overlays
    }
    func getGeoJSONFeatures() throws -> [GeoJSONFeature]{
        let data = getGeoJSONData()
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        guard let jsonDictionary = jsonObject as? [String : Any],
              let features = jsonDictionary["features"] as? [[String : Any]] else{
            throw NSError(domain: "Parsing Error", code: 0)
        }
        var geoJSONFeatures : [GeoJSONFeature] = []
        for feature in features {
            if let geoFeature = GeoJSONFeature(json: feature){
                geoJSONFeatures.append(geoFeature)
            }
        }
        return geoJSONFeatures
    }
    func createMapAnnotations(from geoJSONFeatures : [GeoJSONFeature]) -> [MKPointAnnotation]{
        var annotations: [MKPointAnnotation] = []
        
        for feature in geoJSONFeatures {
            if feature.type == "Feature" && feature.geometry["type"] as? String == "Point" {
                if let coordinates = feature.geometry["coordinates"] as? [Double],
                   let name = feature.properties["name"] as? String {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
                    annotation.title = name
                    // Add more properties as needed
                    // annotation.subtitle = feature.properties["category"] as? String
                    
                    annotations.append(annotation)
                }
            }
        }
        
        return annotations
    }
    
    func getNearestPlace(from searchResult : MKLocalSearchCompletion) async -> CLLocationCoordinate2D{
        var closestCoordinate = CLLocationCoordinate2D()
        let searchReq = MKLocalSearch.Request(completion: searchResult)
        
        let localSearch = MKLocalSearch(request: searchReq)
        do {
            let response = try await localSearch.start()
            if let item = response.mapItems.first {
                closestCoordinate = item.placemark.coordinate
                
            }
        } catch let error {
            print(error.localizedDescription)
        }
        return closestCoordinate
        
    }
    
}
