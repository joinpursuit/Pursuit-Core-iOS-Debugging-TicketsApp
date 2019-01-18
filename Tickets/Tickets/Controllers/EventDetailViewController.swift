//
//  EventDetailViewController.swift
//  Tickets
//
//  Created by Alex Paul on 1/16/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {
  
  @IBOutlet weak var eventImageView: CacheImageView!
  
  public var event: Event?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    updateUI()
  }
  
  private func updateUI() {
    guard let event = event else {
      print("no event passed here")
      return
    }
    guard let imageURL = event.images.first?.url else {
      print("no image url")
      return
    }
    do {
      try eventImageView.setImage(withURLStirng: imageURL.absoluteString,
                                  placeholderImage: UIImage(named: "placeholderImage")!)
    } catch {
      print("setImage error: \(error)")
    }
  }
  
}
