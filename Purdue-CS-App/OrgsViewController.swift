//
//  OrgsViewController.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 3/30/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit
import Foundation

struct CalendarEvents: Decodable {
    
    struct Items: Decodable {
        let id: String
        let summary: String? //Title
        let description: String?
        let location: String?
        
        struct Start: Decodable {
            let dateTime: String?
            let date: String?
        }
        struct End: Decodable {
            let dateTime: String?
            let date: String?
        }
        
        let start: Start
        let end: End
    }
    
    var items: [Items]
    
}

class OrgsViewController: UIViewController {
    
    var calendars = ["Purdue CS" : "https://www.googleapis.com/calendar/v3/calendars/sodicmhprbq87022es0t74blk8@group.calendar.google.com/events?maxResults=15&key=AIzaSyCP_s1sWWfoUpEVKUHjZoGVyAgCjNr1Ghw"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tableEvents: [CalendarEvents.Items]? //Each event in calendar
        
        let url = URL(string: calendars["Purdue CS"]!)!

        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let events = try JSONDecoder().decode(CalendarEvents.self, from: data)
                    tableEvents = events.items
                } catch let error {
                    print(error)
                }
            }
            semaphore.signal()
        }.resume()
        
        semaphore.wait()
        
        for event in tableEvents! {
            print(event.summary!)
        }
        
    }
    
    func convertToDateTime(dateString: String) -> Date {
        let isoDate = dateString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from:isoDate)!
        return date
    }
    
    
}
