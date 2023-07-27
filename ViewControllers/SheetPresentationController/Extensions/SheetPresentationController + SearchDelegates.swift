//
//  SheetPresentationController + SearchBarDelegate + MKLocalSearchDelegate.swift
//  CobainMaps
//
//  Created by Leee on 27/07/23.
//

import Foundation
import UIKit
import MapKit
extension SheetPresentationController : UISearchBarDelegate, MKLocalSearchCompleterDelegate{
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
        destinationSearchBar.resignFirstResponder()
    }
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        recommendationTableView.reloadData()
    }
    func calculateClosestDistance(to destinationCoordinate : CLLocationCoordinate2D) -> [String : Double]{
        for pinPoint in annotations{
            let sourceLocation = CLLocation(latitude: pinPoint.coordinate.latitude, longitude: pinPoint.coordinate.longitude)
            let destinationLocation = CLLocation(latitude: destinationCoordinate.latitude, longitude: destinationCoordinate.longitude)
            let distance = sourceLocation.distance(from: destinationLocation)
            closestGate[pinPoint.title] = distance
        }
        guard let min = closestGate.min(by: {$0.value < $1.value}), let key = min.key, let closestGateTitle = key
        else {return [:]}
        var closestGateDict = [String : Double]()
        closestGateDict[closestGateTitle] = min.value
        closestGate = [:]
        return closestGateDict
        
    }
    
}
