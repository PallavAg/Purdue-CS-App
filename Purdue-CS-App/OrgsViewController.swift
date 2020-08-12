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
import FirebaseDatabase

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
        
        let start: Start?
        let end: End?
        
        let status: String
        
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
        //self.isScrollEnabled = true;
    }
}

// MARK: - Features ToDo
// 1. Improve pull to refresh of events
// 2. Pull to refresh on 'no events' page of table
// 3. 'No upcoming events' to 'No orgs subscribed'
// 4. Fix notification bell error
// 5. Add loader to orgs page
// 6. Subscribe to all orgs by default
// 7. Fix for cancelled events and pull to refresh bug
// 8. Fix for when a calendar is removed
// 9. Fix notifications for a changed event
// 10. Fix Launch Screen Image
// 11. Make org titles easier to see. 2 lines if location exists. Else just org.
// 12. Improved Loading UI for Events Page

// Remove the sempahores for loading JSON data
// Empty announcement should say 'no items'
// Make URLs hyperlinks. HTML parser?
// Fix broken labs
// Add Social media and USB to resources
// Support for repeating and multi-day filtered by end instead of start
// Parse from the different oppurtunity update page. Check for last updated?
// Improve loading of announcements page
class OrgsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var calendar_ids = SearchOrgsViewController.selectedCalendars
    var calendars = [String:String]()
    
    var allResults: [CalendarEvents.Items] = []
    
    var tableEvents: [CalendarEvents.Items] = [] //Each event in calendar
    
    let defaults = UserDefaults.standard
    var notInitialLoad = false
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 126
        tableView.tableFooterView = UIView()
        
        // Remove notificatons since they will be setup in the tableView.
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Setup Pull to Refresh
        refreshControl.addTarget(self, action:  #selector(refreshScreen), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        showActivityIndicator("Loading Events")
        tableView.isScrollEnabled = false;
        
        if defaults.object(forKey: "IDArray") == nil {
            defaults.set([String](), forKey: "IDArray")
        }
        
        if defaults.object(forKey: "OrgsArray") == nil {
            
            var ref: DatabaseReference?
            
            ref = Database.database().reference() // Init database reference
            let myRef = ref?.child("calendar_ids")
            
            myRef?.observeSingleEvent(of: .value, with: { [self] (snapshot) in
                //Handle data not found
                if !snapshot.exists() {
                    return
                }
                
                //Data found
                calendar_ids = snapshot.value as? [String: String] ?? [String: String]()
                
                SearchOrgsViewController.selectedCalendars = calendar_ids
                defaults.set(SearchOrgsViewController.selectedCalendars, forKey: "OrgsArray")
                
                initializeCalendarArray()
            })
            
        } else {
            calendar_ids = defaults.object(forKey: "OrgsArray") as? [String : String] ?? [String : String]()
            initializeCalendarArray()
        }
        
    }
    
    //Calendar link to API
    func calendarIDtoAPI(calendar_id: String) -> String {
        let url = "https://www.googleapis.com/calendar/v3/calendars/" + calendar_id + "/events?maxResults=2000&timeMin=" + Date().getFormat() + "&key=" + API.API_KEY
        return url
    }
    
    // Load all events onto the screen
    func initializeCalendarArray() {

        for (calendar_name, id) in calendar_ids  {
            calendars[calendar_name] = calendarIDtoAPI(calendar_id: id)
        }
        
        DispatchQueue.global(qos: .background).async {
            
            self.loadDidView()
            
            DispatchQueue.main.async {
                self.removeActivityIndicator()
                self.tableView.isScrollEnabled = true;
                self.notInitialLoad = true
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesIn: range)
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                self.tableView.reloadSections(sections as IndexSet, with: .automatic)
            }
        }
    }
    
    func loadDidView(toRemoveCount: Int? = 0) {
        
        for (org_name, urlString) in calendars {
            let url = URL(string: urlString)!
            let semaphore = DispatchSemaphore(value: 0)
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    do {
                        var events = try JSONDecoder().decode(CalendarEvents.self, from: data)
                        
                        for (i, _) in events.items.enumerated().reversed() {
                            if events.items[i].status == "cancelled" {
                                events.items.remove(at: i)
                            } else {
                                events.items[i].organization = org_name
                            }
                        }
                        
                        self.tableEvents.append(contentsOf: events.items)
                        
                    } catch let error {
                        print("Error with \(org_name) in parsing \(urlString) with Error:\n\(error)")
                    }
                }
                semaphore.signal()
            }.resume()
            
            semaphore.wait()
        }
        
        tableEvents.removeSubrange(0..<(toRemoveCount ?? 0))
        
        //Sort items by start date
        tableEvents.sort { (left, right) -> Bool in
            return getStartDate(event: left).timeIntervalSinceNow < getStartDate(event: right).timeIntervalSinceNow
        }
        
        //Remove all items before today's date
        tableEvents.removeAll (where: { getStartDate(event: $0).timeIntervalSinceNow < Calendar.current.startOfDay(for: Date()).timeIntervalSinceNow })
        
        allResults = tableEvents
        
    }
    
    @objc func refreshScreen() {
        
        DispatchQueue.global(qos: .background).async { [self] in
            
            loadDidView(toRemoveCount: tableEvents.count)
            
            for (index, event) in tableEvents.enumerated().reversed() {
                if calendar_ids[event.organization ?? ""] == nil {
                    tableEvents.remove(at: index)
                }
            }
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
                let range = NSMakeRange(0, self.tableView.numberOfSections)
                let sections = NSIndexSet(indexesIn: range)
                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                self.tableView.reloadSections(sections as IndexSet, with: .automatic)
            }
        }
        
    }
    
    //TableEvents only keeps selected items.
    override func viewDidAppear(_ animated: Bool) {
        let previousCals = calendar_ids
        calendar_ids = defaults.object(forKey: "OrgsArray") as? [String : String] ?? [String : String]()
        
        if previousCals != calendar_ids {
            
            tableView.isScrollEnabled = false;
            tableView.restore()
            showActivityIndicator("Loading Events")
            
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
                    
                    self.removeActivityIndicator()
                    self.tableView.isScrollEnabled = true;
                    
                    let range = NSMakeRange(0, self.tableView.numberOfSections)
                    let sections = NSIndexSet(indexesIn: range)
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    self.tableView.reloadSections(sections as IndexSet, with: .automatic)
                    
                }
            }
            
        }
    }
    
    func getStartDate(event: CalendarEvents.Items) -> Date {
        
        if event.start!.dateTime != nil {
            return convertToDateTime(dateString: event.start!.dateTime!)
        } else {
            return convertToDate(dateString: event.start!.date!)
        }
        
    }
    
    func getEndDate(event: CalendarEvents.Items) -> Date {
        
        if event.end!.dateTime != nil {
            return convertToDateTime(dateString: event.end!.dateTime!)
        } else {
            return convertToDate(dateString: event.end!.date!)
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
        center.delegate = self
        let options: UNAuthorizationOptions = [.sound, .alert]
        
        var notifGranted = false
        
        DispatchQueue.main.async {
            //Prompt for notification access
            center.requestAuthorization(options: options) { (granted, error) in
                notifGranted = granted
                if error != nil { print (error!) }
                
                DispatchQueue.main.async {
                    if !notifGranted {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        let alert = UIAlertController(title:"Turn on Notifications", message:"To get event notifications. Please allow notifications in Settings.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title:"Ok", style: .default, handler:nil))
                        self.present(alert, animated:true);
                    }
                }
                
                //Check if notifications enabled
                center.getNotificationSettings { [self] settings in
                    guard settings.authorizationStatus == .authorized else { return }
                    notifGranted = (settings.alertSetting == .enabled)
                    
                    DispatchQueue.main.async {
                        // Continue bell handling
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
                            UINotificationFeedbackGenerator().notificationOccurred(.error)
                            let alert = UIAlertController(title:"Turn on Notifications", message:"To get event notifications. Please allow notifications in Settings.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title:"Ok", style: .default, handler:nil))
                            present(alert, animated:true);
                        }
                    }
                    
                }
                
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let noLocation = (tableEvents[indexPath.row].location?.count == nil)
        let noDescription = (tableEvents[indexPath.row].description?.count == nil)
        
        if noLocation && noDescription { return 70 }
        if noDescription { return 82 } // Has location, no description
        if noLocation { return 110 } // Has description, no location
        
        return 126 // Has both location and description
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        if tableEvents.count == 0 && notInitialLoad {
            
            if SearchOrgsViewController.selectedCalendars.count == 0 {
                tableView.setEmptyView(title: "No organizations subscribed.", message: "Tap the '+' icon to add organizations")
            } else {
                tableView.setEmptyView(title: "No upcoming events.", message: "Tap the '+' icon to add more organizations")
            }
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
        if event.start!.dateTime != nil {
            
            let startDateTime = convertToDateTime(dateString: event.start!.dateTime!)
            let endDateTime = convertToDateTime(dateString: event.end!.dateTime!)
            
            let startTime = startDateTime.toString(dateFormat: "h:mm a")
            let endTime = endDateTime.toString(dateFormat: "h:mm a")
            
            cell.timeLabel.text = startTime + " - " + endTime
            cell.dateLabel.text = startDateTime.toString(dateFormat: "E, MMM d, yyyy")
            
        } else {
            cell.timeLabel.text = "All Day"
            
            let startDate = convertToDate(dateString: event.start!.date!)
            cell.dateLabel.text = startDate.toString(dateFormat: "E, MMM d, yyyy")
        }
        
        //Description
        cell.descriptionLabel.text = event.description
        
        //Location and Organization
        let boldAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Bold", size: 12.0)!]
        let regularAttribute = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-Light", size: 12.0)!]
        
        var orgString = event.organization ?? ""
        if event.location != nil {
            orgString = "\n" + (event.organization ?? "")
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
        
        // Notifications IDs of events with a notification.
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
    
    var strLabel = UILabel()
    var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var activityIndicator = UIActivityIndicatorView()
    
    func showActivityIndicator(_ title: String) {
        DispatchQueue.main.async { [self] in
            view.isUserInteractionEnabled = false
            strLabel.removeFromSuperview()
            activityIndicator.removeFromSuperview()
            effectView.removeFromSuperview()
            
            strLabel = UILabel()
            strLabel.text = title
            strLabel.font = .systemFont(ofSize: 14, weight: .medium)
            strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
            strLabel.frame = CGRect(x: 50, y: 0, width: strLabel.intrinsicContentSize.width, height: 46)
            
            if traitCollection.userInterfaceStyle == .light {
                effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
                strLabel.textColor = UIColor(white: 0.1, alpha: 0.7)
            }
            
            effectView.frame = CGRect(x: view.frame.midX - (strLabel.frame.width + 66)/2, y: view.frame.midY - strLabel.frame.height/2 , width: strLabel.intrinsicContentSize.width + 66, height: 46)
            effectView.layer.cornerRadius = 15
            effectView.layer.masksToBounds = true
            
            activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            activityIndicator.startAnimating()

            effectView.contentView.addSubview(activityIndicator)
            effectView.contentView.addSubview(strLabel)
            
            effectView.alpha = 0
            UIView.animate(withDuration: 0.2) {
                effectView.alpha = 1
                view.addSubview(effectView)
            }
            
        }
    }
    
    // Remove activity indicator from screen and re-enable interaction
    func removeActivityIndicator() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                self.effectView.alpha = 0.0
            }, completion: { (_) in
                self.effectView.removeFromSuperview()
                self.view.isUserInteractionEnabled = true
            })
        }
    }
    
}
