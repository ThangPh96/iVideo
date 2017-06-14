//
//  RootViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class RootViewController: VideoAppViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if VideoApp.isConnectedToNetwork() == false {
            let alert = UIAlertView()
            alert.title = NSLocalizedString("Connection Failed", comment: "")
            alert.message = NSLocalizedString("Please Check Your Internet Connection", comment: "")
            alert.addButton(withTitle: "OK")
            alert.show()
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
            self.addChildViewController(vC)
            vC.view.frame = self.view.bounds
            self.view.addSubview(vC.view)
            
            // call before adding child view controller's view as subview
            vC.didMove(toParentViewController: self)

        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as! MainTabBarController
            sharedAPI.getVideoCategories { (videoCategories) in
                // Save categories trending video
                VideoApp.categoriesTrendingVideo = videoCategories
                self.addChildViewController(vC)
                vC.view.frame = self.view.bounds
                self.view.addSubview(vC.view)
                
                // call before adding child view controller's view as subview
                vC.didMove(toParentViewController: self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Set portrait for all VC, only Now Playing tab is all (both portait and lanscape)
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if VideoApp.tabbarController.selectedIndex == 2 {
            return UIInterfaceOrientationMask.all
        }
        return UIInterfaceOrientationMask.portrait
    }
    
}
