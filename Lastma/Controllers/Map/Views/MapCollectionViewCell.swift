//
// Created by MICHAEL NWANI on 3/24/18.
// Copyright (c) 2018 Lastma. All rights reserved.
//

import UIKit
import SnapKit

class MapCollectionViewCell: UICollectionViewCell {
  let durationLabel: UILabel = {
    let label = UILabel()

    label.text = ""
    label.textColor = .blue // will be changed before cell is displayed
    label.textAlignment = NSTextAlignment.center
    label.font = UIFont(name: "HelveticaNeue-BoldItalic",
                        size: Constants.MAP_COLLECTION_VIEW_CELL_DURATION_LABEL_SIZE)
//        label.font = UIFont(name: "HelveticaNeue-BoldItalic", size: 20.0)
    label.numberOfLines = 0
    return label
  }()

  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupViews() {
    backgroundColor = .white
    addSubview(durationLabel)
    durationLabel.snp.makeConstraints { (make) in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.bottom.equalToSuperview()
    }
  }
}
