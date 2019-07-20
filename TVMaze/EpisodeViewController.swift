//
//  EpisodeViewController.swift
//  TVMaze
//
//  Created by Joshua Homann on 7/13/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit
import Combine

class EpisodeViewController: UIViewController {
  @IBOutlet private var searchBar: UISearchBar!
  @IBOutlet private var collectionView: UICollectionView!
  var id: CurrentValueSubject<Int?, Never> = .init(nil)
  private var seasons: [Season] = []
  private var episodeSink: Any?
  private var dataSource: UICollectionViewDiffableDataSource<Season, Episode>?
  private let searchTerm: CurrentValueSubject<String, Never> = .init("")
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.allowsSelection = true
    navigationItem.leftBarButtonItem =
      splitViewController?.displayModeButtonItem
    navigationItem.leftItemsSupplementBackButton = true
    dataSource = UICollectionViewDiffableDataSource<Season, Episode>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, episode: Episode) -> UICollectionViewCell? in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: EpisodeCollectionViewCell.self), for: indexPath)
      (cell as? EpisodeCollectionViewCell)?.configure(with: episode)
      return cell
    }
    collectionView.dataSource = dataSource

    episodeSink = Publishers
      .CombineLatest(
        id.flatMap { id -> AnyPublisher<[Season], Never> in
          guard let id = id else {
            return Just<[Season]>([]).eraseToAnyPublisher()
          }
          return TVMazeService
            .episode(id: id)
            .replaceError(with: [])
            .eraseToAnyPublisher()
        },
        searchTerm
      )
      .map { (seasons, term) -> [Season] in
        guard !term.isEmpty else {
          return seasons
        }
        return seasons.compactMap { season in
          let episodes = season.episodes.filter { $0.summary.contains(term) }
          return episodes.isEmpty ? nil : Season(id: season.id, episodes: episodes)
        }
      }
      .map { seasons in
        let snapshot = NSDiffableDataSourceSnapshot<Season, Episode>()
        snapshot.appendSections(seasons)
        seasons.forEach { snapshot.appendItems($0.episodes, toSection: $0) }
        return snapshot
      }
      .subscribe(on: RunLoop.main)
      .sink(receiveValue: { [dataSource] snapshot in
        dataSource?.apply(snapshot, animatingDifferences: true)
      })

    collectionView.collectionViewLayout = createLayout()
  }

  func createLayout() -> UICollectionViewLayout {
    let layout = UICollectionViewCompositionalLayout {
      (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in

      let leadingItem = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                           heightDimension: .fractionalHeight(1.0)))
      leadingItem.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45),
                                           heightDimension: .fractionalHeight(0.45)),
        subitems: [leadingItem])
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .continuous

      return section
    }
    return layout
  }


  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? EpisodeDetailViewController,
      let episode = sender as? Episode {
      destination.episode = episode
    }
  }
}

extension EpisodeViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchTerm.value = searchText
  }
}

