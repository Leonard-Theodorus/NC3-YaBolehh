//
//  NavigationDetailViewController + DetailViewControllerDelegate.swift
//  CobainMaps
//
//  Created by Leee on 27/07/23.
//

import Foundation

extension NavigationDetailViewController : DetailViewControllerDelegate{
    func getDetails(exitGate: String, destination: String) {
        destinationLabelText = destination
        gateLabel = exitGate
    }
}
