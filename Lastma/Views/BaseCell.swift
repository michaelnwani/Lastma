//
// Created by Michael Nwani on 3/15/18.
// Copyright (c) 2018 Lastma. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupViews() {

  }
}
