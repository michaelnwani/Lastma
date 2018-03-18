//
//  Constants.swift
//  Lastma
//
//  Created by Michael Nwani on 3/9/18.
//  Copyright © 2018 Lastma. All rights reserved.
//

import UIKit
// 320: iPhone SE (L)
// 375: iPhone 6s/7/8/X (XL)
// 414: iPhone 6/6s/7/8 Plus (XXL)
// 768: iPad (5th generation)/ iPad Pro (9.7-inch) (XXXL)
// 1024: iPad Pro (12.9-inch) (XXXXL)
struct Constants {
  static let xLargeDevice: Bool = {
      return UIScreen.main.bounds.width == 375.0
  }()

  static let xxLargeDevice: Bool = {
      return UIScreen.main.bounds.width == 414.0
  }()

  static let xxxLargeDevice: Bool = {
      return UIScreen.main.bounds.width == 768.0
  }()

  static let xxxxLargeDevice: Bool = {
      return UIScreen.main.bounds.width == 1024.0
  }()

  static let SERVER_URL: String = {
    return "http://lastma.herokuapp.com/api/v1/"
  }()

  static func getSize(_ size: CGFloat, _ incrementAmount: CGFloat) -> CGFloat {
    var baseSize = size
    if (xLargeDevice) {
      baseSize += incrementAmount
    } else if (xxLargeDevice) {
      baseSize += (incrementAmount * 2)
    } else if (xxxLargeDevice) {
      baseSize += (incrementAmount * 3)
    } else if (xxxxLargeDevice) {
      baseSize += (incrementAmount * 4)
    }
    return baseSize
  }

  static let MAP_ADDRESS_TEXT_FIELD_VERTICAL_MARGIN: CGFloat = {
    return getSize(80.0, 10.0)
  }()

  static let MAP_ADDRESS_TEXT_FIELD_HEIGHT: CGFloat = {
    return getSize(40.0, 10.0)
  }()

  static let MAP_ADDRESS_TEXT_FIELD_HORIZONTAL_MARGIN: CGFloat = {
    return getSize(26.0, 4.0)
  }()

  static let HAMBURGER_ICON_BUTTON_WIDTH_OR_HEIGHT: CGFloat = {
    return getSize(20.0, 10.0)
  }()

  static let HAMBURGER_ICON_BUTTON_VERTICAL_MARGIN: CGFloat = {
    return getSize(30.0, 10.0)
  }()

  static let MENU_LAUNCHER_CELL_HEIGHT: CGFloat = {
    return getSize(50.0, 10.0)
  }()

  static let MENU_LAUNCHER_ITEM_SIZE: CGFloat = {
    return getSize(100.0, 25.0)
  }()

  static let MENU_LAUNCHER_MINIMUM_LINE_SPACING_FOR_SECTION: CGFloat = {
    return getSize(10.0, 1.0)
  }()

  static let MENU_ITEM_CELL_NAME_LABEL_SIZE: CGFloat = {
    return getSize(20.0, 5.0)
  }()

  static let MENU_ITEM_CELL_NAME_LABEL_HORIZONTAL_MARGIN: CGFloat = {
    return getSize(16.0, 2.0)
  }()
}
