//
//  GeoJSONFeatures.swift
//  CobainMaps
//
//  Created by Leee on 18/07/23.
//

import Foundation
struct GeoJSONFeature{
    let type : String
    let properties : [String : Any]
    let geometry : [String : Any]
//    let category : [String : Any]
    init?(json: [String: Any]) {
        guard let type = json["type"] as? String,
              let properties = json["properties"] as? [String: Any],
              let geometry = json["geometry"] as? [String: Any]
//              let category = json["category"] as? [String : Any]
        
        else {
            return nil
        }
        
        self.type = type
        self.properties = properties
        self.geometry = geometry
//        self.category = category
    }
}
