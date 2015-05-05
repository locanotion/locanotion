//
//  Constants.swift
//  Locanotion
//
//  Created by William Bertrand on 4/13/15.
//  Copyright (latitude:c) 2015 Locanotion. All rights reserved.
//

import Foundation

//todo: add all locations to an array, then go through each element and set the location
//description to whatever is closest 


//Constants for club location

let NUM_CLUBS = 11
let TERRACE : CLLocation = CLLocation(latitude: 40.347173,longitude: -74.653914)
let TOWER : CLLocation = CLLocation(latitude:40.347688, longitude : -74.653960)
let CANNON : CLLocation = CLLocation(latitude:40.347808, longitude :-74.653345)
let QUAD : CLLocation = CLLocation(latitude:40.348017, longitude : -74.652726)
let IVY : CLLocation = CLLocation(latitude:40.348091, longitude : -74.652179)
let COTTAGE : CLLocation = CLLocation(latitude:40.348217, longitude : -74.651682)
let CAP : CLLocation = CLLocation(latitude:40.348299, longitude : -74.650969)
let CLOISTER : CLLocation = CLLocation(latitude:40.348600, longitude : -74.650534)
let TI : CLLocation = CLLocation(latitude:40.348922, longitude : -74.652270)
let COLONIAL : CLLocation = CLLocation(latitude:40.348845, longitude : -74.652814)
let CHARTER : CLLocation = CLLocation(latitude:40.348759, longitude : -74.650019)
let BOGGLE : CLLocation = CLLocation(latitude:40.344301, longitude : -74.655562)
let CS_BUILDING : CLLocation = CLLocation(latitude:40.350234, longitude : -74.652240)
let WILCOX_DINING : CLLocation = CLLocation(latitude: 40.344809, longitude: -74.656118)
let RADIUS = 0.000435542190839628
let TEST_RADIUS = 0.1


let GLOBAL_ClubLocations : Array<CLLocation> = [CANNON,CAP,CHARTER,CLOISTER,COLONIAL,COTTAGE,IVY,QUAD,TERRACE,TI,TOWER]
let CLUB_NAMES : Array<String> = ["Cannon", "Cap", "Charter", "Cloister", "Colonial","Cottage", "Ivy", "Quad", "Terrace", "Tiger Inn", "Tower"]

let CLUB_DISPLAY_NAMES : Array<String> = ["Cannon", "Cap", "Charter", "Cloister", "Colonial","Cottage", "Ivy", "Quad", "Terrace", "Tiger Inn", "Tower"]

func GET_NEAREST_CLUB() -> String{
    return ""
}

var HISTORY_TONIGHT : Array<String> = Array()


//color of blue for Vole
var VOLE_COLOR = UIColor(hue: 0.546, saturation: 0.58, brightness: 0.87, alpha: 1.0)