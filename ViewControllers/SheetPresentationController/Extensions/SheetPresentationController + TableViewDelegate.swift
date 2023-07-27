//
//  SheetPresentationController + TableViewDelegate.swift
//  CobainMaps
//
//  Created by Leee on 27/07/23.
//

import Foundation
import UIKit
import CoreLocation

extension SheetPresentationController : UITableViewDelegate, UITableViewDataSource{
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
        guard let senderVc else {return}
        let selectedDestination = searchResults[indexPath.row]
        var closestCoordinate = CLLocationCoordinate2D()
        Task{
            closestCoordinate = await mapDataManager.getNearestPlace(from: selectedDestination)
            delegate?.closestGateDetail(closestGate: calculateClosestDistance(to: closestCoordinate), destination: selectedDestination.title, returnBacktoSender: senderVc)
        }
        
    }
}
