//
//  TumblrCell.swift
//  TumblrCodePath
//
//  Created by Micah Peoples on 2/2/17.
//  Copyright © 2017 micah. All rights reserved.
//

import UIKit

class TumblrCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
