//
//  ViewController.swift
//  TVMaze
//
//  Created by Joshua Homann on 7/13/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit
import Combine

class ShowViewController: UIViewController {
  @IBOutlet var searchBar: UISearchBar!
  @IBOutlet var tableView: UITableView!
  private let searchTerm: CurrentValueSubject<String, Never> = .init("")
  private enum Section {
    case shows
  }
  private var dataSource: UITableViewDiffableDataSource<Section, Show>?
  private var showSink: Subscribers.Sink<NSDiffableDataSourceSnapshot<Section, Show>, Never>?
  private var shows: [Show] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    dataSource = UITableViewDiffableDataSource<Section, Show>.init(tableView: tableView) { tableView, indexPath, show in
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
      cell.textLabel?.text = show.name
      return cell
    }
    
    showSink = searchTerm
      .debounce(for: .seconds(0.25), scheduler: RunLoop.main)
      .removeDuplicates()
      .flatMap { term -> AnyPublisher<[Show], Never> in
        guard !term.isEmpty else {
          return Just<[Show]>([]).eraseToAnyPublisher()
        }
        return TVMazeService
          .search(query: term)
          .replaceError(with: [])
          .eraseToAnyPublisher()
      }
      .map { [weak self] shows in
        self?.shows = shows
        let snapshot = NSDiffableDataSourceSnapshot<Section, Show>()
        snapshot.appendSections([.shows])
        snapshot.appendItems(shows, toSection: .shows)
        return snapshot
      }
      .subscribe(on: RunLoop.main)
      .sink(receiveValue: { [dataSource] snapshot in
        dataSource?.apply(snapshot, animatingDifferences: true)
      })
  }
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let episodeViewController = (segue.destination as? UINavigationController)?.topViewController as? EpisodeViewController ?? segue.destination as? EpisodeViewController,
      let indexPath = sender as? IndexPath {
      episodeViewController.id.value = shows[indexPath.row].id
      episodeViewController.navigationItem.title = shows[indexPath.row].name
    }
  }
}

extension ShowViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let episodeViewController = (splitViewController?.viewControllers.last as? UINavigationController)?.topViewController as? EpisodeViewController else {
      return performSegue(withIdentifier: String(describing: EpisodeViewController.self), sender: indexPath)
    }
    episodeViewController.id.value = shows[indexPath.row].id
    episodeViewController.navigationItem.title = shows[indexPath.row].name
  }
}

extension ShowViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchTerm.value = searchText
  }
}

