//
//  DetailView.swift
//  TVMaze
//
//  Created by Joshua Homann on 7/19/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit

class EpisodeDetailViewController: UIViewController {
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var seasonLabel: UILabel!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var detailLabel: UILabel!
  var episode: Episode?
  override func viewDidLoad() {
    super.viewDidLoad()
    guard let episode = episode else {
      return
    }
    imageView.setImage(from: episode.image?.original ?? episode.image?.medium)
    seasonLabel.text = "Season \(episode.season) Episode \(episode.number)"
    titleLabel.text = episode.name
    detailLabel.text = episode
      .summary
      .replacingOccurrences(of: "<p>", with: "")
      .replacingOccurrences(of: "</p>", with: "")
  }
}
