//
//  ClubDetailViewController.swift
//  Locanotion
//
//  Created by William Bertrand on 4/19/15.
//  Copyright (c) 2015 Locanotion. All rights reserved.
//

import Foundation

class ClubDetailViewController : UIViewController{
    var clubName : String!
    
    @IBOutlet var clubNameLabel: UILabel!
    
    @IBOutlet var backButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        clubNameLabel.text = clubName
        backButton.layer.cornerRadius = 3
    }
    
}