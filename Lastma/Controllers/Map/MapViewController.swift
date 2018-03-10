//
//  MapViewController.swift
//  Lastma
//
//  Created by Michael Nwani on 3/7/18.
//  Copyright © 2018 Lastma. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit
//import GooglePlaces

class MapViewController: UIViewController {
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!

    var zoomLevel: Float = 15.0

    // A default location use when location permission is not granted
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.99)

    // Update the map once the user has made their selection.

    let mapAddressTextField: MapAddressTextField = {
        let textField = MapAddressTextField()
        return textField
    }()

    override func loadView() {
        // Create a map.
        setupViews()
        view = mapView

        // Create a marker in the center of the map
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86,
                                                 longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        mapView.delegate = self

        // All GMSMapViews have a GMSBlockingGestureRecognizer by default which block other gestures
        // such as clicking on a text field, so we have to remove it.
//        for gesture in mapView.gestureRecognizers! {
//            print("gesture: \(gesture)")
//            mapView.removeGestureRecognizer(gesture)
//        }
    }

    override func viewDidAppear(_ animated: Bool) {
//        mapAddressTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setupViews() {
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel,
                                              bearing: 30,
                                              viewingAngle: 45.0)

        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.settings.consumesGesturesInView = false
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.addSubview(mapAddressTextField)

        mapAddressTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
            make.right.equalToSuperview().offset(-Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
            make.top.equalToSuperview().offset(Constants.MAP_ADDRESS_TEXT_FIELD_VERTICAL_MARGIN)
            make.height.equalTo(Constants.MAP_ADDRESS_TEXT_FIELD_HEIGHT)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }

    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension MapViewController: GMSMapViewDelegate {
  func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    print("mapView tapped at coordinate")
    print("mapAddressTextField.isEditing: \(mapAddressTextField.isEditing)")
    if (mapAddressTextField.isEditing) {
        mapAddressTextField.endEditing(true)
    }
  }

}

