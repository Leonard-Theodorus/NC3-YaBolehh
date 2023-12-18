//
//  SheetPresentationController + MapViewControllerDelegate.swift
//  CobainMaps
//
//  Created by Leee on 27/07/23.
//

import Foundation
import UIKit
import MapKit
extension SheetPresentationController : MapViewControllerDelegate{
    func getSender(sender: UIViewController) {
        senderVc = sender
    }
    
    func getAnnotations(annotations: [MKPointAnnotation]) {
        self.annotations = annotations
    }
    
}
