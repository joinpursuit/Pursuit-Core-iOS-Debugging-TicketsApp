//
//  CacheImageView.swift
//  Tickets
//
//  Created by Alex Paul on 1/16/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit

class CacheImageView: UIImageView {
  
  private var cache = NSCache<NSString, UIImage>()
  private var imageViewURLString = ""
  
  private lazy var activityIndicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: .whiteLarge)
    indicator.hidesWhenStopped = true
    indicator.color = .orange
    return indicator
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  private func commonInit() {
    addSubview(activityIndicator)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }
  
  public func setImage(withURLStirng urlString: String, placeholderImage: UIImage) throws {
    image = placeholderImage
    if let cacheImage = cache.object(forKey: urlString as NSString) {
      image = cacheImage
    } else {
      imageViewURLString = urlString
      activityIndicator.startAnimating()
      guard let url = URL(string: urlString) else {
        throw AppError.badURL("bad image url: \(urlString)")
      }
      let request = URLRequest(url: url)
      let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
          print("network error: \(error)")
        }
        guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
          print("setImage - bad status code")
          return
        }
        if let data = data {
          if self.imageViewURLString == urlString {
            DispatchQueue.global(qos: .userInitiated).async {
              if let fetchedImage = UIImage(data: data) {
                self.cache.setObject(fetchedImage, forKey: urlString as NSString)
                DispatchQueue.main.async {
                  self.image = fetchedImage
                }
              }
            }
          }
        }
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
        }
      }
      task.resume()
    }
  }
}
