//
//  FriendViewTableCell.swift
//  Locanotion
//
//  Created by William Bertrand on 3/29/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation

class FriendViewTableCell : UITableViewCell {
    @IBOutlet var nameLabel : UILabel!
    @IBOutlet var locLabel : UILabel!
    @IBOutlet var pictureView : UIImageView!
    
    
    override func awakeFromNib() {
        let frame = self.frame
        self.backgroundColor = UIColor.clearColor()
        
        //add blur view for background
        
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        var blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = frame
        self.contentView.addSubview(blurView)
        
    }
    
    
    
}
