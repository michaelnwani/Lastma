//
// Created by Michael Nwani on 3/15/18.
// Copyright (c) 2018 Lastma. All rights reserved.
//

import UIKit

class MenuItem: NSObject {
  let name: MenuItemName
  let imageName: String

  init(name: MenuItemName, imageName: String) {
    self.name = name
    self.imageName = imageName
  }
}

enum MenuItemName: String {
  case Cancel = "Cancel"
  case Home = "Home"
  case TermsPrivacy = "Privacy Policy"
  case OptOut = "Opt Out"
}

class MenuLauncher: NSObject {
  let blackView = UIView()
  let menuItemCellId = "menuItemCellId"
  let menuIconCellId = "menuIconCellId"
  let cellHeight: CGFloat = Constants.MENU_LAUNCHER_CELL_HEIGHT

  let collectionView: UICollectionView = {
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    collectionViewFlowLayout.scrollDirection = .vertical

    let cv = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
//        cv.backgroundColor = .white
    cv.backgroundColor = UIColor(red: 55.0/255.0, green: 69.0/255.0, blue: 80.0/255.0, alpha: 1.0)
    return cv
  }()

  var menuItems: [MenuItem] = {
    return []
  }()

  var mapViewController: MapViewController? {
    didSet {
      print("mapViewController set")
      menuItems = [ MenuItem(name: .TermsPrivacy, imageName: "navBarIcon"),
                    MenuItem(name: .Cancel, imageName: "navBarIcon") ]
    }
  }

  @objc func showControllerForSetting(menuItem: MenuItem) {
    if self.mapViewController != nil {
      // TODO: create this method
      self.mapViewController?.showControllerForSetting(menuItem:menuItem)
    }
  }

  @objc func showSettings() {
    print("[MenuLauncher] showSettings")
    if let window = UIApplication.shared.keyWindow {
      let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                        action: #selector(handleDismissMainMenu))
      blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
      blackView.addGestureRecognizer(tapGestureRecognizer)

      window.addSubview(blackView)
      window.addSubview(collectionView)

      collectionView.frame = CGRect(x: -window.frame.width,
                                    y: 0,
                                    width: window.frame.width * 0.4,
                                    height: window.frame.height)
      blackView.frame = window.frame
      blackView.alpha = 0

      UIView.animate(withDuration: 0.5,
                     delay: 0,
                     usingSpringWithDamping: 1,
                     initialSpringVelocity: 1,
                     options: .curveEaseOut,
                     animations: {
        self.blackView.alpha = 1
        self.collectionView.frame = CGRect(x: 0, y: 0, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
      }, completion: nil)
    }
    //        let vc = PrivacyPolicyController(withHomeButton: false, withDelegate: self, animateDismiss: false)
    //        self.present(vc, animated: true, completion:nil)
  }

  @objc func handleDismissMainMenu(menuItem: MenuItem) {
    print("handleDismissMainMenu")
    UIView.animate(withDuration: 0.5,
                   delay: 0,
                   usingSpringWithDamping: 1,
                   initialSpringVelocity: 1,
                   options: .curveEaseOut, animations: {

      self.blackView.alpha = 0
      if let window = UIApplication.shared.keyWindow {
        // hides the menu
        self.collectionView.frame = CGRect(x: -window.frame.width,
                                           y: 0,
                                           width: self.collectionView.frame.width,
                                           height: self.collectionView.frame.height)
      }
    }) { (completed: Bool) in
//      if menuItem.name == .OptOut {
//        self.presentOptOutDialog(menuItem: menuItem)
//      } else if menuItem.name != .Cancel {
//        self.showControllerForSetting(menuItem: menuItem)
//      }
    }
  }

  override public init() {
    super.init()
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(MenuItemCell.self, forCellWithReuseIdentifier: menuItemCellId)
    collectionView.register(MenuIconCell.self, forCellWithReuseIdentifier: menuIconCellId)
  }
}

extension MenuLauncher: UICollectionViewDataSource {
  func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return menuItems.count+1
  }

  func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    var menuIconCell: MenuIconCell
    var menuItemCell: MenuItemCell

    if indexPath.row == 0 {
      // different cell configuration?
      menuIconCell = collectionView.dequeueReusableCell(withReuseIdentifier: menuIconCellId, for: indexPath) as! MenuIconCell // downcasting
      return menuIconCell
    } else {
      let menuItem = menuItems[indexPath.row-1]
      menuItemCell = collectionView.dequeueReusableCell(withReuseIdentifier: menuItemCellId, for: indexPath) as! MenuItemCell // downcasting
      menuItemCell.menuItem = menuItem
      return menuItemCell
    }
  }
}

extension MenuLauncher: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  func collectionView (_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       sizeForItemAt indexPath: IndexPath) -> CGSize {
    if indexPath.row == 0 {
      return CGSize(width: collectionView.frame.width, height: Constants.MENU_LAUNCHER_ITEM_SIZE)
    } else {
      return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
  }

  func collectionView (_ collectionView: UICollectionView,
                       layout collectionViewLayout: UICollectionViewLayout,
                       minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return Constants.MENU_LAUNCHER_MINIMUM_LINE_SPACING_FOR_SECTION
  }

  func collectionView (_ collectionView: UICollectionView,
                       didSelectItemAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      UIView.animate(withDuration: 0.5,
                     delay: 0,
                     usingSpringWithDamping: 1,
                     initialSpringVelocity: 1,
                     options: .curveEaseOut,
                     animations: {
        self.blackView.alpha = 0
        if let window = UIApplication.shared.keyWindow {
          // hides the menu
          self.collectionView.frame = CGRect(x: -window.frame.width,
                                             y: 0,
                                             width: self.collectionView.frame.width,
                                             height: self.collectionView.frame.height)
        }
      }, completion: nil)
    } else {
      let menuItem = self.menuItems[indexPath.row-1]
      handleDismissMainMenu(menuItem: menuItem)
    }
  }
}

