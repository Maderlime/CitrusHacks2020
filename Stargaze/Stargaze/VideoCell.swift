//
//  VideoCell.swift
//  Stargaze
//
//  Created by Madeline Tjoa on 4/25/20.
//  Copyright © 2020 Madeline Tjoa. All rights reserved.
//

import Foundation
import UIKit
class BaseCell: UICollectionViewCell{
    override init(frame: CGRect){
        super.init(frame:frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupViews(){}
}
