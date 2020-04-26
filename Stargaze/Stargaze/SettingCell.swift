//
//  SettingCell.swift
//  Stargaze
//
//  Created by Madeline Tjoa on 4/25/20.
//  Copyright © 2020 Madeline Tjoa. All rights reserved.
//

import UIKit

class SettingCell: BaseCell{
    var setting: Setting?{
        didSet{
            nameLabel.text = setting?.name
            if let imageName = setting?.imagename{
                iconImageView.image = UIImage(named: imageName)
            }
            
        }
    }
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 0))
        imageView.image = UIImage(named: "settings")
        imageView.contentMode = .scaleAspectFill
        
        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 10)
//        imageView.contentMode = .redraw
//        imageView.contentMode = .topLef
        return imageView
        }()
    let nameLabel: UILabel = {
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 200, height: 21)
        label.text = "Setting"
        label.font = UIFont(name: "Halvetica", size:30)
        label.textColor = .darkGray
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    
    override func setupViews() {
        print("visited")
        super.setupViews()
        addSubview(nameLabel)
        addSubview(iconImageView)

//
        addConstraintsWithFormat(format: "H:|[v0]|", views: iconImageView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: nameLabel)
//        addConstraintsWithFormat(format: "V:|[v0(30)]|", views: nameLabel)
//        addConstraintsWithFormat(format: "V:|[v0]|", views: nameDescription)
//        addConstraintsWithFormat(format: "V:|[v0(30)]|", views: nameLabel)
//        backgroundColor = UIColor.blue
    }
}

extension UIView{
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
