//
// Created by MICHAEL NWANI on 3/19/18.
// Copyright (c) 2018 Lastma. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

public final class GoogleClient: NSObject {
  static let DIRECTIONS_BASE_URL  = "https://maps.googleapis.com/maps/api/directions/json?"
  static let ROADS_BASE_URL       = "https://roads.googleapis.com/v1/snapToRoads?path="

  static let DIRECTIONS_API_KEY   = "AIzaSyAU2oCMFcJoG3aA0p2TMLF-EDB2KmAMLJY"
  static let ROADS_API_KEY        = "AIzaSyDSEJpoiFA0dqYEyIkBAHwzdceq-vrIqtU"

  private static var sharedGoogleClient: GoogleClient = {
    let googleClient = GoogleClient()
    return googleClient
  }()

  // MARK: - Initialization
  override private init() {
    print("[GoogleClient] init")
    super.init()
  }

  class func shared() -> GoogleClient {
    return sharedGoogleClient
  }

  @objc func runSnapToRoad(path: String,
                           completion: @escaping (_ data: [String: Any]) -> Void) {
    var stringUrl = "\(GoogleClient.ROADS_BASE_URL)\(path)&interpolate=true&key=\(GoogleClient.ROADS_API_KEY)"
    stringUrl = stringUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    print("[runSnapToRoad] stringUrl:", stringUrl)

    let url = URL(string: stringUrl)!

    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let response = response as? HTTPURLResponse {
        print("[[GoogleClient] runSnapToRoad] response.statusCode=\(response.statusCode)")
      }
      guard let data = data else {
        if let error = error {
          print("[[GoogleClient] runSnapToRoad] \(error); \(error.localizedDescription)")
          // TODO: maybe rework this to only retry if the return value is not 200 OK, etc.

        }
        return
      }
//      print("data:", data)

      if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as! [String: Any], jsonResponse != nil {
        completion(jsonResponse)
      }
    }
    task.resume()
  }

  @objc func getDirections(origin: CLLocationCoordinate2D,
                           destination: CLLocationCoordinate2D,
                           completion: @escaping (_ data: [String: Any]) -> Void) {
    var stringUrl = "\(GoogleClient.DIRECTIONS_BASE_URL)origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&alternatives=true&key=\(GoogleClient.DIRECTIONS_API_KEY)"
    print("[getDirections] stringUrl:", stringUrl)

    let url = URL(string: stringUrl)!

    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let response = response as? HTTPURLResponse {
        print("[[GoogleClient] getDirections] response.statusCode=\(response.statusCode)")
      }
      guard let data = data else {
        if let error = error {
          print("[[GoogleClient] getDirections] \(error); \(error.localizedDescription)")
          // TODO: maybe rework this to only retry if the return value is not 200 OK, etc.

        }
        return
      }
//      print("data:", data)

      if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as! [String: Any], jsonResponse != nil {
        completion(jsonResponse)
      }
    }
    task.resume()
  }
}
