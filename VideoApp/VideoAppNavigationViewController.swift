//
//  VideoAppNavigationViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class VideoAppNavigationViewController: UINavigationController {

       override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationBar.barTintColor = VideoApp.Settings.themeColor
        self.navigationBar.tintColor = UIColor.white
//        self.navigationBar.isTranslucent = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    }
