//
//  AnnouncementsViewController.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 3/30/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit
import SafariServices

struct cellData {
    var opened = Bool()
    var title = String() //Title of Section
    var sectionData = [String]() //Titles of Updates in subcells
    var link = [String]() //Link to update
}

class AnnouncementsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewData = [cellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //MARK: Populate the data here:
        //Each index is the section index with sectionData containing the sub elements gotten with 
        tableViewData = [cellData(opened: false, title: "Career", sectionData: ["Update 1", "Update 2", "Update 3"], link: ["https://apple.com", "https://google.com", "https://apple.com"]),
                         cellData(opened: false, title: "Employment", sectionData: ["Update 4", "Update 5", "Update 6"], link: ["https://apple.com", "https://apple.com", "https://apple.com"]),
                         cellData(opened: false, title: "Announcement", sectionData: ["Update 7", "Update 8", "Update 9"], link: ["https://apple.com", "https://apple.com", "https://apple.com"]), cellData(opened: false, title: "Announcement", sectionData: ["Update 7", "Update 8", "Update 9"], link: ["https://apple.com", "https://apple.com", "https://apple.com"])]
        
    }
    
    //Number of sections (Oppurtunity Update Categories)
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    //Setup each section with either just title count (1) or subcells count too
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            
            //Return the number of items in the section of 'section'
            return tableViewData[section].sectionData.count+1
        } else {
            //Return 1 for the header if the section is closed
            return 1
        }
    }
    
    //Setup each table row's text and properties
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataIndex = indexPath.row - 1
        if indexPath.row == 0 {
            //Cell is section header
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {return UITableViewCell()}
            
            //Title is the section index title
            cell.textLabel?.text = tableViewData[indexPath.section].title
            
            //Setup Change in collapsible icon
            if tableViewData[indexPath.section].opened == true {
                cell.detailTextLabel?.text = "-"
            } else {
                cell.detailTextLabel?.text = "+"
            }
            
            return cell
        } else {
            //Using different cell identifier here for subsections. Cell is subsection.
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubCell") else {return UITableViewCell()}
            
            //Text is the section's sectionData at the row
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            
            return cell
        }
    }
    
    //Process expanding and collapsing cells on tap
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            if tableViewData[indexPath.section].opened == true {
                //Collapse
                tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                //Expand
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        } else {
            //Subcell tapped. Web View is opened here.
            let selectedItemLink = tableViewData[indexPath.section].link[indexPath.row - 1]
            
            if let url = URL(string: selectedItemLink) {
                tableView.deselectRow(at: indexPath, animated: true)
                let vc = SFSafariViewController(url: url)
                vc.delegate = self
                present(vc, animated: true)
            }
        }
        
    }
    
    //For dismissing safari view
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
    
}
