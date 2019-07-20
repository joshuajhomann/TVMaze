//
//  ImageCache.swift
//  TVMaze
//
//  Created by Joshua Homann on 7/19/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit

class ImageCache {
  enum ImageCacheError: Error {
    case dataConversionFailed
  }
  static let shared = ImageCache()
  private let cache = NSCache<NSURL, UIImage>()
  private init() { }
  func image(for url: URL, completion: @escaping (Result<(UIImage, URL), Error>) -> ()) {
    guard let image = cache.object(forKey: url as NSURL) else {
      URLSession.shared.dataTask(with: url) { [cache] data, _, error in
        guard let image = data.flatMap(UIImage.init(data:)) else {
          return completion(.failure(error ?? ImageCacheError.dataConversionFailed))
        }
        completion(.success((image, url)))
        cache.setObject(image, forKey: url as NSURL)
      }.resume()
      return
    }
    completion(.success((image, url)))
  }
}

extension UIImageView {
  func setImage(from url: URL?) {
    guard let url = url else {
      return
    }
    ImageCache.shared.image(for: url) { [weak self] result in
      switch result {
      case .success(let image, let imageUrl):
        guard url == imageUrl else {
          return
        }
        DispatchQueue.main.async {
          self?.image = image
        }
      case .failure(let error):
        print(error)
        break
      }
    }
  }
}
