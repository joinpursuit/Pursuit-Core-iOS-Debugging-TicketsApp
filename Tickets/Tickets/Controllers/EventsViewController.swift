//
//  ViewController.swift
//  Tickets
//
//  Created by Alex Paul on 1/16/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  private var events = [Event]()
  
  public var isZipcode = true

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    checkForDefaultSearchSettings()
  }
  
  private func checkForDefaultSearchSettings() {
    if let searchKeyword = UserDefaults.standard.object(forKey: "Search Setings") as? String {
      updateRightButtonItem(keyword: searchKeyword)
    } else {
      updateSearchSettings()
    }
  }
  
  private func updateRightButtonItem(keyword: String) {
    for char in keyword {
      if Int(String(char)) == nil {
        isZipcode = false
        break // not a zip code
      }
    }
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: keyword, style: .plain, target: self, action: #selector(updateSearchSettings))
    searchEvents(keyword: keyword)
  }
  
  @objc func updateSearchSettings() {
    let alertController = UIAlertController(title: "Search Settings", message: "Search by city or zip code?", preferredStyle: .alert)
    let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] alert in
      if var textEntered = alertController.textFields?.first?.text {
        if textEntered == "" {
          textEntered = "10023"
          self?.isZipcode = true
        }
        self?.updateRightButtonItem(keyword: textEntered)
        
        // update user defaults with search settings value
        UserDefaults.standard.set(textEntered, forKey: "Search Settings")
      }
    }
    alertController.addAction(submitAction)
    alertController.addTextField { (textfield) in
      textfield.placeholder = "City of Zip code"
      textfield.textAlignment = .center
    }
    present(alertController, animated: true, completion: nil)
  }

  
  private func searchEvents(keyword: String) {
    guard let encodedSearchTerm = keyword.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
      print("percent encoding failed")
      return
    }
    TicketmasterAPIClient.searchEvents(keyword: encodedSearchTerm, isZipcode: isZipcode) { (appError, events) in
      if let appError = appError {
        print(appError.errorMessage())
      } else if let events = events {
        self.events = events
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let indexPath = tableView.indexPathForSelectedRow,
      let _ = segue.destination as? EventDetailViewController else {
        print("indexPath, eventDetailViewController nil")
        return
    }
    let _ = events[indexPath.row]
  }
}

extension EventsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
    let event = events[indexPath.row]
    cell.textLabel?.text = event.name
    cell.detailTextLabel?.text = event.dates.start.dateTime.formatFromISODateString(dateFormat: "MMMM d, yyyy hh:mm a")
    return cell
  }
}

