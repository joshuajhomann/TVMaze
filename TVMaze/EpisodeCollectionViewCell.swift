//
//  EpisodeCollectionViewCell.swift
//  TVMaze
//
//  Created by Joshua Homann on 7/13/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit
import SafariServices

class EpisodeCollectionViewCell: UICollectionViewCell {
  @IBOutlet var imageView: UIImageView!
  @IBOutlet var seasonLabel: UILabel!
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var detailLabel: UILabel!
  private (set) var episode: Episode?
  override func prepareForReuse() {
    super.prepareForReuse()
    contentView.backgroundColor = UIColor.systemBackground
  }
  func configure(with episode: Episode) {
    self.episode = episode
    imageView.setImage(from: episode.image?.medium)
    seasonLabel.text = "Season \(episode.season) Episode \(episode.number)"
    titleLabel.text = episode.name
    detailLabel.text = episode
      .summary
      .replacingOccurrences(of: "<p>", with: "")
      .replacingOccurrences(of: "</p>", with: "")
    let interaction = UIContextMenuInteraction(delegate: self)
    addInteraction(interaction)
  }
}

extension EpisodeCollectionViewCell: UIContextMenuInteractionDelegate {
  func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
    let parent = firstParent(ofType: EpisodeViewController.self)
    let episode = self.episode
    let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions -> UIMenu? in
      let open = UIAction(__title: "Open", image: UIImage(systemName: "globe"), identifier: nil) { action in
        guard let url = episode?.url else {
          return
        }
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .overCurrentContext
        parent?.present(safariViewController, animated: true, completion: nil)
      }
      let detail = UIAction(__title: "Detail", image: UIImage(systemName: "arrow.uturn.right.circle"), identifier: nil) { action in
        parent?.performSegue(withIdentifier: String(describing: EpisodeDetailViewController.self), sender: episode)
      }
      let blue = UIAction(__title: "Blue", image: UIImage(systemName: "paintbrush"), identifier: nil) { action in
        self.contentView.backgroundColor = UIColor(named: "highlight")
      }
      let red = UIAction(__title: "Red", image: UIImage(systemName: "paintbrush.fill"), identifier: nil) { action in
        self.contentView.backgroundColor = UIColor(named: "highlight")
      }
      let highlight = UIMenu(__title: "Highlight", image: UIImage(systemName: "star"), identifier: nil, children:[blue,red])
      return UIMenu(__title: "Menu", image: nil, identifier: nil, children:[open, detail, highlight])
    }
    return configuration
  }
}

extension UIResponder {
  func firstParent<T: UIResponder>(ofType type: T.Type ) -> T? {
    return next as? T ?? next.flatMap { $0.firstParent(ofType: type) }
  }
}
