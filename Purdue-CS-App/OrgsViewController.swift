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
    
    func getFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = NSTimeZone.system
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date()) + "T00:00:00.000Z"
    }
    
}

extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.lightGray
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        messageLabel.textColor = UIColor.lightGray
        messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 10).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -10).isActive = true
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

//Calendar link to API
func calendarIDtoAPI(calendar_id: String) -> String {
    let url = "https://www.googleapis.com/calendar/v3/calendars/" + calendar_id + "/events?maxResults=2000&timeMin=" + Date().getFormat() + "&key=" + API.API_KEY
    return url
}

//MARK: - Features ToDo
//Subscribe to Orgs automatically
//Fix notifications for a changed event
//Fix for when a calendar is removed
//Add Social media to resources
//Parse from the different oppurtunity update page. Check for last updated?
//Make URLs hyperlinks
class OrgsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate {
    
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
    var notInitialLoad = false
    
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
                self.notInitialLoad = true
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesIn: range)
                self.tableView.reloadSections(sections as IndexSet, with: .automatic)
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
        
        //Remove all items before today's date
        tableEvents.removeAll (where: { getStartDate(event: $0).timeIntervalSinceNow < Calendar.current.startOfDay(for: Date()).timeIntervalSinceNow })
        
        allResults = tableEvents
        
    }
    
    @objc func refreshScreen(_ control: UIRefreshControl) {
        
        tableEvents.removeAll(keepingCapacity: true)
        
        loadDidView()
        
        for (index, event) in tableEvents.enumerated().reversed() {
            if calendar_ids[event.organization ?? ""] == nil {
                tableEvents.remove(at: index)
            }
        }
        
        control.endRefreshing()
        let range = NSMakeRange(0, self.tableView.numberOfSections)
        let sections = NSIndexSet(indexesIn: range)
        self.tableView.reloadSections(sections as IndexSet, with: .automatic)
        
    }
    
    //TableEvents only keeps selected items.
    override func viewDidAppear(_ animated: Bool) {
        let previousCals = calendar_ids
        calendar_ids = defaults.object(forKey: "OrgsArray") as! [String : String]
        
        if previousCals != calendar_ids {
            
            tableView.isScrollEnabled = false;
            tableView.restore()
            self.myActivityIndicator.startAnimating()
            
            for (calendar_name, id) in calendar_ids  {
                calendars[calendar_name] = calendarIDtoAPI(calendar_id: id)
            }
            
            tableEvents.removeAll(keepingCapacity: true)
            DispatchQueue.global(qos: .background).async {
                
                self.loadDidView()
                
                DispatchQueue.main.async {
                    
                    for (index, event) in self.tableEvents.enumerated().reversed() {
                        if self.calendar_ids[event.organization ?? ""] == nil {
                            self.tableEvents.remove(at: index)
                        }
                    }
                    
                    self.myActivityIndicator.stopAnimating()
                    self.tableView.isScrollEnabled = true;
                    
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesIn: range)
                    self.tableView.reloadSections(sections as IndexSet, with: .automatic)
                    
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
        
        content.title = event.summary ?? "(No Title)"
        content.subtitle = "Starting in 30 minutes at " + dateInput.toString(dateFormat: "h:mm a")
        
        var body = ""
        
        if let location = event.location {
            body += "Location: " + location
        }
        
        if let description = event.description {
            if body.count != 0 {
                body += "\n"
            }
            body += description
        }
        
        content.body = body
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
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.sound, .alert]
        
        var notifGranted = false
        
        let semaphore = DispatchSemaphore(value: 0)
        
        //Prompt for notification access
        center.requestAuthorization(options: options) { (granted, error) in
            semaphore.signal()
            notifGranted = granted
            if error != nil { print (error!) }
        }
        
        semaphore.wait()
        
        //Check if notifications enabled
        center.getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            notifGranted = (settings.alertSetting == .enabled)
        }
        
        center.delegate = self
        
        if notifGranted {
            
            //Save ID
            let buttonRow = sender.tag
            let event = tableEvents[buttonRow]
            
            let eventID = event.id
            let filledImage = UIImage(systemName: "bell.fill")
            let emptyImage = UIImage(systemName: "bell.slash")
            var savedIDs = defaults.object(forKey: "IDsArray") as? [String] ?? [String]()
            
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
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
            
        } else {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            let alert = UIAlertController(title:"Turn on Notifications", message:"To get event notifications. Please allow notifications in Settings.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Ok", style: .default, handler:nil))
            present(alert, animated:true);
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableEvents[indexPath.row].description?.count == nil {
            return 70;
        } else {
            return 126;
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableEvents.count == 0 && notInitialLoad {
            print(notInitialLoad)
            tableView.setEmptyView(title: "No upcoming events.", message: "Tap the '+' icon to add organizations")
        }
        else {
            tableView.restore()
        }
        
        return tableEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell") as! EventCell
        
        let event = tableEvents[indexPath.row]
        
        //Title
        cell.titleLabel.text = event.summary ?? "(No Title)"
        
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
        
        //Location and Organization
        let boldAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!]
        let regularAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 12.0)!]
        
        var orgString = event.organization ?? ""
        if event.location != nil {
            orgString = " | " + (event.organization ?? "")
        }
        
        let boldLocation = NSAttributedString(string: event.location ?? "", attributes: boldAttribute)
        let regularOrgs = NSAttributedString(string: orgString, attributes: regularAttribute)
        let finalString = NSMutableAttributedString()
        finalString.append(boldLocation)
        finalString.append(regularOrgs)
        
        cell.orgLabel.attributedText = finalString
        
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
