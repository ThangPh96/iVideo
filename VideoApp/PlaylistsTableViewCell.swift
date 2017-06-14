//
//  PlaylistsTableViewCell.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/7/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class PlaylistsTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbImgView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
