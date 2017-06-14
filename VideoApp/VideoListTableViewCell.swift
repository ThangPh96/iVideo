//
//  VideoListTableViewCell.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class VideoListTableViewCell: UITableViewCell {

    @IBOutlet weak var numberBtnWidthLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberBtn: UIButton!
    @IBOutlet weak var thumbImgView: UIImageView!
    @IBOutlet weak var playingBtn: UIButton!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var authorLbl: UILabel!
    @IBOutlet weak var viewCountLbl: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var downLoadButton: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var viewBtn: UIButton!
    @IBOutlet weak var likeCountBtn: UIButton!
    @IBOutlet weak var downloadBtnWidthLayoutConstraint: NSLayoutConstraint!
    
    var extraButtonTappedHandler: ((VideoListTableViewCell) -> Void)?
    var video: Video!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        menuButton.layer.cornerRadius = menuButton.frame.width/2
        downLoadButton.layer.cornerRadius = downLoadButton.frame.width/2
        
        // Custom Buttom
        let image = UIImage(named: "Menu2Filled")
        let setImage = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        menuButton.setImage(setImage, for: .normal)
        menuButton.tintColor = UIColor.darkGray
        menuButton.backgroundColor = UIColor.lightGray
        
        let image2 = UIImage(named: "Download")
        let setImage2 = image2?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        downLoadButton.setImage(setImage2, for: .normal)
        downLoadButton.tintColor = UIColor.white
        downLoadButton.layer.borderColor = UIColor.black.cgColor
        downLoadButton.layer.borderWidth = 1
        downLoadButton.backgroundColor = UIColor.red
        
        let image3 = UIImage(named: "InvisibleFilled")
        let setImage3 = image3?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        viewBtn.setImage(setImage3, for: .normal)
        viewBtn.tintColor = UIColor.red

        let image4 = UIImage(named: "LikeItFilled")
        let setImage4 = image4?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        likeCountBtn.setImage(setImage4, for: .normal)
        likeCountBtn.tintColor = UIColor.red
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        extraButtonTappedHandler?(self)
    }
    
    @IBAction func downloadBtnTapped(_ sender: Any) {
        VideoApp.downloadBtnTapped(video: self.video)
        
    }
    
}
