//
//  MapViewController.swift
//  Lastma
//
//  Created by Michael Nwani on 3/7/18.
//  Copyright © 2018 Lastma. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import SnapKit
import GooglePlaces

final class MapViewController: UIViewController {
  var placesClient: GMSPlacesClient!
  var lastmaClient: LastmaClient!
  var googleClient: GoogleClient!
  var locationManager = CLLocationManager()
  var currentLocation: CLLocation?
  var mapView: GMSMapView!
  // An array to hold the list of likely places.
  var likelyPlaces: [GMSPlace] = []
  // An array to hold a list of markers from the server.
  var markers: [GMSMarker] = []
  // holds polylines created in processSnapToRoads()
  var polylines: [GMSPolyline] = []
  var polylineDurations: [String] = []
  // The currently selected place.
  var selectedPlace: GMSPlace?
  var zoomLevel: Float = 15.0
  // A default location use when location permission is not granted
  let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.99)
  var polylineColors: [UIColor] = [.green, .blue, .purple, .yellow, .red]
  var polylineStrokeWidthList: [CGFloat] = [8, 6, 6, 6, 6]

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

  lazy var collectionView: UICollectionView = {
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    collectionViewFlowLayout.scrollDirection = .horizontal
    collectionViewFlowLayout.minimumLineSpacing = 0

    let collectionView = UICollectionView(frame: .zero,
                                          collectionViewLayout: collectionViewFlowLayout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.isScrollEnabled = false
    collectionView.isPagingEnabled = false
    collectionView.backgroundColor = .white
//    collectionView.isHidden = true
    return collectionView
  }()

  let advertisementView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0, alpha: 0.5)
//    view.alpha = 0

    let labelText = UILabel()
    labelText.textColor = .green
    labelText.text = "This is an advertisement."
    labelText.font = UIFont.systemFont(ofSize: Constants.getSize(16.0, 4.0))

    view.addSubview(labelText)
    labelText.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }

    return view
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
    googleClient = GoogleClient.shared()

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
    switch menuItem.name {
    case .PlanADrive:
      for polyline in polylines {
        polyline.map = nil
      }
      polylines.removeAll()
      polylineDurations.removeAll()
      if !collectionView.isHidden {
        collectionView.isHidden = true
      }
      if mapAddressTextField.isHidden {
        mapAddressTextField.isHidden = false
      }
      let camera = GMSCameraPosition.camera(withLatitude: currentLocation!.coordinate.latitude,
                                            longitude: currentLocation!.coordinate.longitude,
                                            zoom: zoomLevel)
      mapView.animate(to: camera)
    default:
      return
    }
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

    mapView = GMSMapView.map(withFrame: .zero,
                             camera: camera)
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
    mapView.addSubview(advertisementView)
    collectionView.isHidden = true
    mapView.addSubview(collectionView)
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

    collectionView.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(Constants.MAP_COLLECTION_VIEW_CELL_HORIZONTAL_MARGIN)
      make.right.equalToSuperview().offset(-Constants.MAP_COLLECTION_VIEW_CELL_HORIZONTAL_MARGIN)
      make.top.equalToSuperview().offset(Constants.MAP_COLLECTION_VIEW_CELL_VERTICAL_MARGIN)
      make.height.equalTo(Constants.MAP_COLLECTION_VIEW_HEIGHT)
    }

    advertisementView.snp.makeConstraints { make in
      make.left.equalToSuperview()
      make.right.equalToSuperview()
      make.bottom.equalToSuperview()
      make.height.equalTo(60)
    }
    collectionView.register(MapCollectionViewCell.self,
                            forCellWithReuseIdentifier: "\(MapCollectionViewCell.self)")
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
//          print("Current Place name \(place.name) at likelihood \(likelihood.likelihood)")
//          print("Current Place address \(place.formattedAddress)")
//          print("Current Place attributions \(place.attributions)")
//          print("Current Place ID \(place.placeID)")
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

  func processGetDirections(data: [String: Any]) {
//    print("processGetDirections: ", data)
    // 1: make screen zoom to cover new northEast/southWest bounds
    polylines.removeAll()
    polylineDurations.removeAll()

    var routes = data["routes"] as! [[String: Any]]
    routes = routes.sorted { dictionary, dictionary1 in
      let legs = dictionary["legs"] as! [[String: Any]]
      let duration = legs.first!["duration"] as! [String:Any]
      let durationInSeconds = duration["value"] as! Int

      let legs1 = dictionary1["legs"] as! [[String: Any]]
      let duration1 = legs1.first!["duration"] as! [String:Any]
      let durationInSeconds1 = duration1["value"] as! Int

      return durationInSeconds < durationInSeconds1
    }

    var northEastCoords: CLLocationCoordinate2D?
    var southWestCoords: CLLocationCoordinate2D?

    // each route will have its own polyline
    for index in stride(from: routes.count-1, through: 0, by: -1) {
      print("index: ", index)
      let route = routes[index]
      let bounds = route["bounds"] as! [String: Any]
      let northEast = bounds["northeast"] as! [String: Any]
      let southWest = bounds["southwest"] as! [String: Any]
      let legs = route["legs"] as! [[String: Any]]
      let duration = legs.first!["duration"] as! [String:Any]
      let durationText = duration["text"] as! String
      polylineDurations.insert(durationText, at: 0)

      let steps = legs.first!["steps"] as! [[String:Any]]

      // keep an array of durations
      // keep track of the slowest and the fastest in a loop, color the fastest green
      // and the slowest red
//      print("route: ", route)
//      print("bounds: ", bounds)
//      print("northEast: ", northEast)
//      print("southWest: ", southWest)
//      print("number of steps: ", steps.count)

      var pathCoordinates = ""
      for step in steps {
        let startLocation = step["start_location"] as! [String: Any]
        let endLocation = step["end_location"] as! [String: Any]
        pathCoordinates += "\(startLocation["lat"]!),\(startLocation["lng"]!)|\(endLocation["lat"]!),\(endLocation["lng"]!)|"
      }
      pathCoordinates.removeLast()
//      print("pathCoordinates: ", pathCoordinates)

      if northEastCoords == nil {
        northEastCoords = CLLocationCoordinate2D(latitude: northEast["lat"] as! Double,
                                                 longitude: northEast["lng"] as! Double)

        southWestCoords = CLLocationCoordinate2D(latitude: southWest["lat"] as! Double,
                                                 longitude: southWest["lng"] as! Double)
      } else {
        let northEastLat = northEast["lat"] as! Double
        let northEastLng = northEast["lng"] as! Double
        let southWestLat = southWest["lat"] as! Double
        let southWestLng = southWest["lng"] as! Double
        // not perfect but should work for now
        if (northEastLat.magnitude > northEastCoords!.latitude.magnitude) {
          northEastCoords = CLLocationCoordinate2D(latitude: northEastLat,
                                                   longitude: northEastLng)

          southWestCoords = CLLocationCoordinate2D(latitude: southWestLat,
                                                   longitude: southWestLng)
        }
      }

      let polylineColor = self.polylineColors[index]
      print("index: \(index), durationText: \(durationText), polylineColor: \(polylineColor)")
      let polylineStrokeWidth = self.polylineStrokeWidthList[index]

      googleClient.runSnapToRoad(path: pathCoordinates) { dictionary in
        self.processSnapToRoads(data: dictionary,
                                polylineColor: polylineColor,
                                polylineStrokeWidth: polylineStrokeWidth)
      }
    }

    let gmsCoordinateBounds = GMSCoordinateBounds(coordinate: northEastCoords!,
                                                  coordinate: southWestCoords!)

    let update = GMSCameraUpdate.fit(gmsCoordinateBounds)
    DispatchQueue.main.async {
      self.mapView.animate(with: update)
      self.zoomLevel = self.mapView.camera.zoom
    }
  }
  // Speed limit information is only available to Roads API Premium Plan members
  // and even then it wouldn't be reliable for our purposes.
  func processSnapToRoads(data: [String: Any],
                          polylineColor: UIColor,
                          polylineStrokeWidth: CGFloat) {
    let snappedPoints = data["snappedPoints"] as! [[String:Any]]
    let mutablePath = GMSMutablePath()
    for snappedPoint in snappedPoints {
      let location = snappedPoint["location"] as! [String:Any]
      let coord = CLLocationCoordinate2DMake(location["latitude"] as! Double, location["longitude"] as! Double)
      mutablePath.add(coord)
    }
    print("mutablePath", mutablePath)
    let polyline = GMSPolyline(path: mutablePath)
    polyline.strokeColor = polylineColor
    polyline.strokeWidth =  polylineStrokeWidth// default is 1
    polylines.append(polyline)
    print("[processSnapToRoads] polylines.count:", polylines.count)

    DispatchQueue.main.async {
      polyline.map = self.mapView
      if !self.mapAddressTextField.isHidden {
        self.mapAddressTextField.isHidden = true
      }
      if self.collectionView.isHidden {
        self.collectionView.isHidden = false
      }
      self.collectionView.reloadData()
    }
  }
}

// Delegates to handle events for the location manager.
extension MapViewController: CLLocationManagerDelegate {
  // Handle incoming location events.
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let location: CLLocation = locations.last!
    print("Location: \(location)")
    currentLocation = location
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
  }

  func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    print("mapView long pressed at coordinate")
    let markerViewController = MarkerViewController()
    markerViewController.currentLocation = self.currentLocation
    self.present(markerViewController, animated: true)
  }

  func dismissMarkerViewController(newMarker: Marker) {
    print("[dismissMarkerViewController]")
    presentedViewController?.dismiss(animated: true) {
      let coords = CLLocationCoordinate2D(latitude: newMarker.lat,
                                          longitude: newMarker.lng)
      let marker = GMSMarker(position: coords)
      marker.title = newMarker.title
      marker.snippet = newMarker.snippet
      DispatchQueue.main.async { () -> Void in
        marker.map = self.mapView
        self.markers.append(marker)
      }
    }
  }
}

extension MapViewController: GMSAutocompleteViewControllerDelegate {
  // Handle the user's selection (CLLocationCoordinate2D object)
  func viewController (_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    print("Place name: \(place.name)")
    print("Place address: \(place.formattedAddress)")
    print("Place coordinate: \(place.coordinate)")
    dismiss(animated: true, completion: nil)

    // run snap to roads to get a clean GPS trail from user's current location
    // to the location specified below

    // 1) take the user's current location and where they want to go
    // 2) query the distance API with that information to get back the
    // 'steps' that will get them there.

    // 3) take the coordinates of those steps and query the Roads API
    // with that information to get back a list of smoothed-out coordinates
    // 4) create a polyline/waypoint(?) with those coordinates
    googleClient.getDirections(origin: currentLocation!.coordinate, destination: place.coordinate) { dictionary in
      self.processGetDirections(data: dictionary)
    }
//    googleClient.runSnapToRoad(location: place.coordinate)
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

extension MapViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    print("[UICollectionViewDataSource] polylines.count: ", polylines.count)
    return polylines.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(MapCollectionViewCell.self)", for: indexPath) as! MapCollectionViewCell
    let durationLabelText = polylineDurations[indexPath.row]
    let durationLabelTextColor = polylineColors[indexPath.row]
    print("[UICollectionViewDataSource] durationLabelText: ", durationLabelText)
    print("[UICollectionViewDataSource] durationLabelTextColor: ", durationLabelTextColor)
    cell.durationLabel.text = durationLabelText
    cell.durationLabel.textColor = durationLabelTextColor
    return cell
  }
}

extension MapViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {

    let cellWidth:CGFloat = collectionView.frame.width / CGFloat(polylines.count)
    print("[UICollectionViewDelegate] cellWidth: ", cellWidth)
    return CGSize(width: cellWidth, height: collectionView.frame.height)
  }
}
