//
// Created by Michael Nwani on 3/13/18.
// Copyright (c) 2018 Lastma. All rights reserved.
//

import UIKit
import GoogleMaps

public final class LastmaClient: NSObject {

  private static var sharedLastmaClient: LastmaClient = {
    let lastmaClient = LastmaClient()
    return lastmaClient
  }()

  // MARK: - Initialization
  override private init() {
    print("[LastmaClient] init")
    super.init()
  }

  class func shared() -> LastmaClient {
    return sharedLastmaClient
  }

  func sendGetRequest(withPath path: String,
                      retries: Int,
                      closure: @escaping (_ result: [[String: Any]]?) -> Void
  ) {
    print("sendGetRequest called")
    var request = URLRequest(url: URL(string: Constants.SERVER_URL + path)!)
    request.httpMethod = "GET"

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let response = response as? HTTPURLResponse {
        print("[[Client] sendGetRequest] response.statusCode=\(response.statusCode)")
      }
      guard let data = data else {
        if let error = error {
          print("[[Client] sendGetRequest] \(error); \(error.localizedDescription)")
          // TODO: maybe rework this to only retry if the return value is not 200 OK, etc.
          if retries > 0 {
            let when = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
              print("[[Client] sendGetRequest] recursively calling again.")
              self.sendGetRequest(withPath: path,
                                  retries: (retries-1),
                                  closure: closure)
            })
          }
        }
        return
      }

      if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]], jsonResponse != nil {
        closure(jsonResponse)
      }
    }
    task.resume()
  }

  func sendPostRequest(withPath path: String,
                       withJsonDict jsonDictionary: [String:Any],
                       retries: Int,
                       closure: @escaping (_ result: [[String: Any]]?) -> Void
  ) {
    var request = URLRequest(url: URL(string: Constants.SERVER_URL + path)!)
    let jsonData = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)

    request.httpMethod = "POST"
    request.httpBody = jsonData
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let response = response as? HTTPURLResponse {
        print("[[Client] sendPostRequest] response.statusCode=\(response.statusCode)")
      }
      guard let data = data else {
        if let error = error {
          print("[[Client] sendPostRequest] \(error); \(error.localizedDescription)")
          // TODO: maybe rework this to only retry if the return value is not 200 OK, etc.
          if retries > 0 {
            let when = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: when, execute: {
              print("[[Client] sendPostRequest] recursively calling again.")
              self.sendPostRequest(withPath: path, withJsonDict: jsonDictionary, retries: (retries-1), closure: closure)
            })
          }
        }
        return
      }

      if let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]], jsonResponse != nil {
        closure(jsonResponse)
      }
    }
    task.resume()
  }

  @objc func fetchMarkers(completion: @escaping (_ markerList: [GMSMarker]) -> Void) {
    print("fetchMarkers called")
    sendGetRequest(withPath: "markers", retries: 3) { dictionaries in
      print("dictionaries: ", dictionaries)
      DispatchQueue.main.async {
        var markers = [GMSMarker]()
        for dict in dictionaries! {
          let latitude = dict["latitude"] as! Double
          let longitude = dict["longitude"] as! Double

          let marker = GMSMarker()
          marker.title = dict["title"] as! String
          marker.snippet = dict["snippet"] as! String
          marker.position = CLLocationCoordinate2D(latitude: latitude,
                                                   longitude: longitude)

          markers.append(marker)
        }
        completion(markers)
      }
    }
  }
}
