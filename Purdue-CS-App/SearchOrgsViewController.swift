//
//  SearchOrgsViewController.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 4/9/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit
import Firebase

class SearchOrgsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference?
    
    // LEAVE COMMENT FOR TESTING PURPOSE
    //  var calendar_ids: [String: String] = ["Purdue CS": "sodicmhprbq87022es0t74blk8@group.calendar.google.com", "Purdue Hackers": "purduehackers@gmail.com", "CS Events": "256h9v68bnbnponkp0upmfq07s@group.calendar.google.com", "CS Seminars": "t3gdpe5uft0cbfsq9bipl7ofq0@group.calendar.google.com"]
    var calendar_ids: [String: String] = [:]
    
    var calendars = [String]()
    static var selectedCalendars = UserDefaults.standard.object(forKey: "OrgsArray") as? [String : String] ?? [:]
    
    typealias FinishedFillingCalendar = () -> ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.tableView.rowHeight = 70
        
        fillCalendarIds()
    }
    
    func fillCalendarIds() {
        self.ref = Database.database().reference() // Init database reference
        let myRef = self.ref?.child("calendar_ids")
        
        myRef?.observeSingleEvent(of: .value, with: { (snapshot) in
            
            //Handle data not found
            if !snapshot.exists() {
                return
            }
            
            //Data found
            self.calendar_ids = snapshot.value as! [String: String]
            
            self.tableView.reloadData()
            self.sortCalendarEntries()
        })
    }
    
    
    func sortCalendarEntries() {
        self.calendars = Array(calendar_ids.keys)
        self.calendars.sort()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrgCell") as! OrgCell
        
        cell.textLabel?.text = calendars[indexPath.row]
        
        let selected = UITableViewCell.AccessoryType.checkmark
        let unselected = UITableViewCell.AccessoryType.none
        
        if SearchOrgsViewController.selectedCalendars[calendars[indexPath.row]] != nil {
            cell.accessoryType = selected
        } else {
            cell.accessoryType = unselected
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = UITableViewCell.AccessoryType.checkmark
        let unselected = UITableViewCell.AccessoryType.none
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == selected {
            tableView.cellForRow(at: indexPath)?.accessoryType = unselected
            SearchOrgsViewController.selectedCalendars.removeValue(forKey: calendars[indexPath.row])
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = selected
            SearchOrgsViewController.selectedCalendars[calendars[indexPath.row]] = calendar_ids[calendars[indexPath.row]]
        }
        
        UserDefaults.standard.set(SearchOrgsViewController.selectedCalendars, forKey: "OrgsArray")
        
    }
    
}
