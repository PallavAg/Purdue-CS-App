//
//  AnnouncementsViewController.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 3/30/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//
import UIKit
import SafariServices
import SwiftSoup

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
        
        let opportunity_url = URL(string: "https://www.cs.purdue.edu/corporate/opportunity_update.html")
        let html = try! String(contentsOf: opportunity_url!, encoding: .utf8)
           
        // arrays to be used within tableViewData
        
        var opport_sections = [String: [String: String]]()
    
           do {
               let doc: Document = try SwiftSoup.parseBodyFragment(html)
               
               // my body
               let body = doc.body()
               
               // a with href
               let links: Elements? = try body?.select("a[href]") // a with href
               
               
               // Need to parse links with the following prefix
               // careers/
               // employment/
               // announcements/
               // events/
               // internships/
               // scholarships/
               
            let base_url: String = "https://www.cs.purdue.edu/corporate/"
               for link in links! {
                   let linkHref: String = try! link.attr("href")
                   let prefix = linkHref.components(separatedBy: "/")[0]
                   let linkText: String = try! link.text()
                   switch prefix {
                   case "careers":
                    var dict = opport_sections["Careers"]
                    dict?[linkText] = base_url + linkHref
                    opport_sections.updateValue(dict ?? [:], forKey: "Careers")
        
                   case "employment":
                   var dict = opport_sections["Employment"]
                   dict?[linkText] = base_url + linkHref
                    opport_sections.updateValue(dict ?? [:], forKey: "Employment")
                   case "announcements":
                    var dict = opport_sections["Announcements"]
                    dict?[linkText] = base_url + linkHref
                     opport_sections.updateValue(dict ?? [:], forKey: "Announcements")
                    
                   case "events":
                   var dict = opport_sections["Events"]
                    dict?[linkText] = base_url + linkHref
                     opport_sections.updateValue(dict ?? [:], forKey: "Events")
                   case "internships":
                   var dict = opport_sections["Internships"]
                    dict?[linkText] = base_url + linkHref
                     opport_sections.updateValue(dict ?? [:], forKey: "Internships")
                   case "scholarships":
                    var dict = opport_sections["Scholarships"]
                    dict?[linkText] = base_url + linkHref
                     opport_sections.updateValue(dict ?? [:], forKey: "Scholarships")
                   default:
                       print("")
                   }
               }
        
           } catch Exception.Error(let type, let message) {
               print("Type: \(type) \n\nMessage: \(message)")
           } catch {
               print("error")
           }

        
        //MARK: Populate the data here:
        //Each index is the section index with sectionData containing the sub elements gotten with
        
        
        for (title, dict) in opport_sections {
            let titles = Array(dict.keys)
            let links = Array(dict.values)
            let entry = cellData(opened: false, title: title, sectionData: titles, link: links)
            tableViewData.append(entry)
        }
    
        
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
                
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true
                
                let vc = SFSafariViewController(url: url, configuration: config)
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
