//
//  searchHistoriesTableViewCell.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/8/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class SearchHistoriesTableViewCell: UITableViewCell {

    @IBOutlet weak var searchHistoryLabel: UILabel!
    @IBOutlet weak var pushTextBtn: UIButton!
    var startSearch = false
    
    var extraButtonTappedHandler: ((SearchHistoriesTableViewCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func pushTextBtnTapped(_ sender: Any) {
        extraButtonTappedHandler?(self)
    }
    
}
