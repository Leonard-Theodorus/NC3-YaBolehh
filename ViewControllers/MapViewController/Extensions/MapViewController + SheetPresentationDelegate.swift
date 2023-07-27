//
//  MapViewController + SheetPresentationDelegate.swift
//  CobainMaps
//
//  Created by Leee on 27/07/23.
//

import Foundation
import UIKit

extension MapViewController : SheetPresentationControllerDelegate{
    func closestGateDetail(closestGate: [String : Double], destination : String, returnBacktoSender sender: UIViewController) {
        guard let navigationController else { return }
        let detailVc = NavigationDetailViewController()
        self.detailDelegate = detailVc
        if let exitGate = closestGate.keys.first{
            detailDelegate?.getDetails(exitGate: exitGate, destination: destination)
        }
        sheetNavController.isModalInPresentation = false
        sheetNavController.dismiss(animated: true)
        navigationController.pushViewController(detailVc, animated: true)
    }
}
