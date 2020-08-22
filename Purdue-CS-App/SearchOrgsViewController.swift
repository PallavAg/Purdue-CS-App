//
//  SearchOrgsViewController.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 4/9/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchOrgsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference?
    
    var calendar_ids = [String: String]() // Calendars and corresponding API IDs
    var calendarNames = [String]() // Calendar Titles
    
    // Global variable with all the subscribed calendars and API IDs
    static var selectedCalendars = UserDefaults.standard.object(forKey: "OrgsArray") as? [String: String] ?? [String: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        
        showActivityIndicator("Loading Organzations")
        
        self.tableView.rowHeight = 70
        
        // Fetch calendar list from Firebase in the background
        fillCalendarIds()
    }
    
    func fillCalendarIds() {
        self.ref = Database.database().reference() // Init database reference
        let myRef = self.ref?.child("calendar_ids")
        
        myRef?.observeSingleEvent(of: .value, with: { [self] (snapshot) in
            
            //Handle data not found
            if !snapshot.exists() {
                self.showActivityIndicator("Error. Please contact Support.")
                return
            }
            
            //Fetch data
            self.calendar_ids = snapshot.value as? [String: String] ?? [String: String]()
            
            self.calendarNames = Array(self.calendar_ids.keys)
            self.calendarNames.sort()
            
            // Remove any calendars that were previously selected that no longer exist
            for (name, ID) in SearchOrgsViewController.selectedCalendars {
                // If the name or ID no longer exists, it is no longer selected
                if self.calendar_ids[name] == nil || self.calendar_ids[name] != ID {
                    SearchOrgsViewController.selectedCalendars.removeValue(forKey: name)
                }
            }
            UserDefaults.standard.set(SearchOrgsViewController.selectedCalendars, forKey: "OrgsArray")
            
            let range = NSMakeRange(0, self.tableView.numberOfSections)
            let sections = NSIndexSet(indexesIn: range)
            DispatchQueue.main.async {
                self.tableView.reloadSections(sections as IndexSet, with: .automatic)
            }
            self.removeActivityIndicator()
            
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrgCell") as! OrgCell
        
        let selectedCalendarName = calendarNames[indexPath.row]
        
        cell.textLabel?.text = selectedCalendarName
        
        let selected = UITableViewCell.AccessoryType.checkmark
        let unselected = UITableViewCell.AccessoryType.none
        
        if SearchOrgsViewController.selectedCalendars[selectedCalendarName] != nil {
            cell.accessoryType = selected
        } else {
            cell.accessoryType = unselected
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = UITableViewCell.AccessoryType.checkmark
        let unselected = UITableViewCell.AccessoryType.none
        
        let selectedCalendarName = calendarNames[indexPath.row]
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == selected {
            tableView.cellForRow(at: indexPath)?.accessoryType = unselected
            SearchOrgsViewController.selectedCalendars.removeValue(forKey: selectedCalendarName)
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = selected
            SearchOrgsViewController.selectedCalendars[selectedCalendarName] = calendar_ids[selectedCalendarName]
        }
        
        UserDefaults.standard.set(SearchOrgsViewController.selectedCalendars, forKey: "OrgsArray")
        
    }
    
    var strLabel = UILabel()
    var effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var activityIndicator = UIActivityIndicatorView()
    
    func showActivityIndicator(_ title: String) {
        DispatchQueue.main.async { [self] in
            self.view.isUserInteractionEnabled = false
            self.strLabel.removeFromSuperview()
            self.activityIndicator.removeFromSuperview()
            self.effectView.removeFromSuperview()
            
            self.strLabel = UILabel()
            self.strLabel.text = title
            self.strLabel.font = .systemFont(ofSize: 14, weight: .medium)
            self.strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
            self.strLabel.frame = CGRect(x: 50, y: 0, width: self.strLabel.intrinsicContentSize.width, height: 46)
            
            if self.traitCollection.userInterfaceStyle == .light {
                self.effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
                self.strLabel.textColor = UIColor(white: 0.1, alpha: 0.7)
            }
            
            self.effectView.frame = CGRect(x: self.view.frame.midX - (self.strLabel.frame.width + 66)/2, y: self.view.frame.midY - self.strLabel.frame.height/2 , width: self.strLabel.intrinsicContentSize.width + 66, height: 46)
            self.effectView.layer.cornerRadius = 15
            self.effectView.layer.masksToBounds = true
            
            self.activityIndicator = UIActivityIndicatorView(style: .medium)
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
            self.activityIndicator.startAnimating()

            self.effectView.contentView.addSubview(self.activityIndicator)
            self.effectView.contentView.addSubview(self.strLabel)
            
            self.effectView.alpha = 0
            UIView.animate(withDuration: 0.2) {
                self.effectView.alpha = 1
                self.view.addSubview(self.effectView)
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

/* LEAVE COMMENT FOR TESTING PURPOSE
//  var calendar_ids: [String: String] = ["Purdue CS": "sodicmhprbq87022es0t74blk8@group.calendar.google.com", "Purdue Hackers": "purduehackers@gmail.com", "CS Events": "256h9v68bnbnponkp0upmfq07s@group.calendar.google.com", "CS Seminars": "t3gdpe5uft0cbfsq9bipl7ofq0@group.calendar.google.com"]*/
