//
//  SocialsViewController.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 8/12/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit

class SocialsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SocialCell", for: indexPath) as! ResourceCell
        
        switch indexPath.row {
        case 0:
            cell.imageIcon.image = UIImage(named: "facebook")
        case 1:
            cell.imageIcon.image = UIImage(named: "instagram")
        case 2:
            cell.imageIcon.image = UIImage(named: "twitter")
        case 3:
            cell.imageIcon.image = UIImage(named: "linkedin")
        default:
            cell.imageIcon.image = UIImage(named: "instagram")
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated:true)
        
        switch indexPath.row {
        case 0:
            UIApplication.shared.open(URL(string: "https://www.facebook.com/PurdueCS")!)
        case 1:
            UIApplication.shared.open(URL(string: "https://www.instagram.com/purduecs/")!)
        case 2:
            UIApplication.shared.open(URL(string: "https://twitter.com/PurdueCS")!)
        case 3:
            UIApplication.shared.open(URL(string: "https://www.linkedin.com/company/purduecs/")!)
        default:
            UIApplication.shared.open(URL(string: "https://www.instagram.com/purduecs/")!)
        }
        
    }
    
}
