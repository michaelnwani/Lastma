//
// Created by MICHAEL NWANI on 3/25/18.
// Copyright (c) 2018 Lastma. All rights reserved.
//

import UIKit

struct Marker {
  var title: String
  var snippet: String
  var lat: Double
  var lng: Double

  init(title: String,
       snippet: String,
       lat: Double,
       lng: Double) {
    self.title = title
    self.snippet = snippet
    self.lat = lat
    self.lng = lng
  }

  func toJsonDict() -> [String:Any] {
    return ["title": title,
            "snippet": snippet,
            "lat": lat,
            "lng": lng]
  }
}
