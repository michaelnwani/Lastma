//
// Created by Michael Nwani on 3/15/18.
// Copyright (c) 2018 Lastma. All rights reserved.
//

import UIKit
import SnapKit

class MenuItemCell: BaseCell {
  override var isHighlighted: Bool {
    didSet {
      backgroundColor = isHighlighted ? UIColor.black : .white
      nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
//            iconImageView.tintColor = isHighlighted ? UIColor.white : UIColor.darkGray
    }
  }

  var menuItem: MenuItem? {
    didSet {
      nameLabel.text = menuItem?.name.rawValue

//            if let imageName = menuItem?.imageName {
//                iconImageView.image = UIImage(named: imageName)?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
//                iconImageView.tintColor = UIColor.green
//            }
    }
  }

  let nameLabel: UILabel = {
    let label = UILabel()
    label.text = "MenuItem"
    label.textColor = .black
    label.numberOfLines = 0
    label.font = UIFont(name: "Futura-CondensedMedium", size: Constants.MENU_ITEM_CELL_NAME_LABEL_SIZE)
    return label
  }()

  override func setupViews() {
    super.setupViews()

    addSubview(nameLabel)

    nameLabel.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(Constants.MENU_ITEM_CELL_NAME_LABEL_HORIZONTAL_MARGIN)
      make.right.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}
