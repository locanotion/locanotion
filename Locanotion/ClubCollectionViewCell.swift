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
    var clubOpenLabel : UILabel!
    var clubAttendanceLabel : UILabel!
    var clubAttendance : Int!
    var clubImageName : String!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let clubNameFrame = CGRect(x: 0, y: 0, width:frame.width, height:frame.height/3)
        let clubOpenLabelFrame = CGRect(x: 0, y: clubNameFrame.height, width: frame.width, height: frame.height/3)
        let clubAttendanceFrame = CGRect(x: 0, y: clubNameFrame.height + clubOpenLabelFrame.height, width: frame.width, height: frame.height/3)
    
        clubNameLabel = UILabel(frame: clubNameFrame)
        clubOpenLabel = UILabel(frame: clubOpenLabelFrame)
        clubAttendanceLabel = UILabel(frame: clubAttendanceFrame)
        
        
        clubNameLabel.font = UIFont.systemFontOfSize(UIFont.systemFontSize())
        clubNameLabel.textAlignment = .Center
        
        clubOpenLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        clubOpenLabel.textAlignment = .Center
        
        clubAttendanceLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        clubAttendanceLabel.textAlignment = .Center
        
        contentView.addSubview(clubNameLabel)
        contentView.addSubview(clubOpenLabel)
        contentView.addSubview(clubAttendanceLabel)
        
        
    }
    

    
}
