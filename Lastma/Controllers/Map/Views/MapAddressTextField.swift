//
//  MapAddressTextField.swift
//  Lastma
//
//  Created by Michael Nwani on 3/8/18.
//  Copyright © 2018 Lastma. All rights reserved.
//

import UIKit

class MapAddressTextField: UITextField {
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

//    textField.attributedPlaceholder = NSAttributedString(string: "Enter your mobile number", attributes: [NSAttributedStringKey.font: UIFont(name: "HelveticaNeue", size: CheddahConstants.DIMENS_18)!])
    self.font = UIFont.systemFont(ofSize: Constants.getSize(14.0, 4.0))
    self.attributedPlaceholder = NSAttributedString(string: "Where to?",
                                                    attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
    self.layer.backgroundColor = UIColor.white.cgColor
//      self.layer.borderColor = UIColor.gray.cgColor
//      self.layer.borderWidth = 1
    self.textColor = .black
  }

  override func textRect(forBounds bounds: CGRect) -> CGRect {
    return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
  }

  override func editingRect(forBounds bounds: CGRect) -> CGRect {
    return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
  }
}
