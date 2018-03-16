//
// Created by Michael Nwani on 3/15/18.
// Copyright (c) 2018 Lastma. All rights reserved.
//

import UIKit
import SnapKit

class MenuIconCell: BaseCell {
  let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "navBarIcon")
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()

  override func setupViews() {
    super.setupViews()
    addSubview(iconImageView)
    iconImageView.snp.makeConstraints { (make) in
      make.left.equalToSuperview().offset(CheddahConstants.DIMENS_16)
      make.centerY.equalToSuperview()
      make.height.equalTo(CheddahConstants.DIMENS_50)
    }
  }
}
