//
//  WebDetailViewController.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 3/31/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit
import WebKit

class WebDetailViewController: UIViewController {

    var link = String()
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = URL(string: link)
        let request = URLRequest(url: url!)
        webView.load(request)

    }
    
}
