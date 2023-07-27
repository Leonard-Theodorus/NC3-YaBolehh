//
//  SheetPresentationController.swift
//  CobainMaps
//
//  Created by Leee on 21/07/23.
//

import UIKit
import MapKit
import SnapKit
class SheetPresentationController: UIViewController{
    var completer : MKLocalSearchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var annotations = [MKPointAnnotation]()
    var senderVc : UIViewController?
    var closestGate = [String?? : Double]()
    var mapDataManager = MapKitManager()
    weak var delegate : SheetPresentationControllerDelegate?
    fileprivate let cellReuseId = "recCell"
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
        setupConstraints()
    }
    
}
extension SheetPresentationController{
    func setupConstraints(){
        destinationSearchBar.translatesAutoresizingMaskIntoConstraints = false
        recommendationTableView.translatesAutoresizingMaskIntoConstraints = false
        destinationSearchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        recommendationTableView.snp.makeConstraints { make in
            make.top.equalTo(destinationSearchBar.snp.bottom).offset(20)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            
        }
    }
}
protocol SheetPresentationControllerDelegate : AnyObject{
    func closestGateDetail(closestGate : [String : Double], destination : String, returnBacktoSender sender : UIViewController)
}
