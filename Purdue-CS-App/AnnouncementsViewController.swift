//
//  AnnouncementsViewController.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 3/30/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit

struct cellData {
    var opened = Bool()
    var title = String()
    var sectionData = [String]()
}

class AnnouncementsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewData = [cellData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        //Each index is the section index with sectionData containing the sub elements gotten with 
        tableViewData = [cellData(opened: false, title: "Career", sectionData: ["Update 1", "Update 2", "Update 3"]),
                         cellData(opened: false, title: "Employment", sectionData: ["Update 1", "Update 2", "Update 3"]),
                         cellData(opened: false, title: "Announcement", sectionData: ["Update 1", "Update 2", "Update 3"])]
        
    }
    
    //Number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            
            //Return the number of items in the section of 'section'
            return tableViewData[section].sectionData.count+1
        } else {
            //Return 1 for the header if the section is closed
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataIndex = indexPath.row - 1
        if indexPath.row == 0 {
            //Cell is section header
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {return UITableViewCell()}
            
            //Title is the section index title
            cell.textLabel?.text = tableViewData[indexPath.section].title
            
            return cell
        } else {
            //Use different cell identifier here for subsections. Cell is subsection.
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {return UITableViewCell()}
            
            //Text is the section's sectionData at the row
            cell.textLabel?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            
            return cell
        }
    }
    
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
            //Subcell tapped. Open webview here.
        }
        
    }
    
}
