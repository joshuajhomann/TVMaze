//
//  TVMazeService.swift
//  TVMaze
//
//  Created by Joshua Homann on 7/13/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import Foundation
import Combine

enum TVMazeService {
  private enum Constant {
    static let episodesUrl = "http://api.tvmaze.com/shows/:id/episodes"
    static let showUrl = "http://api.tvmaze.com/search/shows"
  }
  static func search(query: String) -> AnyPublisher<[Show], Error> {
    var components = URLComponents(url: URL(string: Constant.showUrl)!, resolvingAgainstBaseURL: false)
    components?.queryItems = [URLQueryItem(name: "q", value: query)]
    return URLSession
    .shared
    .dataTaskPublisher(for: components!.url!)
    .map(\.data)
    .decode(type: [ShowResults].self, decoder: JSONDecoder())
    .map { $0.map { $0.show } }
    .eraseToAnyPublisher()
  }
  static func episode(id: Int) -> AnyPublisher<[Season], Error> {
    let episodesUrl = URL(string: Constant.episodesUrl.replacingOccurrences(of: ":id", with: "\(id)"))!
    return URLSession
      .shared
      .dataTaskPublisher(for: episodesUrl)
      .map(\.data)
      .decode(type: [Episode].self, decoder: JSONDecoder())
      .map {
        let grouped = Dictionary(grouping: $0, by: { $0.season })
        return grouped
          .keys
          .sorted()
          .compactMap { Season(id: $0, episodes: grouped[$0] ?? []) }
      }
      .eraseToAnyPublisher()

  }
}
