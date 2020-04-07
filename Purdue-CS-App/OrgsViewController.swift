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

extension Date {
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

class OrgsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var calendars = ["Purdue CS" : "https://www.googleapis.com/calendar/v3/calendars/sodicmhprbq87022es0t74blk8@group.calendar.google.com/events?maxResults=15&key=AIzaSyCP_s1sWWfoUpEVKUHjZoGVyAgCjNr1Ghw"]
    var tableEvents: [CalendarEvents.Items]? //Each event in calendar
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 193
        
        let url = URL(string: calendars["Purdue CS"]!)!

        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let events = try JSONDecoder().decode(CalendarEvents.self, from: data)
                    self.tableEvents = events.items
                } catch let error {
                    print(error)
                }
            }
            semaphore.signal()
        }.resume()
        
        semaphore.wait()
        
    }
    
    
    
    func convertToDateTime(dateString: String) -> (String, String) {
        
        //Convert Input
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.system
        
        let date = dateFormatter.date(from:dateString)!
        
        let stringTime = date.toString(dateFormat: "h:mm a")
        let stringDate = date.toString(dateFormat: "E, MMM d, yyyy")
        
        return (stringTime, stringDate)
    }
    
    func convertToDate(dateString: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from:dateString)!
        
        let resultString = date.toString(dateFormat: "E, MMM d, yyyy")
        
        return resultString
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableEvents?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        
        let event = tableEvents![indexPath.row]
        
        //Title
        cell.titleLabel.text = event.summary
    
        
        //Date and Time
        if event.start.dateTime != nil {
            let startTime = convertToDateTime(dateString: event.start.dateTime!).0
            let endTime = convertToDateTime(dateString: event.end.dateTime!).0
            cell.timeLabel.text = startTime + " - " + endTime
            
            cell.dateLabel.text = convertToDateTime(dateString: event.start.dateTime!).1
        } else {
            cell.timeLabel.text = "All Day"
            cell.dateLabel.text = convertToDate(dateString: event.start.date!)
        }
        
        //Description
        cell.descriptionLabel.text = event.description
        
        //Organization
        cell.orgLabel.text = "Purdue Hackers"
        
        return cell
    }
    
    
}
