//
//  ResourcesViewController.swift
//  Purdue-CS-App
//
//  Created by Kedar Abhyankar on 4/9/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit
import SafariServices

class ResourcesViewController: UITableViewController, SFSafariViewControllerDelegate {
    
    let labels = ["Lawson Hours & Key Fob", "Lawson Resources","LWSN Map", "HAAS Map", "CS News", "Concern Form", "Feedback", "About Us"];
    
    let images = [UIImage(systemName: "antenna.radiowaves.left.and.right"), UIImage(systemName:"globe"), UIImage(systemName:"map"), UIImage(systemName:"map"),
                  UIImage(systemName:"book"), UIImage(systemName:"paperplane"), UIImage(systemName:"mic"),
                  UIImage(systemName:"person.3")];
    
    let hyperlinks = ["https://www.cs.purdue.edu/resources/docs/building_hours.pdf",
                      "https://www.cs.purdue.edu/resources/index.html",
                      "https://www.cs.purdue.edu/resources/lawson.html",
                      "https://www.cs.purdue.edu/resources/haas.html",
                      "https://www.cs.purdue.edu/news/index.html",
                      "https://my.cs.purdue.edu/undergraduate/concern",
                      "https://forms.gle/pbhq2KqMD1Q1T4Pw5"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return labels.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell", for: indexPath) as! ResourceCell
        cell.cellText.text = labels[indexPath.row]
        cell.imageIcon.image = images[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url: URL?
        let config = SFSafariViewController.Configuration()
        var viewController: SFSafariViewController?;
        
        if(indexPath.row == 7) {
            tableView.deselectRow(at:indexPath, animated:true)
            let alert = UIAlertController(title:"About Us", message:"Brought to you by Pallav Agarwal, Viraat Das and Kedar Abhyankar.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Ok", style: .default, handler:nil))
            present(alert, animated:true);
        } else {
            tableView.deselectRow(at:indexPath, animated:true)
            url = URL(string: hyperlinks[indexPath.row])
            viewController = SFSafariViewController(url: url!, configuration: config)
            viewController?.delegate = self
            present(viewController!, animated:true)
        }
        
    }
}
