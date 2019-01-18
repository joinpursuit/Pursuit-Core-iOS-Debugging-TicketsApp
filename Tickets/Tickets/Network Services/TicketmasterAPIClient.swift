//
//  TicketmasterAPIClient.swift
//  Tickets
//
//  Created by Alex Paul on 1/16/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import Foundation

// https://developer.ticketmaster.com/products-and-docs/apis/discovery-api/v2/#search-events-v2

final class TicketmasterAPIClient {
  private init() {}
  static func searchEvents(keyword: String, isZipcode: Bool, completionHandler: @escaping (AppError?, [Event]?) -> Void) {
    var endpointURLString = ""
    if isZipcode {
      endpointURLString = "https://app.ticketmaster.com/disco very/v2/events.json?apikey=\(SecretKeys.APIKey)&postalCode=\(keyword)&radius=500&unit=miles"
    } else {
      endpointURLString = "https://app.ticketma ster.com/discovery/v2/events.json?apikey=\(SecretKeys.APIKey)&city=\(keyword)&radius=500&unit=miles"
    }
    
    guard let url = URL(string: endpointURLString) else {
      completionHandler(AppError.badURL(endpointURLString), nil)
      return
    }
    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { (data, response, error) in
      if let error = error {
        completionHandler(AppError.networkError(error), nil)
      }
      guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -999
        completionHandler(AppError.badStatusCode("\(statusCode)"), nil)
        return
      }
      if let data = data {
        do {
          let eventData = try JSONDecoder().decode(EventData.self, from: data)
          var events = eventData._embedded.events
          events = events.sorted { $0.dates.start.dateTime.dateFromISODateString() < $1.dates.start.dateTime.dateFromISODateString() }
          completionHandler(nil, eventData._embedded.events)
        } catch {
          completionHandler(AppError.jsonDecodingError(error), nil)
        }
      }
    }
  }
}
