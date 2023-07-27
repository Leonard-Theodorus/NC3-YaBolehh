//
//  RecommendationCell.swift
//  CobainMaps
//
//  Created by Leee on 20/07/23.
//

import UIKit

class RecommendationCell: UITableViewCell {
    
    @IBOutlet weak var placeDescription: UILabel!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var imageLegend: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
