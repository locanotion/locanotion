//
//  ClubCollectionViewCell.swift
//  Locanotion
//
//  Created by William Bertrand on 4/19/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation


class ClubCollectionViewCell : UICollectionViewCell {
    
    var clubNameLabel : UILabel!
    var clubImageName : String!
    var clubImageView : UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //add title blur view
        let titleFrame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height / 4)
        
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = titleFrame
        
        let clubNameFrame = CGRect(x: 0, y: 0, width:frame.width, height:frame.height/3)
        
        clubNameLabel = UILabel(frame: clubNameFrame)
        
        
        clubNameLabel.font = UIFont (name: "HelveticaNeue-UltraLight", size: 30)
        clubNameLabel.textAlignment = .Center
        
              
        let clubImageFrame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
        clubImageView = UIImageView(frame: clubImageFrame)
        clubImageView.contentMode = UIViewContentMode.ScaleToFill
        contentView.addSubview(clubImageView)
        contentView.addSubview(blurView)
        contentView.addSubview(clubNameLabel)
        
        
    }
    

    
}
