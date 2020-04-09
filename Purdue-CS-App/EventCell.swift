//
//  EventCell.swift
//  Purdue-CS-App
//
//  Created by Pallav Agarwal on 4/7/20.
//  Copyright © 2020 Pallav Agarwal. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var orgLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UITextView!
    
    @IBOutlet weak var bellButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
