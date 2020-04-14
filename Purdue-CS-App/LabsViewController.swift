//
//  LabsViewController.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 4/13/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit
import SafariServices

class LabsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SFSafariViewControllerDelegate {
    
    let labs =
    [
    0: ["HAAS G40", "https://www.cs.purdue.edu/cams-delayed/HAASG040.jpg", "https://www.cs.purdue.edu/resources/facilities/haasg40.html"],
    1: ["HAAS G56", "https://www.cs.purdue.edu/cams-delayed/HAASG056.jpg", "https://www.cs.purdue.edu/resources/facilities/haasg56.html"],
    2: ["HAAS 257", "https://www.cs.purdue.edu/cams-delayed/HAAS257.jpg", "https://www.cs.purdue.edu/resources/facilities/haas257.html"],
    3: ["LWSN B131", "https://www.cs.purdue.edu/cams-delayed/LWSNB131.jpg", "https://www.cs.purdue.edu/resources/facilities/lwsnb131.html"],
    4: ["LWSN B146", "https://www.cs.purdue.edu/cams-delayed/LWSNB146.jpg", "https://www.cs.purdue.edu/resources/facilities/lwsnb146.html"],
    5: ["LWSN B148", "https://www.cs.purdue.edu/cams-delayed/LWSNB148.jpg", "https://www.cs.purdue.edu/resources/facilities/lwsnb148.html"],
    6: ["LWSN B158", "https://www.cs.purdue.edu/cams-delayed/LWSNB158.jpg", "https://www.cs.purdue.edu/resources/facilities/lwsnb158.html"],
    7: ["LWSN B160", "https://www.cs.purdue.edu/cams-delayed/LWSNB160.jpg", "https://www.cs.purdue.edu/resources/facilities/lwsnb160.html"]
    ]

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        labs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabCell", for: indexPath)
        cell.textLabel?.text = labs[indexPath.row]![0]
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let url = URL(string: labs[indexPath.row]![2])
        var viewController: SFSafariViewController?
        viewController = SFSafariViewController(url: url!)
        viewController?.delegate = self
        present(viewController!, animated:true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated:true)
        let url = URL(string: labs[indexPath.row]![1])
        var viewController: SFSafariViewController?
        viewController = SFSafariViewController(url: url!)
        viewController?.modalPresentationStyle = .automatic
        viewController?.delegate = self
        present(viewController!, animated:true)
    }

}
