//
//  OrgsViewController.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 3/30/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit
import Foundation
import UserNotifications


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
        
        var organization: String?
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

//Calendar link to API
func calendarIDtoAPI(calendar_id: String) -> String {
    let url = "https://www.googleapis.com/calendar/v3/calendars/" + calendar_id + "/events?maxResults=20&key=" + API.API_KEY
    return url
}

class OrgsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var myActivityIndicator: UIActivityIndicatorView!
    
    //List of calendars
    //LEAVE COMMENT FOR TESTING
    //  var calendar_ids: [String: String] = ["Purdue CS": "sodicmhprbq87022es0t74blk8@group.calendar.google.com", "Purdue Hackers": "purduehackers@gmail.com", "CS Events": "256h9v68bnbnponkp0upmfq07s@group.calendar.google.com", "CS Seminars": "t3gdpe5uft0cbfsq9bipl7ofq0@group.calendar.google.com"]
    var calendar_ids = SearchOrgsViewController.selectedCalendars
    var calendars = [String:String]()
    
    var allResults: [CalendarEvents.Items] = []
    
    var tableEvents: [CalendarEvents.Items] = [] //Each event in calendar
    
    let defaults = UserDefaults.standard
    
    var refControl: UIRefreshControl {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshScreen(_:)), for: .valueChanged)
        return refresh
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addSubview(refControl)
        if defaults.object(forKey: "IDArray") == nil {
            defaults.set([String](), forKey: "IDArray")
        }
        
        if defaults.object(forKey: "OrgsArray") == nil {
            defaults.set(calendar_ids, forKey: "OrgsArray")
        } else {
            calendar_ids = defaults.object(forKey: "OrgsArray") as! [String : String]
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 126
        
        for (calendar_name, id) in calendar_ids  {
            calendars[calendar_name] = calendarIDtoAPI(calendar_id: id)
        }
        
        self.myActivityIndicator.startAnimating()
        tableView.isScrollEnabled = false;
        
        DispatchQueue.global(qos: .background).async {
            
            self.loadDidView()
            
            DispatchQueue.main.async {
                self.myActivityIndicator.stopAnimating()
                self.tableView.isScrollEnabled = true;
                self.tableView.reloadData()
            }
        }
        
    }
    
    func loadDidView() {
        
        for (org_name, urlString) in calendars {
            let url = URL(string: urlString)!
            let semaphore = DispatchSemaphore(value: 0)
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        var events = try JSONDecoder().decode(CalendarEvents.self, from: data)
                        
                        for (i, _) in events.items.enumerated() {
                            events.items[i].organization = org_name
                        }
                        
                        self.tableEvents.append(contentsOf: events.items)
                        
                    } catch let error {
                        print(error)
                    }
                }
                semaphore.signal()
            }.resume()
            
            semaphore.wait()
        }
        
        //Sort items by start date
        tableEvents.sort { (left, right) -> Bool in
            return getStartDate(event: left).timeIntervalSinceNow < getStartDate(event: right).timeIntervalSinceNow
        }
        
        //Remove all items more than 24hrs in the past
        //tableEvents.removeAll (where: { getStartDate(event: $0).timeIntervalSinceNow < -86400 })
        
        allResults = tableEvents
        
    }
    
    @objc func refreshScreen(_ control: UIRefreshControl) {
        
        tableEvents.removeAll(keepingCapacity: true)
        
        loadDidView()
        
        for (index, event) in tableEvents.enumerated().reversed() {
            if calendar_ids[event.organization!] == nil {
                tableEvents.remove(at: index)
            }
        }
        
        control.endRefreshing()
        self.tableView.reloadData()
        
    }
    
    //TableEvents only keeps selected items.
    override func viewDidAppear(_ animated: Bool) {
        let previousCals = calendar_ids
        calendar_ids = defaults.object(forKey: "OrgsArray") as! [String : String]
        
        if previousCals != calendar_ids {
            
            tableView.isScrollEnabled = false;
            self.myActivityIndicator.startAnimating()
            
            for (calendar_name, id) in calendar_ids  {
                calendars[calendar_name] = calendarIDtoAPI(calendar_id: id)
            }
            
            tableEvents.removeAll(keepingCapacity: true)
            DispatchQueue.global(qos: .background).async {
                
                self.loadDidView()
                
                DispatchQueue.main.async {
                    
                    for (index, event) in self.tableEvents.enumerated().reversed() {
                        if self.calendar_ids[event.organization!] == nil {
                            self.tableEvents.remove(at: index)
                        }
                    }
                    
                    self.myActivityIndicator.stopAnimating()
                    self.tableView.isScrollEnabled = true;
                    
                    self.tableView.reloadData()
                    
                }
            }
            
        }
    }
    
    func getStartDate(event: CalendarEvents.Items) -> Date {
        
        if event.start.dateTime != nil {
            return convertToDateTime(dateString: event.start.dateTime!)
        } else {
            return convertToDate(dateString: event.start.date!)
        }
        
    }
    
    func getEndDate(event: CalendarEvents.Items) -> Date {
        
        if event.end.dateTime != nil {
            return convertToDateTime(dateString: event.end.dateTime!)
        } else {
            return convertToDate(dateString: event.end.date!)
        }
        
    }
    
    func setupNotification(dateInput: Date, event: CalendarEvents.Items) {
        
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        
        content.title = event.summary ?? "No Title"
        content.subtitle = "Starting in 30 minutes"
        content.body = "Location: " + (event.location ?? "") + "\n" + (event.description ?? "")
        content.sound = UNNotificationSound.default
        content.threadIdentifier = "local-notifications temp"
        
        let timeInterval = dateInput.timeIntervalSinceNow
        
        if timeInterval > 0 {
            
            let date = Date(timeIntervalSinceNow: timeInterval - 1800)
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: event.id, content: content, trigger: trigger)
            
            center.add(request) { (error) in
                if error != nil {
                    print(error!)
                }
            }
            
        }
        
        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
    }
    
    func convertToDateTime(dateString: String) -> Date {
        
        //Convert Input
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone.system
        
        let date = dateFormatter.date(from:dateString)!
        
        return date
        
    }
    
    func convertToDate(dateString: String) -> Date {
        
        //Convert Input
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let date = dateFormatter.date(from:dateString)!
        
        return date
    }
    
    //Handle Bell Icon
    @objc func bellClicked(sender:UIButton) {
        
        //Save ID
        let buttonRow = sender.tag
        let event = tableEvents[buttonRow]
        
        let eventID = event.id
        let filledImage = UIImage(systemName: "bell.fill")
        let emptyImage = UIImage(systemName: "bell.slash")
        var savedIDs = defaults.object(forKey: "IDsArray") as? [String] ?? [String]()
        
        if let index = savedIDs.firstIndex(of: eventID) {
            //Remove event notification
            savedIDs.remove(at: index)
            sender.setImage(emptyImage, for: .normal)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [eventID])
        } else {
            //Set event notification
            savedIDs.append(eventID)
            sender.setImage(filledImage, for: .normal)
            
            setupNotification(dateInput: getStartDate(event: event), event: event)
            
        }
        
        defaults.set(savedIDs, forKey: "IDsArray")
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableEvents[indexPath.row].description?.count == nil {
            return 70;
        } else {
            return 126;
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        
        let event = tableEvents[indexPath.row]
        
        //Title
        cell.titleLabel.text = event.summary
        
        //Date and Time
        if event.start.dateTime != nil {
            
            let startDateTime = convertToDateTime(dateString: event.start.dateTime!)
            let endDateTime = convertToDateTime(dateString: event.end.dateTime!)
            
            let startTime = startDateTime.toString(dateFormat: "h:mm a")
            let endTime = endDateTime.toString(dateFormat: "h:mm a")
            
            cell.timeLabel.text = startTime + " - " + endTime
            cell.dateLabel.text = startDateTime.toString(dateFormat: "E, MMM d, yyyy")
            
        } else {
            cell.timeLabel.text = "All Day"
            
            let startDate = convertToDate(dateString: event.start.date!)
            cell.dateLabel.text = startDate.toString(dateFormat: "E, MMM d, yyyy")
        }
        
        //Description
        cell.descriptionLabel.text = event.description
        
        //Organization
        cell.orgLabel.text = event.organization
        
        //Notification Bell setup
        let eventID = event.id
        let filledImage = UIImage(systemName: "bell.fill")
        let emptyImage = UIImage(systemName: "bell.slash")
        let savedIDs = defaults.object(forKey: "IDsArray") as? [String] ?? [String]()
        
        if savedIDs.firstIndex(of: eventID) != nil {
            //Notification scheduled
            cell.bellButton.setImage(filledImage, for: .normal)
            setupNotification(dateInput: getStartDate(event: event), event: event)
        } else {
            //Bell icon not tapped
            cell.bellButton.setImage(emptyImage, for: .normal)
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [event.id])
        }
        
        cell.bellButton.tag = indexPath.row
        cell.bellButton.addTarget(self, action: #selector(bellClicked(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    
}
