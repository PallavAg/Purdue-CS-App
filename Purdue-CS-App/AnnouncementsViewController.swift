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

//MARK: - Make sure it doesn't crash when there's no Wifi
class AnnouncementsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var tableViewData = [cellData]()
    
    let opportunity_url = URL(string: "https://www.cs.purdue.edu/corporate/opportunity_update.html")
    let base_url: String = "https://www.cs.purdue.edu/corporate/"
    let sectionTitles = ["Careers", "Employment", "Announcements", "Events", "Internships", "Scholarships"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let oldData = tableViewData
        loadData()
        let newTableData = tableViewData
        
        tableViewData = oldData
        
        if oldData.count == 0 {
            tableViewData = newTableData
            self.tableView.reloadData()
        } else {
            for (newData, oldData) in zip(newTableData, oldData) {
                if newData.sectionData != oldData.sectionData {
                    tableViewData = newTableData
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func loadData() {
        
        tableViewData.removeAll(keepingCapacity: false)
        
        do {
            let html = try String(contentsOf: opportunity_url!, encoding: .utf8)
            
            // arrays to be used within tableViewData
            var opport_sections = [String: [String: String]]() //[Section Title: [Subtitle : Link]]
            
            do {
                let doc: Document = try SwiftSoup.parseBodyFragment(html)
                
                // my body
                let body = doc.body()
                
                // a with href
                let links: Elements? = try body?.select("a[href]") // a with href
                
                for title in sectionTitles {
                    opport_sections.updateValue([:], forKey: title)
                }
                
                for link in links! {
                    let linkHref: String = try! link.attr("href")
                    let prefix = linkHref.components(separatedBy: "/")[0]
                    let linkText: String = try! link.text()
                    
                    for title in sectionTitles {
                        if prefix == title.lowercased() {
                            var dict = opport_sections[title]
                            dict?[linkText] = base_url + linkHref
                            opport_sections.updateValue(dict ?? [:], forKey: title)
                            break;
                        }
                    }
                    
                }
                
            } catch Exception.Error(let type, let message) {
                print("Type: \(type) \n\nMessage: \(message)")
            } catch {
                print("error")
            }
            
            //Populate tableViewData
            for (title, dict) in opport_sections {
                var titles = Array(dict.keys)
                var links = Array(dict.values)
                
                //Fix blank cells and remove index.html links
                for (index, _) in links.enumerated().reversed() {
                    links[index] = links[index].replacingOccurrences(of: " ", with: "%20")
                    if links[index].contains("index.html") {
                        links.remove(at: index)
                        titles.remove(at: index)
                    }
                    
                }
                
                let entry = cellData(opened: false, title: title, sectionData: titles, link: links)
                tableViewData.append(entry)
            }
            
            //Sort by Title
            tableViewData.sort {
                $0.title < $1.title
            }
            
            //Sort Subtitle and URL within each Title
            for index in 0..<tableViewData.count {
                
                let array1 = tableViewData[index].sectionData
                let array2 = tableViewData[index].link
                
                // use zip to combine the two arrays and sort that based on the first
                let combined = zip(array1, array2).sorted {$0.0 < $1.0}
                
                // use map to extract the individual arrays
                let sorted1 = combined.map {$0.0}
                let sorted2 = combined.map {$0.1}
                
                tableViewData[index].sectionData = sorted1
                tableViewData[index].link = sorted2
                
            }
        } catch {
            let alert = UIAlertController(title:"Network Error", message:"Unable to load data. Please check your internet connection.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Ok", style: .default, handler:nil))
            present(alert, animated:true);
        }
    }
    
    //Number of sections (Oppurtunity Update Categories)
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    //Setup each section with either just title count (1) or subcells count too
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            
            // Show 'no items' if a certain section is empty
            if tableViewData[section].sectionData.count == 0 {
                return tableViewData[section].sectionData.count + 2
            }
            
            //Return the number of items in the section of 'section'
            return tableViewData[section].sectionData.count + 1
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
            cell.backgroundColor = UIColor(named: "TableColor")
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
            
            if tableViewData[indexPath.section].sectionData.count == 0 {
                cell.textLabel?.text = "No Items"
                cell.accessoryType = .none
                cell.isUserInteractionEnabled = false
            } else {
                //Text is the section's sectionData at the row
                cell.textLabel?.text = tableViewData[indexPath.section].sectionData[dataIndex]
            }
            
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
