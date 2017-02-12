//
//  PlaceMarker.swift
//  Feed Me
//
//  Created by Sarvesh on 10/17/16.
//  Copyright © 2016 Ron Kliffer. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
class PlaceMarker: GMSMarker {
  let place: GooglePlace
  init(place: GooglePlace) {
    self.place = place
    super.init()
    position = place.coordinate
    icon = UIImage(named: place.placeType+"_pin")
    groundAnchor = CGPoint(x: 0.5, y: 1)
    appearAnimation = kGMSMarkerAnimationPop
  }

}
