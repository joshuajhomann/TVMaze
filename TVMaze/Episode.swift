//
//  Episode.swift
//  TVMaze
//
//  Created by Joshua Homann on 7/13/19.
//  Copyright © 2019 com.josh. All rights reserved.
//
import Foundation

struct Season: Hashable {
  let id: Int
  let episodes: [Episode]
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  static func == (lhs: Season, rhs: Season) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - Episode
struct Episode: Codable, Hashable {
  let id: Int
  let url: URL
  let name: String
  let season, number: Int
  let airdate: String
  let runtime: Int
  let image: Image?
  let summary: String

  enum CodingKeys: String, CodingKey {
    case id, url, name, season, number, airdate, runtime, image, summary
  }

  struct Image: Codable {
    let medium, original: URL
  }
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  static func == (lhs: Episode, rhs: Episode) -> Bool {
    lhs.id == rhs.id
  }
}
