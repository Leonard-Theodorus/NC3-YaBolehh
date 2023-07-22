//
//  NavigationDetailViewController.swift
//  CobainMaps
//
//  Created by Leee on 21/07/23.
//

import UIKit

class NavigationDetailViewController: UIViewController {
    var destinationLabelText = ""
    var gateLabel = ""
    @IBOutlet weak var imageDirectionScrollView: UIScrollView!
    
    @IBOutlet weak var exitGateLabel: UILabel!
    
    @IBOutlet weak var destinationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        setupScrollView()
        // Do any additional setup after loading the view.
    }

}
extension NavigationDetailViewController{
    func setupLabels(){
        exitGateLabel.text = "Closest Exit Through " + "\(gateLabel)"
        destinationLabel.text = destinationLabelText
        
    }
    func setupScrollView(){
        var xOffset : CGFloat = 0.0
        let imageHeight = imageDirectionScrollView.bounds.height
        for n in 0...4{
            let imageView = UIImageView(image: UIImage(named: String(n+1)))
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 20
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageDirectionScrollView.addSubview(imageView)
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: imageDirectionScrollView.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: imageDirectionScrollView.leadingAnchor, constant: xOffset),
                imageView.heightAnchor.constraint(equalTo: imageDirectionScrollView.heightAnchor),
                imageView.widthAnchor.constraint(equalTo: imageDirectionScrollView.heightAnchor)
            ])
            xOffset += imageHeight
            imageDirectionScrollView.contentSize = CGSize(width: xOffset, height: imageHeight)
        }
    }
}

extension NavigationDetailViewController : DetailViewControllerDelegate{
    func getDetails(exitGate: String, destination: String) {
        destinationLabelText = destination
        gateLabel = exitGate
//        destinationLabel.text = destination
//        exitGateLabel.text = exitGate
    }
}
