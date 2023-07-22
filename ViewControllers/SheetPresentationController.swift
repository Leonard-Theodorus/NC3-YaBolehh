//
//  SheetPresentationController.swift
//  CobainMaps
//
//  Created by Leee on 21/07/23.
//

import UIKit
import MapKit
class SheetPresentationController: UIViewController{
    weak var delegate : SheetPresentationControllerDelegate?
    private var senderVc : UIViewController?
    private var mapDataManager = MapKitManager()
    private var annotations = [MKPointAnnotation]()
    fileprivate let cellReuseId = "recCell"
    private var completer : MKLocalSearchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    private var closestGate = [String?? : Double]()
    @IBOutlet weak var destinationSearchBar: UISearchBar!
    @IBOutlet weak var recommendationTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = senderVc as? MapViewController
        completer.delegate = self
        destinationSearchBar.delegate = self
        recommendationTableView.delegate = self
        recommendationTableView.dataSource = self
        recommendationTableView.register(UINib(nibName: "RecommendationCell", bundle: nil), forCellReuseIdentifier: cellReuseId)
    }
    
}
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
extension SheetPresentationController : MapViewControllerDelegate{
    func getSender(sender: UIViewController) {
        senderVc = sender
    }
    
    func getAnnotations(annotations: [MKPointAnnotation]) {
        self.annotations = annotations
    }
    
}
protocol SheetPresentationControllerDelegate : AnyObject{
    func closestGateDetail(closestGate : [String : Double], destination : String, returnBacktoSender sender : UIViewController)
}
