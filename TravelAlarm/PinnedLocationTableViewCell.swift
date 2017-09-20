//
//  PinnedLocationTableViewCell.swift
//  TravelAlarm
//
//  Created by Abdulaziz Ismail on 20/09/2017.
//  Copyright © 2017 Abdulaziz Ismail. All rights reserved.
//

import UIKit

class PinnedLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var pinLocation: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pinImage.image = UIImage(named: "MapPin")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
