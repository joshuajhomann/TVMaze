//
//  SplitViewController.swift
//  TVMaze
//
//  Created by Joshua Homann on 7/19/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit

class SplitViewController: UISplitViewController {
  var collapseDetailViewController = true
  override func viewDidLoad() {
    super.viewDidLoad()
    presentsWithGesture = true
    delegate = self
  }
}

extension SplitViewController: UISplitViewControllerDelegate {
  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
    return collapseDetailViewController
  }
}
