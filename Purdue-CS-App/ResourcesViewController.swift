//
//  ResourcesViewController.swift
//  Purdue-CS-App
//
//  Created by Kedar Abhyankar on 4/9/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit
import SafariServices

//Add Lab Availabilities
class ResourcesViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    let labels = ["View Lab Availabilities", "Lawson Hours & Key Fob", "Lawson Resources", "Lawson Map", "CS News", "CS Concern Form", "Undergraduate Student Board", "Feedback", "CS Deparment Socials", "About"];
    
    let images = [UIImage(systemName: "desktopcomputer"), UIImage(systemName: "antenna.radiowaves.left.and.right"), UIImage(systemName:"globe"), UIImage(systemName:"map"), UIImage(systemName:"book"), UIImage(systemName:"paperplane"), UIImage(systemName: "person.3"), UIImage(systemName:"mic"), UIImage(systemName: "square.and.arrow.up"), UIImage(systemName:"info.circle")];
    
    let hyperlinks = ["",
                      "https://www.cs.purdue.edu/resources/docs/building_hours.pdf",
                      "https://www.cs.purdue.edu/resources/index.html",
                      "https://www.cs.purdue.edu/resources/lawson.html",
                      "https://www.cs.purdue.edu/news/index.html",
                      "https://my.cs.purdue.edu/undergraduate/concern",
                      "https://bit.ly/USBCS",
                      "https://forms.gle/8tjaHyqiZdtQzYYB9"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 100;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell", for: indexPath) as! ResourceCell
        cell.cellText.text = labels[indexPath.row]
        cell.imageIcon.image = images[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at:indexPath, animated:true)
        
        if labels[indexPath.row] == "About" {
            tableView.deselectRow(at:indexPath, animated:true)
            let alert = UIAlertController(title:"About", message:"This is an app to allow students in Computer Science at Purdue University to read the Oppurtunity Update, stay up to date on events by CS Organizations, and get CS Resources. Notifications are sent 30 minutes before an event. Brought to you by Pallav Agarwal, Viraat Das and Kedar Abhyankar.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Ok", style: .default, handler:nil))
            present(alert, animated:true);
        } else if labels[indexPath.row] == "View Lab Availabilities" {
            
            performSegue(withIdentifier: "ShowLabs", sender: nil)
            
        } else if labels[indexPath.row] == "CS Deparment Socials" {
            
            performSegue(withIdentifier: "ShowSocials", sender: nil)
            
        } else {
            let url = URL(string: hyperlinks[indexPath.row])
            var viewController: SFSafariViewController?
            viewController = SFSafariViewController(url: url!)
            viewController?.delegate = self
            present(viewController!, animated:true)
        }
        
    }
}
