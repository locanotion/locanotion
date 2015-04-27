//
//  ClubLabelAnnotation.swift
//  Locanotion
//
//  Created by William Bertrand on 4/24/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation
import MapKit

class ClubLabelAnnotation : MKAnnotationView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let attendenceLabelFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height / 4)
        let friendAttendeceLabelFrame = CGRect(x: 0, y: attendenceLabelFrame.height, width: frame.width, height: frame.height / 2)
        let attendenceLabel = UILabel(frame: attendenceLabelFrame)
        let friendAttendenceLabel = UILabel(frame: friendAttendeceLabelFrame)
        attendenceLabel.text = "Total Attendence"
        friendAttendenceLabel.text = "Friends: "
        
        
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
