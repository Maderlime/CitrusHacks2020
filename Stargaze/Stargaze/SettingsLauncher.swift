//
//  SettingsLauncher.swift
//  Stargaze
//
//  Created by Madeline Tjoa on 4/25/20.
//  Copyright © 2020 Madeline Tjoa. All rights reserved.
//

import UIKit

class Setting: NSObject{
    let name:String
    let imagename: String
    
    init(ImageName: String, name:String){
        self.name = name
        self.imagename = ImageName
    }
}

class SettingsLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SettingCell
        let setting = settings[indexPath.item]
        cell.setting = setting
        return cell
    }
    
    let settings: [Setting] = {
        return [Setting(ImageName: "card1_1", name: " ")]
    }()
    
    let blackView = UIView()
    
    let cellId = "cellId"

    let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.white
        return cv
    }()
    

    
    
    func showSettings(){
        if let window = UIApplication.shared.keyWindow{
            
            blackView.backgroundColor = UIColor(white:0, alpha:0.5)
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, animations:
                {self.blackView.alpha = 1})
            
            window.addSubview(collectionView)
            
            let height : CGFloat = 500
            let y = window.frame.height - height
            
            collectionView.frame = CGRect(x: 0,y: window.frame.height,width: window.frame.width, height: 500)
            
            UIView.animate(withDuration: 0.5, delay:0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations:{
                self.collectionView.frame = CGRect(x: 0,y: y,width: self.collectionView.frame.width, height: self.collectionView.frame.height)}, completion: nil)
            
        }
        
    }
    @objc func handleDismiss(){
           UIView.animate(withDuration: 0.5){
               self.blackView.alpha = 0
           }
           UIView.animate(withDuration: 0.5) {
                if let window = UIApplication.shared.keyWindow{
                    self.collectionView.frame = CGRect(x: 0,y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                }
            }
       }
    
    
    

    
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return settings.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! SettingCell
        let setting = settings[indexPath.item]
        cell.setting = setting
        return cell
    }
    
    private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        return CGSize( width: collectionView.frame.width,height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize( width: collectionView.frame.width,height: 100)
    }
    override init(){
        super.init()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(SettingCell.self, forCellWithReuseIdentifier: cellId)
    }
    
}
