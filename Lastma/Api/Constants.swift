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
}
