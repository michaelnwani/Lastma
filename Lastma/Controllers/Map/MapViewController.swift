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
import GooglePlaces

final class MapViewController: UIViewController {
  var placesClient: GMSPlacesClient!
  var lastmaClient: LastmaClient!
  var locationManager = CLLocationManager()
  var currentLocation: CLLocation?
  var mapView: GMSMapView!

  // An array to hold the list of likely places.
  var likelyPlaces: [GMSPlace] = []

  // An array to hold a list of markers from the server.
  var markers: [GMSMarker] = []

  // The currently selected place.
  var selectedPlace: GMSPlace?

  var zoomLevel: Float = 15.0

  // A default location use when location permission is not granted
  let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.99)

  // Update the map once the user has made their selection.

  let mapAddressTextField: MapAddressTextField = {
      let textField = MapAddressTextField()
      return textField
  }()

  let leftBarButton: UIButton = {
    let barButton = UIButton(type: UIButtonType.custom)
    barButton.setImage(UIImage(named: "hamburgerIcon"), for: UIControlState.normal)
    barButton.frame = CGRect(x: 0,
                             y: 0,
                             width: Constants.HAMBURGER_ICON_BUTTON_WIDTH_OR_HEIGHT,
                             height: Constants.HAMBURGER_ICON_BUTTON_WIDTH_OR_HEIGHT)
    return barButton
  }()

  let hamburgerIconButton: UIButton = {
    let barButton = UIButton(type: UIButtonType.custom)
    barButton.setImage(UIImage(named: "hamburgerIcon"), for: UIControlState.normal)
    barButton.frame = CGRect(x: 0,
                             y: 0,
                             width: Constants.HAMBURGER_ICON_BUTTON_WIDTH_OR_HEIGHT,
                             height: Constants.HAMBURGER_ICON_BUTTON_WIDTH_OR_HEIGHT)
    return barButton
  }()

  lazy var menuLauncher: MenuLauncher = {
    let launcher = MenuLauncher()
    launcher.mapViewController = self
    return launcher
  }()

//  init() {
//    super.init(nibName: nil, bundle: nil)
//  }
//
//  required init?(coder aDecoder: NSCoder) {
//    fatalError("init(coder:) has not been implemented")
//  }

  override func loadView() {
    // Create a map.
    setupViews()
    view = mapView

    // Create a marker in the center of the map
//    let marker = GMSMarker()
//    marker.position = CLLocationCoordinate2D(latitude: -33.86,
//                                             longitude: 151.20)
//    marker.title = "Sydney"
//    marker.snippet = "Australia"
//    marker.map = mapView
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

    // Assign current view controller as delegate for GMSMapView
    mapView.delegate = self

    // Assign GMSPlacesClient
    placesClient = GMSPlacesClient.shared()
    lastmaClient = LastmaClient.shared()

    listLikelyPlaces()
    listMarkers()
    hamburgerIconButton.addTarget(self, action: #selector(handleMainMenu), for: .touchUpInside)
    mapAddressTextField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
    // All GMSMapViews have a GMSBlockingGestureRecognizer by default which block other gestures
    // such as clicking on a text field, so we have to remove it.
//        for gesture in mapView.gestureRecognizers! {
//            print("gesture: \(gesture)")
//            mapView.removeGestureRecognizer(gesture)
//        }
  }

  @objc func handleMainMenu() {
    print("handleMainMenu")
    menuLauncher.showSettings()
  }

  @objc func showControllerForSetting(menuItem: MenuItem) {
//    switch menuItem.name {
//    case .OptOut:
//      CheddahUtil.shared().optOutUser()
//    case .TermsPrivacy:
//      let privacyPolicyController = PrivacyPolicyController()
//      privacyPolicyController.navigationItem.title = menuItem.name.rawValue
//      //        privacyPolicyController.view.backgroundColor = .white
//      navigationController?.navigationBar.tintColor = UIColor(red: 0, green: 214.0/255.0, blue: 158.0/255.0, alpha: 1.0)
//      // NSForegroundColorAttributeName changed to NSAttributedStringKey.foregroundColor
//      navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 0, green: 214.0/255.0, blue: 158.0/255.0, alpha: 1.0)]
//      navigationController?.pushViewController(privacyPolicyController, animated: true)
//    default:
//      print("foo")
//    }
  }

  @objc func textFieldDidBeginEditing(sender: UITextField) {
    print("textFieldDidBeginEditing")
    let autocompleteController = GMSAutocompleteViewController()
    autocompleteController.delegate = self
    present(autocompleteController, animated: true, completion: nil)
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

    do {
      if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
        mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
      } else {
        print("Unable to find style.json")
      }
    } catch {
      print("One or more of the map styles failed to load. \(error)")
    }

    mapView.addSubview(hamburgerIconButton)
    mapView.addSubview(mapAddressTextField)

    hamburgerIconButton.snp.makeConstraints { make in
      make.top.equalToSuperview().offset(Constants.HAMBURGER_ICON_BUTTON_VERTICAL_MARGIN)
      make.left.equalToSuperview().offset(Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
    }

    mapAddressTextField.snp.makeConstraints { (make) in
        make.left.equalToSuperview().offset(Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
        make.right.equalToSuperview().offset(-Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
        make.top.equalToSuperview().offset(Constants.MAP_ADDRESS_TEXT_FIELD_VERTICAL_MARGIN)
        make.height.equalTo(Constants.MAP_ADDRESS_TEXT_FIELD_HEIGHT)
    }
  }

  // Populate the array with the list of likely places.
  func listLikelyPlaces() {
    // Clean up from previous sessions.
    likelyPlaces.removeAll()

    placesClient.currentPlace { (placeLikelihoodList: GMSPlaceLikelihoodList?, error: Error?) in
      if let error = error {
        print("error: \(error.localizedDescription)")
        return
      }

      // Get likely places and add to the list.
      if let likelihoodList = placeLikelihoodList {
        for likelihood in likelihoodList.likelihoods {
          let place = likelihood.place
          print("Current Place name \(place.name) at likelihood \(likelihood.likelihood)")
          print("Current Place address \(place.formattedAddress)")
          print("Current Place attributions \(place.attributions)")
          print("Current Place ID \(place.placeID)")
          self.likelyPlaces.append(place)
        }
      }
    }
  }

  // Populate the markers array with the list of markers.
  func listMarkers() {
    // Clean up from previous sessions.
    markers.removeAll()

    lastmaClient.fetchMarkers { markers in
      DispatchQueue.main.async {
        self.markers = markers
        for marker in self.markers {
          marker.map = self.mapView
        }
      }
    }
  }

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
    case .authorizedAlways:
      print("Location status is always OK.")
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
    print("mapView.cameraTargetBounds.northEast:", mapView.cameraTargetBounds?.northEast)
    print("mapView.cameraTargetBounds.southWest:", mapView.cameraTargetBounds?.southWest)
//    mapView.cameraTargetBounds.northEast
//    mapView.cameraTargetBounds.southWest
  }
}

extension MapViewController: GMSAutocompleteViewControllerDelegate {
  // Handle the user's selection
  func viewController (_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    print("Place name: \(place.name)")
    print("Place address: \(place.formattedAddress)")
    print("Place attributions: \(place.attributions)")
    dismiss(animated: true, completion: nil)
  }

  func viewController (_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: Handle the error.
    print("Error: ", error.localizedDescription)
  }

  func wasCancelled (_ viewController: GMSAutocompleteViewController) {
    dismiss(animated: true, completion: nil)
  }

  // Turn the network activity indicator on and off again.
  func didRequestAutocompletePredictions (_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = true
  }

  func didUpdateAutocompletePredictions (_ viewController: GMSAutocompleteViewController) {
    UIApplication.shared.isNetworkActivityIndicatorVisible = false
  }
}

