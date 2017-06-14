//
//  HistoryViewController.swift
//  VideoApp
//
//  Created by Phan Hữu Thắng on 6/6/17.
//  Copyright © 2017 ThangPh. All rights reserved.
//

import UIKit

class HistoryViewController: VideoAppViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var videoListView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let sortRightButtonItem = UIBarButtonItem(image:  UIImage(named: "Sort"), style: .plain, target: self, action: #selector(self.showEdit))
        sortRightButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = sortRightButtonItem
        self.title = "History"
        //
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vC = storyboard.instantiateViewController(withIdentifier: "PersonalViewController") as! PersonalViewController
        vC.isFavoriteVC = false
        self.addChildViewController(vC)
        vC.view.frame = self.videoListView.bounds
        self.videoListView.addSubview(vC.view)
        
        // call before adding child view controller's view as subview
        vC.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // Func
    func showEdit() {
        VideoApp.sortOfflineVideo()
    }
}
