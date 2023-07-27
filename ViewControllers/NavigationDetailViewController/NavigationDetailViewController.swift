//
//  NavigationDetailViewController.swift
//  CobainMaps
//
//  Created by Leee on 21/07/23.
//

import UIKit
import SnapKit
class NavigationDetailViewController: UIViewController {
    var destinationLabelText = ""
    var gateLabel = ""
    @IBOutlet weak var imageDirectionScrollView: UIScrollView!
    @IBOutlet weak var nearestStationLabel: UILabel!
    @IBOutlet weak var exitGateLabel: UILabel!
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        setupScrollView()
    }

}
extension NavigationDetailViewController{
    func configureConstraints(){
        guard let navigationController else {return}
        exitGateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(32)
        }
        destinationLabel.snp.makeConstraints { make in
            make.top.equalTo(exitGateLabel.snp.bottom).offset(20)
            make.leading.equalTo(exitGateLabel.snp.leading)
        }
        nearestStationLabel.snp.makeConstraints { make in
            make.top.equalTo(destinationLabel.snp.bottom).offset(20)
            make.leading.equalTo(exitGateLabel.snp.leading)
        }
        directionsLabel.snp.makeConstraints { make in
            make.top.equalTo(nearestStationLabel.snp.bottom).offset(20)
            make.leading.equalTo(exitGateLabel.snp.leading)
        }
        
    }
    func setupLabels(){
        exitGateLabel.text = "Closest Exit Through " + "\(gateLabel)"
        destinationLabel.text = destinationLabelText
        configureConstraints()
        
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

