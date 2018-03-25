//
// Created by MICHAEL NWANI on 3/25/18.
// Copyright (c) 2018 Lastma. All rights reserved.
//

import UIKit
import SnapKit
import CoreLocation

final class MarkerViewController: UIViewController {
  var currentLocation: CLLocation?
  var lastmaClient: LastmaClient!

  let titleTextField: MarkerTitleTextField = {
    let markerTitleTextField = MarkerTitleTextField()
    return markerTitleTextField
  }()

  let snippetTextField: MarkerSnippetTextField = {
    let markerSnippetTextField = MarkerSnippetTextField()
    return markerSnippetTextField
  }()

  let cancelButton: UIButton = {
    let button = UIButton()
    button.setTitle("Cancel", for: .normal)
    button.backgroundColor = .gray
    button.isUserInteractionEnabled = true
    button.titleLabel?.textColor = .black
    button.titleLabel?.font = UIFont(name: "Futura-CondensedMedium", size: 16)!
    return button
  }()

  let submitButton: UIButton = {
    let button = UIButton()
    button.setTitle("Finish", for: .normal)
    button.backgroundColor = .green
    button.isUserInteractionEnabled = true
    button.titleLabel?.textColor = .white
    button.titleLabel?.font = UIFont(name: "Futura-CondensedMedium", size: 16)!
    return button
  }()

  // MARK: - Initializers & Lifecycle methods
  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    print("[MarkerViewController] viewDidLoad")
    super.viewDidLoad()
    lastmaClient = LastmaClient.shared()
    setupViews()
  }

  func setupViews() {
    view.backgroundColor = .black

    view.addSubview(titleTextField)
    view.addSubview(snippetTextField)
    view.addSubview(cancelButton)
    view.addSubview(submitButton)

    titleTextField.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
      make.right.equalToSuperview().offset(-Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
      make.top.equalToSuperview().offset(Constants.MAP_ADDRESS_TEXT_FIELD_VERTICAL_MARGIN)
      make.height.equalTo(Constants.MAP_ADDRESS_TEXT_FIELD_HEIGHT)
    }

    snippetTextField.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
      make.right.equalToSuperview().offset(-Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
      make.top.equalTo(titleTextField.snp.bottom).offset(20)
      make.height.equalTo(Constants.MAP_ADDRESS_TEXT_FIELD_HEIGHT)
    }

    cancelButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
      make.right.equalToSuperview().offset(-Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
      make.top.equalTo(snippetTextField.snp.bottom).offset(20)
      make.height.equalTo(Constants.MAP_ADDRESS_TEXT_FIELD_HEIGHT)
    }

    submitButton.snp.makeConstraints { make in
      make.left.equalToSuperview().offset(Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
      make.right.equalToSuperview().offset(-Constants.MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN)
      make.top.equalTo(cancelButton.snp.bottom).offset(20)
      make.height.equalTo(Constants.MAP_ADDRESS_TEXT_FIELD_HEIGHT)
    }

    cancelButton.addTarget(self, action: #selector(cancelCreateMarker), for: .touchUpInside)
    submitButton.addTarget(self, action: #selector(createMarker), for: .touchUpInside)
  }

  @objc func cancelCreateMarker() {
    print("[cancelCreateMarker]")
    dismiss(animated: true)
  }

  @objc func createMarker() {
    print("[createMarker]")
    let title = titleTextField.text!
    let snippet = snippetTextField.text!
    let lat = currentLocation!.coordinate.latitude
    let lng = currentLocation!.coordinate.longitude
    let marker = Marker(title: title,
                        snippet: snippet,
                        lat: lat,
                        lng: lng)

    lastmaClient.createMarker(marker)
    let presentingVC = presentingViewController as! MapViewController
    presentingVC.dismissMarkerViewController(newMarker: marker)
//    dismiss(animated: true)
  }
}
