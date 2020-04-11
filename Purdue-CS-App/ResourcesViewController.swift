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
    
    let labels = ["Lawson Hours + Key Fob", "Resources","LWSN Map", "HAAS Map", "News", "Concern Form", "Feedback", "About Us"];
    let images = [UIImage(named:"antenna"), UIImage(named:"pencil"), UIImage(named:"map"), UIImage(named:"map"),
                  UIImage(named:"book"), UIImage(named:"paperplane"), UIImage(named:"mic"),
                  UIImage(named:"person.3")];
    let hyperlinks = ["https://www.cs.purdue.edu/resources/docs/building_hours.pdf",
                       "https://www.cs.purdue.edu/resources/index.html",
                       "https://www.cs.purdue.edu/resources/lawson.html",
                       "https://www.cs.purdue.edu/resources/haas.html",
                       "https://www.cs.purdue.edu/news/index.html",
                       "https://www.cs.purdue.edu/undergraduate/concerns.html",
                       "https://forms.gle/pbhq2KqMD1Q1T4Pw5"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResourceCell", for: indexPath) as! ResourceCell
        cell.cellText.text = labels[indexPath.row]
        cell.imageIcon.image = images[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url : URL?
        let config = SFSafariViewController.Configuration()
        var viewController : SFSafariViewController?;
        
        print("Index Path is \(indexPath.row)");
        
        if(indexPath.row == 0){
            tableView.deselectRow(at:indexPath, animated:true)
            url = URL(string: hyperlinks[indexPath.row])
            viewController = SFSafariViewController(url: url!, configuration: config)
            viewController?.delegate = self
            present(viewController!, animated:true)
        } else if(indexPath.row == 1){
            tableView.deselectRow(at:indexPath, animated:true)
            url = URL(string: hyperlinks[indexPath.row])
            viewController = SFSafariViewController(url: url!, configuration: config)
            viewController?.delegate = self
            present(viewController!, animated:true)
        } else if(indexPath.row == 2){
            tableView.deselectRow(at:indexPath, animated:true)
            url = URL(string: hyperlinks[indexPath.row])
            viewController = SFSafariViewController(url: url!, configuration: config)
            viewController?.delegate = self
            present(viewController!, animated:true)
        } else if(indexPath.row == 3){
            tableView.deselectRow(at:indexPath, animated:true)
            url = URL(string: hyperlinks[indexPath.row])
            viewController = SFSafariViewController(url: url!, configuration: config)
            viewController?.delegate = self
            present(viewController!, animated:true)
        } else if(indexPath.row == 4){
            tableView.deselectRow(at:indexPath, animated:true)
            url = URL(string: hyperlinks[indexPath.row])
            viewController = SFSafariViewController(url: url!, configuration: config)
            viewController?.delegate = self
            present(viewController!, animated:true)
        } else if(indexPath.row == 5){
            tableView.deselectRow(at:indexPath, animated:true)
            url = URL(string: hyperlinks[indexPath.row])
            viewController = SFSafariViewController(url: url!, configuration: config)
            viewController?.delegate = self
            present(viewController!, animated:true)
        } else if(indexPath.row == 6){
            tableView.deselectRow(at:indexPath, animated:true)
            url = URL(string: hyperlinks[indexPath.row])
            viewController = SFSafariViewController(url: url!, configuration: config)
            viewController?.delegate = self
            present(viewController!, animated:true)
        } else if(indexPath.row == 7){
            tableView.deselectRow(at:indexPath, animated:true)
//            url = URL(string: hyperlinks[indexPath.row])
//            viewController = SFSafariViewController(url: url!, configuration: config)
//            viewController?.delegate = self
//            present(viewController!, animated:true)
            let alert = UIAlertController(title:"About Us", message:"This still has to be programmed!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Ok", style: .default, handler:nil))
            present(alert, animated:true);
        }
    }
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
