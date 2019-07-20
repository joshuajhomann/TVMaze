//
//  Show.swift
//  TVMaze
//
//  Created by Joshua Homann on 7/13/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import Foundation

// MARK: - ShowResults
struct ShowResults: Codable {
  let score: Double
  let show: Show
}

// MARK: - ShowClass
struct Show: Codable, Hashable {
  let id: Int
  let name: String

  enum CodingKeys: String, CodingKey {
    case id, name
  }
}
