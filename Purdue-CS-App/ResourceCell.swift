//
//  ResourceCell.swift
//  Purdue-CS-App
//
//  Created by Kedar Abhyankar on 4/11/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit

class ResourceCell: UITableViewCell {

    @IBOutlet var imageIcon: UIImageView!
    @IBOutlet weak var cellText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
